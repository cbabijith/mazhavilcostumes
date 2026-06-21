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
const DELIVERY_DONE_STATUSES = ['ongoing', 'in_use', 'delivered', 'partial', 'returned', 'completed', 'flagged'];

/** Statuses meaning return is still pending (order is active with customer) */
const RETURN_PENDING_STATUSES = ['ongoing', 'in_use'];

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
  revenueDue: {
    amount: number;
    orderCount: number;
  };
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
  // In-memory cache for dashboard metrics
  // Operational metrics: no cache (real-time data needed)
  // Admin metrics: 30 second cache (expensive analytics queries)
  // Daily report: 30 second cache (cash reconciliation stats)
  private lastMetrics: Record<string, { data: DashboardMetrics; timestamp: number }> = {};
  private lastDailyReport: { data: DailyReportStats; timestamp: number } | null = null;

  /**
   * Clears all in-memory dashboard metric caches.
   * Invoked automatically whenever orders, payments, or collections are modified.
   */
  public clearCache(): void {
    console.log('[DashboardService] Cache invalidated due to data mutations');
    this.lastMetrics = {};
    this.lastDailyReport = null;
  }

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
  async getOperationalMetrics(branchId?: string): Promise<OperationalMetrics> {
    // No caching for operational metrics - need real-time data
    const supabase = createAdminClient();
    const { todayStart, todayEnd, todayStr, yesterdayStr, tomorrowStr, next5DaysStr } = this.getISTDateContext();

    const { data, error } = await supabase.rpc('get_operational_dashboard_metrics', {
      p_today_start: todayStart,
      p_today_end: todayEnd,
      p_today_date: todayStr,
      p_yesterday_date: yesterdayStr,
      p_tomorrow_date: tomorrowStr,
      p_next_5_days_date: next5DaysStr,
      p_branch_id: branchId,
    });

    if (error) {
      console.error('[DashboardService] Error fetching operational metrics RPC:', error);
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
      priorityCleaning: [],
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

    const priorityCleaning: PriorityCleaningOrder[] = (rpcData.priorityCleaning || []).map((r: any) => ({
      id: r.priority_order_id || r.id,
      customerName: r.notes?.match(/Order #(\w+)/)?.[1] || 'Cleaning',
      startDate: r.expected_return_date || '',
      products: [{
        name: r.product?.name || 'Unknown',
        quantity: r.quantity || 0,
      }],
    }));

    const result = {
      cards,
      priorityCleaning,
    };

    return result;
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
    const nowMs = Date.now();
    const roundTo10Sec = (d: Date) => Math.floor(d.getTime() / 10000) * 10000;
    const cacheKey = JSON.stringify({
      startDate: roundTo10Sec(startDate),
      endDate: roundTo10Sec(endDate),
      prevStartDate: roundTo10Sec(prevStartDate),
      prevEndDate: roundTo10Sec(prevEndDate),
      branchId,
      storeId,
      categoryPeriod: overrides?.categoryPeriod,
      roiLimit: overrides?.roiLimit,
    });

    if (this.lastMetrics[cacheKey] && (nowMs - this.lastMetrics[cacheKey].timestamp < 30000)) {
      console.log('[DashboardService] Returning cached admin metrics');
      return this.lastMetrics[cacheKey].data;
    }

    const supabase = createAdminClient();
    const { now, todayStr } = this.getISTDateContext();
    const startDateStr = startDate.toISOString();
    const endDateStr = endDate.toISOString();
    const prevStartDateStr = prevStartDate.toISOString();
    const prevEndDateStr = prevEndDate.toISOString();
    const ninetyDaysAgo = subDays(now, 90).toISOString();
    const velocityEndDateStr = format(addDays(now, 15), 'yyyy-MM-dd');

    const roiLimit = overrides?.roiLimit || 3;
    let catStartDate = startDate;
    if (overrides?.categoryPeriod === 'year') {
      const d = new Date(); d.setFullYear(d.getFullYear() - 1); catStartDate = d;
    } else if (overrides?.categoryPeriod === 'all') {
      catStartDate = new Date(2000, 0, 1);
    }
    const catStartDateStr = catStartDate.toISOString();

    // 1. Unified orders query to fetch data for completed orders in range, active rentals, and pending payment orders
    const activeStatuses = 'ongoing,in_use,partial,delivered,scheduled,pending';
    const completedStatuses = 'returned,completed';
    const paymentDueStatuses = 'partial,pending,due';

    const ordersOrFilter = `status.in.(${activeStatuses}),and(status.in.(${completedStatuses}),payment_status.in.(${paymentDueStatuses})),and(status.in.(${completedStatuses}),updated_at.gte.${startDateStr},updated_at.lte.${endDateStr})`;
    
    let ordersQuery = supabase.from('orders')
      .select('id, status, payment_status, total_amount, amount_paid, updated_at, end_date, invoice_number')
      .or(ordersOrFilter);
    if (branchId) ordersQuery = ordersQuery.eq('branch_id', branchId);

    // 2. Cancellations query in a single round-trip for both periods
    let cancellationsQuery = supabase.from('orders')
      .select('cancelled_at')
      .eq('status', 'cancelled')
      .gte('cancelled_at', prevStartDateStr)
      .lte('cancelled_at', endDateStr);
    if (branchId) cancellationsQuery = cancellationsQuery.eq('branch_id', branchId);

    // 3. Total active products count
    let totalProductsQuery = supabase.from('products').select('id', { count: 'exact', head: true }).eq('is_active', true);
    if (branchId) totalProductsQuery = totalProductsQuery.eq('branch_id', branchId);

    // 4. Rented items query
    let rentedItemsQuery = supabase.from('order_items').select('product_id, orders!inner(status, branch_id)').in('orders.status', ['ongoing', 'in_use', 'delivered', 'partial']);
    if (branchId) rentedItemsQuery = rentedItemsQuery.eq('orders.branch_id', branchId);

    // 5. Booking velocity query
    let upcomingOrdersQuery = supabase.from('orders').select('start_date').gte('start_date', todayStr).lte('start_date', velocityEndDateStr).neq('status', 'cancelled');
    if (branchId) upcomingOrdersQuery = upcomingOrdersQuery.eq('branch_id', branchId);

    // 6. Combined ROI & Category query
    let combinedItemsQuery = supabase.from('order_items')
      .select(`
        product_id,
        quantity,
        price_per_day,
        orders!inner(status, created_at, branch_id),
        products(name, categories:category_id(name))
      `)
      .neq('orders.status', 'cancelled')
      .gte('orders.created_at', catStartDateStr)
      .lte('orders.created_at', endDateStr);
    if (branchId) combinedItemsQuery = combinedItemsQuery.eq('orders.branch_id', branchId);

    // 7. Priority cleaning records query
    let priorityCleaningQuery = supabase.from('cleaning_records').select('id, product_id, quantity, expected_return_date, priority_order_id, notes, product:products(name, branch_id)').in('status', ['scheduled', 'pending']).eq('priority', 'urgent');
    if (branchId) priorityCleaningQuery = priorityCleaningQuery.eq('products.branch_id', branchId);
    priorityCleaningQuery = priorityCleaningQuery.order('expected_return_date', { ascending: true }).limit(5);

    // Execute in parallel
    const [
      currentMetrics,
      prevMetrics,
      ordersRes,
      cancellationsRes,
      totalProductsRes,
      rentedItemsRes,
      upcomingOrdersRes,
      combinedItemsRes,
      deadStockRes,
      priorityRes
    ] = await Promise.all([
      reportService.getUnifiedRevenueMetrics(format(startDate, 'yyyy-MM-dd'), format(endDate, 'yyyy-MM-dd'), branchId),
      reportService.getUnifiedRevenueMetrics(format(prevStartDate, 'yyyy-MM-dd'), format(prevEndDate, 'yyyy-MM-dd'), branchId),
      ordersQuery,
      cancellationsQuery,
      totalProductsQuery,
      rentedItemsQuery,
      upcomingOrdersQuery,
      combinedItemsQuery.returns<any[]>(),
      supabase.rpc('get_dead_stock', {
        p_ninety_days_ago: ninetyDaysAgo,
        p_branch_id: branchId || null
      }),
      priorityCleaningQuery
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

    // Parse the unified orders data
    const ordersData = ordersRes.data || [];

    const completedOrdersData = ordersData.filter(o => 
      ['returned', 'completed'].includes(o.status) && 
      o.updated_at >= startDateStr && 
      o.updated_at <= endDateStr
    );
    const ongoingOrdersData = ordersData.filter(o =>
      ['ongoing', 'in_use', 'partial', 'delivered'].includes(o.status)
    );
    const pendingPaymentData = ordersData.filter(o => 
      ['returned', 'completed'].includes(o.status) && 
      ['partial', 'pending', 'due'].includes(o.payment_status)
    );
    const activeOrdersData = ordersData.filter(o =>
      ['ongoing', 'in_use', 'scheduled', 'pending'].includes(o.status)
    );

    const completedRevenue = completedOrdersData.reduce((sum, o) => sum + Number(o.amount_paid || 0), 0);
    
    // Uncollected Active: money currently in the hands of customers for ongoing rentals
    const activeBalance = ongoingOrdersData.reduce((sum, o) => {
      const balance = Number(o.total_amount || 0) - Number(o.amount_paid || 0);
      return sum + Math.max(0, balance);
    }, 0);

    const pendingAmount = pendingPaymentData.reduce((sum, o) => {
      const balance = Number(o.total_amount || 0) - Number(o.amount_paid || 0);
      return sum + Math.max(0, balance);
    }, 0);

    // Process cancellation counts
    const cancellationsData = cancellationsRes.data || [];
    const cancelCurrent = cancellationsData.filter(o => o.cancelled_at >= startDateStr && o.cancelled_at <= endDateStr).length;
    const cancelPrev = cancellationsData.filter(o => o.cancelled_at >= prevStartDateStr && o.cancelled_at <= prevEndDateStr).length;
    const cancelChange = cancelPrev === 0 ? 0 : ((cancelCurrent - cancelPrev) / cancelPrev) * 100;

    const overdueOrders = activeOrdersData.filter(o =>
      ['ongoing', 'in_use'].includes(o.status) && o.end_date < todayStr
    );

    const totalProducts = totalProductsRes.count || 0;
    const uniqueRentedProducts = new Set((rentedItemsRes.data || []).map((i: any) => i.product_id));
    const rentedOut = uniqueRentedProducts.size;
    const utilizationPercentage = totalProducts > 0 ? Math.round((rentedOut / totalProducts) * 100) : 0;

    const velocityMap = new Map<string, number>();
    (upcomingOrdersRes.data || []).forEach(order => {
      const dateStr = format(new Date(order.start_date), 'yyyy-MM-dd');
      velocityMap.set(dateStr, (velocityMap.get(dateStr) || 0) + 1);
    });

    const bookingVelocity = Array.from({ length: 15 }).map((_, i) => {
      const d = addDays(now, i);
      const dateStr = format(d, 'yyyy-MM-dd');
      return { date: format(d, 'MMM dd'), count: velocityMap.get(dateStr) || 0 };
    });

    // ROI Processing (filtering the combined list client-side for dates >= startDateStr)
    const productStats = new Map<string, { name: string; rentals: number; revenue: number }>();
    const roiItems = (combinedItemsRes.data || []).filter((item: any) => item.orders && item.orders.created_at >= startDateStr);
    roiItems.forEach((item: any) => {
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

    // Category Processing (using the full range of the combined query)
    const categoryRevenueMap = new Map<string, { name: string; revenue: number }>();
    (combinedItemsRes.data || []).forEach((item: any) => {
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
    const deadStock = (deadStockRes.data || []).map((row: any) => ({
      id: row.id,
      name: row.name,
      daysIdle: Number(row.days_idle || 0),
      value: Number(row.value || 0),
    }));

    const result: DashboardMetrics = {
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
        message: `Order ${o.invoice_number || '#' + o.id.substring(0, 8)} is overdue for return`,
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

    this.lastMetrics[cacheKey] = {
      data: result,
      timestamp: nowMs,
    };

    return result;
  }

  /**
   * Daily Report — admin-only today's cash reconciliation stats.
   * Returns 8 metrics for the "Today's Report" panel.
   */
  async getDailyReport(): Promise<DailyReportStats> {
    const nowMs = Date.now();
    if (this.lastDailyReport && (nowMs - this.lastDailyReport.timestamp < 30000)) {
      console.log('[DashboardService] Returning cached daily report');
      return this.lastDailyReport.data;
    }

    const supabase = createAdminClient();
    const { todayStart, todayEnd, todayStr: todayDateStr } = this.getISTDateContext();

    const [
      bookingsRes,
      deliveryTotalRes,
      returnTotalRes,
      paymentsRes,
      damagedRes,
      chargesRes,
      revenueDueRes,
    ] = await Promise.all([
      // 1. Today's Bookings — count of orders created today
      supabase
        .from('orders')
        .select('id, total_amount, customer:customer_id(name)')
        .gte('created_at', todayStart)
        .lte('created_at', todayEnd)
        .neq('status', 'cancelled'),

      // 2. Today's Delivery TOTAL
      supabase
        .from('orders')
        .select('id, status, customer:customer_id(name)')
        .eq('start_date', todayDateStr)
        .neq('status', 'cancelled'),

      // 3. Today's Return TOTAL
      supabase
        .from('orders')
        .select('id, status, customer:customer_id(name)')
        .eq('end_date', todayDateStr)
        .neq('status', 'cancelled'),

      // 4. Today's Payments & Refunds
      supabase
        .from('payments')
        .select('amount, payment_date, payment_mode, payment_type, orders(id, customer:customer_id(name))')
        .gte('payment_date', todayStart)
        .lte('payment_date', todayEnd),

      // 5. Damaged Orders (Today only)
      supabase
        .from('order_status_history')
        .select('id', { count: 'exact', head: true })
        .eq('status', 'flagged')
        .gte('created_at', todayStart)
        .lte('created_at', todayEnd),

      // 6. Today's Accrued Damage charges & Late fees
      supabase
        .from('orders')
        .select('damage_charges_total, late_fee')
        .gte('updated_at', todayStart)
        .lte('updated_at', todayEnd)
        .or('damage_charges_total.gt.0,late_fee.gt.0'),

      // 7. Revenue Due (all outstanding balance across history, to remind daily)
      supabase
        .from('orders')
        .select('total_amount, amount_paid')
        .in('status', ['returned', 'partial', 'flagged'])
        .neq('payment_status', 'paid'),
    ]);

    const bookingList = (bookingsRes.data || []) as any[];
    const deliveryList = (deliveryTotalRes.data || []) as any[];
    const returnList = (returnTotalRes.data || []) as any[];
    const paymentList = (paymentsRes.data || []) as any[];
    const revenueDueOrders = (revenueDueRes.data || []) as any[];

    // Separate payments into collections and refunds client-side
    const revenueList = paymentList.filter(p => p.payment_type !== 'refund');
    const refundList = paymentList.filter(p => p.payment_type === 'refund');

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
    const todaysRefunds = refundList.reduce(
      (sum, p) => sum + Number(p.amount || 0), 0
    );

    // Sum dynamic accrued charges client-side
    const chargesList = chargesRes.data || [];
    const damageIncome = chargesList.reduce(
      (sum, o) => sum + Number(o.damage_charges_total || 0), 0
    );
    const lateFeeIncome = chargesList.reduce(
      (sum, o) => sum + Number(o.late_fee || 0), 0
    );
    
    const revenueDueTotalAmount = revenueDueOrders.reduce(
      (sum, o) => {
        const due = Number(o.total_amount || 0) - Number(o.amount_paid || 0);
        return sum + (due > 0 ? due : 0);
      }, 
      0
    );

    // Compute progress card counts client-side
    const deliveryDoneCount = deliveryList.filter(o => DELIVERY_DONE_STATUSES.includes(o.status)).length;
    const returnDoneCount = returnList.filter(o => RETURN_DONE_STATUSES.includes(o.status)).length;

    const result: DailyReportStats = {
      todaysBookings: bookingList.length,
      todaysSales,
      todaysCollection,
      todaysDelivery: {
        delivered: deliveryDoneCount,
        total: deliveryList.length,
      },
      todaysReturn: {
        returned: returnDoneCount,
        total: returnList.length,
      },
      todaysRevenue: todaysCollection,
      damagedOrders: damagedRes.count || 0,
      todaysRefunds,
      damageIncome,
      lateFeeIncome,
      revenueDue: {
        amount: revenueDueTotalAmount,
        orderCount: revenueDueOrders.length,
      },
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

    this.lastDailyReport = {
      data: result,
      timestamp: nowMs,
    };

    return result;
  }
}

export const dashboardService = new DashboardService();
