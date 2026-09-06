/**
 * Payment Service
 *
 * Business logic layer for payment entities.
 *
 * @module services/paymentService
 */

import { RepositoryResult } from '@/repository';
import { 
  Payment, 
  CreatePaymentDTO, 
  UpdatePaymentDTO,
  PaymentSearchParams,
  PaymentType,
  PaymentMode
} from '@/domain/types/payment';
import { paymentRepository } from '@/repository';
import { dashboardService } from './dashboardService';

export class PaymentService {
  private currentUserId: string | null = null;
  private currentBranchId: string | null = null;

  /**
   * Set user context for audit logging
   */
  setUserContext(userId: string | null, branchId: string | null): void {
    this.currentUserId = userId;
    this.currentBranchId = branchId;
  }

  /**
   * Get a payment by ID
   */
  async getPayment(id: string): Promise<RepositoryResult<Payment>> {
    return await paymentRepository.findById(id);
  }

  /**
   * Get all payments for an order
   */
  async getPaymentsByOrder(orderId: string): Promise<RepositoryResult<Payment[]>> {
    return await paymentRepository.findByOrderId(orderId);
  }

  /**
   * Get all payments with search parameters
   */
  async getAllPayments(params: PaymentSearchParams = {}): Promise<RepositoryResult<Payment[]>> {
    return await paymentRepository.findAll(params);
  }

  /**
   * Create a new payment
   */
  async createPayment(data: CreatePaymentDTO): Promise<RepositoryResult<Payment>> {
    // Validate amount
    if (data.amount <= 0) {
      return {
        data: null,
        error: {
          message: 'Payment amount must be greater than 0',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    // Validate payment mode
    if (!Object.values(PaymentMode).includes(data.payment_mode)) {
      return {
        data: null,
        error: {
          message: 'Invalid payment mode',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    // Validate payment type
    if (!Object.values(PaymentType).includes(data.payment_type)) {
      return {
        data: null,
        error: {
          message: 'Invalid payment type',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    // Block non-refund payments for cancelled/completed orders
    if (data.payment_type !== PaymentType.REFUND) {
      const { orderRepository } = await import('@/repository');
      const orderCheck = await orderRepository.findById(data.order_id);
      if (orderCheck.success && orderCheck.data) {
        const orderStatus = orderCheck.data.status;
        if (orderStatus === 'completed' || orderStatus === 'cancelled') {
          return {
            data: null,
            error: { message: `Cannot collect payment for a ${orderStatus} order`, code: 'ORDER_FINALIZED' } as any,
            success: false,
          };
        }
      }
    }

    // For refund payments, validate amount does not exceed what's refundable
    if (data.payment_type === PaymentType.REFUND) {
      const { orderRepository } = await import('@/repository');
      const orderResult = await orderRepository.findById(data.order_id);
      if (!orderResult.success || !orderResult.data) {
        return {
          data: null,
          error: { message: 'Order not found', code: 'ORDER_NOT_FOUND' } as any,
          success: false,
        };
      }
      const order = orderResult.data;
      // Total refundable = amount already paid
      const totalRefundable = order.amount_paid || 0;
      if (data.amount > totalRefundable) {
        return {
          data: null,
          error: { message: `Refund amount (${data.amount}) exceeds total refundable (${totalRefundable})`, code: 'VALIDATION_ERROR' } as any,
          success: false,
        };
      }
    }

    paymentRepository.setUserContext(this.currentUserId, this.currentBranchId);
    const result = await paymentRepository.create(data);

    // Invalidate dashboard cache on payment registration
    if (result.success) {
      try {
        dashboardService.clearCache();
      } catch (err) {
        console.error('Failed to clear dashboard cache:', err);
      }
    }

    // Reconcile the order's amount_paid / payment_status from the payments
    // table (the source of truth) after ANY money-moving payment. Without
    // this, payments recorded through the return modal or the mobile app
    // leave `orders.amount_paid` stale — fully-paid orders then sit in
    // payment_status='partial', never auto-complete, and show up as phantom
    // "Revenue Due" on the revenue report.
    if (result.success && result.data && data.payment_type !== PaymentType.ADJUSTMENT) {
      try {
        await this.syncOrderPaymentStatus(data.order_id);
      } catch (err) {
        console.error('Failed to sync order payment status:', err);
      }
    }

    // After any non-refund, non-adjustment payment, check auto-complete
    if (result.success && data.payment_type !== PaymentType.REFUND && data.payment_type !== PaymentType.ADJUSTMENT) {
      try {
        const { orderService } = await import('./orderService');
        await orderService.checkAndAutoComplete(data.order_id);
      } catch {
        // Auto-complete is best-effort, don't fail the payment
      }
    }

    return result;
  }

  /**
   * Update a payment
   */
  async updatePayment(id: string, data: UpdatePaymentDTO): Promise<RepositoryResult<Payment>> {
    // Validate payment mode if provided
    if (data.payment_mode && !Object.values(PaymentMode).includes(data.payment_mode)) {
      return {
        data: null,
        error: {
          message: 'Invalid payment mode',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    // Validate amount if provided
    if (data.amount !== undefined && data.amount <= 0) {
      return {
        data: null,
        error: {
          message: 'Payment amount must be greater than 0',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    paymentRepository.setUserContext(this.currentUserId, this.currentBranchId);
    const result = await paymentRepository.update(id, data);
    if (result.success && result.data) {
      try {
        await this.syncOrderPaymentStatus(result.data.order_id);
      } catch (err) {
        console.error('Failed to sync order payment status:', err);
      }
      try {
        dashboardService.clearCache();
      } catch (err) {
        console.error('Failed to clear dashboard cache:', err);
      }
    }
    return result;
  }

  /**
   * Delete a payment
   */
  async deletePayment(id: string): Promise<RepositoryResult<boolean>> {
    const paymentCheck = await paymentRepository.findById(id);
    const result = await paymentRepository.delete(id);
    if (result.success) {
      if (paymentCheck.success && paymentCheck.data) {
        try {
          await this.syncOrderPaymentStatus(paymentCheck.data.order_id);
        } catch (err) {
          console.error('Failed to sync order payment status:', err);
        }
      }
      try {
        dashboardService.clearCache();
      } catch (err) {
        console.error('Failed to clear dashboard cache:', err);
      }
    }
    return result;
  }

  /**
   * Get total payments for an order
   */
  async getTotalForOrder(orderId: string): Promise<RepositoryResult<number>> {
    return await paymentRepository.getTotalForOrder(orderId);
  }


  /**
   * Get final payment for an order
   */
  async getFinalPayment(orderId: string): Promise<RepositoryResult<Payment | null>> {
    const result = await paymentRepository.findByOrderId(orderId);
    if (!result.success) {
      return { data: null, error: result.error, success: false };
    }

    const final = (result.data || []).find(
      (p: Payment) => p.payment_type === PaymentType.FINAL
    );

    return { data: final || null, error: null, success: true };
  }

  async syncOrderPaymentStatus(orderId: string): Promise<void> {
    const { orderRepository } = await import('@/repository');
    const paymentsResult = await paymentRepository.findByOrderId(orderId);
    const orderResult = await orderRepository.findById(orderId);
    if (paymentsResult.success && paymentsResult.data && orderResult.success && orderResult.data) {
      const order = orderResult.data;
      const newAmountPaid = paymentsResult.data.reduce((sum, p) => {
        if (p.payment_type === PaymentType.REFUND) {
          return sum - p.amount;
        }
        return sum + p.amount;
      }, 0);
      const clampedAmountPaid = Math.max(0, newAmountPaid);
      const newPaymentStatus = clampedAmountPaid >= order.total_amount ? 'paid' : clampedAmountPaid > 0 ? 'partial' : 'pending';
      
      // Only perform update and checks if values have changed to prevent infinite loops
      if (order.amount_paid !== clampedAmountPaid || order.payment_status !== newPaymentStatus) {
        await orderRepository.update(orderId, {
          amount_paid: clampedAmountPaid,
          payment_status: newPaymentStatus,
        } as any);

        // Check if the status needs to be auto-completed (since payment status changed)
        try {
          const { orderService } = await import('./orderService');
          await orderService.checkAndAutoComplete(orderId);
        } catch (err) {
          console.error('[paymentService.syncOrderPaymentStatus] Failed to check and auto-complete order:', err);
        }
      }
    }
  }
}

// Singleton instance
export const paymentService = new PaymentService();
