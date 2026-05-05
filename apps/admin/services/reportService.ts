/**
 * Report Service
 *
 * Business logic layer for all 11 reports (R1–R11).
 * Queries Supabase directly using the admin client.
 *
 * @module services/reportService
 */

import { createAdminClient } from '@/lib/supabase/server';
import type {
  ReportFilters,
  DayWiseBookingRow,
  DueOverdueRow,
  RevenueRow,
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

  /** R1: Day-wise booking */
  async getDayWiseBooking(filters: ReportFilters): Promise<DayWiseBookingRow[]> {
    const date = filters.date || new Date(Date.now() + 86400000).toISOString().split('T')[0]; // default: tomorrow
    const { data } = await supabase()
      .from('orders')
      .select('id, status, start_date, end_date, total_amount, customer:customer_id(name, phone), order_items(product:product_id(name))')
      .eq('start_date', date)
      .neq('status', 'cancelled')
      .order('created_at', { ascending: false });

    return (data || []).map((o: any) => ({
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
  async getDueOverdue(): Promise<DueOverdueRow[]> {
    const today = new Date().toISOString().split('T')[0];
    const { data } = await supabase()
      .from('orders')
      .select('id, status, end_date, total_amount, amount_paid, customer:customer_id(name, phone), order_items(product:product_id(name))')
      .lte('end_date', today)
      .in('status', ['ongoing', 'in_use', 'delivered', 'late_return'])
      .order('end_date', { ascending: true });

    return (data || []).map((o: any) => {
      const endDate = new Date(o.end_date);
      const daysOverdue = Math.max(0, Math.floor((Date.now() - endDate.getTime()) / 86400000));
      const paid = Number(o.amount_paid || 0);
      const total = Number(o.total_amount || 0);
      return {
        order_id: o.id,
        customer_name: o.customer?.name || 'Unknown',
        customer_phone: o.customer?.phone || '',
        product_names: (o.order_items || []).map((i: any) => i.product?.name).filter(Boolean).join(', '),
        end_date: o.end_date,
        days_overdue: daysOverdue,
        total_amount: total,
        amount_paid: paid,
        balance: total - paid,
        status: o.status,
      };
    });
  }

  /** R3: Revenue report */
  async getRevenue(filters: ReportFilters): Promise<RevenueRow[]> {
    const period = filters.period || 'month';
    const fromDate = filters.from_date || this.getPeriodStart(period);
    const toDate = filters.to_date || new Date().toISOString().split('T')[0];

    const { data } = await supabase()
      .from('orders')
      .select('id, status, total_amount, amount_paid, advance_amount, created_at')
      .gte('created_at', `${fromDate}T00:00:00`)
      .lte('created_at', `${toDate}T23:59:59`)
      .neq('status', 'cancelled');

    // Group by period
    const groups: Record<string, { completed: number; ongoing: number; scheduled: number; count: number }> = {};
    for (const o of (data || []) as any[]) {
      const key = this.getPeriodKey(o.created_at, period);
      if (!groups[key]) groups[key] = { completed: 0, ongoing: 0, scheduled: 0, count: 0 };
      groups[key].count++;
      const amount = Number(o.amount_paid || o.total_amount || 0);
      const status = (o.status || '').toLowerCase();
      if (['completed', 'returned'].includes(status)) groups[key].completed += amount;
      else if (['ongoing', 'in_use', 'delivered'].includes(status)) groups[key].ongoing += amount;
      else if (['scheduled', 'pending', 'confirmed'].includes(status)) groups[key].scheduled += Number(o.advance_amount || 0);
    }

    return Object.entries(groups).map(([period, v]) => ({
      period,
      completed_revenue: Math.round(v.completed * 100) / 100,
      ongoing_revenue: Math.round(v.ongoing * 100) / 100,
      scheduled_revenue: Math.round(v.scheduled * 100) / 100,
      total_revenue: Math.round((v.completed + v.ongoing + v.scheduled) * 100) / 100,
      order_count: v.count,
    }));
  }

  /** R4: Top costumes */
  async getTopCostumes(filters: ReportFilters): Promise<TopCostumeRow[]> {
    const { data } = await supabase()
      .from('order_items')
      .select('product_id, quantity, subtotal, product:product_id(name, category:category_id(name)), order:order_id(status, start_date, end_date)')
      .not('order.status', 'eq', 'cancelled');

    const map: Record<string, TopCostumeRow & { totalDays: number }> = {};
    for (const item of (data || []) as any[]) {
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
    const { data } = await supabase()
      .from('orders')
      .select('id, customer_id, amount_paid, created_at, customer:customer_id(id, name, phone)')
      .neq('status', 'cancelled');

    const map: Record<string, TopCustomerRow> = {};
    for (const o of (data || []) as any[]) {
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
  async getRentalFrequency(): Promise<RentalFrequencyRow[]> {
    const { data } = await supabase()
      .from('order_items')
      .select('product_id, quantity, created_at, product:product_id(name, category:category_id(name)), order:order_id(status)')
      .not('order.status', 'eq', 'cancelled');

    const map: Record<string, RentalFrequencyRow> = {};
    for (const item of (data || []) as any[]) {
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
    return rows;
  }

  /** R7: ROI / Profit per costume */
  async getROI(): Promise<ROIRow[]> {
    const { data: products } = await supabase()
      .from('products')
      .select('id, name, purchase_price')
      .gt('purchase_price', 0);

    if (!products || products.length === 0) return [];

    const { data: items } = await supabase()
      .from('order_items')
      .select('product_id, quantity, subtotal, order:order_id(status)')
      .in('product_id', products.map((p: any) => p.id))
      .not('order.status', 'eq', 'cancelled');

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

  /** R8: Dead stock / No-sale */
  async getDeadStock(filters: ReportFilters): Promise<DeadStockRow[]> {
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || new Date().toISOString().split('T')[0];

    // Get all products
    const { data: products } = await supabase()
      .from('products')
      .select('id, name, price_per_day, quantity, created_at, category:category_id(name)');

    // Get products that have been rented in the period
    const { data: rentedItems } = await supabase()
      .from('order_items')
      .select('product_id, created_at, order:order_id(status)')
      .gte('created_at', `${fromDate}T00:00:00`)
      .lte('created_at', `${toDate}T23:59:59`)
      .not('order.status', 'eq', 'cancelled');

    const rentedIds = new Set((rentedItems || []).filter((i: any) => i.order?.status !== 'cancelled').map((i: any) => i.product_id));

    // Get last rental date for all products
    const { data: lastRentals } = await supabase()
      .from('order_items')
      .select('product_id, created_at')
      .order('created_at', { ascending: false });

    const lastRentalMap: Record<string, string> = {};
    for (const item of (lastRentals || []) as any[]) {
      if (!lastRentalMap[item.product_id]) lastRentalMap[item.product_id] = item.created_at;
    }

    return (products || [])
      .filter((p: any) => !rentedIds.has(p.id))
      .map((p: any) => {
        const lastRental = lastRentalMap[p.id];
        return {
          product_id: p.id,
          product_name: p.name,
          category_name: p.category?.name || '',
          price_per_day: Number(p.price_per_day),
          quantity: p.quantity,
          days_since_last_rental: lastRental ? Math.floor((Date.now() - new Date(lastRental).getTime()) / 86400000) : null,
          created_at: p.created_at,
        };
      });
  }

  /** R9: Sales by staff */
  async getSalesByStaff(filters: ReportFilters): Promise<SalesByStaffRow[]> {
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || new Date().toISOString().split('T')[0];

    const { data } = await supabase()
      .from('orders')
      .select('id, total_amount, amount_paid, created_by, staff:created_by(id, name, email)')
      .gte('created_at', `${fromDate}T00:00:00`)
      .lte('created_at', `${toDate}T23:59:59`)
      .neq('status', 'cancelled');

    const map: Record<string, SalesByStaffRow> = {};
    for (const o of (data || []) as any[]) {
      if (!o.staff) continue;
      const sid = o.created_by;
      if (!map[sid]) {
        map[sid] = { staff_id: sid, staff_name: o.staff.name || 'Unknown', staff_email: o.staff.email || '', order_count: 0, total_revenue: 0, avg_order_value: 0 };
      }
      map[sid].order_count++;
      map[sid].total_revenue += Number(o.amount_paid || o.total_amount || 0);
    }

    return Object.values(map)
      .map(s => ({ ...s, total_revenue: Math.round(s.total_revenue * 100) / 100, avg_order_value: s.order_count > 0 ? Math.round((s.total_revenue / s.order_count) * 100) / 100 : 0 }))
      .sort((a, b) => b.total_revenue - a.total_revenue);
  }

  /** R10: Inventory + Revenue */
  async getInventoryRevenue(): Promise<InventoryRevenueRow[]> {
    const { data: products } = await supabase()
      .from('products')
      .select('id, name, quantity, available_quantity, price_per_day, category:category_id(name)');

    const { data: items } = await supabase()
      .from('order_items')
      .select('product_id, quantity, subtotal, order:order_id(status)')
      .not('order.status', 'eq', 'cancelled');

    const revenueMap: Record<string, { revenue: number; count: number }> = {};
    for (const item of (items || []) as any[]) {
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
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || new Date().toISOString().split('T')[0];

    const { data } = await supabase()
      .from('customer_enquiries')
      .select('*, staff:logged_by(name, email)')
      .gte('created_at', `${fromDate}T00:00:00`)
      .lte('created_at', `${toDate}T23:59:59`)
      .order('created_at', { ascending: false });

    return (data || []) as CustomerEnquiry[];
  }

  /** R12: GST Filing report */
  async getGSTFilingReport(filters: ReportFilters): Promise<any> {
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || new Date().toISOString().split('T')[0];

    // Fetch invoice prefix from settings
    const { data: settingsData } = await supabase()
      .from('settings')
      .select('value')
      .eq('key', 'invoice_prefix')
      .single();
    const prefix = settingsData?.value || 'INV-';

    // 1. Fetch total counts for GST vs Non-GST transparency
    const { data: allOrders } = await supabase()
      .from('orders')
      .select('id, gst_amount, status')
      .gte('created_at', `${fromDate}T00:00:00`)
      .lte('created_at', `${toDate}T23:59:59`)
      .not('status', 'eq', 'cancelled');

    const totalOrderCount = allOrders?.length || 0;
    const gstOrderCount = allOrders?.filter(o => Number(o.gst_amount) > 0).length || 0;
    const nonGstOrderCount = totalOrderCount - gstOrderCount;

    // 2. Fetch all order items for the detailed slab breakdown
    const { data, error } = await supabase()
      .from('order_items')
      .select(`
        id,
        gst_percentage,
        base_amount,
        gst_amount,
        subtotal,
        order:order_id (
          id,
          status,
          created_at,
          total_amount,
          gst_amount,
          customer:customer_id (
            name
          )
        )
      `)
      .gte('created_at', `${fromDate}T00:00:00`)
      .lte('created_at', `${toDate}T23:59:59`)
      .not('order.status', 'eq', 'cancelled');

    if (error) throw new Error(error.message);

    const items = data || [];
    
    // Group by GST slab
    const slabs: Record<number, { taxable: number; gst: number }> = {
      5: { taxable: 0, gst: 0 },
      12: { taxable: 0, gst: 0 },
      18: { taxable: 0, gst: 0 }
    };

    // Detailed invoice-wise tracking
    const invoiceMap: Record<string, any> = {};

    let totalTaxable = 0;
    let totalGst = 0;

    items.forEach((item: any) => {
      const slab = Number(item.gst_percentage);
      const taxable = Number(item.base_amount || 0);
      const gst = Number(item.gst_amount || 0);

      if (slab > 0) {
        if (!slabs[slab]) slabs[slab] = { taxable: 0, gst: 0 };
        slabs[slab].taxable += taxable;
        slabs[slab].gst += gst;
        
        totalTaxable += taxable;
        totalGst += gst;
      }

      // Track details for the invoice list (only for GST orders)
      const order = item.order;
      if (order && Number(order.gst_amount) > 0) {
        if (!invoiceMap[order.id]) {
          invoiceMap[order.id] = {
            order_id: order.id,
            invoice_no: `${prefix}${order.id.slice(0, 8).toUpperCase()}`,
            date: order.created_at,
            customer_name: order.customer?.name || 'Unknown',
            total_value: Number(order.total_amount || 0),
            taxable_value: 0,
            gst_amount: 0,
            slabs: new Set()
          };
        }
        invoiceMap[order.id].taxable_value += taxable;
        invoiceMap[order.id].gst_amount += gst;
        if (slab > 0) invoiceMap[order.id].slabs.add(slab);
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

    const details = Object.values(invoiceMap).map((inv: any) => ({
      ...inv,
      taxable_value: Math.round(inv.taxable_value * 100) / 100,
      gst_amount: Math.round(inv.gst_amount * 100) / 100,
      slabs: Array.from(inv.slabs).sort().join(', ') + '%'
    })).sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    return {
      summary,
      details,
      composition: {
        total_orders: totalOrderCount,
        gst_orders: gstOrderCount,
        non_gst_orders: nonGstOrderCount,
        gst_percentage: totalOrderCount > 0 ? Math.round((gstOrderCount / totalOrderCount) * 100) : 0
      },
      total_taxable: Math.round(totalTaxable * 100) / 100,
      total_cgst: Math.round((totalGst / 2) * 100) / 100,
      total_sgst: Math.round((totalGst / 2) * 100) / 100,
      total_gst: Math.round(totalGst * 100) / 100,
      period: `${fromDate} to ${toDate}`
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
      .select('*, staff:logged_by(name, email)')
      .single();

    if (error) throw new Error(error.message);
    return data as CustomerEnquiry;
  }

  // ── Helpers ──────────────────────────────────────────────
  private getPeriodStart(period: string): string {
    const now = new Date();
    switch (period) {
      case 'day': return now.toISOString().split('T')[0];
      case 'week': { const d = new Date(now); d.setDate(d.getDate() - 7); return d.toISOString().split('T')[0]; }
      case 'month': { const d = new Date(now.getFullYear(), now.getMonth(), 1); return d.toISOString().split('T')[0]; }
      case 'year': return `${now.getFullYear()}-01-01`;
      default: { const d = new Date(now.getFullYear(), now.getMonth(), 1); return d.toISOString().split('T')[0]; }
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
}

export const reportService = new ReportService();
