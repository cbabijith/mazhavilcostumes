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

export async function GET(request: NextRequest) {
  const guard = await adminOnly(request);
  if (guard.error) return guard.error;

  try {
    const stats = await dashboardService.getDailyReport();
    return NextResponse.json({ success: true, data: stats });
  } catch (error: any) {
    console.error('[API] GET /api/dashboard/daily-report error:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to fetch daily report' },
      { status: 500 }
    );
  }
}
