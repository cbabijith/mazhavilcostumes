/**
 * Revenue Report Hook
 *
 * Loads report pages through the API and collects every matching transaction
 * before an export. No server-side services are imported into the client.
 *
 * @module hooks/useRevenueReport
 */
'use client';

import { useMutation } from '@tanstack/react-query';
import type { ReportFilters, RevenueDetailRow, RevenueReportData } from '@/domain';
import { useAppStore } from '@/stores';

interface RevenueRequest {
  type: 'revenue' | 'todays-revenue';
  filters: ReportFilters;
  branchId?: string | null;
  storeId?: string | null;
}

const EXPORT_PAGE_SIZE = 500;

/**
 * Fetch one page, preserving the report's date, scope and transaction filters.
 * @param request Report type, filters and selected store/branch.
 * @returns Report summary, one detail page and its full matching count.
 * @throws When the API fails or returns an invalid report.
 */
async function fetchRevenuePage(request: RevenueRequest): Promise<RevenueReportData> {
  const { type, filters, branchId, storeId } = request;
  const params = new URLSearchParams({
    page: String(filters.page || 1),
    limit: String(filters.limit || 50),
  });
  if (filters.payment_mode) params.set('payment_mode', filters.payment_mode);

  if (type === 'revenue') {
    params.set('fromDate', filters.from_date || '');
    params.set('toDate', filters.to_date || '');
    if (branchId) params.set('branchId', branchId);
    if (storeId) params.set('storeId', storeId);
    if (filters.status?.length) params.set('statusFilter', filters.status.join(','));
  } else if (filters.status?.length) {
    params.set('status', filters.status.join(','));
  }

  const endpoint = type === 'revenue' ? '/api/reports/revenue' : '/api/reports/todays-revenue';
  const response = await fetch(`${endpoint}?${params.toString()}`, { cache: 'no-store' });
  const json = await response.json();
  if (!response.ok || !json.success) {
    throw new Error(json.error?.message || 'Failed to fetch revenue report');
  }
  const result = type === 'revenue' ? json.data : json.data?.rows;
  if (!Array.isArray(result?.details) || !Number.isSafeInteger(result.total_details_count) || result.total_details_count < 0) {
    throw new Error('Invalid revenue report response');
  }
  return result;
}

/**
 * Collect all pages from the beginning, independently of the displayed page.
 * @param request The same report filters used by the on-screen table.
 * @returns All matching transactions in server order.
 * @throws If a request fails, the count changes, or a page is incomplete.
 */
async function fetchAllRevenueDetails(request: RevenueRequest): Promise<RevenueDetailRow[]> {
  const details: RevenueDetailRow[] = [];
  let expectedTotal: number | undefined;
  let page = 1;

  do {
    const result = await fetchRevenuePage({
      ...request,
      filters: { ...request.filters, page, limit: EXPORT_PAGE_SIZE },
    });
    expectedTotal ??= result.total_details_count;
    const expectedPageLength = Math.min(EXPORT_PAGE_SIZE, expectedTotal - details.length);
    // Never download a partial file when a later page fails or data changes.
    if (result.total_details_count !== expectedTotal || result.details.length !== expectedPageLength) {
      throw new Error('The transaction list changed or could not be loaded completely. Please generate the report and try again.');
    }
    details.push(...result.details);
    page += 1;
  } while (details.length < expectedTotal);

  return details;
}

/**
 * Provide page loading and an uncached export request with error notifications.
 * @returns Page loader and an asynchronous loader for all export details.
 */
export function useRevenueReport() {
  const showError = useAppStore((state) => state.showError);
  const exportMutation = useMutation({
    mutationFn: fetchAllRevenueDetails,
    retry: false,
    onError: (error: Error) => showError('Failed to export revenue report', error.message),
  });

  return { fetchRevenuePage, fetchAllRevenueDetails: exportMutation.mutateAsync };
}
