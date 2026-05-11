/**
 * Damage Assessment Hooks
 *
 * TanStack Query hooks for damage assessment operations.
 * Handles fetching, creating, and updating damage assessments.
 *
 * @module hooks/useDamageAssessments
 */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useAppStore } from '@/stores';
import type { DamageAssessmentWithProduct, DamageDecision } from '@/domain';

const QUERY_KEY = 'damage-assessments';

/**
 * Fetch damage assessments for an order.
 */
export function useDamageAssessments(orderId: string) {
  return useQuery({
    queryKey: [QUERY_KEY, orderId],
    queryFn: async () => {
      const res = await fetch(`/api/orders/${orderId}/damage-assessments`);
      if (!res.ok) throw new Error('Failed to fetch assessments');
      return res.json() as Promise<{
        assessments: DamageAssessmentWithProduct[];
        summary: { allDone: boolean; pending: number; total: number };
      }>;
    },
    enabled: !!orderId,
    staleTime: 30_000,
    refetchOnWindowFocus: false,
  });
}

/**
 * Create damage assessments batch after return processing.
 */
export function useCreateDamageAssessments() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  const mutation = useMutation({
    mutationFn: async (params: {
      orderId: string;
      items: Array<{
        order_item_id: string;
        product_id: string;
        branch_id: string;
        damaged_quantity: number;
      }>;
    }) => {
      const res = await fetch(`/api/orders/${params.orderId}/damage-assessments`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ items: params.items }),
      });
      if (!res.ok) {
        const err = await res.json();
        throw new Error(err.error || 'Failed to create assessments');
      }
      return res.json();
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: [QUERY_KEY, variables.orderId] });
    },
    onError: (error: Error) => {
      showError('Assessment Error', error.message);
    },
  });

  return {
    ...mutation,
    createAssessments: mutation.mutate,
    isCreating: mutation.isPending,
  };
}

/**
 * Update a single damage assessment decision.
 */
export function useAssessDamageUnit() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  const mutation = useMutation({
    mutationFn: async (params: {
      orderId: string;
      assessmentId: string;
      decision: DamageDecision;
      notes?: string;
    }) => {
      const res = await fetch(
        `/api/orders/${params.orderId}/damage-assessments/${params.assessmentId}`,
        {
          method: 'PATCH',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            decision: params.decision,
            notes: params.notes,
          }),
        }
      );
      if (!res.ok) {
        const err = await res.json();
        throw new Error(err.error || 'Failed to update assessment');
      }
      return res.json();
    },
    onSuccess: (result, variables) => {
      queryClient.invalidateQueries({ queryKey: [QUERY_KEY, variables.orderId] });
      // Also invalidate the order to reflect stock changes
      queryClient.invalidateQueries({ queryKey: ['orders', variables.orderId] });
      queryClient.invalidateQueries({ queryKey: ['order', variables.orderId] });
      const label = variables.decision === 'reuse' ? 'Reuse' : 'Write Off';
      showSuccess('Assessment Updated', `Unit marked as "${label}".`);
    },
    onError: (error: Error) => {
      showError('Assessment Error', error.message);
    },
  });

  return {
    ...mutation,
    assessUnit: mutation.mutate,
    isAssessing: mutation.isPending,
  };
}
