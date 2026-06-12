/**
 * Orders Payments API Route
 * GET  /api/orders/[id]/payments — list payments for a specific order
 * POST /api/orders/[id]/payments — create a payment for a specific order
 */

import { NextRequest } from 'next/server';
import { paymentService } from '@/services/paymentService';
import { apiGuard } from '@/lib/apiGuard';
import { getAuthUser } from '@/lib/auth';
import { apiSuccess, apiRepositoryError, apiInternalError } from '@/lib/apiResponse';

interface RouteContext {
  params: Promise<{ id: string }>;
}

export async function GET(request: NextRequest, { params }: RouteContext) {
  try {
    const guard = await apiGuard(request, 'orders');
    if (guard.error) return guard.error;

    const { id: orderId } = await params;
    const result = await paymentService.getPaymentsByOrder(orderId);
    if (!result.success) {
      return apiRepositoryError(result.error, 'Failed to fetch payments');
    }
    return apiSuccess(result.data);
  } catch (error: any) {
    console.error('[API] GET /api/orders/[id]/payments error:', error);
    return apiInternalError(error.message || 'Internal server error');
  }
}

export async function POST(request: NextRequest, { params }: RouteContext) {
  try {
    const guard = await apiGuard(request, 'orders');
    if (guard.error) return guard.error;

    const authUser = await getAuthUser(request);
    paymentService.setUserContext(authUser?.staff_id || null, authUser?.branch_id || null);

    const { id: orderId } = await params;
    const body = await request.json();
    
    const result = await paymentService.createPayment({
      ...body,
      order_id: orderId,
    });
    
    if (!result.success || !result.data) {
      return apiRepositoryError(result.error, 'Failed to create payment');
    }
    return apiSuccess(result.data, { status: 201, message: 'Payment recorded successfully' });
  } catch (error: any) {
    console.error('[API] POST /api/orders/[id]/payments error:', error);
    return apiInternalError(error.message || 'Internal server error');
  }
}
