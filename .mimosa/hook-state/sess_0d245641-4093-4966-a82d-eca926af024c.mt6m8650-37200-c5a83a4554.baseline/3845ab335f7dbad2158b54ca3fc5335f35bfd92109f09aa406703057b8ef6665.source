/**
 * Product Orders / Analytics API Route
 *
 * GET /api/products/[id]/orders
 *
 * Returns the list of order_items referencing this product, together with
 * their parent order, plus aggregated analytics (total revenue from this
 * product, total units rented, active rentals, historical counts).
 *
 * Phase 4 enhancements:
 *   - Monthly revenue breakdown (last 6 months)
 *   - Usage rate (%)
 *   - Average rental duration (days)
 *   - Cancelled orders count
 *   - ROI calculation (if purchase_price > 0)
 *
 * @module app/api/products/[id]/orders/route
 */

import { NextRequest } from 'next/server';
import { createAdminClient } from '@/lib/supabase/server';
import { apiGuard } from '@/lib/apiGuard';
import { apiSuccess, apiBadRequest, apiInternalError } from '@/lib/apiResponse';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const guard = await apiGuard(request, 'products');
    if (guard.error) return guard.error;

    const { id } = await params;

    if (!id || typeof id !== 'string') {
      return apiBadRequest('Invalid product ID');
    }

    const supabase = createAdminClient();

    // Pull order_items for this product, joined with parent order + customer + branch
    const { data: items, error } = await supabase
      .from('order_items')
      .select(
        `
        id,
        order_id,
        product_id,
        quantity,
        price_per_day,
        subtotal,
        created_at,
        order:order_id(
          id,
          status,
          start_date,
          end_date,
          total_amount,
          branch_id,
          customer_id,
          created_at,
          customer:customer_id(id, name, phone),
          branch:branch_id(id, name)
        )
      `
      )
      .eq('product_id', id)
      .order('created_at', { ascending: false });

    if (error) {
      return apiInternalError(error.message);
    }

    // Also fetch the product's purchase_price and created_at for ROI / usage rate
    const { data: productData } = await supabase
      .from('products')
      .select('purchase_price, created_at')
      .eq('id', id)
      .single();

    const purchasePrice = Number(productData?.purchase_price ?? 0);
    const productCreatedAt = productData?.created_at ? new Date(productData.created_at) : null;

    const rows = items || [];

    // Compute aggregate analytics
    let totalUnitsRented = 0;
    let totalRevenue = 0;
    let activeOrders = 0;
    let completedOrders = 0;
    let cancelledOrders = 0;
    const uniqueCustomers = new Set<string>();

    // Monthly revenue tracking (last 6 months)
    const monthlyRevenue: Record<string, { month: string; revenue: number; rentals: number }> = {};
    const now = new Date();
    for (let i = 5; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
      const label = d.toLocaleDateString('en-IN', { month: 'short', year: 'numeric' });
      monthlyRevenue[key] = { month: label, revenue: 0, rentals: 0 };
    }

    // Rental duration tracking
    let totalRentalDays = 0;
    let rentalDaysCount = 0;

    const ACTIVE_STATUSES = new Set([
      'pending',
      'confirmed',
      'preparing',
      'out_for_delivery',
      'delivered',
      'active',
      'ongoing',
    ]);
    const COMPLETED_STATUSES = new Set(['returned', 'completed']);
    const CANCELLED_STATUSES = new Set(['cancelled', 'refunded']);

    for (const item of rows as any[]) {
      const order = item.order;
      if (!order) continue;
      const status = (order.status || '').toLowerCase();

      if (CANCELLED_STATUSES.has(status)) {
        cancelledOrders += 1;
        continue;
      }

      totalUnitsRented += item.quantity || 0;
      totalRevenue += Number(item.subtotal ?? 0);

      if (order.customer_id) uniqueCustomers.add(order.customer_id);
      if (ACTIVE_STATUSES.has(status)) activeOrders += 1;
      else if (COMPLETED_STATUSES.has(status)) completedOrders += 1;

      // Monthly revenue aggregation
      const orderDate = new Date(order.created_at);
      const monthKey = `${orderDate.getFullYear()}-${String(orderDate.getMonth() + 1).padStart(2, '0')}`;
      if (monthlyRevenue[monthKey]) {
        monthlyRevenue[monthKey].revenue += Number(item.subtotal ?? 0);
        monthlyRevenue[monthKey].rentals += 1;
      }

      // Rental duration calculation
      if (order.start_date && order.end_date) {
        const start = new Date(order.start_date);
        const end = new Date(order.end_date);
        const diffDays = Math.max(1, Math.ceil((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)));
        totalRentalDays += diffDays;
        rentalDaysCount += 1;
      }
    }

    // Calculate usage rate
    let usageRate = 0;
    if (productCreatedAt) {
      const daysSinceCreation = Math.max(1, Math.ceil((now.getTime() - productCreatedAt.getTime()) / (1000 * 60 * 60 * 24)));
      usageRate = Math.min(100, Math.round((totalRentalDays / daysSinceCreation) * 100));
    }

    // Calculate average rental duration
    const avgRentalDuration = rentalDaysCount > 0 ? Math.round(totalRentalDays / rentalDaysCount) : 0;

    // Calculate ROI
    let roi: number | null = null;
    if (purchasePrice > 0) {
      roi = Math.round(((totalRevenue - purchasePrice) / purchasePrice) * 100);
    }

    return apiSuccess({
      items: rows,
      analytics: {
        totalOrders: rows.length,
        totalUnitsRented,
        totalRevenue: Math.round(totalRevenue * 100) / 100,
        activeOrders,
        completedOrders,
        cancelledOrders,
        uniqueCustomers: uniqueCustomers.size,
        // Phase 4 enhanced stats
        monthlyRevenue: Object.values(monthlyRevenue),
        usageRate,
        avgRentalDuration,
        roi,
        purchasePrice,
        totalRentalDays,
        daysSinceCreation: productCreatedAt
          ? Math.max(1, Math.ceil((now.getTime() - productCreatedAt.getTime()) / (1000 * 60 * 60 * 24)))
          : 0,
      },
    });
  } catch (err) {
    console.error('Product orders analytics error:', err);
    return apiInternalError();
  }
}
