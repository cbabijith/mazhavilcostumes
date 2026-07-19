/**
 * Daily Report API
 *
 * GET /api/dashboard/daily-report — Admin-only today's cash reconciliation stats
 *
 * Returns 8 metrics: bookings, delivery progress, return progress,
 * revenue, damaged orders, refunds, damage income, late fee income.
 *
 * @module app/api/dashboard/daily-report/route
 */

import { NextRequest, NextResponse } from 'next/server';
import { adminOnly } from '@/lib/apiGuard';
import { dashboardService } from '@/services/dashboardService';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  const guard = await adminOnly(request);
  if (guard.error) return guard.error;

  try {
    const { searchParams } = new URL(request.url);
    const branchId = searchParams.get('branch_id') || undefined;
    const stats = await dashboardService.getDailyReport(branchId);
    return NextResponse.json({ success: true, data: stats });
  } catch (error: any) {
    console.error('[API] GET /api/dashboard/daily-report error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to fetch daily report' },
      { status: 500 }
    );
  }
}
