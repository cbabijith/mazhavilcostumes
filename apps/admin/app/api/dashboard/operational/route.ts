import { NextRequest } from 'next/server';
import { createAdminClient } from '@/lib/supabase/server';
import { apiGuard } from '@/lib/apiGuard';
import { apiInternalError, apiSuccess } from '@/lib/apiResponse';
import { addDays, format } from 'date-fns';

export interface OperationalCard {
  label: string;
  orderCount: number;
  icon: string;
  color: string;
  filterUrl: string;
  completedCount?: number;
  totalCount?: number;
  amount?: number;
}

export interface OperationalMetrics {
  cards: OperationalCard[];
}

export async function GET(request: NextRequest) {
  try {
    const guard = await apiGuard(request, 'dashboard');
    if (guard.error) return guard.error;

    const supabase = createAdminClient();
    const searchParams = request.nextUrl.searchParams;
    const requestedBranchId = searchParams.get('branch_id') || undefined;
    const canSwitchBranches = guard.user.role === 'super_admin' || guard.user.role === 'admin';
    const branchId = canSwitchBranches ? requestedBranchId : guard.user.branch_id || undefined;

    // Get IST date context
    const now = new Date();
    const istDateStr = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Asia/Kolkata',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }).format(now);

    const todayStart = new Date(`${istDateStr}T00:00:00+05:30`).toISOString();
    const todayEnd = new Date(`${istDateStr}T23:59:59+05:30`).toISOString();
    const yesterdayStr = format(addDays(now, 1), 'yyyy-MM-dd');
    const tomorrowStr = format(addDays(now, 1), 'yyyy-MM-dd');
    const next5DaysStr = format(addDays(now, 5), 'yyyy-MM-dd');

    // Call the RPC function
    const { data, error } = await supabase.rpc('get_operational_dashboard_metrics', {
      p_today_start: todayStart,
      p_today_end: todayEnd,
      p_today_date: istDateStr,
      p_yesterday_date: yesterdayStr,
      p_tomorrow_date: tomorrowStr,
      p_next_5_days_date: next5DaysStr,
      p_branch_id: branchId,
    });

    if (error) {
      console.error('[Operational Metrics] Error fetching RPC:', error);
    }

    const rpcData = data || {
      todaysBookings: 0,
      todaysDeliveryTotal: 0,
      todaysDeliveryDone: 0,
      todaysReturnTotal: 0,
      todaysReturnDone: 0,
      prepareDeliveries: 0,
      pendingDeliveries: 0,
      pendingReturns: 0,
      revenueDueCount: 0,
      revenueDueAmount: 0,
    };

    const branchIdParam = branchId ? `&branch_id=${branchId}` : '';

    const cards: OperationalCard[] = [
      {
        label: "Today's Bookings",
        orderCount: rpcData.todaysBookings || 0,
        icon: 'calendar-plus',
        color: 'blue',
        filterUrl: `/dashboard/orders?date_filter=today&exclude_status=cancelled${branchIdParam}`,
      },
      {
        label: "Today's Delivery",
        orderCount: rpcData.todaysDeliveryTotal || 0,
        icon: 'truck',
        color: 'emerald',
        completedCount: rpcData.todaysDeliveryDone || 0,
        totalCount: rpcData.todaysDeliveryTotal || 0,
        filterUrl: `/dashboard/orders?date_filter=today&date_field=start_date&exclude_status=cancelled${branchIdParam}`,
      },
      {
        label: "Today's Return",
        orderCount: rpcData.todaysReturnTotal || 0,
        icon: 'package-check',
        color: 'violet',
        completedCount: rpcData.todaysReturnDone || 0,
        totalCount: rpcData.todaysReturnTotal || 0,
        filterUrl: `/dashboard/orders?date_filter=today&date_field=end_date&exclude_status=cancelled${branchIdParam}`,
      },
      {
        label: "Prepare Delivery (5d)",
        orderCount: rpcData.prepareDeliveries || 0,
        icon: 'boxes',
        color: 'amber',
        filterUrl: `/dashboard/orders?status=scheduled&status=pending&date_filter=custom&date_field=start_date&date_from=${tomorrowStr}&date_to=${next5DaysStr}${branchIdParam}`,
      },
      {
        label: "Pending Delivery",
        orderCount: rpcData.pendingDeliveries || 0,
        icon: 'alert-triangle',
        color: 'rose',
        filterUrl: `/dashboard/orders?status=pending${branchIdParam}`,
      },
      {
        label: "Pending Return",
        orderCount: rpcData.pendingReturns || 0,
        icon: 'clock-alert',
        color: 'red',
        filterUrl: `/dashboard/orders?status=ongoing&status=in_use&date_filter=custom&date_field=end_date&date_to=${yesterdayStr}${branchIdParam}`,
      },
      {
        label: "Revenue Due",
        orderCount: rpcData.revenueDueCount || 0,
        amount: Number(rpcData.revenueDueAmount || 0),
        icon: 'banknote',
        color: 'indigo',
        filterUrl: `/dashboard/orders?status=revenue_due${branchIdParam}`,
      },
    ];

    return apiSuccess({ cards });
  } catch (error) {
    console.error('Error fetching operational metrics:', error);
    return apiInternalError('Failed to fetch operational metrics');
  }
}
