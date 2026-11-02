/**
 * Payment API Route (Individual)
 * GET    /api/payments/:id — get a single payment
 * PATCH  /api/payments/:id — update a payment
 * DELETE /api/payments/:id — delete a payment
 */

import { NextRequest } from 'next/server';
import { paymentService } from '@/services/paymentService';
import { adminOnly, apiGuard } from '@/lib/apiGuard';
import { apiSuccess, apiBadRequest, apiRepositoryError, apiNotFound, apiInternalError } from '@/lib/apiResponse';
import { PaymentMode } from '@/domain';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const guard = await adminOnly(request);
    if (guard.error) return guard.error;

    const { id } = await params;
    const result = await paymentService.getPayment(id);
    if (!result.success || !result.data) {
      return apiNotFound('Payment');
    }
    return apiSuccess(result.data);
  } catch (error: any) {
    console.error('[API] GET /api/payments/:id error:', error);
    return apiInternalError(error.message || 'Internal server error');
  }
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    // Orders-module permission (admin/manager/staff), NOT adminOnly: staff
    // correcting a payment's mode (cash <-> UPI) on the shop floor was
    // getting 403 — the "payment type change not working" complaint. Field
    // whitelist below keeps this to mode/transaction/notes/amount.
    const guard = await apiGuard(request, 'orders');
    if (guard.error) return guard.error;

    const authUser = guard.user;
    paymentService.setUserContext(authUser?.staff_id || null, authUser?.branch_id || null);

    const { id } = await params;
    const body = await request.json();

    const allowed = ['payment_mode', 'transaction_id', 'notes', 'amount'] as const;
    const unknown = Object.keys(body || {}).filter((k) => !(allowed as readonly string[]).includes(k));
    if (unknown.length > 0) {
      return apiBadRequest(`Fields not allowed: ${unknown.join(', ')}`);
    }
    if (body.payment_mode !== undefined && !Object.values(PaymentMode).includes(body.payment_mode)) {
      return apiBadRequest(`Invalid payment mode. Allowed: ${Object.values(PaymentMode).join(', ')}.`);
    }

    const result = await paymentService.updatePayment(id, body);

    if (!result.success) {
      return apiRepositoryError(result.error, 'Failed to update payment');
    }
    return apiSuccess(result.data, { message: 'Payment updated successfully' });
  } catch (error: any) {
    console.error('[API] PATCH /api/payments/:id error:', error);
    return apiInternalError(error.message || 'Internal server error');
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const guard = await adminOnly(request);
    if (guard.error) return guard.error;

    const { id } = await params;
    const result = await paymentService.deletePayment(id);

    if (!result.success) {
      return apiRepositoryError(result.error, 'Failed to delete payment');
    }
    return apiSuccess(null, { message: 'Payment deleted successfully' });
  } catch (error: any) {
    console.error('[API] DELETE /api/payments/:id error:', error);
    return apiInternalError(error.message || 'Internal server error');
  }
}
