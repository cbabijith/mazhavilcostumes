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
  PaymentMode,
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
    paymentRepository.setUserContext(userId, branchId);
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
          code: 'VALIDATION_ERROR',
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
          code: 'VALIDATION_ERROR',
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
          code: 'VALIDATION_ERROR',
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
            error: {
              message: `Cannot collect payment for a ${orderStatus} order`,
              code: 'ORDER_FINALIZED',
            } as any,
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
      const isDepositRefund = data.notes && /deposit|security/i.test(data.notes);

      if (isDepositRefund) {
        // Fetch all payments to see how much deposit has been refunded already
        const paymentsResult = await paymentRepository.findByOrderId(data.order_id);
        const existingRefundedDeposit =
          paymentsResult.success && paymentsResult.data
            ? paymentsResult.data
                .filter(
                  (p) =>
                    p.payment_type === PaymentType.REFUND &&
                    p.notes &&
                    /deposit|security/i.test(p.notes)
                )
                .reduce((sum, p) => sum + p.amount, 0)
            : 0;

        const totalRefundable = (order.security_deposit || 0) - existingRefundedDeposit;
        if (data.amount > totalRefundable) {
          return {
            data: null,
            error: {
              message: `Refund amount (${data.amount}) exceeds remaining security deposit refundable (${totalRefundable})`,
              code: 'VALIDATION_ERROR',
            } as any,
            success: false,
          };
        }
      } else {
        // Regular rental payment refund
        const totalRefundable = order.amount_paid || 0;
        if (data.amount > totalRefundable) {
          return {
            data: null,
            error: {
              message: `Refund amount (${data.amount}) exceeds total refundable (${totalRefundable})`,
              code: 'VALIDATION_ERROR',
            } as any,
            success: false,
          };
        }
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

    // Recalculate and update order totals and payment status
    if (result.success && result.data) {
      try {
        await this.syncOrderPaymentStatus(data.order_id);
      } catch (err) {
        console.error('Failed to sync order payment status:', err);
      }
    }

    // After any non-refund, non-adjustment payment, check auto-complete
    if (
      result.success &&
      data.payment_type !== PaymentType.REFUND &&
      data.payment_type !== PaymentType.ADJUSTMENT
    ) {
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
          code: 'VALIDATION_ERROR',
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
          code: 'VALIDATION_ERROR',
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
  async deletePayment(id: string): Promise<RepositoryResult<Payment>> {
    const paymentCheck = await paymentRepository.findById(id);
    if (!paymentCheck.success || !paymentCheck.data) {
      return {
        data: null,
        error: paymentCheck.error || ({ message: 'Payment not found' } as any),
        success: false,
      };
    }
    const result = await paymentRepository.delete(id);
    if (result.success) {
      try {
        await this.syncOrderPaymentStatus(paymentCheck.data.order_id);
      } catch (err) {
        console.error('Failed to sync order payment status:', err);
      }
      try {
        dashboardService.clearCache();
      } catch (err) {
        console.error('Failed to clear dashboard cache:', err);
      }
      return { data: paymentCheck.data, error: null, success: true };
    }
    return { data: null, error: result.error, success: false };
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

    const final = (result.data || []).find((p: Payment) => p.payment_type === PaymentType.FINAL);

    return { data: final || null, error: null, success: true };
  }

  /**
   * Synchronize order payment status and amount paid based on current payments.
   * Also synchronizes security deposit collection and return status.
   */
  async syncOrderPaymentStatus(orderId: string): Promise<void> {
    const { orderRepository } = await import('@/repository');
    orderRepository.setUserContext(this.currentUserId, this.currentBranchId);
    
    const paymentsResult = await paymentRepository.findByOrderId(orderId);
    const orderResult = await orderRepository.findById(orderId);
    if (paymentsResult.success && paymentsResult.data && orderResult.success && orderResult.data) {
      const order = orderResult.data;

      // 1. Calculate amount_paid (excluding security deposits and deposit refunds)
      const newAmountPaid = paymentsResult.data.reduce((sum, p) => {
        if (p.payment_type === PaymentType.DEPOSIT) {
          return sum;
        }
        if (p.payment_type === PaymentType.REFUND) {
          const isDepositRefund = p.notes && /deposit|security/i.test(p.notes);
          if (isDepositRefund) {
            return sum;
          }
          return sum - p.amount;
        }
        return sum + p.amount;
      }, 0);
      const clampedAmountPaid = Math.max(0, newAmountPaid);

      // 2. Calculate payment status
      const newPaymentStatus =
        clampedAmountPaid >= order.total_amount
          ? 'paid'
          : clampedAmountPaid > 0
            ? 'partial'
            : 'pending';

      // 3. Calculate deposit details (total security deposit payments collected)
      const depositPayments = paymentsResult.data.filter(
        (p) => p.payment_type === PaymentType.DEPOSIT
      );
      const totalDeposit = depositPayments.reduce((sum, p) => sum + p.amount, 0);
      const hasDeposit = depositPayments.length > 0;

      // 4. Calculate if deposit is returned
      const refundPayments = paymentsResult.data.filter(
        (p) => p.payment_type === PaymentType.REFUND
      );
      const depositRefunds = refundPayments.filter(
        (p) => p.notes && /deposit|security/i.test(p.notes)
      );
      const totalDepositRefunded = depositRefunds.reduce((sum, p) => sum + p.amount, 0);
      // Deposit is fully returned if the refunded amount matches or exceeds what was collected
      const isDepositReturned = hasDeposit && totalDepositRefunded >= totalDeposit;

      // 5. Build updates for order
      const updateData: any = {
        amount_paid: clampedAmountPaid,
        payment_status: newPaymentStatus,
      };

      if (hasDeposit) {
        updateData.security_deposit = totalDeposit;
        updateData.deposit_collected = true;
        if (!order.deposit_collected_at) {
          updateData.deposit_collected_at = new Date().toISOString();
        }
      } else {
        // If they deleted all deposit payments, mark as not collected
        updateData.deposit_collected = false;
        updateData.deposit_collected_at = null;
      }

      if (isDepositReturned) {
        updateData.deposit_returned = true;
        if (!order.deposit_returned_at) {
          updateData.deposit_returned_at = new Date().toISOString();
        }
      } else {
        updateData.deposit_returned = false;
        updateData.deposit_returned_at = null;
      }

      await orderRepository.update(orderId, updateData as any);
    }
  }
}

// Singleton instance
export const paymentService = new PaymentService();
