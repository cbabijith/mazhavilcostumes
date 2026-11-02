import { NextRequest } from 'next/server';
import { orderService } from '@/services';
import { ApiTiming } from '@/lib/apiTiming';
import { apiSuccess, apiError, apiUnauthorized, apiBadRequest } from '@/lib/apiResponse';
import { getAuthUser } from '@/lib/auth';

export async function GET(request: NextRequest) {
  const timing = new ApiTiming();
  try {
    const authUser = await getAuthUser(request);
    if (!authUser) {
      return apiUnauthorized();
    }
    timing.mark('auth');

    const { searchParams } = new URL(request.url);
    const startDate = searchParams.get('start_date');
    const endDate = searchParams.get('end_date');
    const branchId = searchParams.get('branch_id');

    if (!startDate || !endDate || !branchId) {
      return apiBadRequest('Missing required parameters: start_date, end_date, branch_id');
    }

    const canSwitchBranches = authUser.role === 'admin' || authUser.role === 'super_admin';
    if (!canSwitchBranches && branchId !== authUser.branch_id) {
      return apiError('Access denied for this branch', { status: 403 });
    }
    const result = await orderService.getCalendarOrders(branchId, startDate, endDate, searchParams.get('summary') === 'true');
    timing.mark('data');

    if (!result.success) {
      return apiError(result.error?.message || 'Failed to fetch calendar orders');
    }

    return timing.attach(apiSuccess(result.data || []));
  } catch (error) {
    console.error('Calendar API Error:', error);
    return apiError('Internal server error', { status: 500 });
  }
}
