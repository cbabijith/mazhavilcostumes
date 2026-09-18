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

/** Round to the paisa so float drift never decides a money comparison. */
const round2 = (n: number) => Math.round(n * 100) / 100;
/** Half a paisa — anything smaller than this is float noise, not money. */
const MONEY_EPSILON = 0.005;
/** ₹100 not ₹100.00 — staff-facing amounts in validation messages. */
const fmt = (n: number) => `₹${Number(n.toFixed(2))}`;

export class PaymentService {
  private currentUserId: string | null = null;
  private currentBranchId: string | null = null;

  /**
   * Total money collected on an order, computed from the payments table
   * (the source of truth — `orders.amount_paid` is a synced copy).
   * Mirrors syncOrderPaymentStatus: refunds subtract, everything else adds.
   */
  private async getPaidAmount(orderId: string, excludePaymentId?: string): Promise<number | null> {
    const paymentsResult = await paymentRepository.findByOrderId(orderId);
    if (!paymentsResult.success || !paymentsResult.data) return null;
    const paidRaw = paymentsResult.data
      .filter((p) => p.id !== excludePaymentId)
      .reduce((sum, p) => {
        return p.payment_type === PaymentType.REFUND
          ? sum - Number(p.amount)
          : sum + Number(p.amount);
      }, 0);
    return Math.max(0, round2(paidRaw));
  }

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
    // Coerce once — JSON bodies can carry "100" as a string, which would make
    // the comparisons below compare strings instead of money.
    const amount = Number(data.amount);
    const payload: CreatePaymentDTO = { ...data, amount };

    // Validate amount
    if (!Number.isFinite(amount) || amount <= 0) {
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
    if (!Object.values(PaymentMode).includes(payload.payment_mode)) {
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
    if (!Object.values(PaymentType).includes(payload.payment_type)) {
      return {
        data: null,
        error: {
          message: 'Invalid payment type',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    // ── Order-level guard (fails CLOSED — an unreadable order must not
    //    accept money). One order fetch serves the status check, the due
    //    ceiling and the refund cap.
    const { orderRepository } = await import('@/repository');
    const orderResult = await orderRepository.findById(payload.order_id);
    if (!orderResult.success || !orderResult.data) {
      return {
        data: null,
        error: { message: 'Order not found', code: 'ORDER_NOT_FOUND' } as any,
        success: false,
      };
    }
    const order = orderResult.data;

    if (payload.payment_type === PaymentType.REFUND) {
      // Refunds stay allowed on any order status (manual cancel-refund flow),
      // but can never return more money than was actually collected.
      const paid = await this.getPaidAmount(payload.order_id);
      if (paid === null) {
        return {
          data: null,
          error: { message: 'Could not verify collected amount — payment blocked', code: 'PAYMENT_STATE_UNKNOWN' } as any,
          success: false,
        };
      }
      if (amount > paid + MONEY_EPSILON) {
        return {
          data: null,
          error: {
            message: `Refund of ${fmt(amount)} exceeds the total collected (${fmt(paid)})`,
            code: 'VALIDATION_ERROR'
          } as any,
          success: false,
        };
      }
    } else {
      // Block collections for cancelled/completed orders (refunds excluded above).
      if (order.status === 'completed' || order.status === 'cancelled') {
        return {
          data: null,
          error: { message: `Cannot collect payment for a ${order.status} order`, code: 'ORDER_FINALIZED' } as any,
          success: false,
        };
      }

      // Due ceiling — the core overpayment guard. Staff (or a stale UI/mobile
      // screen) must not be able to collect money beyond the outstanding
      // balance, and never on a fully-paid order. Computed from the payments
      // table, not the synced `orders.amount_paid` copy, so a stale sync can't
      // re-open a closed order. ADJUSTMENT rows are memo entries that don't
      // move money (see syncOrderPaymentStatus) so they skip this ceiling.
      if (payload.payment_type !== PaymentType.ADJUSTMENT) {
        const paid = await this.getPaidAmount(payload.order_id);
        if (paid === null) {
          return {
            data: null,
            error: { message: 'Could not verify outstanding balance — payment blocked', code: 'PAYMENT_STATE_UNKNOWN' } as any,
            success: false,
          };
        }
        const due = round2(Number(order.total_amount) - paid);
        if (due <= MONEY_EPSILON) {
          return {
            data: null,
            error: {
              message: `This order is already fully paid — ${fmt(paid)} collected of ${fmt(Number(order.total_amount))}. No balance is left to collect.`,
              code: 'PAYMENT_ALREADY_SETTLED'
            } as any,
            success: false,
          };
        }
        if (amount > due + MONEY_EPSILON) {
          return {
            data: null,
            error: {
              message: `Payment of ${fmt(amount)} exceeds the outstanding balance of ${fmt(due)}. Maximum collectable now is ${fmt(due)}.`,
              code: 'PAYMENT_EXCEEDS_DUE'
            } as any,
            success: false,
          };
        }
      }
    }

    paymentRepository.setUserContext(this.currentUserId, this.currentBranchId);
    const result = await paymentRepository.create(payload);

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
    if (result.success && result.data && payload.payment_type !== PaymentType.ADJUSTMENT) {
      try {
        await this.syncOrderPaymentStatus(payload.order_id);
      } catch (err) {
        console.error('Failed to sync order payment status:', err);
      }
    }

    // After any non-refund, non-adjustment payment, check auto-complete
    if (result.success && payload.payment_type !== PaymentType.REFUND && payload.payment_type !== PaymentType.ADJUSTMENT) {
      try {
        const { orderService } = await import('./orderService');
        await orderService.checkAndAutoComplete(payload.order_id);
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

    // Validate amount if provided. Zero is allowed on EDITS — zeroing a
    // collected payment (keeping the row as an audit trail) is a supported
    // correction. Creation still requires a positive amount.
    if (data.amount !== undefined && data.amount < 0) {
      return {
        data: null,
        error: {
          message: 'Payment amount cannot be negative',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    // Due ceiling on edits: increasing a payment must not push the order past
    // fully-paid (the same guard createPayment enforces). Decreasing stays
    // allowed — that's how mistyped amounts get corrected.
    if (data.amount !== undefined) {
      const newAmount = Number(data.amount);
      const existingRes = await paymentRepository.findById(id);
      if (existingRes.success && existingRes.data) {
        const row = existingRes.data;
        // The ceiling only applies to INCREASES — collecting more through an
        // edit. Decreases (including zeroing a payment to ₹0) always make the
        // balance safer and must stay allowed even on already-overpaid orders.
        const isIncrease = newAmount > Number(row.amount) + MONEY_EPSILON;
        if (isIncrease && row.payment_type !== PaymentType.ADJUSTMENT) {
          const { orderRepository } = await import('@/repository');
          const orderResult = await orderRepository.findById(row.order_id);
          if (orderResult.success && orderResult.data) {
            // Balance with this row excluded — the row is being replaced.
            const paidWithoutThis = await this.getPaidAmount(row.order_id, row.id);
            if (paidWithoutThis !== null) {
              if (row.payment_type === PaymentType.REFUND) {
                if (newAmount > paidWithoutThis + MONEY_EPSILON) {
                  return {
                    data: null,
                    error: {
                      message: `Refund of ${fmt(newAmount)} exceeds the total collected (${fmt(paidWithoutThis)})`,
                      code: 'VALIDATION_ERROR'
                    } as any,
                    success: false,
                  };
                }
              } else {
                const due = round2(Number(orderResult.data.total_amount) - paidWithoutThis);
                if (newAmount > due + MONEY_EPSILON) {
                  return {
                    data: null,
                    error: {
                      message: `Payment of ${fmt(newAmount)} exceeds the outstanding balance of ${fmt(Math.max(0, due))}. Maximum collectable now is ${fmt(Math.max(0, due))}.`,
                      code: 'PAYMENT_EXCEEDS_DUE'
                    } as any,
                    success: false,
                  };
                }
              }
            }
          }
        }
      }
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
