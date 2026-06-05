/**
 * Gallery Validation Schemas
 *
 * Zod schemas for validating gallery create/update operations.
 *
 * @module domain/schemas/gallery.schema
 */

import { z } from 'zod';

const baseGallerySchema = {
  store_id: z.string().uuid().optional(),
  image_url: z.string().url('Invalid image URL'),
  sort_order: z.number().int().min(0).optional().default(0),
  is_active: z.boolean().optional().default(true),
};

export const CreateGallerySchema = z.object(baseGallerySchema);
export const UpdateGallerySchema = z.object(baseGallerySchema).partial();

export type CreateGalleryInput = z.infer<typeof CreateGallerySchema>;
export type UpdateGalleryInput = z.infer<typeof UpdateGallerySchema>;
