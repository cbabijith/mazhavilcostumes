/**
 * Order Service
 *
 * Business logic layer for order entities.
 *
 * @module services/orderService
 */

import { RepositoryResult } from '@/repository';
import { 
  Order, 
  OrderWithRelations,
  OrderStatus,
  PaymentStatus,
  CreateOrderDTO,
  UpdateOrderDTO,
  OrderSearchParams,
  ReturnOrderDTO,
  ConditionRating,
  OrderSearchResult
} from '@/domain/types/order';
import { orderRepository, cleaningRepository } from '@/repository';
import { settingsService } from './settingsService';
import { damageAssessmentService } from './damageAssessmentService';
import { dashboardService } from './dashboardService';
import { CleaningPriority, CleaningStatus, DamageDecision } from '@/domain';

/** Buffer days for cleaning/prep — must match orderRepository.ts */
const BUFFER_DAYS = 1;

export class OrderService {
  private currentUserId: string | null = null;
  private currentBranchId: string | null = null;

  /**
   * Recalculate priority cleaning for ALL active orders of a product.
   *
   * Instead of tracking priority incrementally (fragile, causes edge-case bugs),
   * this method re-evaluates the complete picture from scratch every time.
   *
   * Algorithm:
   *  1. Get all active orders containing this product, sorted by end_date ASC
   *  2. For each consecutive pair (current, next): check if next.start_date
   *     falls within current.end_date + buffer
   *  3. If yes → current order needs URGENT cleaning (returns first, must be
   *     cleaned quickly for the next order)
   *  4. Update cleaning records and has_priority_cleaning flags accordingly
   *
   * Called from: createOrder, updateOrder (dates/items/cancel), deleteOrder
   */
  private async recalculateProductPriorityCleaning(
    productId: string,
    branchId: string,
  ): Promise<void> {
    // 1. Get all active orders for this product, sorted by end_date
    const activeResult = await orderRepository.findActiveOrdersForProduct(productId, branchId);
    if (!activeResult.success || !activeResult.data) return;

    const orders = activeResult.data;

    // 2. Get product total stock quantity and category buffer setting
    const productInfo = await orderRepository.getProductBufferInfo(productId);
    if (!productInfo.success || !productInfo.data) return;
    
    const { quantity: totalStock, has_buffer: categoryHasBuffer } = productInfo.data;

    if (totalStock === 0) return;

    // The cleaning buffer is 1 day unless disabled at category level
    const currentBufferDays = categoryHasBuffer ? BUFFER_DAYS : 0;
    const currentBufferMs = currentBufferDays * 24 * 60 * 60 * 1000;

    // 3. Determine which orders need priority cleaning using stock-aware logic.
    //    An order needs priority cleaning ONLY if the total units in use on
    //    its buffer boundary day (cleaning day) exceeds the available stock for
    //    the next order that starts on that day.
    //
    //    Example: 10 total, Order A (5 units, ends May 14, buffer May 15),
    //    Order B (1 unit, starts May 15). On May 15: 5 in cleaning + 1 needed
    //    = 6. Stock = 10. 10 - 5 = 5 free >= 1 needed → NO priority.
    //    But if Order A had 10 units → 10 - 10 = 0 free < 1 needed → URGENT/PRIORITY.
    const needsPriority = new Map<string, string>();

    for (let i = 0; i < orders.length; i++) {
      const current = orders[i];
      const currentEndDate = new Date(current.endDate);

      // Buffer boundary: current end + buffer days
      const bufferEnd = new Date(currentEndDate);
      bufferEnd.setDate(bufferEnd.getDate() + currentBufferDays);

      // Find ALL orders that start within this buffer boundary
      for (let j = 0; j < orders.length; j++) {
        if (i === j) continue;
        const next = orders[j];
        const nextStartDate = new Date(next.startDate);

        // Only check orders that start within the buffer boundary
        if (nextStartDate > bufferEnd) continue;
        // Only check orders that start AFTER the current one ends (not overlapping actual dates)
        if (nextStartDate <= currentEndDate) continue;

        // Calculate: on the buffer day, how many units are occupied by ALL other
        // active orders (excluding the 'next' order which is the one needing units)?
        // The current order's units are "in cleaning" on the buffer day.
        const bufferDayMs = bufferEnd.getTime();
        let totalBlockedOnBufferDay = 0;

        for (const otherOrder of orders) {
          if (otherOrder.orderId === next.orderId) continue; // Don't count the order that needs the units
          const otherStart = new Date(otherOrder.startDate).getTime();
          const otherEnd = new Date(otherOrder.endDate).getTime();
          const otherBufferEnd = otherEnd + currentBufferMs;

          // Is this order's rental or cleaning period active on the buffer day?
          const isRentalDay = otherStart <= bufferDayMs && otherEnd >= bufferDayMs;
          const isCleaningDay = !isRentalDay && otherEnd < bufferDayMs && otherBufferEnd >= bufferDayMs;

          if (isRentalDay || isCleaningDay) {
            totalBlockedOnBufferDay += otherOrder.quantity;
          }
        }

        // If available stock on buffer day is less than what the next order needs → priority!
        const availableOnBufferDay = totalStock - totalBlockedOnBufferDay;
        if (availableOnBufferDay < next.quantity) {
          needsPriority.set(current.orderId, next.orderId);
          break; // One conflict is enough to mark this order as priority
        }
      }
    }

    // 4. Update cleaning records and order flags for ALL active orders
    // Fetch all cleaning records for this product at once to avoid N database queries in the loop
    const cleaningRecordsRes = await cleaningRepository.findMany({ product_id: productId });
    const cleaningRecords = cleaningRecordsRes.success && cleaningRecordsRes.data ? cleaningRecordsRes.data : [];

    const priorityTrueIds: string[] = [];
    const priorityFalseIds: string[] = [];

    for (const order of orders) {
      const priorityForOrderId = needsPriority.get(order.orderId);
      const shouldBeUrgent = !!priorityForOrderId;
      let flagChanged = false;

      // Find cleaning record for this order+product in-memory
      const record = cleaningRecords.find(r => r.order_id === order.orderId);
      if (record) {
        // Skip if cleaning is already done
        if (record.status === CleaningStatus.COMPLETED) continue;

        const currentlyUrgent = record.priority === CleaningPriority.URGENT;

        // Only update if priority state actually changed
        if (shouldBeUrgent && (!currentlyUrgent || record.priority_order_id !== priorityForOrderId)) {
          await cleaningRepository.update(record.id, {
            priority: CleaningPriority.URGENT,
            priority_order_id: priorityForOrderId!,
            notes: `Priority cleaning — needed for Order #${priorityForOrderId!.substring(0, 8)}`,
          });
          flagChanged = true;
        } else if (!shouldBeUrgent && currentlyUrgent) {
          await cleaningRepository.update(record.id, {
            priority: CleaningPriority.NORMAL,
            priority_order_id: null,
            notes: record.notes
              ? `${record.notes} — priority removed (recalculated)`
              : 'Priority removed — no longer needed',
          });
          flagChanged = true;
        }
      } else {
        // HEALING LOGIC: Recreate missing cleaning record
        // Status: IN_PROGRESS if order is returned/flagged, else SCHEDULED
        const isAlreadyBack = ['returned', 'flagged'].includes(order.status);
        
        await cleaningRepository.create({
          product_id: productId,
          order_id: order.orderId,
          branch_id: order.branchId,
          store_id: order.storeId,
          quantity: order.quantity || 1,
          status: isAlreadyBack ? CleaningStatus.IN_PROGRESS : CleaningStatus.SCHEDULED,
          priority: shouldBeUrgent ? CleaningPriority.URGENT : CleaningPriority.NORMAL,
          priority_order_id: shouldBeUrgent ? priorityForOrderId! : undefined,
          expected_return_date: order.endDate,
          started_at: isAlreadyBack ? new Date().toISOString() : undefined,
          notes: `Auto-healed record during priority recalculation. ${shouldBeUrgent ? 'Marked as URGENT.' : ''}`
        });
        flagChanged = true;
      }

      // Collect order IDs for bulk sync instead of calling syncOrderPriorityFlag sequentially
      if (flagChanged) {
        if (shouldBeUrgent) {
          priorityTrueIds.push(order.orderId);
        } else {
          priorityFalseIds.push(order.orderId);
        }
      }
    }

    // Execute bulk updates in parallel to dramatically reduce DB round-trips
    await Promise.all([
      priorityTrueIds.length > 0 ? orderRepository.updateOrderPriorityFlags(priorityTrueIds, true) : Promise.resolve(),
      priorityFalseIds.length > 0 ? orderRepository.updateOrderPriorityFlags(priorityFalseIds, false) : Promise.resolve(),
    ]);
  }

  /**
   * Set user context for audit logging
   */
  setUserContext(userId: string | null, branchId: string | null): void {
    this.currentUserId = userId;
    this.currentBranchId = branchId;
    orderRepository.setUserContext(userId, branchId);
  }

  /**
   * Get all orders
   */
  async getAllOrders(params?: OrderSearchParams): Promise<RepositoryResult<OrderSearchResult>> {
    return await orderRepository.findAll(params);
  }

  /**
   * Get order by ID
   */
  async getOrderById(id: string): Promise<RepositoryResult<OrderWithRelations>> {
    return await orderRepository.findById(id);
  }

  /**
   * Check product availability for given date range (Sweep Line)
   */
  async checkAvailability(productId: string, startDate: string, endDate: string, branchId?: string, excludeOrderId?: string): Promise<RepositoryResult<{ available: number; availableWithPriority: number; total: number; peakReserved: number; overlappingOrders: any[]; priorityCleaningNeeded: boolean; priorityCleaningInfo: any[] }>> {
    const start = new Date(startDate);
    const end = new Date(endDate);
    if (start > end) {
      return {
        data: null,
        error: {
          message: 'Rental end date cannot be before start date',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }
    return await orderRepository.checkAvailability(productId, startDate, endDate, branchId, excludeOrderId);
  }

  /**
   * Get per-day availability calendar for a product
   */
  async getProductAvailabilityCalendar(productId: string, rangeStart: string, rangeEnd: string) {
    return await orderRepository.getAvailabilityCalendar(productId, rangeStart, rangeEnd);
  }

  /**
   * Proactively sync conflicts for ALL orders containing a specific product.
   * Called when product quantity changes.
   */
  async syncProductConflicts(productId: string): Promise<void> {
    await orderRepository.syncProductConflicts(productId);
  }

  /**
   * Re-validate conflicts for a specific order.
   */
  async validateOrderConflicts(orderId: string): Promise<RepositoryResult<boolean>> {
    return await orderRepository.validateOrderStockConflicts(orderId);
  }

  /**
   * Create a new order
   */
  async createOrder(data: CreateOrderDTO): Promise<RepositoryResult<OrderWithRelations>> {
    const totalStart = performance.now();
    console.log('[OrderService.createOrder] Starting order creation flow...');

    // Validate required fields
    if (!data.customer_id) {
      return {
        data: null,
        error: {
          message: 'Customer ID is required',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    if (!data.branch_id) {
      return {
        data: null,
        error: {
          message: 'Branch ID is required',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    if (!data.items || data.items.length === 0) {
      return {
        data: null,
        error: {
          message: 'Order must have at least one item',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    if (!data.rental_start_date || !data.rental_end_date) {
      return {
        data: null,
        error: {
          message: 'Rental start and end dates are required',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    // Validate rental dates
    const startDate = new Date(data.rental_start_date);
    const endDate = new Date(data.rental_end_date);
    
    if (startDate > endDate) {
      return {
        data: null,
        error: {
          message: 'Rental end date cannot be before start date',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    // Validate items
    for (const item of data.items) {
      if (!item.product_id) {
        return { data: null, error: { message: 'Product ID is required for all items', code: 'VALIDATION_ERROR' } as any, success: false };
      }
      if (!item.quantity || item.quantity < 1) {
        return { data: null, error: { message: 'Quantity must be at least 1', code: 'VALIDATION_ERROR' } as any, success: false };
      }
      if (!item.price_per_day || item.price_per_day < 0) {
        return { data: null, error: { message: 'Rent price must be a positive number', code: 'VALIDATION_ERROR' } as any, success: false };
      }
    }

    // Availability checks are skipped — the frontend already checks via
    // useCheckOrderAvailability hook before allowing checkout. Orders are
    // created as 'scheduled' with no inventory deducted. Conflicts are
    // caught by the background syncProductConflictsForRange call.

    // Parallelize pre-creation queries
    const productIds = data.items.map((item: any) => item.product_id);
    const { createAdminClient } = await import('@/lib/supabase/server');
    const adminClient = createAdminClient();

    const [isGstEnabledResult, productsResult, branchResponse] = await Promise.all([
      settingsService.getIsGSTEnabled(),
      adminClient.from('products').select('id, price_per_day, category_id, categories:category_id(gst_percentage)').in('id', productIds),
      adminClient.from('branches').select('store_id').eq('id', data.branch_id).single()
    ]);

    const isGstEnabled = !!(isGstEnabledResult.success && isGstEnabledResult.data);
    const products = productsResult.data;
    const storeId = branchResponse.data?.store_id;

    // Validate price override: price_per_day must be >= product's actual price
    if (products) {
      const productPriceMap = new Map<string, number>();
      for (const p of products) {
        productPriceMap.set(p.id, (p as any).price_per_day ?? 0);
      }
      for (const item of data.items) {
        const productPrice = productPriceMap.get(item.product_id);
        if (productPrice !== undefined && item.price_per_day < productPrice) {
          return {
            data: null,
            error: {
              message: `Price for a product cannot be lower than the original price (${productPrice})`,
              code: 'PRICE_BELOW_ORIGINAL'
            } as any,
            success: false,
          };
        }
        // Set original_price_per_day from DB if not already provided
        if (!(item as any).original_price_per_day && productPrice !== undefined) {
          (item as any).original_price_per_day = productPrice;
        }
      }
    }

    // Look up per-item category GST rates (GST-inclusive: the rent amount already includes GST)
    let perItemGstRates: Map<string, number> = new Map();
    if (isGstEnabled && products) {
      for (const p of products) {
        const cat = Array.isArray(p.categories) ? p.categories[0] : p.categories;
        const gstRate = (cat as any)?.gst_percentage ?? 0;
        perItemGstRates.set(p.id, gstRate);
      }
    }

    const dbStart = performance.now();
    const result = await orderRepository.create(data, isGstEnabled, perItemGstRates, storeId);
    const dbDuration = performance.now() - dbStart;
    console.log(`[OrderService.createOrder] DB save duration: ${dbDuration.toFixed(2)}ms`);

    // Invalidate dashboard cache immediately after DB write succeeds
    if (result.success) {
      try {
        dashboardService.clearCache();
      } catch (err) {
        console.error('Failed to clear dashboard cache:', err);
      }
    }

    // ─── AUTO-SCHEDULE CLEANING FOR ALL ITEMS (BACKGROUND NON-BLOCKING) ──────
    // Every order pre-creates cleaning records so the cleaning queue has
    // full visibility of upcoming workload before items are even returned.
    // Done in background to keep HTTP save response under 1.5 seconds.
    if (result.success && result.data) {
      (async () => {
        const recalcStart = performance.now();
        const newOrder = result.data!;
        const newOrderId = newOrder.id;
        const storeId = newOrder.store_id;
        const endDateStr = new Date(newOrder.end_date).toISOString().split('T')[0];

        // 1. Auto-schedule cleaning records in parallel
        await Promise.all((newOrder.items || []).map(async (item) => {
          if (!item.product_id) return;

          // Check if the product's category requires a buffer
          const product = (item as any).product;
          const category = Array.isArray(product?.category) ? product.category[0] : product?.category;
          const categoryHasBuffer = category?.has_buffer ?? true;
          if (!categoryHasBuffer) return;

          // Create a scheduled cleaning record for this item
          await cleaningRepository.create({
            product_id: item.product_id,
            order_id: newOrderId,
            branch_id: data.branch_id,
            store_id: storeId,
            quantity: item.quantity,
            status: CleaningStatus.SCHEDULED,
            priority: CleaningPriority.NORMAL,
            expected_return_date: endDateStr,
            notes: `Scheduled at order creation — expected return ${endDateStr}`,
          });
        }));

        // 2. Recalculate priority cleaning and sync conflicts in parallel
        await Promise.all((newOrder.items || []).map(async (item) => {
          if (!item.product_id) return;
          const product = (item as any).product;
          const category = Array.isArray(product?.category) ? product.category[0] : product?.category;
          const categoryHasBuffer = category?.has_buffer ?? true;
          if (!categoryHasBuffer) return;

          await this.recalculateProductPriorityCleaning(item.product_id, data.branch_id);
          await orderRepository.syncProductConflictsForRange(item.product_id, newOrder.start_date, newOrder.end_date);
        }));

        const recalcDuration = performance.now() - recalcStart;
        console.log(`[OrderService.createOrder] Background cleaning auto-schedule & priority recalc finished in ${recalcDuration.toFixed(2)}ms`);
      })().catch(err => {
        console.error('[OrderService.createOrder] Background auto-schedule/recalculation failed:', err);
      });
    }

    const totalDuration = performance.now() - totalStart;
    console.log(`[OrderService.createOrder] Total createOrder flow duration: ${totalDuration.toFixed(2)}ms`);
    return result;
  }


  /**
   * Update an existing order
   */
  async updateOrder(id: string, data: UpdateOrderDTO): Promise<RepositoryResult<OrderWithRelations>> {
    const totalStart = performance.now();
    console.log(`[OrderService.updateOrder] Starting order update flow for ID: ${id}...`);

    // Check if order exists
    const existingOrder = await orderRepository.findById(id);
    if (!existingOrder.success || !existingOrder.data) {
      return {
        data: null,
        error: {
          message: 'Order not found',
          code: 'ORDER_NOT_FOUND'
        } as any,
        success: false,
      };
    }

    // Validate status transitions
    if (data.status) {
      const currentStatus = existingOrder.data.status;
      const newStatus = data.status;

      // Define allowed transitions
      const allowedTransitions: Record<OrderStatus, OrderStatus[]> = {
        [OrderStatus.PENDING]: [OrderStatus.SCHEDULED, OrderStatus.CANCELLED, OrderStatus.RETURNED],
        [OrderStatus.CONFIRMED]: [OrderStatus.DELIVERED, OrderStatus.ONGOING, OrderStatus.CANCELLED, OrderStatus.RETURNED], // legacy fallback
        [OrderStatus.SCHEDULED]: [OrderStatus.DELIVERED, OrderStatus.ONGOING, OrderStatus.CANCELLED, OrderStatus.RETURNED],
        [OrderStatus.DELIVERED]: [OrderStatus.IN_USE, OrderStatus.ONGOING, OrderStatus.CANCELLED],
        [OrderStatus.IN_USE]: [OrderStatus.RETURNED, OrderStatus.PARTIAL, OrderStatus.FLAGGED],
        [OrderStatus.ONGOING]: [OrderStatus.RETURNED, OrderStatus.PARTIAL, OrderStatus.FLAGGED],
        [OrderStatus.PARTIAL]: [OrderStatus.RETURNED, OrderStatus.COMPLETED, OrderStatus.FLAGGED],
        [OrderStatus.FLAGGED]: [OrderStatus.RETURNED, OrderStatus.COMPLETED],
        [OrderStatus.RETURNED]: [OrderStatus.COMPLETED],
        // LATE_RETURN removed - now handled by is_late boolean flag
        [OrderStatus.COMPLETED]: [],
        [OrderStatus.CANCELLED]: [],
      };

      if (!allowedTransitions[currentStatus].includes(newStatus)) {
        return {
          data: null,
          error: {
            message: `Cannot transition from ${currentStatus} to ${newStatus}`,
            code: 'INVALID_STATUS_TRANSITION'
          } as any,
          success: false,
        };
      }

      const isBackfillReturn = newStatus === OrderStatus.RETURNED &&
        ['pending', 'confirmed', 'scheduled'].includes(currentStatus);
      if (isBackfillReturn && !(data as any).backfill_note?.trim()) {
        return {
          data: null,
          error: {
            message: 'A note is required when recording an untracked order as returned',
            code: 'BACKFILL_NOTE_REQUIRED'
          } as any,
          success: false,
        };
      }

      // Block starting a rental if its scheduled return date has already passed (except for backdated orders)
      const isStarting = ['ongoing', 'in_use', 'delivered'].includes(newStatus) &&
                         !['ongoing', 'in_use', 'delivered', 'returned', 'completed'].includes(currentStatus);
      if (isStarting) {
        const creationDateStr = new Date(existingOrder.data.created_at).toLocaleDateString('en-CA');
        const isBackdated = existingOrder.data.start_date < creationDateStr;

        if (!isBackdated) {
          const today = new Date();
          today.setHours(0, 0, 0, 0);
          const endDateVal = new Date(existingOrder.data.end_date);
          const endDate = new Date(endDateVal.getFullYear(), endDateVal.getMonth(), endDateVal.getDate());
          if (endDate < today) {
            return {
              data: null,
              error: {
                message: 'Cannot start a rental whose return date has already passed. Please create a new order instead.',
                code: 'VALIDATION_ERROR'
              } as any,
              success: false,
            };
          }
        }
      }
    }

    // Validate rental dates if provided (cross-validating against existing dates if only one is updated)
    if (data.start_date || data.end_date) {
      const startDateVal = data.start_date || existingOrder.data.start_date;
      const endDateVal = data.end_date || existingOrder.data.end_date;
      
      const startDate = new Date(startDateVal);
      const endDate = new Date(endDateVal);
      
      if (startDate > endDate) {
        return {
          data: null,
          error: {
            message: 'Rental end date cannot be before start date',
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
    }

    // Block financial adjustments on finalized orders
    const currentStatus = existingOrder.data.status;
    if (currentStatus === OrderStatus.COMPLETED || currentStatus === OrderStatus.CANCELLED) {
      const financialFields = ['discount', 'discount_type', 'late_fee', 'damage_charges_total', 'total_amount', 'subtotal'];
      const attemptedFinancialChange = financialFields.some(field => (data as any)[field] !== undefined);
      if (attemptedFinancialChange) {
        return {
          data: null,
          error: {
            message: `Cannot modify financial fields on a ${currentStatus} order`,
            code: 'ORDER_FINALIZED'
          } as any,
          success: false,
        };
      }
    }

    // Validate price override for items (if provided)
    if (data.items && data.items.length > 0) {
      const productIds = data.items.map((item: any) => item.product_id);
      const { createAdminClient } = await import('@/lib/supabase/server');
      const adminClient = createAdminClient();
      const { data: products } = await adminClient
        .from('products')
        .select('id, price_per_day')
        .in('id', productIds);

      if (products) {
        const productPriceMap = new Map<string, number>();
        for (const p of products) {
          productPriceMap.set(p.id, (p as any).price_per_day ?? 0);
        }
        for (const item of data.items) {
          const productPrice = productPriceMap.get(item.product_id);
          if (productPrice !== undefined && item.price_per_day < productPrice) {
            return {
              data: null,
              error: {
                message: `Price for a product cannot be lower than the original price (${productPrice})`,
                code: 'PRICE_BELOW_ORIGINAL'
              } as any,
              success: false,
            };
          }
          // Set original_price_per_day from DB if not already provided
          if (!(item as any).original_price_per_day && productPrice !== undefined) {
            (item as any).original_price_per_day = productPrice;
          }
        }
      }
    }

    const dbStart = performance.now();
    const result = await orderRepository.update(id, data);
    const dbDuration = performance.now() - dbStart;
    console.log(`[OrderService.updateOrder] DB update duration: ${dbDuration.toFixed(2)}ms`);

    // If this was a backfill return, record the explanatory note in status history
    if (result.success && data.status === OrderStatus.RETURNED && (data as any).backfill_note?.trim()) {
      const currentStatus = existingOrder.data.status;
      if (['pending', 'confirmed', 'scheduled'].includes(currentStatus)) {
        await orderRepository.addStatusHistory(id, OrderStatus.RETURNED, `Backfill: ${(data as any).backfill_note}`);
      }
    }

    // After any update that changes payment_status or status, check auto-complete
    // Run in background — auto-complete is only relevant for returned/paid orders,
    // not for scheduled→ongoing transitions. Saves 1 blocking DB round-trip.
    if (result.success && (data.payment_status || data.status)) {
      this.checkAndAutoComplete(id).catch(err => {
        console.error('[OrderService.updateOrder] Background auto-complete check failed:', err);
      });
    }

    // ─── PRIORITY CLEANING RECALCULATION ──────────────────────────────────
    // Recalculate priority cleaning when dates, items, or status change.
    // This replaces the old incremental approach that caused edge-case bugs.
    if (result.success) {
      // Execute priority recalculation and conflict synchronization asynchronously in the background.
      // This completely removes the 3.5s+ blocking lag from the user's save transaction!
      (async () => {
        const recalcStart = performance.now();
        const order = existingOrder.data!;
        const branchId = order.branch_id;

        if (data.status === OrderStatus.CANCELLED) {
          // ─── CANCELLATION ──────────────────────────────────────────────
          // 1. Clear priority flag and stock conflict flags on the cancelled order itself
          //    (recalculate only processes active orders, so this order would be skipped)
          await orderRepository.update(id, { 
            has_priority_cleaning: false,
            has_stock_conflict: false,
            conflict_details: []
          } as any);

          // 2. Delete this cancelled order's own scheduled cleaning records
          const ownRecords = await cleaningRepository.findByOrderId(id);
          if (ownRecords.success && ownRecords.data) {
            for (const record of ownRecords.data) {
              if (record.status === CleaningStatus.SCHEDULED) {
                await cleaningRepository.delete(record.id);
              }
            }
          }

          // 3. Recalculate for each product in the order in parallel
          await Promise.all((order.items || []).map(async (item) => {
            if (!item.product_id) return;
            await this.recalculateProductPriorityCleaning(item.product_id, branchId);
            await orderRepository.syncProductConflictsForRange(item.product_id, order.start_date, order.end_date);
          }));
        } else if (data.start_date || data.end_date) {
          // ─── DATE CHANGE ───────────────────────────────────────────────
          // Update expected_return_date on cleaning records, then recalculate in parallel
          const newEndDate = data.end_date || order.end_date;
          const endDateStr = new Date(newEndDate).toISOString().split('T')[0];

          await Promise.all((order.items || []).map(async (item) => {
            if (!item.product_id) return;

            // Update the expected return date on this order's cleaning record
            const cleaningRecord = await cleaningRepository.findByOrderAndProduct(id, item.product_id);
            if (cleaningRecord.success && cleaningRecord.data) {
              await cleaningRepository.update(cleaningRecord.data.id, {
                expected_return_date: endDateStr,
              });
            }

            await this.recalculateProductPriorityCleaning(item.product_id, branchId);
            await orderRepository.syncProductConflictsForRange(item.product_id, order.start_date, order.end_date);
            await orderRepository.syncProductConflictsForRange(
              item.product_id,
              data.start_date || order.start_date,
              data.end_date || order.end_date
            );
          }));
        }

        if (data.items) {
          // ─── ITEM CHANGE ───────────────────────────────────────────────
          // Recalculate for BOTH old products (might lose priority) and
          // new products (might gain priority) in parallel
          const oldProductIds = new Set((order.items || []).map((i: any) => i.product_id).filter(Boolean));
          const newProductIds = new Set(data.items.map((i: any) => i.product_id).filter(Boolean));

          // All affected products = union of old and new
          const allProductIds = new Set([...oldProductIds, ...newProductIds]);
          const finalStart = data.start_date || order.start_date;
          const finalEnd = data.end_date || order.end_date;
          
          await Promise.all(Array.from(allProductIds).map(async (productId) => {
            await this.recalculateProductPriorityCleaning(productId, branchId);
            await orderRepository.syncProductConflictsForRange(productId, finalStart, finalEnd);
          }));
        }
        const recalcDuration = performance.now() - recalcStart;
        console.log(`[OrderService.updateOrder] Background priority recalculation & conflict sync finished in ${recalcDuration.toFixed(2)}ms`);
      })().catch(err => {
        console.error('[OrderService.updateOrder] Background priority recalculation failed:', err);
      });
    }

    if (result.success) {
      try {
        dashboardService.clearCache();
      } catch (err) {
        console.error('Failed to clear dashboard cache:', err);
      }
    }

    const totalDuration = performance.now() - totalStart;
    console.log(`[OrderService.updateOrder] Total updateOrder flow duration: ${totalDuration.toFixed(2)}ms`);
    return result;
  }

  /**
   * Delete an order
   */
  async deleteOrder(id: string): Promise<RepositoryResult<void>> {
    // Check if order exists and collect product info BEFORE deletion
    const existingOrder = await orderRepository.findById(id);
    if (!existingOrder.success || !existingOrder.data) {
      return {
        data: null,
        error: {
          message: 'Order not found',
          code: 'ORDER_NOT_FOUND'
        } as any,
        success: false,
      };
    }

    const order = existingOrder.data;
    const branchId = order.branch_id;
    const affectedProductIds = (order.items || [])
      .map((item: any) => item.product_id)
      .filter(Boolean);

    // 1. Delete this order's SCHEDULED cleaning records BEFORE deleting the order.
    //    Keep in_progress/completed records — they represent real physical work.
    try {
      const ownRecords = await cleaningRepository.findByOrderId(id);
      if (ownRecords.success && ownRecords.data) {
        for (const record of ownRecords.data) {
          if (record.status === CleaningStatus.SCHEDULED) {
            await cleaningRepository.delete(record.id);
          }
        }
      }
    } catch (err) {
      console.error('Failed to delete cleaning records for order:', err);
    }

    // 2. Delete the order itself
    const deleteResult = await orderRepository.delete(id);

    // 3. Recalculate priority cleaning for each affected product in parallel in the background (non-blocking)
    //    (runs AFTER delete so the deleted order won't appear in active orders)
    if (deleteResult.success) {
      Promise.all(affectedProductIds.map(async (productId) => {
        await this.recalculateProductPriorityCleaning(productId, branchId);
        await orderRepository.syncProductConflictsForRange(productId, order.start_date, order.end_date);
      })).catch(err => {
        console.error('[OrderService.deleteOrder] Background priority recalculation failed:', err);
      });
    }

    if (deleteResult.success) {
      try {
        dashboardService.clearCache();
      } catch (err) {
        console.error('Failed to clear dashboard cache:', err);
      }
    }

    return deleteResult;
  }

  /**
   * Get order status history
   */
  async getOrderStatusHistory(orderId: string): Promise<RepositoryResult<any[]>> {
    return await orderRepository.getStatusHistory(orderId);
  }

  /**
   * Count orders
   */
  async countOrders(params?: OrderSearchParams): Promise<RepositoryResult<number>> {
    return await orderRepository.count(params);
  }

  /**
   * Count orders that need action: scheduled + pickup date passed.
   * Used for the filter badge count in the orders list page.
   */
  async countActionNeededOrders(branchId?: string): Promise<RepositoryResult<number>> {
    return await orderRepository.countActionNeeded(branchId);
  }

  /**
   * Count orders with stock conflicts.
   * Used for the filter badge count in the orders list page.
   */
  async countConflictOrders(branchId?: string): Promise<RepositoryResult<number>> {
    return await orderRepository.countConflict(branchId);
  }

  /**
   * Process order return with condition assessment
   */
  async processOrderReturn(orderId: string, returnData: ReturnOrderDTO): Promise<RepositoryResult<OrderWithRelations>> {
    // Check if order exists
    const existingOrder = await orderRepository.findById(orderId);
    if (!existingOrder.success || !existingOrder.data) {
      return {
        data: null,
        error: {
          message: 'Order not found',
          code: 'ORDER_NOT_FOUND'
        } as any,
        success: false,
      };
    }

    // Validate order is in correct status for return
    const currentStatus = existingOrder.data.status;
    if (currentStatus !== OrderStatus.IN_USE && currentStatus !== OrderStatus.ONGOING && currentStatus !== OrderStatus.PARTIAL) {
      return {
        data: null,
        error: {
          message: 'Order must be in use, ongoing, or partial to process return',
          code: 'INVALID_STATUS'
        } as any,
        success: false,
      };
    }

    // Validate return data
    if (!returnData.items || returnData.items.length === 0) {
      return {
        data: null,
        error: {
          message: 'Return data must include at least one item',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    // Validate items
    for (const item of returnData.items) {
      if (!item.item_id) {
        return {
          data: null,
          error: {
            message: 'Item ID is required for all return items',
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
      if (!item.condition_rating) {
        return {
          data: null,
          error: {
            message: 'Condition rating is required for all items',
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
      if (item.damage_charges && item.damage_charges < 0) {
        return {
          data: null,
          error: {
            message: 'Damage charges cannot be negative',
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
    }

    const result = await orderRepository.processReturn(orderId, returnData);
    
    if (result.success && result.data) {
      // Clear dashboard cache immediately (in-memory, non-blocking)
      try { dashboardService.clearCache(); } catch (err) { console.error('Failed to clear dashboard cache:', err); }

      // ─── POST-RETURN HOUSEKEEPING (BACKGROUND, NON-BLOCKING) ─────────────
      // Auto-complete check, cleaning record transitions, and damage assessments
      // don't affect the return response. Run them in the background so the user
      // sees "returned" status immediately. "completed" status and cleaning
      // records appear within ~2s via background processing.
      const returnedOrderData = result.data;
      (async () => {
        // 1. Auto-complete check (returned + paid → completed)
        await this.checkAndAutoComplete(orderId).catch(err =>
          console.error('[OrderService.processOrderReturn] Background auto-complete failed:', err)
        );

        // 2. Transition cleaning records: scheduled → in_progress
        try {
          const productReturnMap = new Map<string, { quantity: number; returnedQuantity: number }>();
          for (const item of returnedOrderData.items || []) {
            if (!item.product_id) continue;
            productReturnMap.set(item.product_id, {
              quantity: item.quantity,
              returnedQuantity: item.returned_quantity || 0,
            });
          }

          await Promise.all(Array.from(productReturnMap.entries()).map(async ([productId, info]) => {
            const scheduledRecord = await cleaningRepository.findScheduledByOrderAndProduct(orderId, productId);
            if (!scheduledRecord.success || !scheduledRecord.data) return;

            const record = scheduledRecord.data;
            const totalQty = info.quantity;
            const returnedQty = info.returnedQuantity;

            if (returnedQty >= totalQty) {
              await cleaningRepository.update(record.id, {
                status: CleaningStatus.IN_PROGRESS,
                started_at: new Date().toISOString(),
                quantity: record.quantity,
                notes: record.notes
                  ? `${record.notes} — all items returned, cleaning started`
                  : 'All items returned, cleaning started',
              });
            } else {
              const justReturnedQty = Math.min(returnedQty, record.quantity);
              const remainingQty = record.quantity - justReturnedQty;

              if (justReturnedQty > 0) {
                await cleaningRepository.update(record.id, {
                  status: CleaningStatus.IN_PROGRESS,
                  started_at: new Date().toISOString(),
                  quantity: justReturnedQty,
                  notes: record.notes
                    ? `${record.notes} — partial return (${justReturnedQty} of ${totalQty}), cleaning started`
                    : `Partial return (${justReturnedQty} of ${totalQty}), cleaning started`,
                });

                if (remainingQty > 0) {
                  await cleaningRepository.create({
                    product_id: productId,
                    order_id: orderId,
                    branch_id: returnedOrderData.branch_id,
                    store_id: record.store_id,
                    quantity: remainingQty,
                    status: CleaningStatus.SCHEDULED,
                    priority: record.priority,
                    priority_order_id: record.priority_order_id || undefined,
                    expected_return_date: record.expected_return_date || undefined,
                    notes: `Partial return — awaiting ${remainingQty} more unit(s)`,
                  });
                }
              }
            }
          }));
        } catch (err) {
          console.error('Failed to transition cleaning records:', err);
        }

        // 3. Auto-create damage assessments for damaged items
        try {
          const damagedItems = returnData.items
            .filter(item => item.condition_rating === 'damaged' && (item.damaged_quantity || 0) > 0)
            .map(item => {
              const orderItem = returnedOrderData.items.find(i => i.id === item.item_id);
              return {
                order_item_id: item.item_id,
                product_id: orderItem?.product_id || '',
                branch_id: returnedOrderData.branch_id,
                damaged_quantity: item.damaged_quantity || 0,
              };
            })
            .filter(item => item.product_id);

          if (damagedItems.length > 0) {
            await damageAssessmentService.createAssessments({
              order_id: orderId,
              items: damagedItems,
            });
          }
        } catch (err) {
          console.error('Failed to auto-create damage assessments:', err);
        }
      })().catch(err => {
        console.error('[OrderService.processOrderReturn] Background post-return housekeeping failed:', err);
      });
    }

    return result;
  }

  /**
   * Update damage details for a specific order item incrementally.
   */
  async updateOrderItemDamage(itemId: string, data: {
    condition_rating: ConditionRating;
    damage_description: string | null;
    damage_charges: number;
    damaged_quantity: number;
  }): Promise<RepositoryResult<any>> {
    // Basic validation
    if (!itemId) {
      return {
        data: null,
        error: { message: 'Item ID is required', code: 'VALIDATION_ERROR' } as any,
        success: false,
      };
    }

    if (data.damage_charges < 0) {
      return {
        data: null,
        error: { message: 'Damage charges cannot be negative', code: 'VALIDATION_ERROR' } as any,
        success: false,
      };
    }

    const result = await orderRepository.updateOrderItemDamage(itemId, data);
    if (result.success) {
      try {
        dashboardService.clearCache();
      } catch (err) {
        console.error('Failed to clear dashboard cache:', err);
      }
    }
    return result;
  }

  /**
   * Check if both item and payment tracks are complete, and auto-transition to 'completed'.
   * Called server-side after:
   *   1. processReturn() sets status to 'returned'
   *   2. A payment is recorded that makes payment_status = 'paid'
   *
   * Conditions for auto-complete:
   *   - status === 'returned'
   *   - payment_status === 'paid'
   */
  async checkAndAutoComplete(orderId: string): Promise<void> {
    const orderResult = await orderRepository.findById(orderId);
    if (!orderResult.success || !orderResult.data) return;

    const order = orderResult.data;

    const paymentDone = order.payment_status === PaymentStatus.PAID;
    
    // Status-based "items done" check
    let itemsDone = order.status === OrderStatus.RETURNED || order.status === OrderStatus.COMPLETED;

    // If flagged, check if all damage assessments are resolved
    if (order.status === OrderStatus.FLAGGED) {
      const assessmentResult = await damageAssessmentService.getAssessmentsForOrder(orderId);
      if (assessmentResult.success && assessmentResult.data && assessmentResult.data.length > 0) {
        const assessments = assessmentResult.data;
        const allDone = assessments.every(a => a.decision !== DamageDecision.PENDING);
        
        // If all are assessed, transition order from FLAGGED to RETURNED status
        if (allDone) {
          await orderRepository.update(orderId, { status: OrderStatus.RETURNED } as any);
          // Sync priority flag (clears it for returned/completed orders)
          await orderRepository.syncOrderPriorityFlag(orderId);
          // Add status history entry
          await orderRepository.addStatusHistory(orderId, OrderStatus.RETURNED, 'Damage assessment complete: all units resolved');
          order.status = OrderStatus.RETURNED;
          itemsDone = true;
        }
      }
    }

    if (itemsDone && paymentDone) {
      await orderRepository.update(orderId, { status: OrderStatus.COMPLETED } as any);
      // Sync priority flag (clears it for completed orders)
      await orderRepository.syncOrderPriorityFlag(orderId);
      // Add status history entry
      await orderRepository.addStatusHistory(orderId, OrderStatus.COMPLETED, 'Auto-completed: items returned/reused + payment settled');
    }
  }

  /**
   * Transition all overdue orders (ongoing/in_use past end_date) to late_return.
   *
   * DEPRECATED: This function is no longer needed as the is_late flag is now
   * automatically calculated by a database trigger. The trigger sets is_late=true
   * when end_date < current_date AND status is in (ongoing, in_use, delivered).
   *
   * @returns Number of orders transitioned (always 0 now)
   */
  async transitionOverdueOrders(): Promise<number> {
    return await orderRepository.transitionOverdueToLateReturn();
  }
}

// Singleton instance
export const orderService = new OrderService();
