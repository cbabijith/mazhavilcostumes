/**
 * Order Hooks
 *
 * TanStack Query hooks for order operations.
 * All operations go through API routes (server-side, service role key).
 *
 * Flow: UI → hooks → fetch(/api/orders) → service → repository → supabase
 *
 * @module hooks/useOrders
 */

import { useQuery, useMutation, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { Order, OrderWithRelations, CreateOrderDTO, UpdateOrderDTO, OrderSearchParams, ReturnOrderDTO, OrderStatusHistory } from '@/domain/types/order';
import { useAppStore } from '@/stores';
import type { ApiSuccessResponse, PaginationMeta } from '@/lib/apiResponse';
import { queryKeys } from '@/lib/query-client';

async function apiFetch<T>(url: string, options?: RequestInit): Promise<T> {
  const res = await fetch(url, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    let errorMessage = body.error?.message || body.error || `Request failed (${res.status})`;
    if (body.error?.details) {
      errorMessage += `: ${JSON.stringify(body.error.details)}`;
    }
    throw new Error(errorMessage);
  }
  return res.json();
}

interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  meta?: PaginationMeta;
  // Backwards compat — these are now in meta
  total?: number;
  totalPages?: number;
  page?: number;
  limit?: number;
  hasNext?: boolean;
  hasPrev?: boolean;
  actionNeededCount?: number;
  conflictCount?: number;
  error?: any;
}

/**
 * Fetch all orders
 */
export function useOrders(params?: OrderSearchParams & { page?: number; limit?: number }) {
  return useQuery<PaginatedResponse<OrderWithRelations>>({
    queryKey: queryKeys.orderList(params),
    queryFn: async () => {
      const searchParams = new URLSearchParams();
      if (params?.customer_id) searchParams.append('customer_id', params.customer_id);
      if (params?.branch_id) searchParams.append('branch_id', params.branch_id);
      if (params?.status) {
        if (Array.isArray(params.status)) {
          params.status.forEach(s => searchParams.append('status', s));
        } else {
          searchParams.append('status', params.status);
        }
      }
      if (params?.exclude_status) {
        if (Array.isArray(params.exclude_status)) {
          params.exclude_status.forEach(s => searchParams.append('exclude_status', s));
        } else {
          searchParams.append('exclude_status', params.exclude_status);
        }
      }
      if (params?.product_id) searchParams.append('product_id', params.product_id);
      if (params?.payment_status) {
        if (Array.isArray(params.payment_status)) {
          params.payment_status.forEach(s => searchParams.append('payment_status', s));
        } else {
          searchParams.append('payment_status', params.payment_status);
        }
      }
      if (params?.query) searchParams.append('query', params.query);
      if (params?.date_filter) searchParams.append('date_filter', params.date_filter);
      if (params?.date_field) searchParams.append('date_field', params.date_field);
      if (params?.date_from) searchParams.append('date_from', params.date_from);
      if (params?.date_to) searchParams.append('date_to', params.date_to);
      if (params?.limit) searchParams.append('limit', params.limit.toString());
      if (params?.page) searchParams.append('page', params.page.toString());
      if (params?.has_damage_charges) searchParams.append('has_damage_charges', 'true');
      if (params?.has_stock_conflict) searchParams.append('has_stock_conflict', 'true');
      if (params?.sort_by) searchParams.append('sort_by', params.sort_by);
      if (params?.sort_order) searchParams.append('sort_order', params.sort_order);
      
      const queryString = searchParams.toString();
      const url = `/api/orders${queryString ? `?${queryString}` : ''}`;
      
      const raw = await apiFetch<ApiSuccessResponse<OrderWithRelations[]> & { meta?: PaginationMeta }>(url);

      // Normalise to the shape the UI expects
      return {
        success: raw.success,
        data: raw.data,
        total: raw.meta?.total ?? 0,
        totalPages: raw.meta?.totalPages ?? 0,
        page: raw.meta?.page ?? 1,
        limit: raw.meta?.limit ?? 25,
        hasNext: raw.meta?.hasNext ?? false,
        hasPrev: raw.meta?.hasPrev ?? false,
        actionNeededCount: raw.meta?.actionNeededCount ?? 0,
        conflictCount: raw.meta?.conflictCount ?? 0,
      };
    },
    placeholderData: keepPreviousData,
  });
}

/**
 * Fetch a single order by ID
 */
export function useOrder(id: string) {
  return useQuery<{ success: boolean; data?: OrderWithRelations; error?: any }>({
    queryKey: queryKeys.orderDetail(id),
    queryFn: async () => {
      const res = await apiFetch<ApiSuccessResponse<OrderWithRelations>>(`/api/orders/${id}`);
      return { success: true, data: res.data };
    },
    enabled: !!id,

  });
}

/**
 * Fetch order status history
 */
export function useOrderStatusHistory(id: string, enabled: boolean = true) {
  return useQuery<{ success: boolean; data?: OrderStatusHistory[]; error?: any }>({
    queryKey: queryKeys.orderHistory(id),
    queryFn: async () => {
      const res = await apiFetch<ApiSuccessResponse<OrderStatusHistory[]>>(`/api/orders/${id}/history`);
      return { success: true, data: res.data };
    },
    enabled: enabled && !!id,

  });
}

/**
 * Create a new order
 */
export function useCreateOrder() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  const mutation = useMutation({
    mutationFn: (data: CreateOrderDTO) =>
      apiFetch<ApiSuccessResponse<OrderWithRelations>>('/api/orders', { method: 'POST', body: JSON.stringify(data) }),
    onSuccess: async (data) => {
      await queryClient.invalidateQueries({ queryKey: queryKeys.orders });
      await queryClient.invalidateQueries({ queryKey: ['cleaning'] });
      if (data?.data?.id) {
        await queryClient.invalidateQueries({ queryKey: ['payments', 'order', data.data.id] });
      }
      showSuccess('Order created successfully');
    },
    onError: (error) => showError('Failed to create order', error.message),
  });

  return {
    ...mutation,
    createOrder: mutation.mutate,
    isLoading: mutation.isPending,
  };
}

/**
 * Update an existing order
 */
export function useUpdateOrder() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  const mutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateOrderDTO }) => 
      apiFetch<ApiSuccessResponse<Order>>(`/api/orders/${id}`, { method: 'PATCH', body: JSON.stringify(data) }),
    onMutate: async ({ id, data }) => {
      await queryClient.cancelQueries({ queryKey: queryKeys.orderLists() });

      const previousLists = queryClient.getQueriesData<PaginatedResponse<OrderWithRelations>>({ queryKey: queryKeys.orderLists() });

      // Exclude items from spread — UpdateOrderDTO.items has a different shape than OrderItem[]
      const { items: _items, ...scalarData } = data;
      queryClient.setQueriesData<PaginatedResponse<OrderWithRelations>>({ queryKey: queryKeys.orderLists() }, (old) => {
        if (!old?.data) return old;
        return {
          ...old,
          data: old.data.map((o) => o.id === id ? { ...o, ...scalarData } as OrderWithRelations : o),
        };
      });

      return { previousLists };
    },
    onSuccess: async (_res, variables) => {
      // Invalidate detail cache to trigger findById refetch with full relations
      await queryClient.invalidateQueries({ queryKey: queryKeys.orderDetail(variables.id) });
      await queryClient.invalidateQueries({ queryKey: queryKeys.orderLists() });
      await queryClient.invalidateQueries({ queryKey: ['cleaning'] });
      showSuccess('Order updated successfully');
    },
    onError: (error, _variables, context) => {
      if (context?.previousLists) {
        for (const [key, data] of context.previousLists) {
          queryClient.setQueryData(key, data);
        }
      }
      showError('Failed to update order', error.message);
    },
  });

  return {
    ...mutation,
    updateOrder: mutation.mutate,
    isLoading: mutation.isPending,
  };
}

/**
 * Delete an order
 */
export function useDeleteOrder() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  const mutation = useMutation({
    mutationFn: (id: string) => apiFetch<ApiSuccessResponse<null>>(`/api/orders/${id}`, { method: 'DELETE' }),
    onMutate: async (id) => {
      await queryClient.cancelQueries({ queryKey: queryKeys.orderLists() });
      const previousLists = queryClient.getQueriesData<PaginatedResponse<OrderWithRelations>>({ queryKey: queryKeys.orderLists() });
      
      queryClient.setQueriesData<PaginatedResponse<OrderWithRelations>>({ queryKey: queryKeys.orderLists() }, (old) => {
        if (!old?.data) return old;
        return { ...old, data: old.data.filter((o) => o.id !== id), total: (old.total ?? 0) - 1 };
      });
      return { previousLists };
    },
    onSuccess: async (_data, id) => {
      queryClient.removeQueries({ queryKey: queryKeys.orderDetail(id) });
      await queryClient.invalidateQueries({ queryKey: ['cleaning'] });
      showSuccess('Order deleted successfully');
    },
    onError: (error, _id, context) => {
      if (context?.previousLists) {
        for (const [key, data] of context.previousLists) {
          queryClient.setQueryData(key, data);
        }
      }
      showError('Failed to delete order', error.message);
    },
  });

  return {
    ...mutation,
    deleteOrder: mutation.mutate,
    isLoading: mutation.isPending,
  };
}

/**
 * Process order return
 */
export function useProcessOrderReturn() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  const mutation = useMutation({
    mutationFn: ({ orderId, returnData }: { orderId: string; returnData: ReturnOrderDTO }) => 
      apiFetch<ApiSuccessResponse<Order>>(`/api/orders/${orderId}/return`, { method: 'PATCH', body: JSON.stringify(returnData) }),
    onMutate: async ({ orderId }) => {
      await queryClient.cancelQueries({ queryKey: queryKeys.orderLists() });
      const previousLists = queryClient.getQueriesData<PaginatedResponse<OrderWithRelations>>({ queryKey: queryKeys.orderLists() });
      return { previousLists };
    },
    onSuccess: async (_res, variables) => {
      // Invalidate detail cache to trigger findById refetch with full relations
      await queryClient.invalidateQueries({ queryKey: queryKeys.orderDetail(variables.orderId) });
      await queryClient.invalidateQueries({ queryKey: queryKeys.orderLists() });
      await queryClient.invalidateQueries({ queryKey: ['cleaning'] });
      showSuccess('Order return processed successfully');
    },
    onError: (error, _variables, context) => {
      if (context?.previousLists) {
        for (const [key, data] of context.previousLists) {
          queryClient.setQueryData(key, data);
        }
      }
      showError('Failed to process order return', error.message);
    },
  });

  return {
    ...mutation,
    processOrderReturn: mutation.mutate,
    isLoading: mutation.isPending,
  };
}

/**
 * Update damage details for a specific order item incrementally
 */
export function useUpdateOrderItemDamage() {
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();

  const mutation = useMutation({
    mutationFn: ({ itemId, data }: { itemId: string; data: any }) => 
      apiFetch<any>(`/api/orders/items/${itemId}/damage`, { method: 'PATCH', body: JSON.stringify(data) }),
    onSuccess: async (data) => {
      // Invalidate the specific order detail and lists
      if (data.order_id) {
        await queryClient.invalidateQueries({ queryKey: queryKeys.orderDetail(data.order_id) });
      }
      await queryClient.invalidateQueries({ queryKey: queryKeys.orderLists() });
      showSuccess('Item damage saved successfully');
    },
    onError: (error) => {
      showError('Failed to save item damage', error.message);
    },
  });

  return {
    ...mutation,
    updateOrderItemDamage: mutation.mutate,
    isUpdating: mutation.isPending,
  };
}

