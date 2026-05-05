import { NextRequest, NextResponse } from 'next/server';
import { reportService } from '@/services/reportService';
import { ReportFilters } from '@/domain';

/**
 * GET /api/reports/gst-filing
 * 
 * Fetches the GST filing report (R12) for a given period.
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    
    const filters: ReportFilters = {
      from_date: searchParams.get('from_date') || undefined,
      to_date: searchParams.get('to_date') || undefined,
      period: (searchParams.get('period') as any) || 'month'
    };

    const report = await reportService.getGSTFilingReport(filters);

    return NextResponse.json({
      success: true,
      data: report
    });
  } catch (error: any) {
    console.error('GST Filing Report Error:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
