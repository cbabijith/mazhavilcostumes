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
import { orderRepository, cleaningRepository, paymentRepository } from '@/repository';
import { settingsService } from './settingsService';
import { damageAssessmentService } from './damageAssessmentService';
import { dashboardService } from './dashboardService';
import { CleaningPriority, CleaningStatus, DamageDecision } from '@/domain';
import { PaymentType, PaymentMode } from '@/domain/types/payment';

/** True if `v` is a valid PaymentMode string value. */
function isValidPaymentMode(v: unknown): v is PaymentMode {
  return typeof v === 'string' && Object.values(PaymentMode).includes(v as PaymentMode);
}

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
    paymentRepository.setUserContext(userId, branchId);
  }

  /**
   * Get all orders (lightweight list query — no items, minimal fields)
   */
  async getAllOrders(params?: OrderSearchParams): Promise<RepositoryResult<OrderSearchResult>> {
    return await orderRepository.findAll(params);
  }

  /**
   * Alias for getAllOrders — explicit list query
   */
  async getOrdersList(params?: OrderSearchParams): Promise<RepositoryResult<OrderSearchResult>> {
    return await orderRepository.findAll(params);
  }

  /**
   * Get order by ID (full data with items, products, category)
   */
  async getOrderById(id: string): Promise<RepositoryResult<OrderWithRelations>> {
    return await orderRepository.findById(id);
  }

  /**
   * Set (or edit/remove) the order's SINGLE discount.
   *
   * Business rules (client decision 2026-09-06): one discount per order, no
   * stacking — a new value replaces the previous one; the total is recomputed
   * by swapping old discount for new. Setting 0 removes the discount.
   */
  async setOrderDiscount(
    orderId: string,
    amount: number,
    notes?: string,
    changedBy?: string | null
  ): Promise<RepositoryResult<Order>> {
    if (!Number.isFinite(amount) || amount < 0) {
      return {
        data: null,
        error: { message: 'Discount amount must be zero or a positive number', code: 'VALIDATION_ERROR' } as any,
        success: false,
      };
    }

    const orderResult = await orderRepository.findById(orderId);
    if (!orderResult.success || !orderResult.data) {
      return { data: null, error: { message: 'Order not found', code: 'ORDER_NOT_FOUND' } as any, success: false };
    }
    const order = orderResult.data;
    if (order.status === 'cancelled') {
      return { data: null, error: { message: 'Cannot adjust a cancelled order', code: 'VALIDATION_ERROR' } as any, success: false };
    }

    const currentDiscount = Number(order.discount || 0);
    const newTotal = Number(order.total_amount || 0) - (amount - currentDiscount);
    if (newTotal < 0) {
      return {
        data: null,
        error: { message: `Discount of ₹${amount} exceeds the order total (max ₹${(Number(order.total_amount) + currentDiscount).toFixed(2)})`, code: 'VALIDATION_ERROR' } as any,
        success: false,
      };
    }

    const amountPaid = Number(order.amount_paid || 0);
    const paymentStatus = amountPaid >= newTotal ? 'paid' : amountPaid > 0 ? 'partial' : 'pending';

    const updateResult = await orderRepository.update(orderId, {
      discount: amount,
      total_amount: newTotal,
      payment_status: paymentStatus,
    } as any);
    if (!updateResult.success || !updateResult.data) {
      return updateResult;
    }

    await orderRepository.addStatusHistory(
      orderId,
      order.status,
      amount > 0
        ? `Discount set to ₹${amount}${notes ? ` — ${notes}` : ''} (was ₹${currentDiscount})`
        : `Discount removed (was ₹${currentDiscount})`,
    );

    // A larger discount can settle the balance — auto-complete like the
    // payment path does (best-effort).
    this.checkAndAutoComplete(orderId).catch(err => {
      console.error('[OrderService.setOrderDiscount] auto-complete failed:', err);
    });

    try {
      dashboardService.clearCache();
    } catch { /* best-effort */ }

    return updateResult;
  }

  /**
   * Alias for getOrderById — explicit detail query
   */
  async getOrderDetail(id: string): Promise<RepositoryResult<OrderWithRelations>> {
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
    const perItemGstRates: Map<string, number> = new Map();
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

    // Create advance payment record through PaymentRepository (correct audit fields)
    // This is awaited — not background — so payment failures are visible, not silently swallowed.
    if (result.success && result.data && data.advance_collected && data.advance_amount && data.advance_amount > 0) {
      const paymentResult = await paymentRepository.create({
        order_id: result.data.id,
        payment_type: PaymentType.ADVANCE,
        amount: data.advance_amount,
        payment_mode: (data.advance_payment_method as PaymentMode) || PaymentMode.CASH,
        notes: 'Advance payment collected at order creation',
      });

      if (!paymentResult.success) {
        console.error('[OrderService.createOrder] Failed to create advance payment record:', paymentResult.error);
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
  async updateOrder(id: string, data: UpdateOrderDTO): Promise<RepositoryResult<Order>> {
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

    // Defensive: never forward an empty items array to the repository.
    // An empty array MUST mean "don't touch items", not "delete all items".
    // The schema (UpdateOrderSchema) and repository both guard this too, but
    // internal callers (auto-complete, status transitions) can reach this path
    // without schema validation — strip empty items here as the final safety net.
    if (Array.isArray((data as any).items) && (data as any).items.length === 0) {
      const { items: _omit, ...dataWithoutItems } = data as any;
      data = dataWithoutItems;
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
    // FLAGGED orders always re-check: legacy flagged orders with all damage
    // assessments already decided must un-stick on ANY save (e.g. a notes-only
    // edit), not only on status/payment changes — otherwise they sit in
    // flagged forever until an unrelated event fires.
    if (result.success && (data.payment_status || data.status || currentStatus === OrderStatus.FLAGGED)) {
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
      // ─── ADVANCE PAYMENT RECONCILIATION ──────────────────────────────────
      // The OrderForm only sends amount_paid/payment_status on CREATE, not on
      // update. So if an advance is added/changed/removed during an edit, the
      // `payments` table (the source of truth for amount_paid) is never touched,
      // and the order detail/list pages show a wrong "Due" amount with no entry
      // in Payment History. Reconcile the ADVANCE payment row here, BEFORE
      // syncOrderPaymentStatus recomputes amount_paid from the payment rows.
      if (
        (data as any).advance_amount !== undefined ||
        (data as any).advance_collected !== undefined
      ) {
        try {
          await this.reconcileAdvancePayment(id, existingOrder.data, data);
        } catch (err) {
          console.error('[OrderService.updateOrder] Failed to reconcile advance payment:', err);
        }
      }

      try {
        const { paymentService } = await import('./paymentService');
        await paymentService.syncOrderPaymentStatus(id);
      } catch (err) {
        console.error('[OrderService.updateOrder] Failed to sync order payment status:', err);
      }

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
   * Synchronize the ADVANCE-type payment row for an order with the order's
   * current `advance_amount` / `advance_collected` state.
   *
   * Called from updateOrder() whenever the edit form sends advance fields.
   * `payments` is the source of truth for `amount_paid`: syncOrderPaymentStatus
   * sums payment rows to recompute it, so the ADVANCE row must match.
   *
   * Logic:
   *  - newAdvance <= 0 (or not collected): delete any existing ADVANCE row.
   *  - newAdvance > 0 and no ADVANCE row exists: create one.
   *  - newAdvance > 0 and ADVANCE row exists with a different amount: update it.
   *  - Otherwise (same amount): no-op.
   *
   * We compare against the PRE-edit advance to detect a real change, and only
   * touch the payments table when something actually moved — this keeps
   * status-only or items-only edits from churning payment history.
   */
  private async reconcileAdvancePayment(
    orderId: string,
    existingOrder: OrderWithRelations,
    data: UpdateOrderDTO,
  ): Promise<void> {
    const newAdvance = Number((data as any).advance_amount ?? 0) || 0;
    const newCollected = (data as any).advance_collected ?? (newAdvance > 0);
    const effectiveAdvance = newCollected ? newAdvance : 0;
    const oldAdvance = Number(existingOrder.advance_amount ?? 0) || 0;

    // No change in advance amount → nothing to reconcile.
    if (effectiveAdvance === oldAdvance) return;

    paymentRepository.setUserContext(this.currentUserId, this.currentBranchId);

    // Find the existing ADVANCE payment row for this order, if any.
    const existingPaymentsRes = await paymentRepository.findByOrderId(orderId);
    const existingPayments = existingPaymentsRes.success && existingPaymentsRes.data ? existingPaymentsRes.data : [];
    const advanceRow = existingPayments.find(p => p.payment_type === PaymentType.ADVANCE);

    if (effectiveAdvance <= 0) {
      // Advance was removed/cleared → delete the ADVANCE payment row.
      if (advanceRow) {
        await paymentRepository.delete(advanceRow.id);
      }
      return;
    }

    // advance_payment_method is typed as PaymentMethod on the order but
    // PaymentMode on payments. The two enums share string values (cash, upi,
    // gpay, bank_transfer) except for the outlier (OTHER vs CHEQUE), so coerce
    // through the string and validate, falling back to CASH.
    const methodStr = (data as any).advance_payment_method ||
      existingOrder.advance_payment_method ||
      PaymentMode.CASH;
    const method = isValidPaymentMode(methodStr) ? methodStr : PaymentMode.CASH;

    if (!advanceRow) {
      // Advance added where none existed → create.
      await paymentRepository.create({
        order_id: orderId,
        payment_type: PaymentType.ADVANCE,
        amount: effectiveAdvance,
        payment_mode: method,
        notes: 'Advance payment updated during order edit',
      });
    } else if (Number(advanceRow.amount) !== effectiveAdvance) {
      // Advance amount changed → update existing row.
      await paymentRepository.update(advanceRow.id, {
        amount: effectiveAdvance,
        payment_mode: method,
      });
    }
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
  async processOrderReturn(orderId: string, returnData: ReturnOrderDTO): Promise<RepositoryResult<Order>> {
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
    // FLAGGED is allowed: orders flagged for damage may still have unreturned
    // items out with the customer that come back days later.
    const currentStatus = existingOrder.data.status;
    if (currentStatus !== OrderStatus.IN_USE && currentStatus !== OrderStatus.ONGOING && currentStatus !== OrderStatus.PARTIAL && currentStatus !== OrderStatus.FLAGGED) {
      return {
        data: null,
        error: {
          message: 'Order must be in use, ongoing, partial, or flagged to process return',
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
      // returned_quantity is the NEW TOTAL for the item (not a delta) — it can
      // never exceed the ordered quantity, otherwise inventory would be
      // incremented above what was ever rented out.
      if (item.returned_quantity === undefined || item.returned_quantity === null
        || !Number.isInteger(item.returned_quantity) || item.returned_quantity < 0) {
        return {
          data: null,
          error: {
            message: 'Returned quantity must be a non-negative integer for all items',
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
      const orderItem = existingOrder.data.items?.find(i => i.id === item.item_id);
      if (!orderItem) {
        return {
          data: null,
          error: {
            message: `Item ${item.item_id} does not belong to this order`,
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
      if (item.returned_quantity > orderItem.quantity) {
        return {
          data: null,
          error: {
            message: `Returned quantity (${item.returned_quantity}) cannot exceed ordered quantity (${orderItem.quantity})`,
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
      // returned_quantity is a NEW TOTAL, so it can never go DOWN — a lower
      // value would silently un-return units, flip is_returned back to false
      // and corrupt the outstanding-units math on every client.
      const alreadyReturned = orderItem.returned_quantity || 0;
      if (item.returned_quantity < alreadyReturned) {
        return {
          data: null,
          error: {
            message: `Returned quantity (${item.returned_quantity}) cannot be less than the ${alreadyReturned} unit(s) already returned. Send the NEW TOTAL (already returned + returning now), not just the units being returned now.`,
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
      // Damaged units are a subset of the units coming back
      if ((item.damaged_quantity || 0) > item.returned_quantity) {
        return {
          data: null,
          error: {
            message: `Damaged quantity (${item.damaged_quantity}) cannot exceed returned quantity (${item.returned_quantity})`,
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
    }

    // Return-time adjustments can never be negative — a negative late fee or
    // discount would silently reduce the order total (an un-authorized refund).
    if ((returnData.late_fee ?? 0) < 0) {
      return {
        data: null,
        error: { message: 'Late fee cannot be negative', code: 'VALIDATION_ERROR' } as any,
        success: false,
      };
    }
    if ((returnData.discount ?? 0) < 0) {
      return {
        data: null,
        error: { message: 'Discount cannot be negative', code: 'VALIDATION_ERROR' } as any,
        success: false,
      };
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
        // Fetch order items for background processing (returnedOrderData is a bare Order without joins)
        const itemsResult = await orderRepository.getOrderItems(orderId);
        const orderItems = itemsResult.data || [];

        // 1. Auto-complete check (returned + paid → completed)
        await this.checkAndAutoComplete(orderId).catch(err =>
          console.error('[OrderService.processOrderReturn] Background auto-complete failed:', err)
        );

        // 2. Transition cleaning records: scheduled → in_progress
        try {
          const productReturnMap = new Map<string, { quantity: number; returnedQuantity: number }>();
          for (const item of orderItems) {
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
              const orderItem = orderItems.find((i: any) => i.id === item.item_id);
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
      const assessments = assessmentResult.success && assessmentResult.data ? assessmentResult.data : [];

      // Zero assessment rows can mean two things:
      //  a) nothing is assessable (damage recorded with 0 damaged units, or a
      //     legacy flagged order without damaged quantities) — the order would
      //     otherwise sit in FLAGGED forever, so it must transition here;
      //  b) assessable damage exists but the rows were never created (legacy
      //     order or failed auto-creation) — keep it flagged; the Damage
      //     Assessment Panel offers a backfill button for exactly this case.
      const hasAssessableDamage = (order.items || []).some(
        i => i.condition_rating === 'damaged' && (i.damaged_quantity || 0) > 0
      );
      const allDone = assessments.length > 0
        ? assessments.every(a => a.decision !== DamageDecision.PENDING)
        : !hasAssessableDamage;

        // If all are assessed, transition order out of FLAGGED — but only to
        // RETURNED when every unit is physically back. Orders that still have
        // units out with the customer must land in PARTIAL so staff can
        // process the remaining returns later (completed/returned are not
        // returnable statuses).
        if (allDone) {
          const itemsResult = await orderRepository.getOrderItems(orderId);
          const items = itemsResult.data || [];
          const allUnitsBack = items.length > 0 && items.every(i => (i.returned_quantity || 0) >= i.quantity);
          const nextStatus = allUnitsBack ? OrderStatus.RETURNED : OrderStatus.PARTIAL;

          await orderRepository.update(orderId, { status: nextStatus } as any);
          // Sync priority flag (clears it for returned/completed orders)
          await orderRepository.syncOrderPriorityFlag(orderId);
          // Add status history entry
          await orderRepository.addStatusHistory(orderId, nextStatus, assessments.length > 0
            ? (allUnitsBack
                ? 'Damage assessment complete: all units resolved'
                : 'Damage assessment complete: units still out with customer')
            : 'Unflagged: no assessable damage units on this order');
          order.status = nextStatus;
          itemsDone = allUnitsBack;
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
