/**
 * Products Count API
 *
 * Route: GET /api/products/count
 *
 * Returns the total count of products with optional filtering.
 * Used by the mobile app to get total product count efficiently.
 *
 * Query parameters:
 * - category_id: Filter by category
 * - store_id: Filter by store
 * - branch_id: Filter by branch
 * - status: Filter by status (active/inactive)
 * - is_featured: Filter featured products
 * - in_stock: Filter in-stock products
 *
 * Response:
 *   200 { success: true, data: { count: number } }
 *   500 { success: false, error: { message, code } }
 *
 * @module app/api/products/count/route
 */

import { NextRequest } from "next/server";
import { productRepository } from "@/repository";
import { apiGuard } from "@/lib/apiGuard";
import { apiSuccess, apiInternalError } from "@/lib/apiResponse";

/** GET /api/products/count — get total product count with optional filters */
export async function GET(request: NextRequest) {
  try {
    // Public endpoint (or add auth guard if needed)
    // const guard = await apiGuard(request, 'products');
    // if (guard.error) return guard.error;

    const { searchParams } = new URL(request.url);
    
    // Build filters object
    const filters: Record<string, any> = {};
    
    if (searchParams.get('category_id')) {
      filters.category_id = searchParams.get('category_id');
    }
    if (searchParams.get('store_id')) {
      filters.store_id = searchParams.get('store_id');
    }
    if (searchParams.get('branch_id')) {
      filters.branch_id = searchParams.get('branch_id');
    }
    if (searchParams.get('status')) {
      filters.is_active = searchParams.get('status') === 'active';
    }
    if (searchParams.get('is_featured') === 'true') {
      filters.is_featured = true;
    }
    if (searchParams.get('in_stock') === 'true') {
      filters.in_stock = true;
    }

    const result = await productRepository.getProductCount(filters);

    if (!result.success || result.data === null) {
      return apiInternalError('Failed to fetch product count');
    }

    return apiSuccess({ count: result.data });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}
