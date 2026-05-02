/**
 * Dashboard Service
 *
 * Provides aggregated metrics for the admin dashboard.
 * Two tiers:
 *   - Operational metrics (all roles): today's bookings, deliveries, returns, overdue
 *   - Admin revenue metrics (admin only): revenue by status, pacing, category, cancellations
 *
 * @module services/dashboardService
 */

import { createAdminClient } from '@/lib/supabase/server';
import { format, differenceInDays, addDays, startOfDay, endOfDay } from 'date-fns';

// ─── Types ─────────────────────────────────────────────────────────────────────

export interface OperationalCard {
  label: string;
  orderCount: number;
  productCount: number;
  icon: string;
  color: string;
  filterUrl: string;
}

export interface OperationalMetrics {
  cards: OperationalCard[];
}

export interface RevenueByStatus {
  completedRevenue: number;
  ongoingRevenue: number;
  scheduledRevenue: number;
}

export interface CancellationStats {
  currentCount: number;
  previousCount: number;
  percentageChange: number;
  isPositive: boolean;
}

export interface DashboardMetrics {
  revenuePacing: {
    current: number;
    previous: number;
    percentageChange: number;
    isPositive: boolean;
  };
  revenueByStatus: RevenueByStatus;
  cancellationStats: CancellationStats;
  utilization: {
    percentage: number;
    rentedOut: number;
    totalProducts: number;
  };
  actionRequired: {
    totalIssues: number;
    overdueCount: number;
    damagedCount: number;
    pendingApprovalCount: number;
  };
  bookingVelocity: {
    date: string;
    count: number;
  }[];
  topPerformers: {
    id: string;
    name: string;
    rentals: number;
    revenue: number;
  }[];
  deadStock: {
    id: string;
    name: string;
    daysIdle: number;
    value: number;
  }[];
  categoryRevenue: {
    name: string;
    revenue: number;
    percentage: number;
  }[];
  bottlenecks: {
    id: string;
    type: 'cleaning' | 'approval' | 'overdue';
    message: string;
    severity: 'high' | 'medium';
  }[];
}

// ─── Service ───────────────────────────────────────────────────────────────────

export class DashboardService {

  /**
   * Operational Metrics — visible to ALL roles.
   * Returns 6 cards: Today's Booking, Today's Delivery, Today's Return,
   * Prepare Delivery (next 7 days), Pending Delivery, Pending Return.
   */
  async getOperationalMetrics(): Promise<OperationalMetrics> {
    const supabase = createAdminClient();
    const now = new Date();
    const todayStart = startOfDay(now).toISOString();
    const todayEnd = endOfDay(now).toISOString();
    const next7Days = endOfDay(addDays(now, 7)).toISOString();

    // 1. Today's Bookings — orders created today
    const { data: todaysBookings } = await supabase
      .from('orders')
      .select('id, order_items(quantity)')
      .gte('created_at', todayStart)
      .lte('created_at', todayEnd)
      .neq('status', 'cancelled');

    const todaysBookingProducts = (todaysBookings || []).reduce((sum, o: any) =>
      sum + (o.order_items?.reduce((s: number, i: any) => s + (i.quantity || 0), 0) || 0), 0);

    // 2. Today's Delivery — orders starting today (pickup/delivery)
    const { data: todaysDeliveries } = await supabase
      .from('orders')
      .select('id, order_items(quantity)')
      .gte('start_date', todayStart.split('T')[0])
      .lte('start_date', todayEnd.split('T')[0])
      .in('status', ['scheduled', 'pending']);

    const todaysDeliveryProducts = (todaysDeliveries || []).reduce((sum, o: any) =>
      sum + (o.order_items?.reduce((s: number, i: any) => s + (i.quantity || 0), 0) || 0), 0);

    // 3. Today's Return — orders ending today
    const { data: todaysReturns } = await supabase
      .from('orders')
      .select('id, order_items(quantity)')
      .gte('end_date', todayStart.split('T')[0])
      .lte('end_date', todayEnd.split('T')[0])
      .in('status', ['ongoing', 'in_use', 'late_return']);

    const todaysReturnProducts = (todaysReturns || []).reduce((sum, o: any) =>
      sum + (o.order_items?.reduce((s: number, i: any) => s + (i.quantity || 0), 0) || 0), 0);

    // 4. Prepare Delivery — scheduled orders starting within next 7 days
    const tomorrowStart = startOfDay(addDays(now, 1)).toISOString().split('T')[0];
    const { data: prepareDeliveries } = await supabase
      .from('orders')
      .select('id, order_items(quantity)')
      .gte('start_date', tomorrowStart)
      .lte('start_date', next7Days.split('T')[0])
      .in('status', ['scheduled', 'pending']);

    const prepareDeliveryProducts = (prepareDeliveries || []).reduce((sum, o: any) =>
      sum + (o.order_items?.reduce((s: number, i: any) => s + (i.quantity || 0), 0) || 0), 0);

    // 5. Pending Delivery (overdue) — orders past start_date still in scheduled/pending
    const { data: pendingDeliveries } = await supabase
      .from('orders')
      .select('id, order_items(quantity)')
      .lt('start_date', todayStart.split('T')[0])
      .in('status', ['scheduled', 'pending']);

    const pendingDeliveryProducts = (pendingDeliveries || []).reduce((sum, o: any) =>
      sum + (o.order_items?.reduce((s: number, i: any) => s + (i.quantity || 0), 0) || 0), 0);

    // 6. Pending Return (overdue) — orders past end_date still in ongoing/in_use
    const { data: pendingReturns } = await supabase
      .from('orders')
      .select('id, order_items(quantity)')
      .lt('end_date', todayStart.split('T')[0])
      .in('status', ['ongoing', 'in_use', 'late_return']);

    const pendingReturnProducts = (pendingReturns || []).reduce((sum, o: any) =>
      sum + (o.order_items?.reduce((s: number, i: any) => s + (i.quantity || 0), 0) || 0), 0);

    return {
      cards: [
        {
          label: "Today's Bookings",
          orderCount: todaysBookings?.length || 0,
          productCount: todaysBookingProducts,
          icon: 'calendar-plus',
          color: 'blue',
          filterUrl: '/dashboard/orders?date_filter=today',
        },
        {
          label: "Today's Delivery",
          orderCount: todaysDeliveries?.length || 0,
          productCount: todaysDeliveryProducts,
          icon: 'truck',
          color: 'emerald',
          filterUrl: '/dashboard/orders?status=scheduled&date_filter=today',
        },
        {
          label: "Today's Return",
          orderCount: todaysReturns?.length || 0,
          productCount: todaysReturnProducts,
          icon: 'package-check',
          color: 'violet',
          filterUrl: '/dashboard/orders?status=ongoing&date_filter=today',
        },
        {
          label: "Prepare Delivery",
          orderCount: prepareDeliveries?.length || 0,
          productCount: prepareDeliveryProducts,
          icon: 'boxes',
          color: 'amber',
          filterUrl: '/dashboard/orders?status=scheduled',
        },
        {
          label: "Pending Delivery",
          orderCount: pendingDeliveries?.length || 0,
          productCount: pendingDeliveryProducts,
          icon: 'alert-triangle',
          color: 'rose',
          filterUrl: '/dashboard/orders?status=pending',
        },
        {
          label: "Pending Return",
          orderCount: pendingReturns?.length || 0,
          productCount: pendingReturnProducts,
          icon: 'clock-alert',
          color: 'red',
          filterUrl: '/dashboard/orders?status=late_return',
        },
      ],
    };
  }

  /**
   * Full dashboard metrics — admin-level data + operational metrics.
   */
  async getMetrics(startDate: Date, endDate: Date, prevStartDate: Date, prevEndDate: Date): Promise<DashboardMetrics> {
    const supabase = createAdminClient();
    const now = new Date();

    // 1. Revenue Pacing (Current vs Previous Period)
    const { data: currentPayments } = await supabase
      .from('payments')
      .select('amount, payment_type')
      .gte('payment_date', startDate.toISOString())
      .lte('payment_date', endDate.toISOString())
      .neq('payment_type', 'refund');

    const currentRevenue = currentPayments?.reduce((sum, p) => sum + Number(p.amount), 0) || 0;

    const { data: prevPayments } = await supabase
      .from('payments')
      .select('amount, payment_type')
      .gte('payment_date', prevStartDate.toISOString())
      .lte('payment_date', prevEndDate.toISOString())
      .neq('payment_type', 'refund');

    const prevRevenue = prevPayments?.reduce((sum, p) => sum + Number(p.amount), 0) || 0;
    const percentageChange = prevRevenue === 0 ? 100 : ((currentRevenue - prevRevenue) / prevRevenue) * 100;

    // 2. Revenue by Status
    const { data: completedOrders } = await supabase
      .from('orders')
      .select('total_amount')
      .eq('status', 'completed');
    const completedRevenue = completedOrders?.reduce((sum, o) => sum + Number(o.total_amount || 0), 0) || 0;

    const { data: ongoingOrders } = await supabase
      .from('orders')
      .select('total_amount')
      .in('status', ['ongoing', 'in_use', 'late_return', 'partial']);
    const ongoingRevenue = ongoingOrders?.reduce((sum, o) => sum + Number(o.total_amount || 0), 0) || 0;

    const { data: scheduledOrders } = await supabase
      .from('orders')
      .select('advance_amount')
      .in('status', ['scheduled', 'pending'])
      .eq('advance_collected', true);
    const scheduledRevenue = scheduledOrders?.reduce((sum, o) => sum + Number(o.advance_amount || 0), 0) || 0;

    // 3. Cancellation Stats
    const { count: currentCancelCount } = await supabase
      .from('orders')
      .select('id', { count: 'exact', head: true })
      .eq('status', 'cancelled')
      .gte('cancelled_at', startDate.toISOString())
      .lte('cancelled_at', endDate.toISOString());

    const { count: prevCancelCount } = await supabase
      .from('orders')
      .select('id', { count: 'exact', head: true })
      .eq('status', 'cancelled')
      .gte('cancelled_at', prevStartDate.toISOString())
      .lte('cancelled_at', prevEndDate.toISOString());

    const cancelCurrent = currentCancelCount || 0;
    const cancelPrev = prevCancelCount || 0;
    const cancelChange = cancelPrev === 0 ? 0 : ((cancelCurrent - cancelPrev) / cancelPrev) * 100;

    // 4. Overdue Orders
    const { data: activeOrders } = await supabase
      .from('orders')
      .select('id, status, end_date')
      .in('status', ['ongoing', 'in_use', 'late_return', 'scheduled', 'pending']);

    const overdueOrders = activeOrders?.filter(o =>
      ['ongoing', 'in_use', 'late_return'].includes(o.status) && new Date(o.end_date) < now
    ) || [];

    // 5. Utilization
    const { count: totalProducts } = await supabase
      .from('products')
      .select('id', { count: 'exact', head: true })
      .eq('is_active', true);

    const { data: rentedItems } = await supabase
      .from('order_items')
      .select('product_id, orders!inner(status)')
      .in('orders.status', ['ongoing', 'in_use', 'late_return']);

    const uniqueRentedProducts = new Set((rentedItems || []).map((i: any) => i.product_id));
    const rentedOut = uniqueRentedProducts.size;
    const utilizationPercentage = totalProducts && totalProducts > 0
      ? Math.round((rentedOut / totalProducts) * 100) : 0;

    // 6. Booking Velocity (next 15 days)
    const velocityEndDate = addDays(now, 15);
    const { data: upcomingOrders } = await supabase
      .from('orders')
      .select('start_date, status')
      .gte('start_date', now.toISOString())
      .lte('start_date', velocityEndDate.toISOString())
      .neq('status', 'cancelled');

    const velocityMap = new Map<string, number>();
    upcomingOrders?.forEach(order => {
      const dateStr = format(new Date(order.start_date), 'yyyy-MM-dd');
      velocityMap.set(dateStr, (velocityMap.get(dateStr) || 0) + 1);
    });

    const bookingVelocity = Array.from({ length: 15 }).map((_, i) => {
      const d = addDays(now, i);
      const dateStr = format(d, 'yyyy-MM-dd');
      return { date: format(d, 'MMM dd'), count: velocityMap.get(dateStr) || 0 };
    });

    // 7. Top Performers
    const { data: orderItems } = await supabase
      .from('order_items')
      .select('product_id, quantity, price_per_day, products(name, category_id, categories:category_id(name))')
      .returns<any[]>();

    const productStats = new Map<string, { name: string; rentals: number; revenue: number }>();
    orderItems?.forEach(item => {
      if (!item.products) return;
      const pid = item.product_id;
      const stats = productStats.get(pid) || { name: item.products.name, rentals: 0, revenue: 0 };
      stats.rentals += item.quantity;
      stats.revenue += item.quantity * Number(item.price_per_day || 0);
      productStats.set(pid, stats);
    });

    const topPerformers = Array.from(productStats.values())
      .sort((a, b) => b.revenue - a.revenue)
      .slice(0, 3)
      .map((p, i) => ({ id: String(i), ...p }));

    // 8. Category Revenue
    const categoryRevenueMap = new Map<string, { name: string; revenue: number }>();
    orderItems?.forEach(item => {
      if (!item.products?.categories) return;
      const catName = item.products.categories.name || 'Uncategorized';
      const existing = categoryRevenueMap.get(catName) || { name: catName, revenue: 0 };
      existing.revenue += item.quantity * Number(item.price_per_day || 0);
      categoryRevenueMap.set(catName, existing);
    });

    const categoryRevenueArr = Array.from(categoryRevenueMap.values())
      .sort((a, b) => b.revenue - a.revenue);
    const totalCategoryRevenue = categoryRevenueArr.reduce((sum, c) => sum + c.revenue, 0);
    const categoryRevenue = categoryRevenueArr.slice(0, 5).map(c => ({
      name: c.name,
      revenue: c.revenue,
      percentage: totalCategoryRevenue > 0 ? Math.round((c.revenue / totalCategoryRevenue) * 100) : 0,
    }));

    // 9. Dead Stock (90+ days with no orders)
    const ninetyDaysAgo = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
    const { data: recentOrderProductIds } = await supabase
      .from('order_items')
      .select('product_id, orders!inner(created_at)')
      .gte('orders.created_at', ninetyDaysAgo.toISOString())
      .returns<any[]>();

    const recentProductIdSet = new Set(recentOrderProductIds?.map(i => i.product_id) || []);

    const { data: allActiveProducts } = await supabase
      .from('products')
      .select('id, name, price_per_day, created_at')
      .eq('is_active', true)
      .limit(100);

    const deadStock = (allActiveProducts || [])
      .filter(p => !recentProductIdSet.has(p.id))
      .map(p => ({
        id: p.id,
        name: p.name,
        daysIdle: Math.max(0, differenceInDays(now, new Date(p.created_at))),
        value: Number(p.price_per_day || 0),
      }))
      .filter(p => p.daysIdle >= 90)
      .sort((a, b) => b.daysIdle - a.daysIdle)
      .slice(0, 5);

    return {
      revenuePacing: {
        current: currentRevenue,
        previous: prevRevenue,
        percentageChange: Math.abs(Math.round(percentageChange)),
        isPositive: percentageChange >= 0,
      },
      revenueByStatus: {
        completedRevenue,
        ongoingRevenue,
        scheduledRevenue,
      },
      cancellationStats: {
        currentCount: cancelCurrent,
        previousCount: cancelPrev,
        percentageChange: Math.abs(Math.round(cancelChange)),
        isPositive: cancelChange <= 0, // fewer cancellations is positive
      },
      utilization: {
        percentage: utilizationPercentage,
        rentedOut,
        totalProducts: totalProducts || 0,
      },
      actionRequired: {
        totalIssues: overdueOrders.length,
        overdueCount: overdueOrders.length,
        damagedCount: 0,
        pendingApprovalCount: 0,
      },
      bookingVelocity,
      topPerformers,
      deadStock,
      categoryRevenue,
      bottlenecks: overdueOrders.slice(0, 3).map(o => ({
        id: o.id,
        type: 'overdue' as const,
        message: `Order #${o.id.substring(0, 8)} is overdue for return`,
        severity: 'high' as const,
      })),
    };
  }
}

export const dashboardService = new DashboardService();
