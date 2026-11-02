/**
 * Categories Product Counts API
 *
 * Route: GET /api/categories/product-counts
 *
 * Returns a map of category_id -> product_count for all active categories.
 * Used by the mobile app to display product counts in the category tree.
 *
 * Response:
 *   200 { success: true, data: { [categoryId: string]: number } }
 *   500 { success: false, error: { message, code } }
 *
 * @module app/api/categories/product-counts/route
 */

import { NextRequest } from "next/server";
import { categoryService } from "@/services";
import { apiGuard } from "@/lib/apiGuard";
import { apiSuccess, apiInternalError, apiBadRequest, apiRepositoryError } from "@/lib/apiResponse";
import { z } from "zod";

/** GET /api/categories/product-counts — get product counts for all categories */
export async function GET(request: NextRequest) {
  try {
    const guard = await apiGuard(request, 'categories');
    if (guard.error) return guard.error;
    const requestedBranch = request.nextUrl.searchParams.get('branch_id') || undefined;
    if (requestedBranch && !z.uuid().safeParse(requestedBranch).success) {
      return apiBadRequest('Invalid branch_id');
    }
    const canSwitch = ['admin', 'super_admin'].includes(guard.user.role);
    const branchId = canSwitch ? requestedBranch : guard.user.branch_id || undefined;
    const result = await categoryService.getProductCounts(branchId, guard.user.store_id);
    if (!result.success || !result.data) {
      return apiRepositoryError(result.error, 'Failed to fetch product counts');
    }
    return apiSuccess(result.data.counts, {
      meta: { total: result.data.total, page: 1, limit: result.data.total,
        totalPages: 1, hasNext: false, hasPrev: false },
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}
