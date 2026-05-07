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
import { orderRepository } from '@/repository';
import { settingsService } from './settingsService';
import { cleaningService } from './cleaningService';
import { CleaningPriority } from '@/domain';

export class OrderService {
  private currentUserId: string | null = null;
  private currentBranchId: string | null = null;

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
  async checkAvailability(productId: string, startDate: string, endDate: string, branchId?: string, excludeOrderId?: string, bufferOverride: boolean = false): Promise<RepositoryResult<{ available: number; total: number; peakReserved: number; overlappingOrders: any[]; adjacentOrders: any[] }>> {
    return await orderRepository.checkAvailability(productId, startDate, endDate, branchId, excludeOrderId, bufferOverride);
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

    // Validate items
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
      
      const bufferOverride = !!(data as any).buffer_override;
      const availCheck = await this.checkAvailability(item.product_id, data.rental_start_date, data.rental_end_date, data.branch_id, undefined, bufferOverride);
      if (!availCheck.success) {
        return {
          data: null,
          error: availCheck.error,
          success: false
        };
      }
      if (availCheck.data!.available < item.quantity) {
        return {
          data: null,
          error: { message: `Insufficient availability for product. Only ${availCheck.data!.available} available.`, code: 'VALIDATION_ERROR' } as any,
          success: false
        };
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

    return await orderRepository.create(data, isGstEnabled, perItemGstRates);
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

    return result;
  }

  /**
   * Delete an order
   */
  async deleteOrder(id: string): Promise<RepositoryResult<void>> {
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

    return await orderRepository.delete(id);
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

      // ─── PHASE 2: AUTO-CREATE CLEANING RECORDS ─────────────────────────────────
      try {
        const order = result.data;
        const branchId = order.branch_id;
        
        for (const item of order.items || []) {
          // Check for upcoming Skip Gap orders for this product to mark as URGENT
          // We look for orders starting within the next 3 days (buffer period)
          const now = new Date();
          const threeDaysLater = new Date();
          threeDaysLater.setDate(now.getDate() + 3);

          const { data: upcomingOrders } = await orderRepository.findAll({
            branch_id: branchId,
            product_id: item.product_id,
            status: [OrderStatus.SCHEDULED, OrderStatus.CONFIRMED],
            buffer_override: true,
          });

          // Filter for those starting very soon (in the buffer overlap)
          const urgentOrder = (upcomingOrders || []).find(o => {
            const hasProduct = o.items.some(oi => oi.product_id === item.product_id);
            const start = new Date(o.start_date);
            return hasProduct && start >= now && start <= threeDaysLater;
          });

          // ONLY create cleaning records for URGENT items (needed for upcoming Skip Gap bookings)
          // AND only if the product's category requires a buffer.
          const categoryHasBuffer = (item as any).product?.category?.has_buffer ?? true;

          if (urgentOrder && categoryHasBuffer) {
            await cleaningService.createRecord({
              product_id: item.product_id,
              order_id: orderId, // The order being returned
              branch_id: branchId,
              quantity: item.quantity,
              priority: CleaningPriority.URGENT,
              priority_order_id: urgentOrder.id,
              notes: `Needed for urgent Skip Gap Order #${urgentOrder.id.substring(0, 8)}`,
            });
          }
        }
      } catch (err) {
        console.error('Failed to create cleaning records:', err);
        // We don't block the return process if cleaning record creation fails
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
