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
import { format, differenceInDays, addDays, startOfDay, endOfDay, subDays } from 'date-fns';
import { reportService } from './reportService';

// ─── Shared Status Constants ────────────────────────────────────────────────────
// Single source of truth for which statuses count as "delivered" or "returned".
// Used by getOperationalMetrics(), getDailyReport(), and click-through URLs.

/** Statuses meaning delivery is still pending (order not yet picked up) */
const DELIVERY_PENDING_STATUSES = ['scheduled', 'pending', 'confirmed'];

/** Statuses meaning delivery was completed (order has been picked up / is active or done) */
const DELIVERY_DONE_STATUSES = ['ongoing', 'in_use', 'delivered', 'late_return', 'partial', 'returned', 'completed', 'flagged'];

/** Statuses meaning return is still pending (order is active with customer) */
const RETURN_PENDING_STATUSES = ['ongoing', 'in_use', 'late_return'];

/** Statuses meaning return was completed */
const RETURN_DONE_STATUSES = ['returned', 'completed', 'flagged'];

// ─── Types ─────────────────────────────────────────────────────────────────────

export interface OperationalCard {
  label: string;
  orderCount: number;
  icon: string;
  color: string;
  filterUrl: string;
  /** For progress cards (delivery/return): how many are completed */
  completedCount?: number;
  /** For progress cards (delivery/return): total expected */
  totalCount?: number;
  /** For revenue-related cards: total currency amount */
  amount?: number;
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
  pendingAmount: number;
  activeBalance?: number;
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
  salesPacing: {
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
    maintenanceCount: number;
    pendingApprovalCount: number;
  };
  dailyRevenue: {
    date: string;
    amount: number;
  }[];
  total_cash: number;
  total_upi: number;
  total_gpay: number;
  total_bank_transfer: number;
  total_amount_collection: number;
  bookingVelocity: {
    date: string;
    count: number;
  }[];
  total_booking_sales?: number;
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

// ─── Daily Report Types ────────────────────────────────────────────────────────

export interface DailyReportStats {
  todaysBookings: number;
  todaysSales: number;           // Total value of orders booked today
  todaysCollection: number;      // Total cash collected today
  todaysDelivery: { delivered: number; total: number };
  todaysReturn: { returned: number; total: number };
  todaysRevenue: number;         // Deprecated alias for todaysCollection
  damagedOrders: number;
  todaysRefunds: number;
  damageIncome: number;
  lateFeeIncome: number;
  mode_breakdown: {
    cash: number;
    upi: number;
    gpay: number;
    bank_transfer: number;
    other: number;
  };
  details: {
    bookings: { id: string; customer: string; amount: number }[];
    deliveries: { id: string; customer: string; status: string }[];
    returns: { id: string; customer: string; status: string }[];
    collections: { amount: number; mode: string; customer: string; orderId: string }[];
  };
}

// ─── Service ───────────────────────────────────────────────────────────────────

export class DashboardService {
  private getISTDateContext() {
    // 1. Get current time in IST
    const now = new Date();
    // Use Intl to get the current date string in IST
    const istDateStr = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Asia/Kolkata',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }).format(now); // "YYYY-MM-DD"

    // 2. Create the Start and End of that date in IST
    // 00:00:00 IST is 18:30:00 UTC of previous day
    const todayStart = new Date(`${istDateStr}T00:00:00+05:30`).toISOString();
    const todayEnd = new Date(`${istDateStr}T23:59:59+05:30`).toISOString();

    const istNow = new Date(now.toLocaleString('en-US', { timeZone: 'Asia/Kolkata' }));

    return {
      now: istNow,
      todayStart,
      todayEnd,
      todayStr: istDateStr,
      yesterdayStr: format(subDays(istNow, 1), 'yyyy-MM-dd'),
      tomorrowStr: format(addDays(istNow, 1), 'yyyy-MM-dd'),
      next5DaysStr: format(addDays(istNow, 5), 'yyyy-MM-dd'),
    };
  }

  /**
   * Operational Metrics — visible to ALL roles.
   * Returns 7 cards: Today's Booking, Today's Delivery, Today's Return,
   * Prepare Delivery (next 5 days), Pending Delivery, Pending Return, Revenue Due.
   */
  async getOperationalMetrics(): Promise<OperationalMetrics> {
    const supabase = createAdminClient();
    const { todayStart, todayEnd, todayStr, yesterdayStr, tomorrowStr, next5DaysStr } = this.getISTDateContext();

    // 1. Today's Bookings — orders created today
    const { data: todaysBookings } = await supabase
      .from('orders')
      .select('id')
      .gte('created_at', todayStart)
      .lte('created_at', todayEnd)
      .neq('status', 'cancelled');

    // 2a. Today's Delivery TOTAL — all non-cancelled orders with start_date = today
    const { data: todaysDeliveryTotal } = await supabase
      .from('orders')
      .select('id')
      .eq('start_date', todayStr)
      .neq('status', 'cancelled');

    // 2b. Today's Delivery DONE — start_date = today AND already picked up/active
    const { count: todaysDeliveryDoneCount } = await supabase
      .from('orders')
      .select('id', { count: 'exact', head: true })
      .eq('start_date', todayStr)
      .in('status', DELIVERY_DONE_STATUSES);

    // 3a. Today's Return TOTAL — all non-cancelled orders with end_date = today
    const { data: todaysReturnTotal } = await supabase
      .from('orders')
      .select('id')
      .eq('end_date', todayStr)
      .neq('status', 'cancelled');

    // 3b. Today's Return DONE — end_date = today AND already returned
    const { count: todaysReturnDoneCount } = await supabase
      .from('orders')
      .select('id', { count: 'exact', head: true })
      .eq('end_date', todayStr)
      .in('status', RETURN_DONE_STATUSES);

    // 4. Prepare Delivery — scheduled/pending orders starting within next 5 days
    const { data: prepareDeliveries } = await supabase
      .from('orders')
      .select('id')
      .gte('start_date', tomorrowStr)
      .lte('start_date', next5DaysStr)
      .in('status', DELIVERY_PENDING_STATUSES);

    // 5. Pending Delivery (overdue) — orders past start_date still in scheduled/pending
    const { data: pendingDeliveries } = await supabase
      .from('orders')
      .select('id')
      .lt('start_date', todayStr)
      .in('status', DELIVERY_PENDING_STATUSES);

    // 6. Pending Return (overdue) — orders past end_date still in ongoing/in_use/late_return
    const { data: pendingReturns } = await supabase
      .from('orders')
      .select('id')
      .lt('end_date', todayStr)
      .in('status', RETURN_PENDING_STATUSES);

    // 7. Revenue Due — orders returned/partial/flagged with balance
    const { data: revenueDueOrders } = await supabase
      .from('orders')
      .select('total_amount, amount_paid')
      .in('status', ['returned', 'partial', 'flagged', 'late_return'])
      .neq('payment_status', 'paid');

    const deliveryTotal = todaysDeliveryTotal?.length || 0;
    const deliveryDone = todaysDeliveryDoneCount || 0;
    const returnTotal = todaysReturnTotal?.length || 0;
    const returnDone = todaysReturnDoneCount || 0;

    const revenueDueTotalAmount = (revenueDueOrders || []).reduce(
      (sum, o) => {
        const due = Number(o.total_amount || 0) - Number(o.amount_paid || 0);
        return sum + (due > 0 ? due : 0);
      }, 
      0
    );

    const cards: OperationalCard[] = [
        {
          label: "Today's Bookings",
          orderCount: todaysBookings?.length || 0,
          icon: 'calendar-plus',
          color: 'blue',
          filterUrl: '/dashboard/orders?date_filter=today&exclude_status=cancelled',
        },
        {
          label: "Today's Delivery",
          orderCount: deliveryTotal,
          icon: 'truck',
          color: 'emerald',
          completedCount: deliveryDone,
          totalCount: deliveryTotal,
          filterUrl: '/dashboard/orders?date_filter=today&date_field=start_date&exclude_status=cancelled',
        },
        {
          label: "Today's Return",
          orderCount: returnTotal,
          icon: 'package-check',
          color: 'violet',
          completedCount: returnDone,
          totalCount: returnTotal,
          filterUrl: '/dashboard/orders?date_filter=today&date_field=end_date&exclude_status=cancelled',
        },
        {
          label: "Prepare Delivery (5d)",
          orderCount: prepareDeliveries?.length || 0,
          icon: 'boxes',
          color: 'amber',
          filterUrl: `/dashboard/orders?status=scheduled&status=pending&date_filter=custom&date_field=start_date&date_from=${tomorrowStr}&date_to=${next5DaysStr}`,
        },
        {
          label: "Pending Delivery",
          orderCount: pendingDeliveries?.length || 0,
          icon: 'alert-triangle',
          color: 'rose',
          filterUrl: '/dashboard/orders?status=pending',
        },
        {
          label: "Pending Return",
          orderCount: pendingReturns?.length || 0,
          icon: 'clock-alert',
          color: 'red',
          filterUrl: `/dashboard/orders?status=ongoing&status=in_use&status=late_return&date_filter=custom&date_field=end_date&date_to=${yesterdayStr}`,
        },
        {
          label: "Revenue Due",
          orderCount: revenueDueOrders?.length || 0,
          amount: revenueDueTotalAmount,
          icon: 'banknote',
          color: 'indigo',
          filterUrl: '/dashboard/orders?status=revenue_due',
        },
      ];

    // 7. Priority Cleaning — Scheduled urgent cleaning records
    // Fetch cleaning records that are scheduled or pending with urgent priority
    const { data: priorityCleaningRecords } = await supabase
      .from('cleaning_records')
      .select('id, product_id, quantity, expected_return_date, priority_order_id, notes, product:products(name)')
      .in('status', ['scheduled', 'pending'])
      .eq('priority', 'urgent')
      .order('expected_return_date', { ascending: true })
      .limit(10);

    const priorityCleaning: PriorityCleaningOrder[] = (priorityCleaningRecords || []).map((r: any) => ({
      id: r.priority_order_id || r.id,
      customerName: r.notes?.match(/Order #(\w+)/)?.[1] || 'Cleaning',
      startDate: r.expected_return_date || '',
      products: [{
        name: r.product?.name || 'Unknown',
        quantity: r.quantity || 0,
      }],
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
    branchId?: string | null,
    storeId?: string | null,
    overrides?: {
      categoryPeriod?: 'month' | 'year' | 'all';
      roiLimit?: number;
    }
  ): Promise<DashboardMetrics> {
    const supabase = createAdminClient();
    const { now, todayStr } = this.getISTDateContext();
    const startDateStr = startDate.toISOString();
    const endDateStr = endDate.toISOString();
    const prevStartDateStr = prevStartDate.toISOString();
    const prevEndDateStr = prevEndDate.toISOString();
    const ninetyDaysAgo = subDays(now, 90).toISOString();
    const velocityEndDate = addDays(now, 15).toISOString();
    const velocityEndDateStr = format(addDays(now, 15), 'yyyy-MM-dd');

    const roiLimit = overrides?.roiLimit || 3;
    let catStartDate = startDate;
    if (overrides?.categoryPeriod === 'year') {
      const d = new Date(); d.setFullYear(d.getFullYear() - 1); catStartDate = d;
    } else if (overrides?.categoryPeriod === 'all') {
      catStartDate = new Date(2000, 0, 1);
    }
    const catStartDateStr = catStartDate.toISOString();

    // Prepare optimized queries with branch filtering
    let completedQuery = supabase.from('orders').select('amount_paid').in('status', ['returned', 'completed']).gte('updated_at', startDateStr).lte('updated_at', endDateStr);
    if (branchId) completedQuery = completedQuery.eq('branch_id', branchId);
    
    let activeRentalsQuery = supabase.from('orders').select('total_amount, amount_paid').in('status', ['ongoing', 'in_use', 'late_return', 'partial', 'delivered']);
    if (branchId) activeRentalsQuery = activeRentalsQuery.eq('branch_id', branchId);
    
    let scheduledQuery = supabase.from('orders').select('advance_amount').in('status', ['scheduled', 'pending']).eq('advance_collected', true).gte('created_at', startDateStr).lte('created_at', endDateStr);
    if (branchId) scheduledQuery = scheduledQuery.eq('branch_id', branchId);
    
    let currentCancellationsQuery = supabase.from('orders').select('id', { count: 'exact', head: true }).eq('status', 'cancelled').gte('cancelled_at', startDateStr).lte('cancelled_at', endDateStr);
    if (branchId) currentCancellationsQuery = currentCancellationsQuery.eq('branch_id', branchId);
    
    let prevCancellationsQuery = supabase.from('orders').select('id', { count: 'exact', head: true }).eq('status', 'cancelled').gte('cancelled_at', prevStartDateStr).lte('cancelled_at', prevEndDateStr);
    if (branchId) prevCancellationsQuery = prevCancellationsQuery.eq('branch_id', branchId);
    
    let activeOrdersQuery = supabase.from('orders').select('id, status, end_date').in('status', ['ongoing', 'in_use', 'late_return', 'scheduled', 'pending']);
    if (branchId) activeOrdersQuery = activeOrdersQuery.eq('branch_id', branchId);
    
    let totalProductsQuery = supabase.from('products').select('id', { count: 'exact', head: true }).eq('is_active', true);
    if (branchId) totalProductsQuery = totalProductsQuery.eq('branch_id', branchId);
    
    let rentedItemsQuery = supabase.from('order_items').select('product_id, orders!inner(status, branch_id)').in('orders.status', ['ongoing', 'in_use', 'late_return', 'delivered', 'partial']);
    if (branchId) rentedItemsQuery = rentedItemsQuery.eq('orders.branch_id', branchId);
    
    let upcomingOrdersQuery = supabase.from('orders').select('start_date').gte('start_date', todayStr).lte('start_date', velocityEndDateStr).neq('status', 'cancelled');
    if (branchId) upcomingOrdersQuery = upcomingOrdersQuery.eq('branch_id', branchId);
    
    let roiItemsQuery = supabase.from('order_items').select('product_id, quantity, price_per_day, orders!inner(status, created_at, branch_id), products(name)').neq('orders.status', 'cancelled').gte('orders.created_at', startDateStr).lte('orders.created_at', endDateStr);
    if (branchId) roiItemsQuery = roiItemsQuery.eq('orders.branch_id', branchId);
    
    let catItemsQuery = supabase.from('order_items').select('quantity, price_per_day, orders!inner(status, created_at, branch_id), products(categories:category_id(name))').neq('orders.status', 'cancelled').gte('orders.created_at', catStartDateStr).lte('orders.created_at', endDateStr);
    if (branchId) catItemsQuery = catItemsQuery.eq('orders.branch_id', branchId);
    
    let deadStockQuery = supabase.from('order_items').select('product_id, orders!inner(created_at, branch_id)').gte('orders.created_at', ninetyDaysAgo);
    if (branchId) deadStockQuery = deadStockQuery.eq('orders.branch_id', branchId);
    
    let activeProductsQuery = supabase.from('products').select('id, name, price_per_day, created_at').eq('is_active', true);
    if (branchId) activeProductsQuery = activeProductsQuery.eq('branch_id', branchId);
    activeProductsQuery = activeProductsQuery.limit(100);
    
    let priorityCleaningQuery = supabase.from('cleaning_records').select('id, product_id, quantity, expected_return_date, priority_order_id, notes, product:products(name, branch_id)').in('status', ['scheduled', 'pending']).eq('priority', 'urgent');
    if (branchId) priorityCleaningQuery = priorityCleaningQuery.eq('products.branch_id', branchId);
    priorityCleaningQuery = priorityCleaningQuery.order('expected_return_date', { ascending: true }).limit(5);
    
    let pendingPaymentQuery = supabase.from('orders').select('total_amount, amount_paid').in('status', ['returned', 'completed']).in('payment_status', ['partial', 'pending', 'due']);
    if (branchId) pendingPaymentQuery = pendingPaymentQuery.eq('branch_id', branchId);

    // Kick off all queries in parallel
    const [
      currentMetrics,
      prevMetrics,
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
      priorityRes,
      pendingPaymentRes
    ] = await Promise.all([
      (async () => {
        console.log(`[DashboardService] Fetching metrics for branch:`, branchId);
        return reportService.getUnifiedRevenueMetrics(format(startDate, 'yyyy-MM-dd'), format(endDate, 'yyyy-MM-dd'), branchId);
      })(),
      reportService.getUnifiedRevenueMetrics(format(prevStartDate, 'yyyy-MM-dd'), format(prevEndDate, 'yyyy-MM-dd'), branchId),
      completedQuery,
      activeRentalsQuery,
      scheduledQuery,
      currentCancellationsQuery,
      prevCancellationsQuery,
      activeOrdersQuery,
      totalProductsQuery,
      rentedItemsQuery,
      upcomingOrdersQuery,
      roiItemsQuery.returns<any[]>(),
      catItemsQuery.returns<any[]>(),
      deadStockQuery.returns<any[]>(),
      activeProductsQuery,
      priorityCleaningQuery,
      pendingPaymentQuery
    ]);

    // Processing results
    // Processing results from Unified Metrics
    const currentRevenue = currentMetrics.total_amount_collection || 0;
    const prevRevenue = prevMetrics.total_amount_collection || 0;
    const currentSales = currentMetrics.total_booking_sales || 0;
    const prevSales = prevMetrics.total_booking_sales || 0;

    console.log('[DashboardMetrics] FINAL MAPPING:', { 
      currentRevenue, 
      currentSales,
      branchId
    });

    // Cap growth % at 999% to avoid misleading numbers when previous period is near-zero
    const calculateChange = (curr: number, prev: number) => {
      if (isNaN(curr) || isNaN(prev)) return 0;
      const raw = prev === 0 ? (curr > 0 ? 100 : 0) : ((curr - prev) / prev) * 100;
      return Math.min(Math.abs(raw), 999) * (raw >= 0 ? 1 : -1);
    };

    const revenueChange = calculateChange(currentRevenue, prevRevenue);
    const salesChange = calculateChange(currentSales, prevSales);

    // Use daily trends from unified metrics
    const dailyTrends = currentMetrics.dailyTrends;
    const total_cash = currentMetrics.total_cash;
    const total_upi = currentMetrics.total_upi;
    const total_gpay = currentMetrics.total_gpay;
    const total_bank_transfer = currentMetrics.total_bank_transfer;

    const dailyRevenue = dailyTrends.map(t => ({
      date: format(new Date(t.date), 'MMM dd'),
      amount: t.cash
    }));

    const completedRevenue = completedOrdersRes.data?.reduce((sum, o) => sum + Number(o.amount_paid || 0), 0) || 0;
    // Uncollected Active: money currently in the hands of customers for ongoing rentals
    const activeBalance = (ongoingOrdersRes.data || []).reduce((sum, o) => {
      const balance = Number(o.total_amount || 0) - Number(o.amount_paid || 0);
      return sum + Math.max(0, balance);
    }, 0);

    const pendingAmount = (pendingPaymentRes.data || []).reduce((sum, o) => {
      const balance = Number(o.total_amount || 0) - Number(o.amount_paid || 0);
      return sum + Math.max(0, balance);
    }, 0);

    const cancelCurrent = currentCancelRes.count || 0;
    const cancelPrev = prevCancelRes.count || 0;
    const cancelChange = cancelPrev === 0 ? 0 : ((cancelCurrent - cancelPrev) / cancelPrev) * 100;

    const overdueOrders = activeOrdersRes.data?.filter(o =>
      ['ongoing', 'in_use', 'late_return'].includes(o.status) && o.end_date < todayStr
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
        percentageChange: revenueChange,
        isPositive: revenueChange >= 0,
      },
      salesPacing: {
        current: currentSales,
        previous: prevSales,
        percentageChange: salesChange,
        isPositive: salesChange >= 0,
      },
      revenueByStatus: { completedRevenue, ongoingRevenue: 0, scheduledRevenue: 0, pendingAmount, activeBalance },
      cancellationStats: {
        currentCount: cancelCurrent,
        previousCount: cancelPrev,
        percentageChange: Math.abs(Math.round(cancelChange)),
        isPositive: cancelChange <= 0,
      },
      utilization: { percentage: utilizationPercentage, rentedOut, totalProducts },
      actionRequired: {
        totalIssues: overdueOrders.length + (priorityRes.data?.length || 0),
        overdueCount: overdueOrders.length,
        maintenanceCount: priorityRes.data?.length || 0,
        pendingApprovalCount: 0,
      },
      dailyRevenue,
      total_cash,
      total_upi,
      total_gpay,
      total_bank_transfer,
      total_amount_collection: currentRevenue,
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
      priorityCleaning: (priorityRes.data || []).map((r: any) => ({
        id: r.priority_order_id || r.id,
        customerName: r.notes?.match(/Order #(\w+)/)?.[1] || 'Cleaning',
        startDate: r.expected_return_date || '',
        products: [{
          name: r.product?.name || 'Unknown',
          quantity: r.quantity || 0,
        }],
      })),
    };
  }

  /**
   * Daily Report — admin-only today's cash reconciliation stats.
   * Returns 8 metrics for the "Today's Report" panel.
   */
  async getDailyReport(): Promise<DailyReportStats> {
    const supabase = createAdminClient();
    const { todayStart, todayEnd, todayStr: todayDateStr } = this.getISTDateContext();

    const [
      bookingsRes,
      todaySalesRes,
      deliveryTotalRes,
      deliveryDoneRes,
      returnTotalRes,
      returnDoneRes,
      revenueRes,
      damagedRes,
      refundRes,
      damageIncomeRes,
      lateFeeRes,
    ] = await Promise.all([
      // 1. Today's Bookings — count of orders created today
      supabase
        .from('orders')
        .select('id, total_amount, customer:customer_id(name)')
        .gte('created_at', todayStart)
        .lte('created_at', todayEnd)
        .neq('status', 'cancelled'),

      // 2. Today's Sales — total value of orders created today
      supabase
        .from('orders')
        .select('total_amount')
        .gte('created_at', todayStart)
        .lte('created_at', todayEnd)
        .neq('status', 'cancelled'),

      // 3. Today's Delivery TOTAL
      supabase
        .from('orders')
        .select('id, status, customer:customer_id(name)')
        .eq('start_date', todayDateStr)
        .neq('status', 'cancelled'),

      // 4. Today's Delivery DONE
      supabase
        .from('orders')
        .select('id', { count: 'exact', head: true })
        .eq('start_date', todayDateStr)
        .in('status', DELIVERY_DONE_STATUSES),

      // 5. Today's Return TOTAL
      supabase
        .from('orders')
        .select('id, status, customer:customer_id(name)')
        .eq('end_date', todayDateStr)
        .neq('status', 'cancelled'),

      // 6. Today's Return DONE
      supabase
        .from('orders')
        .select('id', { count: 'exact', head: true })
        .eq('end_date', todayDateStr)
        .in('status', RETURN_DONE_STATUSES),

      // 7. Today's Payments (Cash Collection)
      supabase
        .from('payments')
        .select('amount, payment_date, payment_mode, orders(id, customer:customer_id(name))')
        .gte('payment_date', todayStart)
        .lte('payment_date', todayEnd)
        .neq('payment_type', 'refund'),

      // 8. Damaged Orders (Today only)
      supabase
        .from('order_status_history')
        .select('id', { count: 'exact', head: true })
        .eq('status', 'flagged')
        .gte('created_at', todayStart)
        .lte('created_at', todayEnd),

      // 9. Today's Refunds
      supabase
        .from('payments')
        .select('amount')
        .gte('payment_date', todayStart)
        .lte('payment_date', todayEnd)
        .eq('payment_type', 'refund'),

      // 10. Damage Income (Accrual)
      supabase
        .from('orders')
        .select('damage_charges_total')
        .gt('damage_charges_total', 0)
        .gte('updated_at', todayStart)
        .lte('updated_at', todayEnd),

      // 11. Late Fee Income (Accrual)
      supabase
        .from('orders')
        .select('late_fee')
        .gt('late_fee', 0)
        .gte('updated_at', todayStart)
        .lte('updated_at', todayEnd),
    ]);

    const bookingList = (bookingsRes.data || []) as any[];
    const deliveryList = (deliveryTotalRes.data || []) as any[];
    const returnList = (returnTotalRes.data || []) as any[];
    const revenueList = (revenueRes.data || []) as any[];

    const todaysCollection = revenueList.reduce(
      (sum, p) => sum + Number(p.amount || 0), 0
    );

    // 8. Breakdown calculations
    const r = (n: number) => {
      const val = Math.round(n * 100) / 100;
      return isNaN(val) ? 0 : val;
    };

    const mode_breakdown = { cash: 0, upi: 0, gpay: 0, bank_transfer: 0, other: 0 };
    revenueList.forEach(p => {
      const mode = (p.payment_mode || '').toLowerCase();
      const amount = Number(p.amount || 0);
      if (isNaN(amount)) return;

      if (mode === 'cash') mode_breakdown.cash += amount;
      else if (mode === 'upi') mode_breakdown.upi += amount;
      else if (mode === 'gpay') mode_breakdown.gpay += amount;
      else if (mode === 'bank_transfer') mode_breakdown.bank_transfer += amount;
      else mode_breakdown.other += amount;
    });

    // Sanitize breakdown with rounding
    mode_breakdown.cash = r(mode_breakdown.cash);
    mode_breakdown.upi = r(mode_breakdown.upi);
    mode_breakdown.gpay = r(mode_breakdown.gpay);
    mode_breakdown.bank_transfer = r(mode_breakdown.bank_transfer);
    mode_breakdown.other = r(mode_breakdown.other);

    const todaysSales = bookingList.reduce(
      (sum, o) => sum + Number(o.total_amount || 0), 0
    );
    const todaysRefunds = (refundRes.data || []).reduce(
      (sum, p) => sum + Number(p.amount || 0), 0
    );
    const damageIncome = (damageIncomeRes.data || []).reduce(
      (sum, o) => sum + Number(o.damage_charges_total || 0), 0
    );
    const lateFeeIncome = (lateFeeRes.data || []).reduce(
      (sum, o) => sum + Number(o.late_fee || 0), 0
    );

    return {
      todaysBookings: bookingList.length,
      todaysSales,
      todaysCollection,
      todaysDelivery: {
        delivered: deliveryDoneRes.count || 0,
        total: deliveryList.length,
      },
      todaysReturn: {
        returned: returnDoneRes.count || 0,
        total: returnList.length,
      },
      todaysRevenue: todaysCollection,
      damagedOrders: damagedRes.count || 0,
      todaysRefunds,
      damageIncome,
      lateFeeIncome,
      mode_breakdown,
      details: {
        bookings: bookingList.map(o => ({ id: o.id, customer: o.customer?.name || 'Walk-in', amount: o.total_amount })),
        deliveries: deliveryList.map(o => ({ id: o.id, customer: o.customer?.name || 'Walk-in', status: o.status })),
        returns: returnList.map(o => ({ id: o.id, customer: o.customer?.name || 'Walk-in', status: o.status })),
        collections: revenueList.map(p => ({
          amount: p.amount,
          mode: p.payment_mode,
          customer: p.orders?.customer?.name || 'Walk-in',
          orderId: p.orders?.id?.substring(0, 8) || 'N/A'
        }))
      }
    };
  }
}

export const dashboardService = new DashboardService();
