/**
 * Gallery Domain Types
 *
 * Type definitions for the gallery domain.
 *
 * @module domain/types/gallery
 */

import { BaseEntity } from './common';

export interface GalleryItem extends BaseEntity {
  store_id: string | null;
  image_url: string;
  sort_order: number;
  is_active: boolean;
  // Audit fields
  readonly created_by: string | null;
  readonly created_at_branch_id: string | null;
  readonly updated_by: string | null;
  readonly updated_at_branch_id: string | null;
}

export interface CreateGalleryItemDTO {
  store_id?: string;
  image_url: string;
  sort_order?: number;
  is_active?: boolean;
}

export interface UpdateGalleryItemDTO {
  image_url?: string;
  sort_order?: number;
  is_active?: boolean;
}
