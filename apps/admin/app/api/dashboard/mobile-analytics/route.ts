/**
 * Mobile Analytics API Route
 *
 * Provides the full analytics data (revenue, pacing, charts, category revenue,
 * top performers, dead stock, bottlenecks) for the mobile app's dashboard.
 *
 * This endpoint wraps dashboardService.getMetrics() with mobile-friendly
 * date range presets.
 *
 * Admin-only — staff and manager roles cannot access analytics.
 *
 * @module app/api/dashboard/mobile-analytics
 */

import { NextRequest } from 'next/server';
import { apiGuard } from '@/lib/apiGuard';
import { apiInternalError, apiSuccess, apiForbidden } from '@/lib/apiResponse';
import { dashboardService } from '@/services/dashboardService';
import {
  startOfDay, endOfDay,
  startOfWeek, endOfWeek,
  startOfMonth, endOfMonth,
  subDays, subWeeks, subMonths,
} from 'date-fns';

export async function GET(request: NextRequest) {
  try {
    const guard = await apiGuard(request, 'dashboard');
    if (guard.error) return guard.error;

    // Only admin/super_admin/owner can see analytics
    const isAdmin = ['admin', 'super_admin', 'owner'].includes(guard.user.role || '');
    if (!isAdmin) {
      return apiForbidden('Analytics is only available for admin users');
    }

    const searchParams = request.nextUrl.searchParams;
    const range = searchParams.get('range') || 'this_week';
    const requestedBranchId = searchParams.get('branch_id') || undefined;
    const canSwitchBranches = guard.user.role === 'super_admin' || guard.user.role === 'admin';
    const branchId = canSwitchBranches ? requestedBranchId : guard.user.branch_id || undefined;

    // IST-aware current time
    const rawNow = new Date();
    const istOffset = 5.5 * 60 * 60 * 1000;
    const now = new Date(rawNow.getTime() + istOffset);

    // Calculate date ranges based on the range parameter
    let startDate: Date;
    let endDate: Date;
    let prevStartDate: Date;
    let prevEndDate: Date;

    switch (range) {
      case 'today':
        startDate = startOfDay(now);
        endDate = endOfDay(now);
        prevStartDate = startOfDay(subDays(now, 1));
        prevEndDate = endOfDay(subDays(now, 1));
        break;
      case 'yesterday':
        startDate = startOfDay(subDays(now, 1));
        endDate = endOfDay(subDays(now, 1));
        prevStartDate = startOfDay(subDays(now, 2));
        prevEndDate = endOfDay(subDays(now, 2));
        break;
      case 'this_week':
        startDate = startOfWeek(now, { weekStartsOn: 1 });
        endDate = now;
        prevStartDate = startOfWeek(subWeeks(now, 1), { weekStartsOn: 1 });
        prevEndDate = endOfWeek(subWeeks(now, 1), { weekStartsOn: 1 });
        break;
      case 'last_week':
        startDate = startOfWeek(subWeeks(now, 1), { weekStartsOn: 1 });
        endDate = endOfWeek(subWeeks(now, 1), { weekStartsOn: 1 });
        prevStartDate = startOfWeek(subWeeks(now, 2), { weekStartsOn: 1 });
        prevEndDate = endOfWeek(subWeeks(now, 2), { weekStartsOn: 1 });
        break;
      case 'this_month':
        startDate = startOfMonth(now);
        endDate = now;
        prevStartDate = startOfMonth(subMonths(now, 1));
        prevEndDate = endOfMonth(subMonths(now, 1));
        break;
      case 'last_month':
        startDate = startOfMonth(subMonths(now, 1));
        endDate = endOfMonth(subMonths(now, 1));
        prevStartDate = startOfMonth(subMonths(now, 2));
        prevEndDate = endOfMonth(subMonths(now, 2));
        break;
      default:
        // Default to this_week
        startDate = startOfWeek(now, { weekStartsOn: 1 });
        endDate = now;
        prevStartDate = startOfWeek(subWeeks(now, 1), { weekStartsOn: 1 });
        prevEndDate = endOfWeek(subWeeks(now, 1), { weekStartsOn: 1 });
    }

    const catPeriod = (searchParams.get('cat_period') as 'month' | 'year' | 'all') || 'month';
    const roiLimit = searchParams.get('roi_limit') ? parseInt(searchParams.get('roi_limit')!) : 5;

    const metrics = await dashboardService.getMetrics(
      startDate,
      endDate,
      prevStartDate,
      prevEndDate,
      branchId,
      undefined, // storeId
      { categoryPeriod: catPeriod, roiLimit: roiLimit }
    );

    if (!metrics) {
      return apiInternalError('Failed to compute analytics metrics');
    }

    // Return a mobile-friendly subset of the full metrics
    const response = {
      salesPacing: metrics.salesPacing,
      revenuePacing: metrics.revenuePacing,
      revenueByStatus: metrics.revenueByStatus,
      cancellationStats: metrics.cancellationStats,
      actionRequired: metrics.actionRequired,
      dailyRevenue: metrics.dailyRevenue,
      total_cash: metrics.total_cash,
      total_upi: metrics.total_upi,
      total_gpay: metrics.total_gpay,
      total_bank_transfer: metrics.total_bank_transfer,
      total_amount_collection: metrics.total_amount_collection,
      bookingVelocity: metrics.bookingVelocity,
      categoryRevenue: metrics.categoryRevenue,
      topPerformers: metrics.topPerformers,
      deadStock: metrics.deadStock,
      bottlenecks: metrics.bottlenecks,
    };

    return apiSuccess(response);
  } catch (error) {
    console.error('[MobileAnalytics] Error:', error);
    return apiInternalError('Failed to fetch analytics metrics');
  }
}
