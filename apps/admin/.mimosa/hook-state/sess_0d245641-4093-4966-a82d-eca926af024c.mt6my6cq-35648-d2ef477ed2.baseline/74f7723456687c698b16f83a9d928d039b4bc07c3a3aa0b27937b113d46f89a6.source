/**
 * Gallery REST API — Single Resource Endpoint
 *
 * Routes:
 *   GET    /api/gallery/:id   Fetch one gallery item by id
 *   PATCH  /api/gallery/:id   Update a gallery item
 *   DELETE /api/gallery/:id   Delete a gallery item
 *
 * @module app/api/gallery/[id]/route
 */

import { NextRequest } from "next/server";
import { galleryService } from "@/services/galleryService";
import { apiGuard } from "@/lib/apiGuard";
import { getAuthUser } from "@/lib/auth";
import { apiSuccess, apiRepositoryError, apiNotFound, apiInternalError } from "@/lib/apiResponse";

interface RouteContext {
  params: Promise<{ id: string }>;
}

export async function GET(request: NextRequest, { params }: RouteContext) {
  try {
    const guard = await apiGuard(request, 'gallery');
    if (guard.error) return guard.error;

    const { id } = await params;
    const result = await galleryService.getGalleryItemById(id);
    if (!result.success || !result.data) {
      return apiNotFound('Gallery item');
    }
    return apiSuccess(result.data);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}

export async function PATCH(request: NextRequest, { params }: RouteContext) {
  try {
    const guard = await apiGuard(request, 'gallery');
    if (guard.error) return guard.error;

    const authUser = await getAuthUser(request);
    galleryService.setUserContext(
      authUser?.staff_id || null, 
      authUser?.branch_id || null,
      authUser?.store_id || null
    );

    const { id } = await params;
    const body = await request.json();

    const result = await galleryService.updateGalleryItem(id, body);
    if (!result.success) {
      return apiRepositoryError(result.error, 'Failed to update gallery item');
    }
    return apiSuccess(result.data, { message: 'Gallery item updated successfully' });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}

export async function DELETE(request: NextRequest, { params }: RouteContext) {
  try {
    const guard = await apiGuard(request, 'gallery');
    if (guard.error) return guard.error;

    const authUser = await getAuthUser(request);
    galleryService.setUserContext(
      authUser?.staff_id || null, 
      authUser?.branch_id || null,
      authUser?.store_id || null
    );

    const { id } = await params;

    const result = await galleryService.deleteGalleryItem(id);
    if (!result.success) {
      return apiRepositoryError(result.error, 'Failed to delete gallery item');
    }
    return apiSuccess(null, { message: 'Gallery item deleted successfully' });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}
