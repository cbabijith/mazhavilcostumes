/**
 * Cleaning Hooks
 *
 * @module hooks/useCleaning
 */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { 
  CleaningRecord, 
  CleaningStatus, 
  CleaningPriority,
  CleaningSearchParams 
} from '@/domain';
import { useAppStore } from '@/stores';

const cleaningKeys = {
  all: ['cleaning'] as const,
  queue: (branchId: string) => ['cleaning', 'queue', branchId] as const,
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

export function useCleaningQueue(branchId: string, status?: CleaningStatus) {
  return useQuery({
    queryKey: [...cleaningKeys.queue(branchId), status],
    queryFn: async () => {
      const url = `/api/cleaning?branch_id=${branchId}${status ? `&status=${status}` : ''}`;
      const res = await apiFetch<{ success: boolean; data: CleaningRecord[] }>(url);
      return res.data;
    },
    enabled: !!branchId,
  });
}

export function useStartCleaning() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  return useMutation({
    mutationFn: (id: string) =>
      apiFetch(`/api/cleaning/${id}`, { 
        method: 'PATCH', 
        body: JSON.stringify({ status: CleaningStatus.IN_PROGRESS }) 
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: cleaningKeys.all });
      showSuccess('Cleaning started');
    },
    onError: (err: any) => showError('Failed to start cleaning', err.message),
  });
}

export function useCompleteCleaning() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  return useMutation({
    mutationFn: (id: string) =>
      apiFetch(`/api/cleaning/${id}`, { 
        method: 'PATCH', 
        body: JSON.stringify({ status: CleaningStatus.COMPLETED }) 
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: cleaningKeys.all });
      showSuccess('Cleaning completed');
    },
    onError: (err: any) => showError('Failed to complete cleaning', err.message),
  });
}
