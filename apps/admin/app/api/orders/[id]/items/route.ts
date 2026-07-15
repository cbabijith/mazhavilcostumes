/**
 * Orders Items API — On-demand item fetching
 *
 *   GET /api/orders/:id/items   Fetch items for a single order
 *
 * Used by the OrderItemsPanel slide-out in the orders list.
 * This avoids fetching all item data with product joins for every order
 * in the list view.
 *
 * @module app/api/orders/[id]/items/route
 */

import { NextRequest } from "next/server";
import { orderRepository } from "@/repository/orderRepository";
import { apiGuard } from "@/lib/apiGuard";
import { apiSuccess, apiNotFound, apiInternalError } from "@/lib/apiResponse";

interface RouteContext {
  params: Promise<{ id: string }>;
}

/** GET /api/orders/:id/items — fetch order items with product details */
export async function GET(_request: NextRequest, { params }: RouteContext) {
  try {
    const guard = await apiGuard(_request, 'orders');
    if (guard.error) return guard.error;

    const { id } = await params;

    const result = await orderRepository.getOrderItems(id);
    if (!result.success) {
      return apiNotFound('Order items');
    }

    return apiSuccess(result.data);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}
