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

export interface PriorityCleaningOrder {
  id: string;
  customerName: string;
  startDate: string;
  products: {
    name: string;
    quantity: number;
  }[];
}

export interface OperationalMetrics {
  cards: OperationalCard[];
  priorityCleaning: PriorityCleaningOrder[];
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
  dailyRevenue: {
    date: string;
    amount: number;
  }[];
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
  priorityCleaning: PriorityCleaningOrder[];
}

// ─── Service ───────────────────────────────────────────────────────────────────

export class DashboardService {

  /**
   * Operational Metrics — visible to ALL roles.
   * Returns 6 cards: Today's Booking, Today's Delivery, Today's Return,
   * Prepare Delivery (next 5 days), Pending Delivery, Pending Return.
   */
  async getOperationalMetrics(): Promise<OperationalMetrics> {
    const supabase = createAdminClient();
    const now = new Date();
    const todayStart = startOfDay(now).toISOString();
    const todayEnd = endOfDay(now).toISOString();
    const next5Days = endOfDay(addDays(now, 5)).toISOString();

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

    // 4. Prepare Delivery — scheduled orders starting within next 5 days
    const tomorrowStart = startOfDay(addDays(now, 1)).toISOString().split('T')[0];
    const { data: prepareDeliveries } = await supabase
      .from('orders')
      .select('id, order_items(quantity)')
      .gte('start_date', tomorrowStart)
      .lte('start_date', next5Days.split('T')[0])
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

    const cards = [
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
          label: "Prepare Delivery (5d)",
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
      ];

    // 7. Priority Cleaning — Prior Cleaning orders needing urgent prep
    // Fetch upcoming Prior Cleaning orders starting in the next 5 days
    const { data: priorityOrders } = await supabase
      .from('orders')
      .select('id, start_date, buffer_override, customer:customer_id(name), items:order_items(product_id, quantity, product:product_id(name))')
      .eq('buffer_override', true)
      .in('status', ['confirmed', 'scheduled'])
      .gte('start_date', todayStart.split('T')[0])
      .lte('start_date', endOfDay(addDays(now, 5)).toISOString().split('T')[0])
      .order('start_date', { ascending: true });

    const priorityCleaning: PriorityCleaningOrder[] = (priorityOrders || []).map((o: any) => ({
      id: o.id,
      customerName: o.customer?.name || 'Unknown',
      startDate: o.start_date,
      products: (o.items || []).map((i: any) => ({
        name: i.product?.name || 'Unknown',
        quantity: i.quantity || 0,
      })),
    }));

    return {
      cards,
      priorityCleaning,
    };
  }

  /**
   * Full dashboard metrics — admin-level data + operational metrics.
   */
  async getMetrics(
    startDate: Date, endDate: Date, 
    prevStartDate: Date, prevEndDate: Date,
    overrides?: {
      categoryPeriod?: 'month' | 'year' | 'all';
      roiLimit?: number;
    }
  ): Promise<DashboardMetrics> {
    const supabase = createAdminClient();
    const now = new Date();
    const startDateStr = startDate.toISOString();
    const endDateStr = endDate.toISOString();
    const prevStartDateStr = prevStartDate.toISOString();
    const prevEndDateStr = prevEndDate.toISOString();
    const ninetyDaysAgo = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000).toISOString();
    const velocityEndDate = addDays(now, 15).toISOString();

    const roiLimit = overrides?.roiLimit || 3;
    let catStartDate = startDate;
    if (overrides?.categoryPeriod === 'year') {
      const d = new Date(); d.setFullYear(d.getFullYear() - 1); catStartDate = d;
    } else if (overrides?.categoryPeriod === 'all') {
      catStartDate = new Date(2000, 0, 1);
    }
    const catStartDateStr = catStartDate.toISOString();

    // Kick off all queries in parallel
    const [
      currentPaymentsRes,
      prevPaymentsRes,
      completedOrdersRes,
      ongoingOrdersRes,
      scheduledOrdersRes,
      currentCancelRes,
      prevCancelRes,
      activeOrdersRes,
      totalProductsRes,
      rentedItemsRes,
      upcomingOrdersRes,
      roiItemsRes,
      catItemsRes,
      recentOrderRes,
      allActiveProductsRes,
      priorityRes
    ] = await Promise.all([
      // 1. Current Payments
      supabase.from('payments').select('amount, payment_date').gte('payment_date', startDateStr).lte('payment_date', endDateStr).neq('payment_type', 'refund'),
      
      // 2. Previous Payments
      supabase.from('payments').select('amount').gte('payment_date', prevStartDateStr).lte('payment_date', prevEndDateStr).neq('payment_type', 'refund'),
      
      // 3. Completed Orders
      supabase.from('orders').select('total_amount').eq('status', 'completed').gte('updated_at', startDateStr).lte('updated_at', endDateStr),
      
      // 4. Ongoing Orders
      supabase.from('orders').select('total_amount').in('status', ['ongoing', 'in_use', 'late_return', 'partial']).gte('start_date', startDateStr.split('T')[0]).lte('start_date', endDateStr.split('T')[0]),
      
      // 5. Scheduled Orders
      supabase.from('orders').select('advance_amount').in('status', ['scheduled', 'pending']).eq('advance_collected', true).gte('created_at', startDateStr).lte('created_at', endDateStr),
      
      // 6. Current Cancellations
      supabase.from('orders').select('id', { count: 'exact', head: true }).eq('status', 'cancelled').gte('cancelled_at', startDateStr).lte('cancelled_at', endDateStr),
      
      // 7. Previous Cancellations
      supabase.from('orders').select('id', { count: 'exact', head: true }).eq('status', 'cancelled').gte('cancelled_at', prevStartDateStr).lte('cancelled_at', prevEndDateStr),
      
      // 8. Active Orders (for Overdue)
      supabase.from('orders').select('id, status, end_date').in('status', ['ongoing', 'in_use', 'late_return', 'scheduled', 'pending']),
      
      // 9. Total Products
      supabase.from('products').select('id', { count: 'exact', head: true }).eq('is_active', true),
      
      // 10. Rented Items
      supabase.from('order_items').select('product_id, orders!inner(status)').in('orders.status', ['ongoing', 'in_use', 'late_return']),
      
      // 11. Upcoming Orders (Velocity)
      supabase.from('orders').select('start_date').gte('start_date', now.toISOString()).lte('start_date', velocityEndDate).neq('status', 'cancelled'),
      
      // 12. ROI Items
      supabase.from('order_items').select('product_id, quantity, price_per_day, orders!inner(status, created_at), products(name)').neq('orders.status', 'cancelled').gte('orders.created_at', startDateStr).lte('orders.created_at', endDateStr).returns<any[]>(),
      
      // 13. Category Items
      supabase.from('order_items').select('quantity, price_per_day, orders!inner(status, created_at), products(categories:category_id(name))').neq('orders.status', 'cancelled').gte('orders.created_at', catStartDateStr).lte('orders.created_at', endDateStr).returns<any[]>(),
      
      // 14. Dead Stock (Recent Orders)
      supabase.from('order_items').select('product_id, orders!inner(created_at)').gte('orders.created_at', ninetyDaysAgo).returns<any[]>(),
      
      // 15. Active Products (Dead Stock check)
      supabase.from('products').select('id, name, price_per_day, created_at').eq('is_active', true).limit(100),
      
      // 16. Priority Cleaning
      supabase.from('orders').select('id, start_date, customer:customer_id(name), order_items(quantity, products(name))').eq('buffer_override', true).in('status', ['scheduled', 'pending', 'confirmed']).gte('start_date', now.toISOString().split('T')[0]).order('start_date', { ascending: true }).limit(5)
    ]);

    // Processing results
    const currentPayments = currentPaymentsRes.data || [];
    const prevPayments = prevPaymentsRes.data || [];
    const currentRevenue = currentPayments.reduce((sum, p) => sum + Number(p.amount), 0) || 0;
    const prevRevenue = prevPayments.reduce((sum, p) => sum + Number(p.amount), 0) || 0;
    const percentageChange = prevRevenue === 0 ? 100 : ((currentRevenue - prevRevenue) / prevRevenue) * 100;

    // Daily Revenue Map
    const dailyRevenueMap = new Map<string, number>();
    currentPayments.forEach(p => {
      const dateStr = format(new Date(p.payment_date), 'MMM dd');
      dailyRevenueMap.set(dateStr, (dailyRevenueMap.get(dateStr) || 0) + Number(p.amount));
    });

    const diffDays = differenceInDays(endDate, startDate);
    const dailyRevenue = Array.from({ length: diffDays + 1 }).map((_, i) => {
      const d = addDays(startDate, i);
      const dateStr = format(d, 'MMM dd');
      return { date: dateStr, amount: dailyRevenueMap.get(dateStr) || 0 };
    });

    const completedRevenue = completedOrdersRes.data?.reduce((sum, o) => sum + Number(o.total_amount || 0), 0) || 0;
    const ongoingRevenue = ongoingOrdersRes.data?.reduce((sum, o) => sum + Number(o.total_amount || 0), 0) || 0;
    const scheduledRevenue = scheduledOrdersRes.data?.reduce((sum, o) => sum + Number(o.advance_amount || 0), 0) || 0;

    const cancelCurrent = currentCancelRes.count || 0;
    const cancelPrev = prevCancelRes.count || 0;
    const cancelChange = cancelPrev === 0 ? 0 : ((cancelCurrent - cancelPrev) / cancelPrev) * 100;

    const overdueOrders = activeOrdersRes.data?.filter(o =>
      ['ongoing', 'in_use', 'late_return'].includes(o.status) && new Date(o.end_date) < now
    ) || [];

    const totalProducts = totalProductsRes.count || 0;
    const uniqueRentedProducts = new Set((rentedItemsRes.data || []).map((i: any) => i.product_id));
    const rentedOut = uniqueRentedProducts.size;
    const utilizationPercentage = totalProducts > 0 ? Math.round((rentedOut / totalProducts) * 100) : 0;

    const velocityMap = new Map<string, number>();
    upcomingOrdersRes.data?.forEach(order => {
      const dateStr = format(new Date(order.start_date), 'yyyy-MM-dd');
      velocityMap.set(dateStr, (velocityMap.get(dateStr) || 0) + 1);
    });

    const bookingVelocity = Array.from({ length: 15 }).map((_, i) => {
      const d = addDays(now, i);
      const dateStr = format(d, 'yyyy-MM-dd');
      return { date: format(d, 'MMM dd'), count: velocityMap.get(dateStr) || 0 };
    });

    // ROI Processing
    const productStats = new Map<string, { name: string; rentals: number; revenue: number }>();
    roiItemsRes.data?.forEach(item => {
      if (!item.products) return;
      const pid = item.product_id;
      const stats = productStats.get(pid) || { name: item.products.name, rentals: 0, revenue: 0 };
      stats.rentals += item.quantity;
      stats.revenue += item.quantity * Number(item.price_per_day || 0);
      productStats.set(pid, stats);
    });

    const topPerformers = Array.from(productStats.values())
      .sort((a, b) => b.revenue - a.revenue)
      .slice(0, roiLimit)
      .map((p, i) => ({ id: String(i), ...p }));

    // Category Processing
    const categoryRevenueMap = new Map<string, { name: string; revenue: number }>();
    catItemsRes.data?.forEach(item => {
      if (!item.products?.categories) return;
      const catName = item.products.categories.name || 'Uncategorized';
      const existing = categoryRevenueMap.get(catName) || { name: catName, revenue: 0 };
      existing.revenue += item.quantity * Number(item.price_per_day || 0);
      categoryRevenueMap.set(catName, existing);
    });

    const categoryRevenueArr = Array.from(categoryRevenueMap.values()).sort((a, b) => b.revenue - a.revenue);
    const totalCategoryRevenue = categoryRevenueArr.reduce((sum, c) => sum + c.revenue, 0);
    const categoryRevenue = categoryRevenueArr.slice(0, 5).map(c => ({
      name: c.name,
      revenue: c.revenue,
      percentage: totalCategoryRevenue > 0 ? Math.round((c.revenue / totalCategoryRevenue) * 100) : 0,
    }));

    // Dead Stock
    const recentProductIdSet = new Set(recentOrderRes.data?.map(i => i.product_id) || []);
    const deadStock = (allActiveProductsRes.data || [])
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
      revenueByStatus: { completedRevenue, ongoingRevenue, scheduledRevenue },
      cancellationStats: {
        currentCount: cancelCurrent,
        previousCount: cancelPrev,
        percentageChange: Math.abs(Math.round(cancelChange)),
        isPositive: cancelChange <= 0,
      },
      utilization: { percentage: utilizationPercentage, rentedOut, totalProducts },
      actionRequired: {
        totalIssues: overdueOrders.length,
        overdueCount: overdueOrders.length,
        damagedCount: 0,
        pendingApprovalCount: 0,
      },
      dailyRevenue,
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
      priorityCleaning: (priorityRes.data || []).map((o: any) => ({
        id: o.id,
        customerName: o.customer?.name || 'Unknown',
        startDate: o.start_date,
        products: o.order_items?.map((item: any) => ({
          name: item.products?.name || 'Unknown Product',
          quantity: item.quantity,
        })) || [],
      })),
    };
  }
}

export const dashboardService = new DashboardService();
