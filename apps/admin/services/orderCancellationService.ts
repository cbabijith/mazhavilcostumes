/**
 * Order cancellation validation and orchestration.
 * The repository transaction owns stock, payment and audit consistency.
 * @module services/orderCancellationService
 */
import { CancelOrderSchema, type Order, type UpdateOrderDTO } from '@/domain';
import { orderRepository, type RepositoryResult } from '@/repository';
import { dashboardService } from './dashboardService';
import { PostgrestError } from '@supabase/supabase-js';

export class OrderCancellationService {
  /**
   * Cancel a rental within the authenticated staff member's store/branch.
   * @param id Order ID.
   * @param data Requested reason, refund and physical-return confirmation.
   * @param staffId Verified staff ID from the API guard.
   * @returns Cancelled order or an actionable validation/database error.
   */
  async cancelOrder(id: string, data: UpdateOrderDTO, staffId: string | null): Promise<RepositoryResult<Order>> {
    const parsed = CancelOrderSchema.safeParse(data);
    if (!parsed.success || !staffId) {
      return { data: null, success: false, error: new PostgrestError({
        code: staffId ? 'VALIDATION_ERROR' : '42501',
        message: staffId ? parsed.error?.issues[0]?.message || 'Invalid cancellation' : 'An authenticated staff account is required',
        details: '', hint: '',
      }) };
    }
    // Cancellation cannot be combined with unrelated edits to prices or items.
    const allowed = new Set(['status', 'cancellation_reason', 'cancelled_at', 'refund_amount', 'refund_payment_mode', 'stock_returned']);
    if (Object.keys(data).some(key => !allowed.has(key))) {
      return { data: null, success: false, error: new PostgrestError({
        code: 'VALIDATION_ERROR', message: 'Submit cancellation separately from other order changes',
        details: '', hint: '',
      }) };
    }
    const result = await orderRepository.cancelOrder(id, parsed.data, staffId);
    if (result.success) dashboardService.clearCache();
    return result;
  }
}

export const orderCancellationService = new OrderCancellationService();
