/**
 * Gallery Repository
 *
 * Data access layer for gallery entities using Supabase.
 *
 * @module repository/galleryRepository
 */

import { BaseRepository, RepositoryResult } from './supabaseClient';
import { 
  GalleryItem, 
  CreateGalleryItemDTO, 
  UpdateGalleryItemDTO
} from '@/domain';

export class GalleryRepository extends BaseRepository {
  private readonly tableName = 'gallery';

  /**
   * Find all gallery items
   */
  async findAll(params?: { is_active?: boolean }): Promise<RepositoryResult<GalleryItem[]>> {
    let query = this.client
      .from(this.tableName)
      .select('*');

    if (params?.is_active !== undefined) {
      query = query.eq('is_active', params.is_active);
    }

    // Order by sort_order ascending, then created_at descending
    query = query.order('sort_order', { ascending: true })
                 .order('created_at', { ascending: false });

    const response = await query;
    return this.handleResponse<GalleryItem[]>(response);
  }

  /**
   * Find gallery item by ID
   */
  async findById(id: string): Promise<RepositoryResult<GalleryItem>> {
    const response = await this.client
      .from(this.tableName)
      .select('*')
      .eq('id', id)
      .single();

    return this.handleResponse<GalleryItem>(response);
  }

  /**
   * Create a new gallery item
   */
  async create(data: CreateGalleryItemDTO): Promise<RepositoryResult<GalleryItem>> {
    const response = await this.client
      .from(this.tableName)
      .insert({
        ...data,
        ...this.getCreateAuditFields(),
      })
      .select()
      .single();

    return this.handleResponse<GalleryItem>(response);
  }

  /**
   * Update an existing gallery item
   */
  async update(id: string, data: UpdateGalleryItemDTO): Promise<RepositoryResult<GalleryItem>> {
    const response = await this.client
      .from(this.tableName)
      .update({
        ...data,
        ...this.getUpdateAuditFields(),
      })
      .eq('id', id)
      .select()
      .single();

    return this.handleResponse<GalleryItem>(response);
  }

  /**
   * Delete a gallery item
   */
  async delete(id: string): Promise<RepositoryResult<void>> {
    const response = await this.client
      .from(this.tableName)
      .delete()
      .eq('id', id);

    return this.handleResponse<void>(response);
  }
}

// Singleton instance
export const galleryRepository = new GalleryRepository();
