/**
 * Report Service
 *
 * Business logic layer for all 11 reports (R1–R11).
 * Queries Supabase directly using the admin client.
 *
 * @module services/reportService
 */

import { createAdminClient } from '@/lib/supabase/server';
import { settingsService } from './settingsService';
import type {
  ReportFilters,
  DayWiseBookingRow,
  DueOverdueRow,
  RevenueRow,
  RevenueDetailRow,
  RevenueReportData,
  TopCostumeRow,
  TopCustomerRow,
  RentalFrequencyRow,
  ROIRow,
  DeadStockRow,
  SalesByStaffRow,
  InventoryRevenueRow,
  CustomerEnquiry,
  CreateEnquiryDTO,
} from '@/domain';

const supabase = () => createAdminClient();

export class ReportService {
  private getISTDateContext() {
    const now = new Date();
    // Use Intl to get the current date string in IST consistently
    const istDateStr = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Asia/Kolkata',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }).format(now); // "YYYY-MM-DD"

    return {
      now,
      today: istDateStr,
    };
  }

  private formatISTQueryRange(fromDate: string, toDate: string) {
    return {
      start: `${fromDate}T00:00:00+05:30`,
      end: `${toDate}T23:59:59+05:30`,
    };
  }

  /**
   * Fetch ALL rows for a query by paging past Supabase/PostgREST's 1000-row
   * response cap. Without this, any report query that can exceed 1000 rows
   * (payments for a year, all order_items, etc.) silently drops the newest
   * rows and the report looks "frozen" at an arbitrary date.
   *
   * The builder receives a zero-based range and must apply stable ordering
   * (unique column, e.g. id) so pages don't overlap/skip.
   */
  private async fetchAllPages<T = any>(
    buildPage: (from: number, to: number) => any,
    pageSize = 1000
  ): Promise<T[]> {
    const first = await buildPage(0, pageSize - 1);
    if (first.error) throw new Error(first.error.message);
    const all: T[] = [...((first.data || []) as T[])];
    const total = typeof first.count === 'number' ? first.count : all.length;

    while (all.length < total) {
      const page = await buildPage(all.length, all.length + pageSize - 1);
      if (page.error) throw new Error(page.error.message);
      if (!page.data || page.data.length === 0) break;
      all.push(...(page.data as T[]));
    }
    return all;
  }

  /** R1: Day-wise booking */
  async getDayWiseBooking(filters: ReportFilters): Promise<DayWiseBookingRow[]> {
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || today;
    const toDate = filters.to_date || today;

    const data = await this.fetchAllPages((from, to) =>
      supabase()
        .from('orders')
        .select('id, status, start_date, end_date, total_amount, customer:customer_id(name, phone), order_items(product:product_id(name))', { count: 'exact' })
        .gte('start_date', fromDate)
        .lte('start_date', toDate)
        .in('status', ['scheduled', 'pending', 'confirmed', 'ongoing', 'in_use', 'delivered'])
        .order('id', { ascending: true })
        .range(from, to)
    );

    return (data as any[]).map((o: any) => ({
      order_id: o.id,
      customer_name: o.customer?.name || 'Unknown',
      customer_phone: o.customer?.phone || '',
      product_names: (o.order_items || []).map((i: any) => i.product?.name).filter(Boolean).join(', '),
      start_date: o.start_date,
      end_date: o.end_date,
      total_amount: Number(o.total_amount || 0),
      status: o.status,
    }));
  }

  /** R2: Due / Overdue */
  async getDueOverdue(filters: ReportFilters): Promise<DueOverdueRow[]> {
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || today;
    const toDate = filters.to_date || today;

    const data = await this.fetchAllPages((from, to) =>
      supabase()
        .from('orders')
        .select('id, status, end_date, total_amount, amount_paid, customer:customer_id(name, phone), order_items(product:product_id(name))', { count: 'exact' })
        .lte('end_date', toDate)
        .gte('end_date', fromDate)
        .in('status', ['ongoing', 'in_use', 'delivered'])
        .order('id', { ascending: true })
        .range(from, to)
    );

    return (data as any[]).map((o: any) => {
      const returnDate = new Date(o.end_date);
      const todayDate = new Date(today);
      const diffTime = todayDate.getTime() - returnDate.getTime();
      const daysOverdue = Math.max(0, Math.floor(diffTime / (1000 * 60 * 60 * 24)));
      
      // Dynamically determine status for the report
      let displayStatus = o.status;
      if (daysOverdue > 0 && ['ongoing', 'in_use', 'delivered', 'pending'].includes(o.status)) {
        displayStatus = 'overdue';
      }

      return {
        order_id: o.id,
        customer_name: o.customer?.name || 'Unknown',
        customer_phone: o.customer?.phone || '',
        product_names: (o.order_items || []).map((i: any) => i.product?.name).filter(Boolean).join(', '),
        end_date: o.end_date,
        days_overdue: daysOverdue,
        total_amount: o.total_amount,
        amount_paid: o.amount_paid,
        balance: Math.max(0, o.total_amount - o.amount_paid),
        status: displayStatus,
      };
    });
  }

  /** R3: Revenue report - "Fair" Version with Sales vs Cash Separation */
  async getRevenue(filters: ReportFilters, branchId?: string | null, storeId?: string | null): Promise<RevenueReportData> {
    const period = filters.period || 'month';
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || this.getPeriodStart(period);
    const toDate = filters.to_date || today;
    const limit = filters.limit || 50;
    const page = filters.page || 1;
    const range = this.formatISTQueryRange(fromDate, toDate);
    
    // Resolve status filter for filtering payments by order status
    const statusFilter = filters.status?.length ? filters.status : null;

    // Use unified metrics helper for the summary part
    const metrics = await this.getUnifiedRevenueMetrics(fromDate, toDate, branchId, storeId, statusFilter);
    
    const offset = (page - 1) * limit;

    // 3. Fetch Paginated Details for the table
    let detailsQuery = supabase()
      .from('payments')
      .select(`
        id,
        amount,
        payment_mode,
        payment_type,
        payment_date,
        created_at,
        order:order_id!inner (
          id,
          status,
          branch_id,
          store_id,
          customer:customer_id (
            name
          )
        )
      `, { count: 'exact' })
      .gte('payment_date', range.start)
      .lte('payment_date', range.end)
      .order('payment_date', { ascending: false })
      .range(offset, offset + limit - 1);

    if (branchId) detailsQuery = detailsQuery.eq('order.branch_id', branchId);
    if (storeId) detailsQuery = detailsQuery.eq('order.store_id', storeId);

    if (filters.payment_mode && filters.payment_mode !== 'all') {
      detailsQuery = detailsQuery.eq('payment_mode', filters.payment_mode);
    }

    const { data: rawDetails, count: totalDetailsCount, error: detailsError } = await detailsQuery;
    if (detailsError) throw new Error(detailsError.message);

    const detailsData = (statusFilter && statusFilter.length > 0)
      ? (rawDetails || []).filter(p => p.order && statusFilter.includes((p.order as any).status))
      : (rawDetails || []);

    const formattedDetails = detailsData.map((p: any) => ({
      order_id: p.order?.id,
      customer_name: p.order?.customer?.name || 'Walk-in',
      date: p.payment_date,
      amount: p.payment_type === 'refund' || p.payment_type === 'cancelled_keep' ? -Number(p.amount) : Number(p.amount),
      payment_mode: p.payment_mode,
      payment_type: p.payment_type,
      status: p.order?.status
    }));

    return {
      summary: (metrics.summary as any[]),
      details: formattedDetails as any[],
      total_booking_sales: metrics.total_booking_sales,
      total_cash_collection: metrics.total_cash_collection,
      total_received: metrics.total_received,
      total_amount_collection: metrics.total_amount_collection,
      total_collected: metrics.total_amount_collection, // Backward compatibility
      total_net_revenue: metrics.total_net_revenue,
      total_gst_collected: metrics.total_gst_collected,
      total_refunded: metrics.total_refunded,
      refund_due: metrics.refund_due,
      revenue_due: metrics.revenue_due,
      revenue_due_count: metrics.revenue_due_count,
      cancelled_total: metrics.cancelled_total,
      total_cash: metrics.total_cash,
      total_upi: metrics.total_upi,
      total_gpay: metrics.total_gpay,
      total_bank_transfer: metrics.total_bank_transfer,
      total_damage_charges: metrics.total_damage_charges,
      total_late_fees: metrics.total_late_fees,
      total_details_count: statusFilter ? detailsData.length : (totalDetailsCount || 0),
    };
  }

  /**
   * Unified Revenue Metrics Helper
   * Shared between getRevenue (Report) and Dashboard
   */
  public async getUnifiedRevenueMetrics(
    fromDate: string, 
    toDate: string, 
    branchId?: string | null, 
    storeId?: string | null,
    statusFilter?: string[] | null
  ) {
    const range = this.formatISTQueryRange(fromDate, toDate);

    // 1. Fetch Aggregation Data — includes refunds and order details for GST calc
    //    (paged: a year/all-time window holds 1499+ payment rows today)
    const buildAggPage = (from: number, to: number) => {
      let q = supabase()
        .from('payments')
        .select(`
          amount,
          payment_mode,
          payment_type,
          payment_date,
          created_at,
          order:order_id!inner (
            id,
            status,
            payment_status,
            total_amount,
            gst_amount,
            branch_id,
            store_id,
            customer:customer_id(name)
          )
        `, { count: 'exact' })
        .gte('payment_date', range.start)
        .lte('payment_date', range.end)
        .order('id', { ascending: true })
        .range(from, to);

      if (branchId) q = q.eq('order.branch_id', branchId);
      if (storeId) q = q.eq('order.store_id', storeId);
      return q;
    };

    // 2. Fetch Orders created in this period (for "Booking Sales")
    const buildBookingPage = (from: number, to: number) => {
      let q = supabase()
        .from('orders')
        .select('id, total_amount, created_at, status', { count: 'exact' })
        .gte('created_at', range.start)
        .lte('created_at', range.end)
        .neq('status', 'cancelled') // Don't count cancelled orders in "won business"
        .order('id', { ascending: true })
        .range(from, to);

      if (branchId) q = q.eq('branch_id', branchId);
      if (storeId) q = q.eq('store_id', storeId);
      return q;
    };

    // 4. Fetch cancelled orders with unrefunded money (for refund_due)
    const buildCancelledPage = (from: number, to: number) => {
      let q = supabase()
        .from('orders')
        .select('id, amount_paid, payment_status', { count: 'exact' })
        .eq('status', 'cancelled')
        .gt('amount_paid', 0)
        .neq('payment_status', 'refund_waived')
        .order('id', { ascending: true })
        .range(from, to);

      if (branchId) q = q.eq('branch_id', branchId);
      return q;
    };

    // 5. Fetch all orders in range to calculate Revenue Due (outstanding balance)
    const buildRevenueDuePage = (from: number, to: number) => {
      let q = supabase()
        .from('orders')
        .select('id, total_amount, amount_paid, start_date, status, payment_status', { count: 'exact' })
        .gte('start_date', fromDate)
        .lte('start_date', toDate)
        .in('status', ['returned', 'partial', 'flagged'])
        .neq('payment_status', 'paid')
        .order('id', { ascending: true })
        .range(from, to);

      if (branchId) q = q.eq('branch_id', branchId);
      if (storeId) q = q.eq('store_id', storeId);
      return q;
    };

    // 6. Fetch damage charges and late fees (Accrual view)
    const buildDueChargesPage = (from: number, to: number) => {
      let q = supabase()
        .from('orders')
        .select('damage_charges_total, late_fee', { count: 'exact' })
        .gte('updated_at', range.start)
        .lte('updated_at', range.end)
        .or('damage_charges_total.gt.0,late_fee.gt.0')
        .order('id', { ascending: true })
        .range(from, to);

      if (branchId) q = q.eq('branch_id', branchId);
      if (storeId) q = q.eq('store_id', storeId);
      return q;
    };

    // Execute in parallel (each internally paged past the 1000-row cap)
    const [aggData, bookings, cancelledOrders, revenueDueData, dueChargesResult] = await Promise.all([
      this.fetchAllPages(buildAggPage),
      this.fetchAllPages(buildBookingPage),
      this.fetchAllPages(buildCancelledPage),
      this.fetchAllPages(buildRevenueDuePage),
      this.fetchAllPages(buildDueChargesPage),
    ]);

    // Filter payments client-side if status filter is active
    const rawPayments = aggData as any[];
    const allPayments = (statusFilter && statusFilter.length > 0)
      ? rawPayments.filter(p => p.order && statusFilter.includes((p.order as any).status))
      : rawPayments;

    // GST-per-order source of truth for the cash-basis card: item-level
    // gst_amount sums. The orders.gst_amount column drifts on legacy/edited
    // orders (verified: 19,988 vs the true item-level 30,956 on a year of
    // data), which skewed the GST-in-collections figure.
    const itemGstMap: Record<string, number> = {};
    {
      const itemRows = await this.fetchAllPages((from, to) =>
        supabase()
          .from('order_items')
          .select('order_id, gst_amount', { count: 'exact' })
          .order('id', { ascending: true })
          .range(from, to)
      );
      for (const it of itemRows as any[]) {
        itemGstMap[it.order_id] = (itemGstMap[it.order_id] || 0) + Number(it.gst_amount || 0);
      }
    }

    // Process Summary Groups
    const summaryGroups: Record<string, RevenueRow> = {};
    const orderCounts: Record<string, Set<string>> = {};
    const dailyTrends: Record<string, { date: string; cash: number; sales: number }> = {};

    let totalBookingSales = 0;
    let totalReceived = 0;
    let totalRefunded = 0;
    let totalCancelledKeep = 0;
    let totalNetRevenue = 0;
    let totalGstCollected = 0;
    let totalCash = 0;
    let totalUpi = 0;
    let totalGpay = 0;
    let totalBankTransfer = 0;
    let cancelledNet = 0;
    let totalRevenueDue = 0;

    // A. Process Booking Sales (Business Won)
    for (const o of bookings) {
      const key = this.getPeriodKey(o.created_at, 'month');
      if (!summaryGroups[key]) {
        summaryGroups[key] = this.initSummaryRow(key);
        orderCounts[key] = new Set();
      }
      
      const amount = Number(o.total_amount ?? 0);
      summaryGroups[key].booking_sales += amount;
      totalBookingSales += amount;

      // For daily trends
      const dateKey = o.created_at.split('T')[0];
      if (!dailyTrends[dateKey]) dailyTrends[dateKey] = { date: dateKey, cash: 0, sales: 0 };
      dailyTrends[dateKey].sales += amount;
    }

    // B. Process Revenue Due (Outstanding)
    for (const o of revenueDueData) {
      const key = this.getPeriodKey(o.start_date, 'month');
      if (!summaryGroups[key]) {
        summaryGroups[key] = this.initSummaryRow(key);
        orderCounts[key] = new Set();
      }
      
      const due = Number(o.total_amount || 0) - Number(o.amount_paid || 0);
      if (due > 0) {
        summaryGroups[key].revenue_due += due;
        totalRevenueDue += due;
      }
    }

    // C. Process Cash Collections (Money in hand)
    for (const p of allPayments) {
      const order = p.order;
      if (!order) continue;

      const date = p.payment_date || p.created_at.split('T')[0];
      const key = this.getPeriodKey(date, 'month');
      if (!summaryGroups[key]) {
        summaryGroups[key] = this.initSummaryRow(key);
        orderCounts[key] = new Set();
      }

      const g = summaryGroups[key];
      const amount = Number(p.amount || 0);
      const isRefund = p.payment_type === 'refund';
      const isCancelledKeep = p.payment_type === 'cancelled_keep';
      const mode = (p.payment_mode || '').toLowerCase();
      const status = (order.status || '').toLowerCase();

      orderCounts[key].add(order.id);

      // GST Calculation Ratio — prefer the item-level sum (see itemGstMap note);
      // fall back to the order column only for orders without item rows.
      // Guard: a zero/garbage order total makes the ratio explode (one
      // real-world zero-total order inflated this card by ~₹107k), so the
      // ratio is clamped to [0, 1] and attributed nothing when total ≤ 0.
      const totalOrder = Number(order.total_amount || 0);
      const gstBase = itemGstMap[order.id] ?? Number(order.gst_amount ?? 0);
      const gstRatio = totalOrder > 0 ? Math.min(gstBase / totalOrder, 1) : 0;
      const gstPortion = amount * gstRatio;
      const netPortion = amount - gstPortion;

      // Trends
      const dateKey = date.split('T')[0];
      if (!dailyTrends[dateKey]) dailyTrends[dateKey] = { date: dateKey, cash: 0, sales: 0 };

      if (isRefund) {
        totalRefunded += amount;
        g.refund_amount += amount;
        g.total_revenue -= amount;
        g.cash_collection -= amount;
        g.gst_collected -= gstPortion;
        g.net_revenue -= netPortion;
        totalNetRevenue -= netPortion;
        totalGstCollected -= gstPortion;
        dailyTrends[dateKey].cash -= amount;
        if (status === 'cancelled') cancelledNet -= amount;
      } else if (isCancelledKeep) {
        totalCancelledKeep += amount;
        g.total_revenue += amount;
        g.net_revenue += netPortion;
        totalNetRevenue += netPortion;
        dailyTrends[dateKey].cash += amount;
      } else {
        totalReceived += amount;
        dailyTrends[dateKey].cash += amount;
        g.total_revenue += amount;
        g.cash_collection += amount;
        g.gst_collected += gstPortion;
        g.net_revenue += netPortion;
        totalNetRevenue += netPortion;
        totalGstCollected += gstPortion;

        if (mode === 'cash') { g.cash_revenue += amount; totalCash += amount; }
        else if (mode === 'upi') { g.upi_revenue += amount; totalUpi += amount; }
        else if (mode === 'gpay') { g.gpay_revenue += amount; totalGpay += amount; }
        else if (mode === 'bank_transfer') { g.bank_transfer_revenue += amount; totalBankTransfer += amount; }
        else { g.other_revenue += amount; }

        // Status breakdown
        if (status === 'cancelled') {
           g.cancelled_revenue += amount;
        } else if (['completed', 'returned'].includes(status)) {
           g.completed_revenue += amount;
        } else if (['ongoing', 'in_use', 'delivered'].includes(status)) {
           g.ongoing_revenue += amount;
        } else {
           g.scheduled_revenue += amount;
        }
      }
    }

    const r = (n: number) => {
      const val = Math.round(n * 100) / 100;
      return isNaN(val) ? 0 : val;
    };
    const total_amount_collection = totalReceived - (totalRefunded + totalCancelledKeep);
    
    // Finalize summary
    const summary = Object.entries(summaryGroups).map(([key, g]) => ({
      ...g,
      order_count: orderCounts[key]?.size || 0,
      booking_sales: r(g.booking_sales),
      cash_collection: r(g.cash_collection),
      amount_collection: r(g.cash_collection),
      net_revenue: r(g.net_revenue),
      gst_collected: r(g.gst_collected),
      revenue_due: r(g.revenue_due),
      total_revenue: r(g.total_revenue),
      completed_revenue: r(g.completed_revenue),
      ongoing_revenue: r(g.ongoing_revenue),
      scheduled_revenue: r(g.scheduled_revenue),
      cancelled_revenue: r(g.cancelled_revenue),
      refund_amount: r(g.refund_amount),
      cash_revenue: r(g.cash_revenue),
      upi_revenue: r(g.upi_revenue),
      gpay_revenue: r(g.gpay_revenue),
      bank_transfer_revenue: r(g.bank_transfer_revenue),
      other_revenue: r(g.other_revenue),
    })).sort((a: any, b: any) => b.period.localeCompare(a.period));

    // Process accrual-based charges
    const dueCharges = dueChargesResult as any[];
    const totalDamageCharges = dueCharges.reduce((sum, o) => sum + Number(o.damage_charges_total || 0), 0);
    const totalLateFees = dueCharges.reduce((sum, o) => sum + Number(o.late_fee || 0), 0);
    const refundDueAmount = cancelledOrders.reduce((sum, o) => sum + Number(o.amount_paid || 0), 0);

    return {
      summary,
      total_booking_sales: r(totalBookingSales),
      total_received: r(totalReceived),
      total_amount_collection: r(total_amount_collection),
      total_cash_collection: r(total_amount_collection),
      total_net_revenue: r(totalNetRevenue),
      total_gst_collected: r(totalGstCollected),
      total_cash: r(totalCash),
      total_upi: r(totalUpi),
      total_gpay: r(totalGpay),
      total_bank_transfer: r(totalBankTransfer),
      total_refunded: r(totalRefunded),
      cancelled_total: r(cancelledNet), // Net profit from cancellations
      refund_due: r(refundDueAmount),
      revenue_due: r(totalRevenueDue),
      revenue_due_count: revenueDueData.length,
      total_damage_charges: r(totalDamageCharges),
      total_late_fees: r(totalLateFees),
      dailyTrends: this.padDailyTrends(dailyTrends, fromDate, toDate)
    };
  }

  private initSummaryRow(period: string): RevenueRow {
    return {
      period,
      booking_sales: 0,
      cash_collection: 0,
      amount_collection: 0,
      net_revenue: 0,
      gst_collected: 0,
      revenue_due: 0,
      completed_revenue: 0,
      ongoing_revenue: 0,
      scheduled_revenue: 0,
      cancelled_revenue: 0,
      refund_amount: 0,
      cash_revenue: 0,
      upi_revenue: 0,
      gpay_revenue: 0,
      bank_transfer_revenue: 0,
      other_revenue: 0,
      total_revenue: 0,
      order_count: 0
    };
  }


  /** R4: Top costumes */
  async getTopCostumes(filters: ReportFilters): Promise<TopCostumeRow[]> {
    const items = await this.fetchAllPages((from, to) =>
      supabase()
        .from('order_items')
        .select('product_id, quantity, subtotal, product:product_id(name, category:category_id(name)), order:order_id(status, start_date, end_date)', { count: 'exact' })
        .order('id', { ascending: true })
        .range(from, to)
    );

    const map: Record<string, TopCostumeRow & { totalDays: number }> = {};
    for (const item of items as any[]) {
      if (!item.product) continue;
      const order = item.order;
      if (!order || order.status === 'cancelled') continue;
      const pid = item.product_id;
      if (!map[pid]) {
        map[pid] = { product_id: pid, product_name: item.product.name, category_name: item.product.category?.name || '', rental_count: 0, revenue: 0, avg_rental_days: 0, totalDays: 0 };
      }
      map[pid].rental_count += item.quantity || 1;
      map[pid].revenue += Number(item.subtotal || 0);
      if (order.start_date && order.end_date) {
        map[pid].totalDays += Math.max(1, Math.ceil((new Date(order.end_date).getTime() - new Date(order.start_date).getTime()) / 86400000));
      }
    }

    const rows = Object.values(map).map(r => ({ ...r, avg_rental_days: r.rental_count > 0 ? Math.round(r.totalDays / r.rental_count) : 0 }));
    const rankBy = filters.rank_by || 'count';
    rows.sort((a, b) => rankBy === 'revenue' ? b.revenue - a.revenue : b.rental_count - a.rental_count);
    return rows.slice(0, filters.limit || 50);
  }

  /** R5: Top customers */
  async getTopCustomers(filters: ReportFilters): Promise<TopCustomerRow[]> {
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || today;
    const range = this.formatISTQueryRange(fromDate, toDate);

    const data = await this.fetchAllPages((from, to) =>
      supabase()
        .from('orders')
        .select('id, customer_id, amount_paid, created_at, customer:customer_id(id, name, phone)', { count: 'exact' })
        .eq('status', 'completed')
        .gte('created_at', range.start)
        .lte('created_at', range.end)
        .order('id', { ascending: true })
        .range(from, to)
    );

    const map: Record<string, TopCustomerRow> = {};
    for (const o of data as any[]) {
      if (!o.customer) continue;
      const cid = o.customer_id;
      if (!map[cid]) {
        map[cid] = { customer_id: cid, customer_name: o.customer.name, customer_phone: o.customer.phone || '', order_count: 0, total_spent: 0, last_order_date: '' };
      }
      map[cid].order_count++;
      map[cid].total_spent += Number(o.amount_paid || 0);
      if (!map[cid].last_order_date || o.created_at > map[cid].last_order_date) {
        map[cid].last_order_date = o.created_at;
      }
    }

    const rows = Object.values(map);
    rows.sort((a, b) => b.total_spent - a.total_spent);
    return rows.slice(0, filters.limit || 50);
  }

  /** R6: Rental frequency */
  async getRentalFrequency(filters: ReportFilters): Promise<RentalFrequencyRow[]> {
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || today;
    const range = this.formatISTQueryRange(fromDate, toDate);

    const data = await this.fetchAllPages((from, to) =>
      supabase()
        .from('order_items')
        .select('product_id, quantity, created_at, product:product_id(name, category:category_id(name)), order:order_id(status)', { count: 'exact' })
        .gte('created_at', range.start)
        .lte('created_at', range.end)
        .order('id', { ascending: true })
        .range(from, to)
    );

    const map: Record<string, RentalFrequencyRow> = {};
    for (const item of data as any[]) {
      if (!item.product || item.order?.status === 'cancelled') continue;
      const pid = item.product_id;
      if (!map[pid]) {
        map[pid] = { product_id: pid, product_name: item.product.name, category_name: item.product.category?.name || '', rental_count: 0, last_rented: '' };
      }
      map[pid].rental_count += item.quantity || 1;
      if (!map[pid].last_rented || item.created_at > map[pid].last_rented) {
        map[pid].last_rented = item.created_at;
      }
    }

    const rows = Object.values(map);
    rows.sort((a, b) => b.rental_count - a.rental_count);
    return rows.slice(0, filters.limit || 50);
  }

  /** R7: ROI / Profit per costume */
  async getROI(filters: ReportFilters): Promise<ROIRow[]> {
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || today;
    const range = this.formatISTQueryRange(fromDate, toDate);

    const { data: products } = await supabase()
      .from('products')
      .select('id, name, purchase_price')
      .gt('purchase_price', 0);

    if (!products || products.length === 0) return [];

    const items = await this.fetchAllPages((from, to) =>
      supabase()
        .from('order_items')
        .select('product_id, quantity, subtotal, order:order_id(status, created_at)', { count: 'exact' })
        // No .in('product_id', ...) — the full SKU list exceeds the PostgREST
        // URL limit; the date range bounds the scan and the product filter is
        // applied implicitly by mapping only over `products` below.
        .gte('created_at', range.start)
        .lte('created_at', range.end)
        .order('id', { ascending: true })
        .range(from, to)
    );

    const revenueMap: Record<string, { revenue: number; count: number }> = {};
    for (const item of (items || []) as any[]) {
      if (item.order?.status === 'cancelled') continue;
      const pid = item.product_id;
      if (!revenueMap[pid]) revenueMap[pid] = { revenue: 0, count: 0 };
      revenueMap[pid].revenue += Number(item.subtotal || 0);
      revenueMap[pid].count += item.quantity || 1;
    }

    return products.map((p: any) => {
      const rev = revenueMap[p.id] || { revenue: 0, count: 0 };
      const purchasePrice = Number(p.purchase_price);
      const profit = rev.revenue - purchasePrice;
      return {
        product_id: p.id,
        product_name: p.name,
        purchase_price: purchasePrice,
        total_revenue: Math.round(rev.revenue * 100) / 100,
        profit: Math.round(profit * 100) / 100,
        roi_percentage: purchasePrice > 0 ? Math.round((profit / purchasePrice) * 100) : 0,
        rental_count: rev.count,
      };
    }).sort((a: ROIRow, b: ROIRow) => b.roi_percentage - a.roi_percentage);
  }

  /** R8: Dead stock / No-sale
   *
   * "Dead stock" = a product that had zero non-cancelled rentals within the
   * selected date window. Soft-deleted and inactive products are excluded so
   * the report reflects sellable inventory only.
   *
   * NOTE: The schema has a `products.last_rented_at` column intended as an
   * O(1) source for this report, but it is unpopulated in production
   * (0% fill rate as of 2026-08), so we continue to derive last-rented from
   * `order_items`. If/when that column is backfilled and maintained, the
   * full-table scan below can be replaced.
   */
  async getDeadStock(filters: ReportFilters): Promise<DeadStockRow[]> {
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || today;
    const range = this.formatISTQueryRange(fromDate, toDate);

    // Get all SELLABLE products — exclude soft-deleted (deleted_at) and
    // archived (is_active = false) so the report only reflects real inventory.
    const products = await this.fetchAllPages((from, to) =>
      supabase()
        .from('products')
        .select('id, name, price_per_day, quantity, created_at, category:category_id(name)', { count: 'exact' })
        .eq('is_active', true)
        .is('deleted_at', null)
        .order('id', { ascending: true })
        .range(from, to)
    );

    // Get products that have been rented in the period (non-cancelled only)
    const rentedItems = await this.fetchAllPages((from, to) =>
      supabase()
        .from('order_items')
        .select('product_id, created_at, order:order_id(status)', { count: 'exact' })
        .gte('created_at', range.start)
        .lte('created_at', range.end)
        .order('id', { ascending: true })
        .range(from, to)
    );

    const rentedIds = new Set(
      (rentedItems as any[])
        .filter((i: any) => i.order?.status !== 'cancelled')
        .map((i: any) => i.product_id)
    );

    // Get last rental date for all products. Limited to the products we care
    // about (sellable ones) to keep the scan bounded.
    const productIds = new Set((products as any[]).map((p: any) => p.id));
    const lastRentalMap: Record<string, string> = {};
    if (productIds.size > 0) {
      // No .in('product_id', ids) filter: with hundreds of sellable SKUs the
      // UUID list blows past the PostgREST URL limit (the pre-refactor code
      // failed silently on exactly that). A full id-ordered scan paginated
      // with fetchAllPages is bounded by total order_items (~thousands).
      const lastRentals = await this.fetchAllPages((from, to) =>
        supabase()
          .from('order_items')
          .select('product_id, created_at, order:order_id(status)', { count: 'exact' })
          .order('id', { ascending: true })
          .range(from, to)
      );
      for (const item of lastRentals as any[]) {
        // Skip cancelled-order items when determining the true last rental
        if (item.order?.status === 'cancelled') continue;
        if (!productIds.has(item.product_id)) continue;
        // Ascending scan: keep overwriting so each product ends up with its
        // LATEST non-cancelled rental (keeping only the first would report
        // the earliest rental instead).
        lastRentalMap[item.product_id] = item.created_at;
      }
    }

    // Use the IST date context (not raw Date.now()) for day-spread math,
    // consistent with the rest of the report service.
    const nowMs = new Date(today).getTime();
    const DAY_MS = 86400000;

    return (products || [])
      .filter((p: any) => !rentedIds.has(p.id))
      .map((p: any) => {
        const lastRental = lastRentalMap[p.id];
        const price = Number(p.price_per_day) || 0;
        const qty = Number(p.quantity) || 0;
        return {
          product_id: p.id,
          product_name: p.name,
          category_name: p.category?.name || '',
          price_per_day: price,
          quantity: qty,
          // Days idle = days since last rental. For never-rented products,
          // fall back to days since the product was added to inventory —
          // this distinguishes "newly added stock" (low number) from
          // "genuinely stale" (high number) and is always a usable number.
          days_since_last_rental: lastRental
            ? Math.floor((nowMs - new Date(lastRental).getTime()) / DAY_MS)
            : Math.floor((nowMs - new Date(p.created_at).getTime()) / DAY_MS),
          never_rented: !lastRental,
          stock_value: Math.round(price * qty * 100) / 100,
          created_at: p.created_at,
        };
      });
  }

  /** R13: Damage / Flagged report — what got damaged, why, and the money side */
  async getDamageReport(filters: ReportFilters): Promise<any> {
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || today;
    const range = this.formatISTQueryRange(fromDate, toDate);

    // 1. Damaged items in the period (any damage marker). Paged.
    const damagedItems = await this.fetchAllPages((from, to) =>
      supabase()
        .from('order_items')
        .select(`
          id, order_id, product_id, quantity, returned_quantity,
          damaged_quantity, damage_charges, damage_description, condition_rating, created_at,
          product:product_id(id, name),
          order:order_id(id, invoice_number, status, payment_status, total_amount, amount_paid, created_at,
            customer:customer_id(name, phone))
        `, { count: 'exact' })
        .or('damaged_quantity.gt.0,damage_charges.gt.0,condition_rating.eq.damaged')
        .gte('created_at', range.start)
        .lte('created_at', range.end)
        .order('id', { ascending: true })
        .range(from, to)
    ) as any[];

    // 2. Live snapshot: orders currently FLAGGED (damage pending assessment)
    const flaggedOrders = await this.fetchAllPages((from, to) =>
      supabase()
        .from('orders')
        .select(`
          id, invoice_number, status, payment_status, total_amount, amount_paid,
          late_fee, discount, damage_charges_total, created_at,
          customer:customer_id(name, phone),
          items:order_items(id, product_id, quantity, returned_quantity, damaged_quantity,
            damage_charges, damage_description, condition_rating,
            product:product_id(name))
        `, { count: 'exact' })
        .eq('status', 'flagged')
        .order('created_at', { ascending: false })
        .range(from, to)
    ) as any[];

    // 3. Damage assessments state (bounded: table only holds real units).
    //    Per flagged order we need BOTH pending counts AND whether any rows
    //    exist at all — "damaged units but zero rows" means assessments were
    //    never created and staff must use the panel's backfill button.
    const allAssessments = await this.fetchAllPages((from, to) =>
      supabase()
        .from('damage_assessments')
        .select('id, order_id, product_id, unit_index, decision', { count: 'exact' })
        .order('id', { ascending: true })
        .range(from, to)
    ) as any[];
    const pendingByOrder: Record<string, number> = {};
    const anyByOrder: Record<string, number> = {};
    let pendingTotal = 0;
    for (const a of allAssessments) {
      anyByOrder[a.order_id] = (anyByOrder[a.order_id] || 0) + 1;
      if (a.decision === 'pending') {
        pendingByOrder[a.order_id] = (pendingByOrder[a.order_id] || 0) + 1;
        pendingTotal += 1;
      }
    }

    // ── Aggregates ──
    let feesCharged = 0, feesCollected = 0, feesPending = 0, unitsDamaged = 0;
    const orderIdsWithDamage = new Set<string>();
    for (const it of damagedItems) {
      const fee = Number(it.damage_charges || 0);
      const units = Number(it.damaged_quantity || 0);
      feesCharged += fee;
      unitsDamaged += units;
      orderIdsWithDamage.add(it.order_id);
      const payStatus = it.order?.payment_status;
      if (payStatus === 'paid') feesCollected += fee;
      else feesPending += fee;
    }

    // ── Group by product: which products keep getting damaged and why ──
    const byProduct: Record<string, {
      product_id: string; product_name: string; orders_count: number; units_damaged: number;
      damage_fees: number; reasons: string[]; last_damaged_at: string;
    }> = {};
    for (const it of damagedItems) {
      const pid = it.product_id;
      const p = byProduct[pid] || {
        product_id: pid,
        product_name: it.product?.name || 'Unknown',
        orders_count: 0, units_damaged: 0, damage_fees: 0, reasons: [], last_damaged_at: '',
      };
      p.orders_count += 1;
      p.units_damaged += Number(it.damaged_quantity || 0);
      p.damage_fees += Number(it.damage_charges || 0);
      const reason = (it.damage_description || '').trim();
      if (reason && !p.reasons.includes(reason)) p.reasons.push(reason);
      if (!p.last_damaged_at || it.created_at > p.last_damaged_at) p.last_damaged_at = it.created_at;
      byProduct[pid] = p;
    }
    const damagedProducts = Object.values(byProduct)
      .map(p => ({ ...p, damage_fees: Math.round(p.damage_fees * 100) / 100, reasons: p.reasons.slice(0, 5) }))
      .sort((a, b) => b.units_damaged - a.units_damaged || b.damage_fees - a.damage_fees);

    // ── Flagged order rows (action needed) ──
    const flaggedRows = flaggedOrders.map(o => {
      const damaged = (o.items || []).filter((i: any) =>
        (i.damaged_quantity || 0) > 0 || (i.damage_charges || 0) > 0 || i.condition_rating === 'damaged');
      return {
        order_id: o.id,
        invoice_number: o.invoice_number,
        customer_name: o.customer?.name || 'Unknown',
        customer_phone: o.customer?.phone || '',
        created_at: o.created_at,
        payment_status: o.payment_status,
        total_amount: Number(o.total_amount || 0),
        amount_paid: Number(o.amount_paid || 0),
        balance_due: Math.max(0, Number(o.total_amount || 0) - Number(o.amount_paid || 0)),
        damage_fees: damaged.reduce((s: number, i: any) => s + Number(i.damage_charges || 0), 0),
        damaged_units: damaged.reduce((s: number, i: any) => s + Number(i.damaged_quantity || 0), 0),
        products_summary: damaged
          .map((i: any) => `${i.product?.name || 'Product'} ×${i.damaged_quantity || 0}${i.damage_description ? ` (${i.damage_description})` : ''}`)
          .join('; '),
        pending_assessments: pendingByOrder[o.id] || 0,
        // damaged units exist but no assessment rows were ever created —
        // staff must open the order and press "Create Damage Assessments"
        assessments_missing: (damaged.reduce((s: number, i: any) => s + Number(i.damaged_quantity || 0), 0)) > 0
          && !(anyByOrder[o.id] > 0),
      };
    });

    // ── Item detail rows (this is the `summary` array the reports page
    //    feeds to the sortable table + Excel/PDF export) ──
    const itemRows = damagedItems.map(it => ({
      invoice_number: it.order?.invoice_number || '',
      order_status: it.order?.status || '',
      customer_name: it.order?.customer?.name || 'Unknown',
      product_name: it.product?.name || 'Product',
      damaged_units: Number(it.damaged_quantity || 0),
      returned_units: Number(it.returned_quantity || 0),
      ordered_units: Number(it.quantity || 0),
      damage_fee: Number(it.damage_charges || 0),
      reason: it.damage_description || '',
      payment_status: it.order?.payment_status || '',
      created_at: it.created_at,
    }));

    return {
      period: { from: fromDate, to: toDate },
      totals: {
        damaged_orders: orderIdsWithDamage.size,
        damaged_units: unitsDamaged,
        damage_fees_charged: Math.round(feesCharged * 100) / 100,
        damage_fees_collected: Math.round(feesCollected * 100) / 100,
        damage_fees_pending: Math.round(feesPending * 100) / 100,
        flagged_orders_now: flaggedRows.length,
        pending_assessments_now: pendingTotal,
        assessments_missing_now: flaggedRows.filter((f: any) => f.assessments_missing).length,
      },
      flagged_orders: flaggedRows,
      damaged_products: damagedProducts,
      summary: itemRows,
    };
  }

  /** R9: Sales by staff */
  async getSalesByStaff(filters: ReportFilters): Promise<SalesByStaffRow[]> {
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || today;
    const range = this.formatISTQueryRange(fromDate, toDate);

    const data = await this.fetchAllPages((from, to) =>
      supabase()
        .from('orders')
        .select(`
          id, 
          status,
          total_amount, 
          amount_paid, 
          discount, 
          created_by, 
          staff:created_by(id, name, email),
          order_items(discount, subtotal)
        `, { count: 'exact' })
        .gte('created_at', range.start)
        .lte('created_at', range.end)
        .order('id', { ascending: true })
        .range(from, to)
    );

    const map: Record<string, SalesByStaffRow> = {};
    for (const o of data as any[]) {
      if (!o.staff) continue;
      const sid = o.created_by;
      const isCancelled = o.status === 'cancelled';

      if (!map[sid]) {
        map[sid] = { 
          staff_id: sid, 
          staff_name: o.staff.name || 'Unknown', 
          staff_email: o.staff.email || '', 
          order_count: 0, 
          cancelled_order_count: 0,
          total_revenue: 0, 
          avg_order_value: 0,
          total_item_discount: 0,
          total_order_discount: 0,
          total_discount: 0,
          discount_percentage: 0
        };
      }
      
      if (isCancelled) {
        map[sid].cancelled_order_count++;
        continue; // Don't count revenue/discount for cancelled orders
      }

      const itemDiscount = (o.order_items || []).reduce((sum: number, item: any) => sum + Number(item.discount || 0), 0);
      const orderDiscount = Number(o.discount || 0);
      const totalRev = Number(o.amount_paid || o.total_amount || 0);

      map[sid].order_count++;
      map[sid].total_revenue += totalRev;
      map[sid].total_item_discount += itemDiscount;
      map[sid].total_order_discount += orderDiscount;
      map[sid].total_discount += (itemDiscount + orderDiscount);
    }

    return Object.values(map)
      .map(s => {
        const potentialRevenue = s.total_revenue + s.total_discount;
        return { 
          ...s, 
          total_revenue: Math.round(s.total_revenue * 100) / 100, 
          total_item_discount: Math.round(s.total_item_discount * 100) / 100,
          total_order_discount: Math.round(s.total_order_discount * 100) / 100,
          total_discount: Math.round(s.total_discount * 100) / 100,
          avg_order_value: s.order_count > 0 ? Math.round((s.total_revenue / s.order_count) * 100) / 100 : 0,
          discount_percentage: potentialRevenue > 0 ? Math.round((s.total_discount / potentialRevenue) * 10000) / 100 : 0
        };
      })
      .sort((a, b) => b.total_revenue - a.total_revenue);
  }

  /** Fetch order history for a specific staff member */
  async getStaffOrderHistory(staffId: string, filters: ReportFilters): Promise<any[]> {
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || today;
    const range = this.formatISTQueryRange(fromDate, toDate);

    const { data, error } = await supabase()
      .from('orders')
      .select(`
        id,
        status,
        start_date,
        end_date,
        total_amount,
        discount,
        customer:customer_id(name),
        order_items(product:product_id(name), quantity)
      `)
      .eq('created_by', staffId)
      .gte('created_at', range.start)
      .lte('created_at', range.end)
      .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);

    return (data || []).map((o: any) => ({
      id: o.id,
      status: o.status,
      date: o.start_date,
      customer: o.customer?.name || 'Unknown',
      products: (o.order_items || []).map((i: any) => `${i.product?.name} (x${i.quantity})`).join(', '),
      amount: o.total_amount,
      discount: o.discount
    }));
  }

  /** R10: Inventory + Revenue */
  async getInventoryRevenue(): Promise<InventoryRevenueRow[]> {
    const { data: products } = await supabase()
      .from('products')
      .select('id, name, quantity, available_quantity, price_per_day, category:category_id(name)');

    const items = await this.fetchAllPages((from, to) =>
      supabase()
        .from('order_items')
        .select('product_id, quantity, subtotal, order:order_id(status)', { count: 'exact' })
        .order('id', { ascending: true })
        .range(from, to)
    );

    const revenueMap: Record<string, { revenue: number; count: number }> = {};
    for (const item of items as any[]) {
      if (item.order?.status === 'cancelled') continue;
      const pid = item.product_id;
      if (!revenueMap[pid]) revenueMap[pid] = { revenue: 0, count: 0 };
      revenueMap[pid].revenue += Number(item.subtotal || 0);
      revenueMap[pid].count += item.quantity || 1;
    }

    return (products || []).map((p: any) => {
      const rev = revenueMap[p.id] || { revenue: 0, count: 0 };
      return {
        product_id: p.id,
        product_name: p.name,
        category_name: p.category?.name || '',
        quantity: p.quantity,
        available_quantity: p.available_quantity,
        price_per_day: Number(p.price_per_day),
        lifetime_revenue: Math.round(rev.revenue * 100) / 100,
        rental_count: rev.count,
      };
    }).sort((a: InventoryRevenueRow, b: InventoryRevenueRow) => b.lifetime_revenue - a.lifetime_revenue);
  }

  /** R11: Customer enquiry log */
  async getEnquiries(filters: ReportFilters): Promise<CustomerEnquiry[]> {
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || today;
    const range = this.formatISTQueryRange(fromDate, toDate);

    const { data } = await supabase()
      .from('customer_enquiries')
      .select('*, logged_by_staff:staff!logged_by(name, email)')
      .gte('created_at', range.start)
      .lte('created_at', range.end)
      .order('created_at', { ascending: false });

    return (data || []).map((d: any) => ({
      ...d,
      staff: d.logged_by_staff
    })) as CustomerEnquiry[];
  }

  /** R12: GST Filing report */
  async getGSTFilingReport(filters: ReportFilters): Promise<any> {
    const { today } = this.getISTDateContext();
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || today;
    const range = this.formatISTQueryRange(fromDate, toDate);

    // Check if GST is currently enabled
    const gstEnabledResult = await settingsService.getIsGSTEnabled();
    const isGstEnabled = !!(gstEnabledResult.success && gstEnabledResult.data);

    // Fetch invoice prefix from settings
    const { data: settingsData } = await supabase()
      .from('settings')
      .select('value')
      .eq('key', 'invoice_prefix')
      .single();
    const prefix = settingsData?.value || 'INV-';

    // Fetch all order items with their order data.
    // PAGED: Supabase/PostgREST caps a single response at 1000 rows and the
    // table already holds 2000+ items — an unpaged fetch silently dropped the
    // newest items, which made this report look "stuck" at a past date.
    // We fetch without date filter and filter client-side by order.created_at
    // because the !inner join syntax with aliases is unreliable.
    const buildItemPage = (from: number, to: number) =>
      supabase()
        .from('order_items')
        .select(`
          id,
          gst_percentage,
          base_amount,
          gst_amount,
          subtotal,
          quantity,
          product:product_id (
            name
          ),
          order:order_id (
            id,
            status,
            created_at,
            invoice_number,
            total_amount,
            gst_amount,
            customer:customer_id (
              name
            )
          )
        `, { count: 'exact' })
        .order('id', { ascending: true })
        .range(from, to);

    const data = await this.fetchAllPages(buildItemPage);

    // Client-side filter: only items whose ORDER was created in the date range.
    // For GST filing, ONLY finalized rentals are counted: 'completed' (returned
    // + paid) and 'returned' (fully returned). Scheduled/ongoing/partial/flagged
    // orders represent rentals that have not concluded — their tax cannot be
    // reported on a GSTR-1 yet. The status filter is intentionally NOT taken
    // from the request: this is a statutory scope, not a user preference.
    const GST_ELIGIBLE_STATUSES = new Set(['completed', 'returned']);
    const fromTs = new Date(range.start).getTime();
    const toTs = new Date(range.end).getTime();
    const items = (data || []).filter((item: any) => {
      const order = item.order;
      if (!order) return false;
      if (!GST_ELIGIBLE_STATUSES.has(order.status)) return false;
      const orderTs = new Date(order.created_at).getTime();
      return orderTs >= fromTs && orderTs <= toTs;
    });

    // Denominator for composition = distinct orders that actually have line items.
    // Empty/ghost orders (created but no items) are excluded so the GST adoption
    // percentage is not diluted by orders that have no taxable activity.
    const ordersWithItems = new Set<string>();
    items.forEach((item: any) => ordersWithItems.add(item.order.id));
    const totalOrderCount = ordersWithItems.size;

    // Group by GST slab
    const slabs: Record<number, { taxable: number; gst: number }> = {
      5: { taxable: 0, gst: 0 },
      12: { taxable: 0, gst: 0 },
      18: { taxable: 0, gst: 0 },
      28: { taxable: 0, gst: 0 }
    };

    const invoiceMap: Record<string, any> = {};

    let totalTaxable = 0;
    let totalGst = 0;

    items.forEach((item: any) => {
      const order = item.order;
      // Status/date/cancelled filters already applied when `items` was built.

      const slab = Number(item.gst_percentage || 0);
      const taxable = Number(item.base_amount || 0);
      const gst = Number(item.gst_amount || 0);
      const isGstItem = gst > 0;

      if (isGstItem) {
        if (!slabs[slab]) slabs[slab] = { taxable: 0, gst: 0 };
        slabs[slab].taxable += taxable;
        slabs[slab].gst += gst;

        totalTaxable += taxable;
        totalGst += gst;
      }

      // Track details for the invoice list. Every order that has at least one
      // line item gets a row — both GST and exempt orders — so the client can
      // see exactly which orders/items carry GST and which are exempt.
      if (!invoiceMap[order.id]) {
        // Use the STORED invoice number (assigned at order creation) as the
        // source of truth. Only fall back to a derived number for legacy
        // orders that predate the invoice_number column.
        const storedInvoiceNo = (order as any).invoice_number as string | null;
        let formattedInvoiceNo = storedInvoiceNo;
        if (!formattedInvoiceNo) {
          const orderDate = new Date(order.created_at);
          const year = orderDate.getFullYear();
          const month = orderDate.getMonth();
          let fiscalStartYear = year;
          if (month < 3) {
            fiscalStartYear = year - 1;
          }
          const startYY = String(fiscalStartYear).slice(-2);
          const endYY = String(fiscalStartYear + 1).slice(-2);
          formattedInvoiceNo = `MAZ-${startYY}${endYY}-${order.id.slice(0, 8).toUpperCase()}`;
        }

        invoiceMap[order.id] = {
          order_id: order.id,
          invoice_no: formattedInvoiceNo,
          date: order.created_at,
          customer_name: order.customer?.name || 'Unknown',
          status: order.status,
          total_value: Number(order.total_amount || 0),
          taxable_value: 0,        // GST items' base_amount (for filing)
          gst_amount: 0,
          cgst: 0,
          sgst: 0,
          slabs: new Set(),
          gst_items: [] as string[],
          exempt_items: [] as string[],
          exempt_value: 0,         // exempt items' base — visible separately
        };
      }

      const pName = item.product?.name || 'Unknown';
      const qty = Number(item.quantity || 1);
      const lineSubtotal = Number(item.subtotal || 0);

      if (isGstItem) {
        invoiceMap[order.id].gst_items.push(`${pName} x${qty}`);
        invoiceMap[order.id].taxable_value += taxable;
        invoiceMap[order.id].gst_amount += gst;
        invoiceMap[order.id].cgst += (gst / 2);
        invoiceMap[order.id].sgst += (gst / 2);
        invoiceMap[order.id].slabs.add(slab);
      } else {
        invoiceMap[order.id].exempt_items.push(`${pName} x${qty}`);
        invoiceMap[order.id].exempt_value += lineSubtotal;
      }
    });

    const summary = Object.entries(slabs)
      .map(([slab, vals]) => ({
        slab: Number(slab),
        taxable_value: Math.round(vals.taxable * 100) / 100,
        cgst: Math.round((vals.gst / 2) * 100) / 100,
        sgst: Math.round((vals.gst / 2) * 100) / 100,
        total_gst: Math.round(vals.gst * 100) / 100
      }))
      .filter(s => s.taxable_value > 0)
      .sort((a, b) => a.slab - b.slab);

    // GST orders = orders that have at least one GST-bearing line item.
    // This is the single source of truth for the composition count — it must
    // match the per-item definition used by the slab totals, NOT the stale
    // order-level gst_amount snapshot column.
    const details = Object.values(invoiceMap)
      .map((inv: any) => {
        const gstItemList = inv.gst_items.join(', ') || '-';
        const exemptItemList = inv.exempt_items.join(', ') || '-';
        // Compose an items summary that makes the GST vs exempt split visible
        // in a single column, e.g. "SKIRT-24 x2 (GST), WIG-1 x1 (Exempt)".
        const parts: string[] = [];
        if (inv.gst_items.length) parts.push(`${inv.gst_items.join(', ')} (GST)`);
        if (inv.exempt_items.length) parts.push(`${inv.exempt_items.join(', ')} (Exempt)`);
        const itemsSummary = parts.length ? parts.join(' · ') : '-';

        return {
          ...inv,
          taxable_value: Math.round(inv.taxable_value * 100) / 100,
          gst_amount: Math.round(inv.gst_amount * 100) / 100,
          cgst: Math.round(inv.cgst * 100) / 100,
          sgst: Math.round(inv.sgst * 100) / 100,
          exempt_value: Math.round(inv.exempt_value * 100) / 100,
          slabs: inv.slabs.size > 0 ? Array.from(inv.slabs as Set<number>).sort().map((s) => `${s}%`).join(', ') : '-',
          gst_items_summary: gstItemList,
          exempt_items_summary: exemptItemList,
          items_summary: itemsSummary,
          has_gst: inv.gst_amount > 0,
          has_exempt: inv.exempt_items.length > 0,
        };
      })
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    // Composition derived from the SAME per-item definition used for totals.
    const gstOrderIds = new Set<string>();
    items.forEach((item: any) => {
      if (Number(item.gst_amount || 0) > 0) gstOrderIds.add(item.order.id);
    });
    const finalGstOrderCount = gstOrderIds.size;

    return {
      summary,
      details,
      composition: {
        total_orders: totalOrderCount,
        gst_orders: finalGstOrderCount,
        non_gst_orders: Math.max(0, totalOrderCount - finalGstOrderCount),
        gst_percentage: totalOrderCount > 0 ? Math.round((finalGstOrderCount / totalOrderCount) * 100) : 0
      },
      total_taxable: Math.round(totalTaxable * 100) / 100,
      total_cgst: Math.round((totalGst / 2) * 100) / 100,
      total_sgst: Math.round((totalGst / 2) * 100) / 100,
      total_gst: Math.round(totalGst * 100) / 100,
      period: `${fromDate} to ${toDate}`,
      is_gst_enabled: isGstEnabled,
    };
  }

  /** Create enquiry */
  async createEnquiry(dto: CreateEnquiryDTO, staffId: string, branchId: string | null, storeId: string | null): Promise<CustomerEnquiry> {
    const { data, error } = await supabase()
      .from('customer_enquiries')
      .insert({
        product_query: dto.product_query,
        customer_name: dto.customer_name || null,
        customer_phone: dto.customer_phone || null,
        notes: dto.notes || null,
        logged_by: staffId,
        branch_id: branchId,
        store_id: storeId,
      })
      .select('*, logged_by_staff:staff!logged_by(name, email)')
      .single();

    if (error) throw new Error(error.message);
    return {
      ...(data as any),
      staff: (data as any).logged_by_staff
    } as CustomerEnquiry;
  }

  // ── Helpers ──────────────────────────────────────────────
  private getPeriodStart(period: string): string {
    const { now } = this.getISTDateContext();
    switch (period) {
      case 'day': return now.toLocaleDateString('en-CA');
      case 'week': { const d = new Date(now); d.setDate(d.getDate() - 7); return d.toLocaleDateString('en-CA'); }
      case 'month': { const d = new Date(now.getFullYear(), now.getMonth(), 1); return d.toLocaleDateString('en-CA'); }
      case 'year': return `${now.getFullYear()}-01-01`;
      default: { const d = new Date(now.getFullYear(), now.getMonth(), 1); return d.toLocaleDateString('en-CA'); }
    }
  }

  private getPeriodKey(dateStr: string, period: string): string {
    const d = new Date(dateStr);
    switch (period) {
      case 'day': return d.toISOString().split('T')[0];
      case 'week': { const start = new Date(d); start.setDate(start.getDate() - start.getDay() + 1); return `Week of ${start.toLocaleDateString('en-IN', { month: 'short', day: 'numeric' })}`; }
      case 'month': return d.toLocaleDateString('en-IN', { month: 'short', year: 'numeric' });
      case 'year': return String(d.getFullYear());
      default: return d.toLocaleDateString('en-IN', { month: 'short', year: 'numeric' });
    }
  }

  private padDailyTrends(trends: Record<string, any>, fromDate: string, toDate: string) {
    const start = new Date(fromDate);
    const end = new Date(toDate);
    const result = [];
    
    for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
      const dateKey = d.toISOString().split('T')[0];
      const data = trends[dateKey] || { date: dateKey, cash: 0, sales: 0 };
      result.push(data);
    }
    
    return result.sort((a, b) => a.date.localeCompare(b.date));
  }
}

export const reportService = new ReportService();
