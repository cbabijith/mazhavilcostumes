/**
 * Gallery Reorder API
 * POST /api/gallery/reorder — bulk update gallery sort_orders
 */

import { NextRequest } from "next/server";
import { galleryService } from "@/services/galleryService";
import { apiGuard } from "@/lib/apiGuard";
import { getAuthUser } from "@/lib/auth";
import { apiSuccess, apiBadRequest, apiInternalError } from "@/lib/apiResponse";

export async function POST(request: NextRequest) {
  try {
    const guard = await apiGuard(request, 'gallery');
    if (guard.error) return guard.error;

    const authUser = await getAuthUser(request);
    galleryService.setUserContext(
      authUser?.staff_id || null, 
      authUser?.branch_id || null,
      authUser?.store_id || null
    );

    const { galleryItems } = await request.json();

    if (!Array.isArray(galleryItems)) {
      return apiBadRequest('Invalid payload — galleryItems must be an array');
    }

    // Update each gallery item's sort_order
    for (const item of galleryItems) {
      if (item.sort_order !== undefined) {
        await galleryService.updateGalleryItem(item.id, { sort_order: item.sort_order });
      }
    }

    return apiSuccess(null, { message: 'Gallery layout order updated successfully' });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}
