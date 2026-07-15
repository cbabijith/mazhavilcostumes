/**
 * Order Availability Check API
 *
 * POST /api/orders/check-availability
 *
 * Batch-checks availability for all items in a potential order.
 * Used by the Order Form to show real-time availability before checkout.
 *
 * Body: {
 *   items: [{ product_id, quantity }],
 *   start_date: "YYYY-MM-DD",
 *   end_date: "YYYY-MM-DD",
 *   branch_id: "uuid",
 *   exclude_order_id?: "uuid"  // for edit scenarios
 * }
 *
 * @module app/api/orders/check-availability/route
 */

import { NextRequest } from 'next/server';
import { orderService } from '@/services/orderService';
import { apiGuard } from '@/lib/apiGuard';
import { apiSuccess, apiBadRequest, apiInternalError } from '@/lib/apiResponse';

export async function POST(request: NextRequest) {
  try {
    const guard = await apiGuard(request, 'orders');
    if (guard.error) return guard.error;

    const body = await request.json();
    const { items, start_date, end_date, branch_id, exclude_order_id } = body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      return apiBadRequest('items array is required');
    }
    if (!start_date || !end_date) {
      return apiBadRequest('start_date and end_date are required');
    }

    // Deduplicate items by product_id (keep max quantity per product)
    const productMap = new Map<string, { product_id: string; quantity: number; product_name?: string }>();
    for (const item of items) {
      if (!item.product_id || !item.quantity) {
        return apiBadRequest('Each item must have product_id and quantity');
      }
      const existing = productMap.get(item.product_id);
      if (!existing || item.quantity > existing.quantity) {
        productMap.set(item.product_id, item);
      }
    }
    const uniqueItems = Array.from(productMap.values());

    // Run all availability checks in parallel
    const results = await Promise.all(
      uniqueItems.map(async (item) => {
        const availResult = await orderService.checkAvailability(
          item.product_id,
          start_date,
          end_date,
          branch_id,
          exclude_order_id
        );

        if (!availResult.success || !availResult.data) {
          return {
            product_id: item.product_id,
            product_name: item.product_name || 'Unknown',
            requested: item.quantity,
            available: 0,
            isAvailable: false,
            peakReserved: 0,
            overlappingOrders: [],
            total: 0,
            error: availResult.error?.message || 'Failed to check availability',
          };
        }

        const isAvailable = availResult.data.available >= item.quantity;
        const isAvailableWithPriority = availResult.data.availableWithPriority >= item.quantity;

        return {
          product_id: item.product_id,
          product_name: item.product_name || 'Unknown',
          requested: item.quantity,
          available: availResult.data.available,
          availableWithPriority: availResult.data.availableWithPriority,
          isAvailable: isAvailable || isAvailableWithPriority,
          peakReserved: availResult.data.peakReserved,
          overlappingOrders: availResult.data.overlappingOrders,
          priorityCleaningNeeded: availResult.data.priorityCleaningNeeded,
          priorityCleaningInfo: availResult.data.priorityCleaningInfo || [],
          total: availResult.data.total,
        };
      })
    );

    const allAvailable = results.every(r => r.isAvailable);

    return apiSuccess({ allAvailable, items: results });
  } catch (err) {
    console.error('Order availability check error:', err);
    return apiInternalError();
  }
}
