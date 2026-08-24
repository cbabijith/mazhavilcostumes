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
import { categoryRepository } from "@/repository";
import { apiGuard } from "@/lib/apiGuard";
import { apiSuccess, apiInternalError } from "@/lib/apiResponse";

/** GET /api/categories/product-counts — get product counts for all categories */
export async function GET(request: NextRequest) {
  try {
    // Public endpoint (or add auth guard if needed)
    // const guard = await apiGuard(request, 'categories');
    // if (guard.error) return guard.error;

    // Get all categories
    const categoriesResult = await categoryRepository.findAll();
    if (!categoriesResult.success || !categoriesResult.data) {
      return apiInternalError('Failed to fetch categories');
    }

    // Build product counts map
    const productCounts: Record<string, number> = {};
    
    for (const category of categoriesResult.data) {
      const countResult = await categoryRepository.getProductCount(category.id);
      if (countResult.success && countResult.data !== null) {
        productCounts[category.id] = countResult.data;
      } else {
        productCounts[category.id] = 0;
      }
    }

    return apiSuccess(productCounts);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}
