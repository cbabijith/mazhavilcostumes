/**
 * Settings Hooks
 *
 * TanStack Query hooks for settings operations.
 * All operations go through API routes for correct store_id context.
 *
 * @module hooks/useSettings
 */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { queryUtils } from '@/lib/query-client';
import { useAppStore } from '@/stores';
import { DEFAULT_GST_SLABS } from '@/domain/types/category';

// Query keys (local — note: the centralized queryKeys from query-client.ts is
// also imported and used below for the new slabs hooks; this local object is
// kept for backwards-compat with the existing hooks in this file.)
const queryKeys = {
  settings: ['settings'] as const,
  gst: ['settings', 'gst'] as const,
  invoicePrefix: ['settings', 'invoice_prefix'] as const,
  paymentTerms: ['settings', 'payment_terms'] as const,
  authorizedSignature: ['settings', 'authorized_signature'] as const,
  gstSlabs: ['settings', 'gstSlabs'] as const,
};

/**
 * Generic fetch helper for settings API
 */
async function fetchSettingValue(key: string): Promise<string | null> {
  const res = await fetch(`/api/settings?key=${encodeURIComponent(key)}`);
  if (!res.ok) return null;
  const json = await res.json();
  return json.data?.value ?? null;
}

/**
 * Check if GST is enabled (via API route for correct store_id context)
 */
export function useIsGSTEnabled() {
  return useQuery({
    queryKey: [...queryKeys.settings, 'is_gst_enabled'],
    queryFn: async () => {
      const res = await fetch('/api/settings?key=is_gst_enabled');
      if (!res.ok) return { success: true, data: false };
      const json = await res.json();
      const val = json.data?.value;
      return { success: true, data: val === true || val === 'true' };
    },
  });
}

/**
 * Enable or disable GST (auto-save toggle — no save button needed)
 */
export function useUpdateIsGSTEnabled() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  const mutation = useMutation({
    mutationFn: async (isEnabled: boolean) => {
      const res = await fetch('/api/settings', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ key: 'is_gst_enabled', value: isEnabled ? 'true' : 'false' }),
      });
      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.error?.message || body.error || `Request failed (${res.status})`);
      }
      return res.json();
    },
    onSuccess: () => {
      queryUtils.invalidateSettings();
      queryClient.invalidateQueries({ queryKey: ['settings'] });
      showSuccess('GST status updated successfully');
    },
    onError: (error) => {
      showError('Failed to update GST status', error.message);
    },
  });

  return {
    ...mutation,
    updateIsGSTEnabled: mutation.mutate,
    isLoading: mutation.isPending,
  };
}

/**
 * Get invoice prefix
 */
export function useInvoicePrefix() {
  return useQuery({
    queryKey: queryKeys.invoicePrefix,
    queryFn: async () => {
      const value = await fetchSettingValue('invoice_prefix');
      return { success: true, data: value != null ? { value } : null };
    },
  });
}

/**
 * Get payment terms
 */
export function usePaymentTerms() {
  return useQuery({
    queryKey: queryKeys.paymentTerms,
    queryFn: async () => {
      const value = await fetchSettingValue('payment_terms');
      return { success: true, data: value != null ? { value } : null };
    },
  });
}

/**
 * Get authorized signature
 */
export function useAuthorizedSignature() {
  return useQuery({
    queryKey: queryKeys.authorizedSignature,
    queryFn: async () => {
      const value = await fetchSettingValue('authorized_signature');
      return { success: true, data: value != null ? { value } : null };
    },
  });
}

/**
 * Update a setting
 */
export function useUpdateSetting() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  const mutation = useMutation({
    mutationFn: async ({ key, value }: { key: string; value: string }) => {
      const res = await fetch('/api/settings', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ key, value }),
      });
      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.error?.message || body.error || `Request failed (${res.status})`);
      }
      return res.json();
    },
    onSuccess: () => {
      queryUtils.invalidateSettings();
      queryClient.invalidateQueries({ queryKey: ['settings'] });
      // Removed showSuccess here to prevent duplicate toasts since page.tsx handles it
    },
    onError: (error) => {
      showError('Failed to update setting', error.message);
    },
  });

  return {
    ...mutation,
    updateSetting: mutation.mutateAsync,
    isLoading: mutation.isPending,
  };
}

/**
 * Get the configured GST percentage slabs.
 * Returns the parsed number[] from the API, falling back to DEFAULT_GST_SLABS
 * on any failure so consumers (e.g. CategoryForm) always have a usable list.
 */
export function useGstSlabs() {
  return useQuery({
    queryKey: queryKeys.gstSlabs,
    queryFn: async () => {
      const res = await fetch('/api/settings?key=gst_slabs');
      if (!res.ok) return [...DEFAULT_GST_SLABS];
      const json = await res.json();
      const val = json.data?.value;
      if (Array.isArray(val) && val.length > 0) return val as number[];
      return [...DEFAULT_GST_SLABS];
    },
    staleTime: 5 * 60 * 1000,
  });
}

/**
 * Update the configured GST percentage slabs.
 * Pass a complete number[] — it replaces the stored list.
 */
export function useUpdateGstSlabs() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  const mutation = useMutation({
    mutationFn: async (slabs: number[]) => {
      const res = await fetch('/api/settings', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ key: 'gst_slabs', value: JSON.stringify(slabs) }),
      });
      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.error?.message || body.error || `Request failed (${res.status})`);
      }
      return res.json();
    },
    onSuccess: () => {
      // Invalidate the slabs query and all category queries (the dropdown options change)
      queryClient.invalidateQueries({ queryKey: queryKeys.gstSlabs });
      queryUtils.invalidateCategories();
      showSuccess('GST slabs updated successfully');
    },
    onError: (error) => {
      showError('Failed to update GST slabs', error.message);
    },
  });

  return {
    ...mutation,
    updateGstSlabs: mutation.mutate,
    isLoading: mutation.isPending,
  };
}
