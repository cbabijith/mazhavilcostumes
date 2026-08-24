/**
 * Gallery Service
 *
 * Business logic layer for gallery entities.
 *
 * @module services/galleryService
 */

import { RepositoryResult } from '@/repository';
import { 
  GalleryItem, 
  CreateGalleryItemDTO, 
  UpdateGalleryItemDTO
} from '@/domain';
import { galleryRepository } from '@/repository';

export class GalleryService {
  private currentUserId: string | null = null;
  private currentBranchId: string | null = null;
  private currentStoreId: string | null = null;

  /**
   * Set user context for audit logging
   */
  setUserContext(userId: string | null, branchId: string | null, storeId: string | null = null): void {
    this.currentUserId = userId;
    this.currentBranchId = branchId;
    this.currentStoreId = storeId;
    galleryRepository.setUserContext(userId, branchId);
  }

  /**
   * Get all gallery items
   */
  async getAllGalleryItems(params?: { is_active?: boolean }): Promise<RepositoryResult<GalleryItem[]>> {
    return await galleryRepository.findAll(params);
  }

  /**
   * Get gallery item by ID
   */
  async getGalleryItemById(id: string): Promise<RepositoryResult<GalleryItem>> {
    return await galleryRepository.findById(id);
  }

  /**
   * Create a new gallery item
   */
  async createGalleryItem(data: CreateGalleryItemDTO): Promise<RepositoryResult<GalleryItem>> {
    if (!data.image_url) {
      return {
        data: null,
        error: {
          message: 'Image URL is required',
          code: 'VALIDATION_ERROR'
        } as any,
        success: false,
      };
    }

    // Assign store_id from context if not provided in DTO
    const storeId = data.store_id || this.currentStoreId || undefined;

    return await galleryRepository.create({
      ...data,
      store_id: storeId,
    });
  }

  /**
   * Update an existing gallery item
   */
  async updateGalleryItem(id: string, data: UpdateGalleryItemDTO): Promise<RepositoryResult<GalleryItem>> {
    const existing = await galleryRepository.findById(id);
    if (!existing.success || !existing.data) {
      return {
        data: null,
        error: {
          message: 'Gallery item not found',
          code: 'NOT_FOUND'
        } as any,
        success: false,
      };
    }

    return await galleryRepository.update(id, data);
  }

  /**
   * Delete a gallery item
   */
  async deleteGalleryItem(id: string): Promise<RepositoryResult<void>> {
    const existing = await galleryRepository.findById(id);
    if (!existing.success || !existing.data) {
      return {
        data: null,
        error: {
          message: 'Gallery item not found',
          code: 'NOT_FOUND'
        } as any,
        success: false,
      };
    }

    return await galleryRepository.delete(id);
  }
}

// Singleton instance
export const galleryService = new GalleryService();
