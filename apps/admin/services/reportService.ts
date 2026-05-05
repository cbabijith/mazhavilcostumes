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
    const today = new Date().toLocaleDateString('en-CA');
    const date = filters.date || today;

    const { data, error } = await supabase()
      .from('orders')
      .select('id, status, start_date, end_date, total_amount, customer:customer_id(name, phone), order_items(product:product_id(name))')
      .eq('start_date', date)
      .in('status', ['scheduled', 'pending', 'confirmed', 'ongoing', 'in_use', 'delivered'])
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching day-wise bookings:', error);
      throw new Error(error.message);
    }

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
    const today = new Date().toLocaleDateString('en-CA');
    const { data } = await supabase()
      .from('orders')
      .select('id, status, end_date, total_amount, amount_paid, customer:customer_id(name, phone), order_items(product:product_id(name))')
      .lt('end_date', today)
      .in('status', ['ongoing', 'in_use', 'delivered', 'late_return'])
      .order('end_date', { ascending: true });

    return (data || []).map((o: any) => {
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

  /** R3: Revenue report */
  async getRevenue(filters: ReportFilters): Promise<RevenueRow[]> {
    const period = filters.period || 'month';
    const fromDate = filters.from_date || this.getPeriodStart(period);
    const toDate = filters.to_date || new Date().toLocaleDateString('en-CA');

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
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || new Date().toLocaleDateString('en-CA');

    const { data } = await supabase()
      .from('orders')
      .select('id, customer_id, amount_paid, created_at, customer:customer_id(id, name, phone)')
      .neq('status', 'cancelled')
      .gte('created_at', fromDate)
      .lte('created_at', toDate + 'T23:59:59');

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
  async getRentalFrequency(filters: ReportFilters): Promise<RentalFrequencyRow[]> {
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || new Date().toLocaleDateString('en-CA');

    const { data } = await supabase()
      .from('order_items')
      .select('product_id, quantity, created_at, product:product_id(name, category:category_id(name)), order:order_id(status)')
      .gte('created_at', fromDate)
      .lte('created_at', toDate + 'T23:59:59')
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
    return rows.slice(0, filters.limit || 50);
  }

  /** R7: ROI / Profit per costume */
  async getROI(filters: ReportFilters): Promise<ROIRow[]> {
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || new Date().toLocaleDateString('en-CA');

    const { data: products } = await supabase()
      .from('products')
      .select('id, name, purchase_price')
      .gt('purchase_price', 0);

    if (!products || products.length === 0) return [];

    const { data: items } = await supabase()
      .from('order_items')
      .select('product_id, quantity, subtotal, order:order_id(status, created_at)')
      .in('product_id', products.map((p: any) => p.id))
      .gte('created_at', fromDate)
      .lte('created_at', toDate + 'T23:59:59')
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
    const toDate = filters.to_date || new Date().toLocaleDateString('en-CA');

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
    const toDate = filters.to_date || new Date().toLocaleDateString('en-CA');

    const { data, error } = await supabase()
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
      `)
      .gte('created_at', `${fromDate}T00:00:00`)
      .lte('created_at', `${toDate}T23:59:59`);

    if (error) throw new Error(error.message);

    const map: Record<string, SalesByStaffRow> = {};
    for (const o of (data || []) as any[]) {
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
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || new Date().toLocaleDateString('en-CA');

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
      .gte('created_at', `${fromDate}T00:00:00`)
      .lte('created_at', `${toDate}T23:59:59`)
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
    const toDate = filters.to_date || new Date().toLocaleDateString('en-CA');

    const { data } = await supabase()
      .from('customer_enquiries')
      .select('*, logged_by_staff:staff!logged_by(name, email)')
      .gte('created_at', `${fromDate}T00:00:00`)
      .lte('created_at', `${toDate}T23:59:59`)
      .order('created_at', { ascending: false });

    return (data || []).map((d: any) => ({
      ...d,
      staff: d.logged_by_staff
    })) as CustomerEnquiry[];
  }

  /** R12: GST Filing report */
  async getGSTFilingReport(filters: ReportFilters): Promise<any> {
    const fromDate = filters.from_date || this.getPeriodStart(filters.period || 'month');
    const toDate = filters.to_date || new Date().toLocaleDateString('en-CA');

    // Fetch invoice prefix from settings
    const { data: settingsData } = await supabase()
      .from('settings')
      .select('value')
      .eq('key', 'invoice_prefix')
      .single();
    const prefix = settingsData?.value || 'INV-';

    // 1. Fetch total counts for GST vs Non-GST transparency
    let orderQuery = supabase()
      .from('orders')
      .select('id, gst_amount, status')
      .gte('created_at', `${fromDate}T00:00:00`)
      .lte('created_at', `${toDate}T23:59:59`)
      .not('status', 'eq', 'cancelled');

    if (filters.status?.length) {
      orderQuery = orderQuery.in('status', filters.status);
    }

    const { data: allOrders } = await orderQuery;

    const totalOrderCount = allOrders?.length || 0;

    // 2. Fetch all order items for the detailed slab breakdown
    let itemQuery = supabase()
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
      .lte('created_at', `${toDate}T23:59:59`);

    const { data, error } = await itemQuery;

    if (error) throw new Error(error.message);

    const items = data || [];
    
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
      // Skip items from cancelled orders or if status filter is applied and doesn't match
      if (!order || order.status === 'cancelled') return;
      
      if (filters.status?.length && !filters.status.includes(order.status)) {
        return;
      }

      const slab = Number(item.gst_percentage || 0);
      const taxable = Number(item.base_amount || 0);
      const gst = Number(item.gst_amount || 0);

      if (slab > 0) {
        if (!slabs[slab]) slabs[slab] = { taxable: 0, gst: 0 };
        slabs[slab].taxable += taxable;
        slabs[slab].gst += gst;
        
        totalTaxable += taxable;
        totalGst += gst;
      }

      // Track details for the invoice list (Include if order has GST OR item has GST)
      const hasGst = Number(order.gst_amount) > 0 || gst > 0 || slab > 0;
      if (hasGst) {
        if (!invoiceMap[order.id]) {
          invoiceMap[order.id] = {
            order_id: order.id,
            invoice_no: `${prefix}${order.id.slice(0, 8).toUpperCase()}`,
            date: order.created_at,
            customer_name: order.customer?.name || 'Unknown',
            status: order.status,
            total_value: Number(order.total_amount || 0),
            taxable_value: 0,
            gst_amount: 0,
            cgst: 0,
            sgst: 0,
            slabs: new Set()
          };
        }
        invoiceMap[order.id].taxable_value += taxable;
        invoiceMap[order.id].gst_amount += gst;
        invoiceMap[order.id].cgst += (gst / 2);
        invoiceMap[order.id].sgst += (gst / 2);
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

    const details = Object.values(invoiceMap)
      .filter((inv: any) => inv.gst_amount > 0) // Only include orders that actually have GST items
      .map((inv: any) => ({
        ...inv,
        taxable_value: Math.round(inv.taxable_value * 100) / 100,
        gst_amount: Math.round(inv.gst_amount * 100) / 100,
        cgst: Math.round(inv.cgst * 100) / 100,
        sgst: Math.round(inv.sgst * 100) / 100,
        slabs: inv.slabs.size > 0 ? Array.from(inv.slabs).sort().join(', ') + '%' : '-'
      })).sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    // Correct the GST order count based on actual items processed
    const finalGstOrderCount = Object.keys(invoiceMap).length;

    return {
      summary,
      details,
      composition: {
        total_orders: totalOrderCount,
        gst_orders: finalGstOrderCount,
        non_gst_orders: totalOrderCount - finalGstOrderCount,
        gst_percentage: totalOrderCount > 0 ? Math.round((finalGstOrderCount / totalOrderCount) * 100) : 0
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
    const now = new Date();
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
}

export const reportService = new ReportService();
