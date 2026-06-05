/**
 * Gallery Hooks - Optimized with API Routes
 *
 * TanStack Query hooks for gallery operations.
 *
 * @module hooks/useGallery
 */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { GalleryItem, CreateGalleryItemDTO, UpdateGalleryItemDTO } from '@/domain';
import { useAppStore } from '@/stores';
import type { ApiSuccessResponse } from '@/lib/apiResponse';

const galleryKeys = {
  all: ['gallery'] as const,
  detail: (id: string) => ['gallery', id] as const,
};

async function apiFetch<T>(url: string, options?: RequestInit): Promise<T> {
  const res = await fetch(url, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.error?.message || body.error || `Request failed (${res.status})`);
  }
  return res.json();
}

/**
 * Fetch all gallery items
 */
export function useGallery(params?: { is_active?: boolean }) {
  const queryParams = new URLSearchParams();
  if (params?.is_active !== undefined) queryParams.set('is_active', params.is_active.toString());

  const queryString = queryParams.toString();
  const url = queryString ? `/api/gallery?${queryString}` : '/api/gallery';

  return useQuery({
    queryKey: [...galleryKeys.all, params],
    queryFn: async () => {
      const response = await apiFetch<ApiSuccessResponse<GalleryItem[]>>(url);
      return response.data || [];
    },
    refetchOnWindowFocus: false,
    refetchOnMount: true,
  });
}

/**
 * Fetch a single gallery item by ID
 */
export function useGalleryItem(id: string) {
  return useQuery({
    queryKey: galleryKeys.detail(id),
    queryFn: async () => {
      const response = await apiFetch<ApiSuccessResponse<GalleryItem>>(`/api/gallery/${id}`);
      return response.data;
    },
    enabled: !!id,
    refetchOnWindowFocus: false,
  });
}

/**
 * Create a new gallery item
 */
export function useCreateGalleryItem() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  return useMutation({
    mutationFn: ({ silent, ...data }: CreateGalleryItemDTO & { silent?: boolean }) =>
      apiFetch<ApiSuccessResponse<GalleryItem>>('/api/gallery', { method: 'POST', body: JSON.stringify(data) }),
    onSuccess: async (result, variables) => {
      queryClient.invalidateQueries({ queryKey: galleryKeys.all });
      if (!variables.silent) {
        showSuccess('Gallery image uploaded successfully');
      }
    },
    onError: (error) => {
      showError('Failed to upload gallery image', error.message);
    },
  });
}

/**
 * Update an existing gallery item
 */
export function useUpdateGalleryItem() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateGalleryItemDTO }) =>
      apiFetch<ApiSuccessResponse<GalleryItem>>(`/api/gallery/${id}`, { method: 'PATCH', body: JSON.stringify(data) }),
    onSuccess: async (result, variables) => {
      queryClient.invalidateQueries({ queryKey: galleryKeys.all });
      queryClient.setQueryData(galleryKeys.detail(variables.id), result.data);
      showSuccess('Gallery image updated successfully');
    },
    onError: (error) => {
      showError('Failed to update gallery image', error.message);
    },
  });
}

/**
 * Delete a gallery item
 */
export function useDeleteGalleryItem() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  return useMutation({
    mutationFn: (id: string) =>
      apiFetch<ApiSuccessResponse<null>>(`/api/gallery/${id}`, { method: 'DELETE' }),
    onSuccess: async () => {
      queryClient.invalidateQueries({ queryKey: galleryKeys.all });
      showSuccess('Gallery image deleted successfully');
    },
    onError: (error) => {
      showError('Failed to delete gallery image', error.message);
    },
  });
}

/**
 * Reorder gallery items
 */
export function useReorderGalleryItems() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  return useMutation({
    mutationFn: (galleryItems: { id: string; sort_order: number }[]) =>
      apiFetch<ApiSuccessResponse<null>>('/api/gallery/reorder', { method: 'POST', body: JSON.stringify({ galleryItems }) }),
    onMutate: async (newOrder) => {
      await queryClient.cancelQueries({ queryKey: galleryKeys.all });
      const previousQueries = queryClient.getQueriesData<GalleryItem[]>({ queryKey: galleryKeys.all });

      queryClient.setQueriesData<GalleryItem[]>({ queryKey: galleryKeys.all }, (old) => {
        if (!old || !Array.isArray(old)) return old;
        return old.map((item) => {
          const update = newOrder.find((o) => o.id === item.id);
          if (update) {
            return {
              ...item,
              sort_order: update.sort_order,
            };
          }
          return item;
        }).sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0));
      });

      return { previousQueries };
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: galleryKeys.all });
      showSuccess('Gallery layout order updated');
    },
    onError: (error, _variables, context) => {
      if (context?.previousQueries) {
        for (const [queryKey, data] of context.previousQueries) {
          queryClient.setQueryData(queryKey, data);
        }
      }
      showError('Failed to reorder gallery items', error.message);
    },
  });
}
