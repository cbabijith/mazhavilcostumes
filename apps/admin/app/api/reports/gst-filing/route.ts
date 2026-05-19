import { NextRequest } from 'next/server';
import { reportService } from '@/services/reportService';
import { settingsService } from '@/services/settingsService';
import { apiGuard } from '@/lib/apiGuard';
import { getAuthUser } from '@/lib/auth';
import { apiSuccess, apiBadRequest, apiInternalError } from '@/lib/apiResponse';
import { ReportFilters } from '@/domain';

/**
 * GET /api/reports/gst-filing
 * 
 * Fetches the GST filing report (R12) for a given period.
 */
export async function GET(request: NextRequest) {
  try {
    // 1. Secure the endpoint
    const guard = await apiGuard(request, 'reports');
    if (guard.error) return guard.error;

    // 2. Set the real store_id from the authenticated user
    const authUser = await getAuthUser(request);
    if (authUser?.store_id) {
      settingsService.setStoreId(authUser.store_id);
    }

    const { searchParams } = new URL(request.url);
    
    const statusParam = searchParams.get('status');
    const filters: ReportFilters = {
      from_date: searchParams.get('from_date') || undefined,
      to_date: searchParams.get('to_date') || undefined,
      period: (searchParams.get('period') as any) || 'month',
      status: statusParam ? statusParam.split(',') : undefined
    };

    const report = await reportService.getGSTFilingReport(filters);

    return apiSuccess(report);
  } catch (error: any) {
    console.error('GST Filing Report Error:', error);
    return apiInternalError(error.message || 'Failed to fetch GST filing report');
  }
}
