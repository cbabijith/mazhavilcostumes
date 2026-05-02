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
  'sales-by-staff', 'inventory-revenue', 'enquiry-log',
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
    };

    let data: any;
    switch (type as ReportType) {
      case 'day-wise-booking': data = await reportService.getDayWiseBooking(filters); break;
      case 'due-overdue': data = await reportService.getDueOverdue(); break;
      case 'revenue': data = await reportService.getRevenue(filters); break;
      case 'top-costumes': data = await reportService.getTopCostumes(filters); break;
      case 'top-customers': data = await reportService.getTopCustomers(filters); break;
      case 'rental-frequency': data = await reportService.getRentalFrequency(); break;
      case 'roi': data = await reportService.getROI(); break;
      case 'dead-stock': data = await reportService.getDeadStock(filters); break;
      case 'sales-by-staff': data = await reportService.getSalesByStaff(filters); break;
      case 'inventory-revenue': data = await reportService.getInventoryRevenue(); break;
      case 'enquiry-log': data = await reportService.getEnquiries(filters); break;
    }

    return apiSuccess({ rows: data, count: data?.length || 0 });
  } catch (err) {
    console.error('Report API error:', err);
    return apiInternalError();
  }
}
