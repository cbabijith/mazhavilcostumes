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
  ReturnOrderDTO
} from '@/domain/types/order';
import { orderRepository, cleaningRepository } from '@/repository';
import { settingsService } from './settingsService';
import { CleaningPriority, CleaningStatus } from '@/domain';

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

    // 2. Get product total stock quantity
    const totalStock = await orderRepository.getProductTotalQuantity(productId);
    if (totalStock === 0) return;

    // 3. Determine which orders need priority cleaning using stock-aware logic.
    //    An order needs priority cleaning ONLY if the total units in use on
    //    its buffer boundary day (cleaning day) exceeds the available stock for
    //    the next order that starts on that day.
    //
    //    Example: 10 total, Order A (5 units, ends May 14, buffer May 15),
    //    Order B (1 unit, starts May 15). On May 15: 5 in cleaning + 1 needed
    //    = 6. Stock = 10. 10 - 5 = 5 free >= 1 needed → NO priority.
    //    But if Order A had 10 units → 10 - 10 = 0 free < 1 needed → PRIORITY.
    const needsPriority = new Map<string, string>();

    for (let i = 0; i < orders.length; i++) {
      const current = orders[i];
      const currentEndDate = new Date(current.endDate);

      // Buffer boundary: current end + buffer days
      const bufferEnd = new Date(currentEndDate);
      bufferEnd.setDate(bufferEnd.getDate() + BUFFER_DAYS);

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
          const otherBufferEnd = otherEnd + BUFFER_DAYS * 24 * 60 * 60 * 1000;

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
    for (const order of orders) {
      const priorityForOrderId = needsPriority.get(order.orderId);
      const shouldBeUrgent = !!priorityForOrderId;

      // Find cleaning record for this order+product
      const cleaningResult = await cleaningRepository.findByOrderAndProduct(order.orderId, productId);
      if (cleaningResult.success && cleaningResult.data) {
        const record = cleaningResult.data;
        const currentlyUrgent = record.priority === CleaningPriority.URGENT;

        // Only update if priority state actually changed
        if (shouldBeUrgent && (!currentlyUrgent || record.priority_order_id !== priorityForOrderId)) {
          await cleaningRepository.update(record.id, {
            priority: CleaningPriority.URGENT,
            priority_order_id: priorityForOrderId!,
            notes: `Priority cleaning — needed for Order #${priorityForOrderId!.substring(0, 8)}`,
          });
        } else if (!shouldBeUrgent && currentlyUrgent) {
          await cleaningRepository.update(record.id, {
            priority: CleaningPriority.NORMAL,
            priority_order_id: null,
            notes: record.notes
              ? `${record.notes} — priority removed (recalculated)`
              : 'Priority removed — no longer needed',
          });
        }
      }

      // Update order's has_priority_cleaning flag
      await orderRepository.update(order.orderId, {
        has_priority_cleaning: shouldBeUrgent,
      } as any);
    }
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
  async getAllOrders(params?: OrderSearchParams): Promise<RepositoryResult<OrderWithRelations[]>> {
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
    return await orderRepository.checkAvailability(productId, startDate, endDate, branchId, excludeOrderId);
  }

  /**
   * Get per-day availability calendar for a product
   */
  async getProductAvailabilityCalendar(productId: string, rangeStart: string, rangeEnd: string) {
    return await orderRepository.getAvailabilityCalendar(productId, rangeStart, rangeEnd);
  }

  /**
   * Create a new order
   */
  async createOrder(data: CreateOrderDTO): Promise<RepositoryResult<OrderWithRelations>> {
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
    
    if (startDate >= endDate) {
      return {
        data: null,
        error: {
          message: 'Rental end date must be after start date',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    // Validate items and check availability
    const priorityCleaningInfoList: any[] = [];
    for (const item of data.items) {
      if (!item.product_id) {
        return {
          data: null,
          error: {
            message: 'Product ID is required for all items',
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
      if (!item.quantity || item.quantity < 1) {
        return {
          data: null,
          error: {
            message: 'Quantity must be at least 1',
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
      if (!item.price_per_day || item.price_per_day < 0) {
        return {
          data: null,
          error: {
            message: 'Rent price must be a positive number',
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
      
      const availCheck = await this.checkAvailability(item.product_id, data.rental_start_date, data.rental_end_date, data.branch_id);
      if (!availCheck.success) {
        return {
          data: null,
          error: availCheck.error,
          success: false
        };
      }

      // Check if priority cleaning is needed and not confirmed
      const needsPriority = availCheck.data!.priorityCleaningNeeded;
      const availableWithPriority = availCheck.data!.availableWithPriority;
      const normallyAvailable = availCheck.data!.available;

      if (normallyAvailable < item.quantity && needsPriority && availableWithPriority >= item.quantity && !data.priority_cleaning_confirmed) {
        return {
          data: null,
          error: {
            message: 'Priority cleaning required but not confirmed',
            code: 'PRIORITY_CLEANING_REQUIRED',
            details: availCheck.data!.priorityCleaningInfo
          } as any,
          success: false
        };
      }

      // If still not enough even with priority cleaning, block
      if (availableWithPriority < item.quantity) {
        return {
          data: null,
          error: { message: `Insufficient availability for product. Only ${availCheck.data!.available} available.`, code: 'VALIDATION_ERROR' } as any,
          success: false
        };
      }

      // Collect priority cleaning info for later
      if (needsPriority && data.priority_cleaning_confirmed && availCheck.data!.priorityCleaningInfo) {
        priorityCleaningInfoList.push(...availCheck.data!.priorityCleaningInfo);
      }
    }

    // Get GST settings
    const isGstEnabledResult = await settingsService.getIsGSTEnabled();
    const isGstEnabled = !!(isGstEnabledResult.success && isGstEnabledResult.data);

    // Look up per-item category GST rates (GST-inclusive: the rent amount already includes GST)
    let perItemGstRates: Map<string, number> = new Map();
    if (isGstEnabled) {
      const productIds = data.items.map((item: any) => item.product_id);
      const { createAdminClient } = await import('@/lib/supabase/server');
      const adminClient = createAdminClient();
      const { data: products } = await adminClient
        .from('products')
        .select('id, category_id, categories:category_id(gst_percentage)')
        .in('id', productIds);
      
      if (products) {
        for (const p of products) {
          const cat = Array.isArray(p.categories) ? p.categories[0] : p.categories;
          const gstRate = (cat as any)?.gst_percentage ?? 0;
          perItemGstRates.set(p.id, gstRate);
        }
      }
    }

    const result = await orderRepository.create(data, isGstEnabled, perItemGstRates);

    // ─── AUTO-SCHEDULE CLEANING FOR ALL ITEMS ────────────────────────────────
    // Every order pre-creates cleaning records so the cleaning queue has
    // full visibility of upcoming workload before items are even returned.
    if (result.success && result.data) {
      try {
        const newOrder = result.data;
        const newOrderId = newOrder.id;
        const storeId = newOrder.store_id;
        const endDateStr = new Date(newOrder.end_date).toISOString().split('T')[0];

        for (const item of newOrder.items || []) {
          if (!item.product_id) continue;

          // Check if the product's category requires a buffer
          const product = (item as any).product;
          const category = Array.isArray(product?.category) ? product.category[0] : product?.category;
          const categoryHasBuffer = category?.has_buffer ?? true;
          if (!categoryHasBuffer) continue;

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
        }

        // ─── RECALCULATE PRIORITY CLEANING ────────────────────────────────────
        // Instead of inline priority tracking, recalculate from scratch for
        // each product. This handles all edge cases: direction, date changes,
        // multi-priority, item changes, etc.
        for (const item of newOrder.items || []) {
          if (!item.product_id) continue;
          const product = (item as any).product;
          const category = Array.isArray(product?.category) ? product.category[0] : product?.category;
          const categoryHasBuffer = category?.has_buffer ?? true;
          if (!categoryHasBuffer) continue;

          await this.recalculateProductPriorityCleaning(item.product_id, data.branch_id);
        }
      } catch (err) {
        console.error('Failed to schedule cleaning records:', err);
      }
    }

    return result;
  }


  /**
   * Update an existing order
   */
  async updateOrder(id: string, data: UpdateOrderDTO): Promise<RepositoryResult<OrderWithRelations>> {
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
        [OrderStatus.PENDING]: [OrderStatus.SCHEDULED, OrderStatus.CANCELLED],
        [OrderStatus.CONFIRMED]: [OrderStatus.DELIVERED, OrderStatus.ONGOING, OrderStatus.CANCELLED], // legacy fallback
        [OrderStatus.SCHEDULED]: [OrderStatus.DELIVERED, OrderStatus.ONGOING, OrderStatus.CANCELLED],
        [OrderStatus.DELIVERED]: [OrderStatus.IN_USE, OrderStatus.ONGOING, OrderStatus.CANCELLED],
        [OrderStatus.IN_USE]: [OrderStatus.RETURNED, OrderStatus.LATE_RETURN, OrderStatus.PARTIAL, OrderStatus.FLAGGED],
        [OrderStatus.ONGOING]: [OrderStatus.RETURNED, OrderStatus.LATE_RETURN, OrderStatus.PARTIAL, OrderStatus.FLAGGED],
        [OrderStatus.PARTIAL]: [OrderStatus.RETURNED, OrderStatus.COMPLETED, OrderStatus.FLAGGED],
        [OrderStatus.FLAGGED]: [OrderStatus.RETURNED, OrderStatus.COMPLETED],
        [OrderStatus.RETURNED]: [OrderStatus.COMPLETED],
        [OrderStatus.LATE_RETURN]: [OrderStatus.COMPLETED, OrderStatus.FLAGGED],
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
    }

    // Validate rental dates if provided
    if (data.start_date && data.end_date) {
      const startDate = new Date(data.start_date);
      const endDate = new Date(data.end_date);
      
      if (startDate >= endDate) {
        return {
          data: null,
          error: {
            message: 'Rental end date must be after start date',
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

    const result = await orderRepository.update(id, data);

    // After any update that changes payment_status or status, check auto-complete
    if (result.success && (data.payment_status || data.status)) {
      await this.checkAndAutoComplete(id);
    }

    // ─── PRIORITY CLEANING RECALCULATION ──────────────────────────────────
    // Recalculate priority cleaning when dates, items, or status change.
    // This replaces the old incremental approach that caused edge-case bugs.
    if (result.success) {
      try {
        const order = existingOrder.data;
        const branchId = order.branch_id;

        if (data.status === OrderStatus.CANCELLED) {
          // ─── CANCELLATION ──────────────────────────────────────────────
          // 1. Clear priority flag on the cancelled order itself
          //    (recalculate only processes active orders, so this order would be skipped)
          await orderRepository.update(id, { has_priority_cleaning: false } as any);

          // 2. Delete this cancelled order's own scheduled cleaning records
          const ownRecords = await cleaningRepository.findByOrderId(id);
          if (ownRecords.success && ownRecords.data) {
            for (const record of ownRecords.data) {
              if (record.status === CleaningStatus.SCHEDULED) {
                await cleaningRepository.delete(record.id);
              }
            }
          }

          // 3. Recalculate for each product in the order
          for (const item of order.items || []) {
            if (!item.product_id) continue;
            await this.recalculateProductPriorityCleaning(item.product_id, branchId);
          }
        } else if (data.start_date || data.end_date) {
          // ─── DATE CHANGE ───────────────────────────────────────────────
          // Update expected_return_date on cleaning records, then recalculate
          const newEndDate = data.end_date || order.end_date;
          const endDateStr = new Date(newEndDate).toISOString().split('T')[0];

          for (const item of order.items || []) {
            if (!item.product_id) continue;

            // Update the expected return date on this order's cleaning record
            const cleaningRecord = await cleaningRepository.findByOrderAndProduct(id, item.product_id);
            if (cleaningRecord.success && cleaningRecord.data) {
              await cleaningRepository.update(cleaningRecord.data.id, {
                expected_return_date: endDateStr,
              });
            }

            await this.recalculateProductPriorityCleaning(item.product_id, branchId);
          }
        }

        if (data.items) {
          // ─── ITEM CHANGE ───────────────────────────────────────────────
          // Recalculate for BOTH old products (might lose priority) and
          // new products (might gain priority)
          const oldProductIds = new Set((order.items || []).map((i: any) => i.product_id).filter(Boolean));
          const newProductIds = new Set(data.items.map((i: any) => i.product_id).filter(Boolean));

          // All affected products = union of old and new
          const allProductIds = new Set([...oldProductIds, ...newProductIds]);
          for (const productId of allProductIds) {
            await this.recalculateProductPriorityCleaning(productId, branchId);
          }
        }
      } catch (err) {
        console.error('Failed to recalculate priority cleaning:', err);
      }
    }

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

    // 3. Recalculate priority cleaning for each affected product
    //    (runs AFTER delete so the deleted order won't appear in active orders)
    if (deleteResult.success) {
      try {
        for (const productId of affectedProductIds) {
          await this.recalculateProductPriorityCleaning(productId, branchId);
        }
      } catch (err) {
        console.error('Failed to recalculate priority cleaning after delete:', err);
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
    if (currentStatus !== OrderStatus.IN_USE && currentStatus !== OrderStatus.ONGOING && currentStatus !== OrderStatus.LATE_RETURN && currentStatus !== OrderStatus.PARTIAL) {
      return {
        data: null,
        error: {
          message: 'Order must be in use, ongoing, partial, or late return to process return',
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
    
    // After return processing, check if both tracks are done for auto-complete
    if (result.success && result.data) {
      await this.checkAndAutoComplete(orderId);

      // ─── TRANSITION CLEANING RECORDS: scheduled → in_progress ──────────────
      // Cleaning records are pre-created at order time (status: scheduled).
      // On return, we transition to in_progress (cleaning starts now).
      // For partial returns, we SPLIT the record: returned items start cleaning,
      // remaining items keep a scheduled record for when they arrive.
      try {
        // Deduplicate: collect per-product return info from the returned items
        const productReturnMap = new Map<string, { quantity: number; returnedQuantity: number }>();
        for (const item of result.data.items || []) {
          if (!item.product_id) continue;
          productReturnMap.set(item.product_id, {
            quantity: item.quantity,
            returnedQuantity: item.returned_quantity || 0,
          });
        }

        for (const [productId, info] of productReturnMap) {
          // Find the SCHEDULED cleaning record for this order+product.
          // After prior partial returns, this may be a smaller "remainder" record.
          const scheduledRecord = await cleaningRepository.findScheduledByOrderAndProduct(orderId, productId);
          if (!scheduledRecord.success || !scheduledRecord.data) continue;

          const record = scheduledRecord.data;
          const totalQty = info.quantity;
          const returnedQty = info.returnedQuantity;

          if (returnedQty >= totalQty) {
            // ALL units returned → transition the entire record to in_progress
            await cleaningRepository.update(record.id, {
              status: CleaningStatus.IN_PROGRESS,
              started_at: new Date().toISOString(),
              quantity: record.quantity, // keep the record's quantity as-is
              notes: record.notes
                ? `${record.notes} — all items returned, cleaning started`
                : 'All items returned, cleaning started',
            });
          } else {
            // PARTIAL return → split the cleaning record
            // Calculate how many items were just returned in this batch
            // The scheduled record's quantity represents items still waiting.
            // We need to figure out how many of those are now returned.
            const justReturnedQty = Math.min(returnedQty, record.quantity);
            const remainingQty = record.quantity - justReturnedQty;

            if (justReturnedQty > 0) {
              // Update existing record: cover the returned items, start cleaning
              await cleaningRepository.update(record.id, {
                status: CleaningStatus.IN_PROGRESS,
                started_at: new Date().toISOString(),
                quantity: justReturnedQty,
                notes: record.notes
                  ? `${record.notes} — partial return (${justReturnedQty} of ${totalQty}), cleaning started`
                  : `Partial return (${justReturnedQty} of ${totalQty}), cleaning started`,
              });

              // Create a new scheduled record for the remaining items
              if (remainingQty > 0) {
                await cleaningRepository.create({
                  product_id: productId,
                  order_id: orderId,
                  branch_id: result.data.branch_id,
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
        }
      } catch (err) {
        console.error('Failed to transition cleaning records:', err);
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

    const itemsDone = order.status === OrderStatus.RETURNED;
    const paymentDone = order.payment_status === PaymentStatus.PAID;

    if (itemsDone && paymentDone) {
      await orderRepository.update(orderId, { status: OrderStatus.COMPLETED } as any);
      // Add status history entry
      await orderRepository.addStatusHistory(orderId, OrderStatus.COMPLETED, 'Auto-completed: items returned + payment settled');
    }
  }

  /**
   * Transition all overdue orders (ongoing/in_use past end_date) to late_return.
   * Called by:
   *   1. Vercel Cron Job (daily)
   *   2. On-read when the orders list is fetched (lazy fallback)
   *
   * @returns Number of orders transitioned
   */
  async transitionOverdueOrders(): Promise<number> {
    return await orderRepository.transitionOverdueToLateReturn();
  }
}

// Singleton instance
export const orderService = new OrderService();
