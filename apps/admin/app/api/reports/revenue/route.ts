import { NextRequest } from 'next/server';
import { reportService } from '@/services';
import { apiSuccess, apiBadRequest, apiInternalError } from '@/lib/apiResponse';
import { apiGuard } from '@/lib/apiGuard';

/**
 * Revenue Report API Route
 * 
 * Fetches revenue metrics on the server to bypass RLS issues 
 * and use the SERVICE_ROLE_KEY safely.
 */
export async function GET(request: NextRequest) {
  try {
    // 1. Secure the endpoint
    const guard = await apiGuard(request, 'reports');
    if (guard.error) return guard.error;

    // 2. Parse query parameters
    const { searchParams } = new URL(request.url);
    const fromDate = searchParams.get('fromDate');
    const toDate = searchParams.get('toDate');
    const branchId = searchParams.get('branchId') || undefined;
    const storeId = searchParams.get('storeId') || undefined;
    const statusFilter = searchParams.get('statusFilter') || undefined;
    const page = Number(searchParams.get('page') ?? 1);
    const limit = Number(searchParams.get('limit') ?? 50);
    const paymentMode = searchParams.get('payment_mode') || undefined;

    if (!fromDate || !toDate) {
      return apiBadRequest('Missing required date parameters');
    }

    if (!Number.isSafeInteger(page) || page < 1 || !Number.isSafeInteger(limit) || limit < 1 || limit > 500 || !Number.isSafeInteger(page * limit)) {
      return apiBadRequest('Page must be a positive integer and limit must be between 1 and 500');
    }

    // 3. Fetch data using the service (which uses adminClient on server)
    const reportData = await reportService.getRevenue(
      {
        from_date: fromDate,
        to_date: toDate,
        status: statusFilter ? statusFilter.split(',') : undefined,
        payment_mode: paymentMode,
        page,
        limit,
      },
      branchId,
      storeId
    );

    return apiSuccess(reportData);
  } catch (error: any) {
    console.error('[RevenueReportAPI] Error:', error);
    return apiInternalError(error.message || 'Failed to fetch revenue report');
  }
}
