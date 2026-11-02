/**
 * Orders Discount API Route
 *
 * PATCH /api/orders/:id/discount — set / edit / remove the order's SINGLE discount.
 *
 * Body (JSON): { amount: number (₹, 0 removes the discount), notes?: string }
 *
 * One discount per order: a new value REPLACES the previous one (no stacking).
 * The order total is recomputed and payment status re-derived; the change is
 * written to the status history for audit.
 *
 * @module app/api/orders/[id]/discount/route
 */

import { NextRequest } from 'next/server';
import { orderService } from '@/services/orderService';
import { apiGuard } from '@/lib/apiGuard';
import { apiSuccess, apiBadRequest, apiRepositoryError, apiInternalError } from '@/lib/apiResponse';

interface RouteContext {
  params: Promise<{ id: string }>;
}

export async function PATCH(request: NextRequest, { params }: RouteContext) {
  try {
    const guard = await apiGuard(request, 'orders');
    if (guard.error) return guard.error;

    const { id } = await params;
    const body = await request.json();

    if (typeof body?.amount !== 'number' || !Number.isFinite(body.amount)) {
      return apiBadRequest('amount (number, ₹) is required — send 0 to remove the discount.');
    }
    if (body.notes !== undefined && typeof body.notes !== 'string') {
      return apiBadRequest('notes must be a string.');
    }

    const result = await orderService.setOrderDiscount(id, body.amount, body.notes, guard.user?.staff_id || null);
    if (!result.success || !result.data) {
      return apiRepositoryError(result.error, 'Failed to set discount');
    }
    return apiSuccess(result.data, { message: body.amount > 0 ? `Discount set to ₹${body.amount}` : 'Discount removed' });
  } catch (error: any) {
    console.error('[API] PATCH /api/orders/[id]/discount error:', error);
    return apiInternalError(error.message || 'Internal server error');
  }
}
