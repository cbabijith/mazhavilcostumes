import { NextRequest } from 'next/server';
import { apiGuard } from '@/lib/apiGuard';
import { apiInternalError, apiSuccess } from '@/lib/apiResponse';
import { dashboardService } from '@/services/dashboardService';

export async function GET(request: NextRequest) {
  try {
    const guard = await apiGuard(request, 'dashboard');
    if (guard.error) return guard.error;

    const searchParams = request.nextUrl.searchParams;
    const requestedBranchId = searchParams.get('branch_id') || undefined;
    const canSwitchBranches = guard.user.role === 'super_admin' || guard.user.role === 'admin';
    const branchId = canSwitchBranches ? requestedBranchId : guard.user.branch_id || undefined;

    // Call the unified dashboard service to ensure consistent calculations and URLs
    const metrics = await dashboardService.getOperationalMetrics(branchId);

    return apiSuccess(metrics);
  } catch (error) {
    console.error('Error fetching operational metrics:', error);
    return apiInternalError('Failed to fetch operational metrics');
  }
}
