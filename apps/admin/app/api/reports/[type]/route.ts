/**
 * Reports API Route
 *
 * GET /api/reports/[type]
 * Returns data for the specified report type.
 *
 * @module app/api/reports/[type]/route
 */

import { NextRequest } from 'next/server';
import { apiGuard } from '@/lib/apiGuard';
import { apiSuccess, apiBadRequest, apiInternalError } from '@/lib/apiResponse';
import { reportService } from '@/services/reportService';
import type { ReportType, ReportFilters } from '@/domain';

const VALID_TYPES: ReportType[] = [
  'day-wise-booking', 'due-overdue', 'revenue', 'top-costumes',
  'top-customers', 'rental-frequency', 'roi', 'dead-stock',
  'sales-by-staff', 'inventory-revenue', 'enquiry-log', 'gst-filing',
  'todays-revenue'
];

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ type: string }> }
) {
  try {
    const guard = await apiGuard(request, 'reports');
    if (guard.error) return guard.error;

    const { type } = await params;
    if (!VALID_TYPES.includes(type as ReportType)) {
      return apiBadRequest(`Invalid report type: ${type}`);
    }

    const sp = request.nextUrl.searchParams;
    const filters: ReportFilters = {
      date: sp.get('date') || undefined,
      from_date: sp.get('from_date') || undefined,
      to_date: sp.get('to_date') || undefined,
      period: (sp.get('period') as any) || undefined,
      rank_by: (sp.get('rank_by') as any) || undefined,
      limit: sp.get('limit') ? parseInt(sp.get('limit')!) : undefined,
      page: sp.get('page') ? parseInt(sp.get('page')!) : undefined,
      status: sp.get('status') ? sp.get('status')!.split(',') : undefined,
      payment_mode: sp.get('payment_mode') || undefined,
    };

    const staffId = sp.get('staffId');

    let data: any;
    if (type === 'sales-by-staff' && staffId) {
      data = await reportService.getStaffOrderHistory(staffId, filters);
    } else {
      switch (type as ReportType) {
        case 'day-wise-booking': data = await reportService.getDayWiseBooking(filters); break;
        case 'due-overdue': data = await reportService.getDueOverdue(filters); break;
        case 'revenue': data = await reportService.getRevenue(filters); break;
        case 'top-costumes': data = await reportService.getTopCostumes(filters); break;
        case 'top-customers': data = await reportService.getTopCustomers(filters); break;
        case 'rental-frequency': data = await reportService.getRentalFrequency(filters); break;
        case 'roi': data = await reportService.getROI(filters); break;
        case 'dead-stock': data = await reportService.getDeadStock(filters); break;
        case 'sales-by-staff': data = await reportService.getSalesByStaff(filters); break;
        case 'inventory-revenue': data = await reportService.getInventoryRevenue(); break;
        case 'enquiry-log': data = await reportService.getEnquiries(filters); break;
        case 'gst-filing': data = await reportService.getGSTFilingReport(filters); break;
        case 'todays-revenue': {
          const today = new Date().toLocaleDateString('en-CA');
          data = await reportService.getRevenue({ ...filters, from_date: today, to_date: today });
          break;
        }
      }
    }

    console.log(`[Report API] Fetching ${type} with filters:`, filters);
    console.log(`[Report API] Rows found:`, data?.length || 0);

    return apiSuccess({ rows: data, count: data?.length || 0 });
  } catch (err) {
    console.error('Report API error:', err);
    return apiInternalError();
  }
}

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ type: string }> }
) {
  try {
    const { type } = await params;
    if (type !== 'enquiry-log') {
      return apiBadRequest('Only enquiry-log supports POST');
    }

    const guard = await apiGuard(request, 'reports');
    if (guard.error) return guard.error;

    const dto = await request.json();
    const user = guard.user;

    const result = await reportService.createEnquiry(
      dto,
      user.staff_id || user.id,
      user.branch_id || null,
      user.store_id || null
    );

    return apiSuccess(result);
  } catch (err: any) {
    console.error('Report POST error:', err);
    return apiInternalError(err.message);
  }
}
