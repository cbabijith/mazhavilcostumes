/**
 * Gallery REST API — Collection Endpoint
 *
 * Routes:
 *   GET  /api/gallery       List all gallery items (super_admin, admin, manager)
 *   POST /api/gallery       Create a new gallery item (super_admin, admin, manager)
 *
 * @module app/api/gallery/route
 */

import { NextRequest } from "next/server";
import { galleryService } from "@/services/galleryService";
import { apiGuard } from "@/lib/apiGuard";
import { getAuthUser } from "@/lib/auth";
import { apiSuccess, apiRepositoryError, apiInternalError } from "@/lib/apiResponse";

export async function GET(request: NextRequest) {
  try {
    const guard = await apiGuard(request, 'gallery');
    if (guard.error) return guard.error;

    const { searchParams } = new URL(request.url);
    const activeParam = searchParams.get('is_active');
    const is_active = activeParam !== null ? activeParam === 'true' : undefined;

    const result = await galleryService.getAllGalleryItems({ is_active });
    if (!result.success) {
      return apiRepositoryError(result.error, 'Failed to fetch gallery items');
    }
    return apiSuccess(result.data);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}

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

    const body = await request.json();
    const result = await galleryService.createGalleryItem(body);
    if (!result.success) {
      return apiRepositoryError(result.error, 'Failed to create gallery item');
    }
    return apiSuccess(result.data, { status: 201, message: 'Gallery item created successfully' });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}
