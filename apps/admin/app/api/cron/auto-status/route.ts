/**
 * Cron: Auto-Status Transition
 *
 * Runs daily via Vercel Cron to:
 *   1. Transition overdue orders from ongoing/in_use → late_return
 *   2. Auto-complete cleaning records whose buffer period has expired
 *
 * Schedule: Every day at 00:05 IST (18:35 UTC previous day)
 *
 * Security: Protected by CRON_SECRET header validation.
 *
 * @module app/api/cron/auto-status/route
 */

import { NextRequest, NextResponse } from 'next/server';
import { orderService } from '@/services/orderService';
import { cleaningService } from '@/services/cleaningService';

export const dynamic = 'force-dynamic';
export const maxDuration = 30; // 30 seconds max for cron

export async function GET(request: NextRequest) {
  // Verify cron secret to prevent unauthorized access
  const authHeader = request.headers.get('authorization');
  const cronSecret = process.env.CRON_SECRET;

  if (cronSecret && authHeader !== `Bearer ${cronSecret}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  try {
    // 1. Transition overdue orders to late_return
    const transitioned = await orderService.transitionOverdueOrders();

    // 2. Auto-complete cleaning records past their buffer period
    const cleaningCompleted = await cleaningService.autoCompleteExpiredCleaning();

    return NextResponse.json({
      success: true,
      message: `Auto-status transition complete`,
      transitioned,
      cleaningCompleted,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Cron auto-status failed:', error);
    return NextResponse.json(
      { error: 'Internal server error', details: error instanceof Error ? error.message : String(error) },
      { status: 500 }
    );
  }
}
