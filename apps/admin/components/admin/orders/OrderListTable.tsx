/**
 * OrderListTable Component
 *
 * High-performance datatable for rendering orders.
 * Uses memoized OrderRow components to prevent full-table re-renders
 * when only selection state or individual rows change.
 *
 * Features:
 *   - Select all / deselect all
 *   - Column sorting (ascending / descending) on all fields
 *   - Shimmer skeleton loading state
 *   - Empty state with CTA
 *   - Each row is independently memoized via React.memo
 *
 * @component
 * @module components/admin/orders/OrderListTable
 */

"use client";

import React, { useCallback, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { ShoppingCart, ArrowUpDown, ArrowUp, ArrowDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { type OrderWithRelations } from "@/domain";
import OrderRow from "./OrderRow";
import OrderItemsPanel from "./OrderItemsPanel";

type SortField = "customer" | "created_at" | "phone" | "dates" | "items" | "amount" | "status";
type SortDirection = "asc" | "desc";

interface SortState {
  field: SortField | null;
  direction: SortDirection;
}

interface OrderListTableProps {
  orders: OrderWithRelations[];
  isLoading: boolean;
  searchQuery: string;
  selectedOrders: string[];
  onSelectAll: () => void;
  onToggleSelect: (id: string) => void;
  onCancel: (order: OrderWithRelations) => void;
}

/** Shimmer skeleton for the loading state — static component, zero re-renders. */
const TableSkeleton = React.memo(function TableSkeleton() {
  return (
    <div className="divide-y divide-slate-100">
      {/* Table header skeleton */}
      <div className="hidden md:grid grid-cols-[auto_1fr_110px_120px_140px_160px_120px_100px_120px] gap-4 p-4 bg-slate-50/50">
        <div className="h-4 w-4 bg-slate-200 rounded animate-pulse" />
        <div className="h-4 w-24 bg-slate-200 rounded animate-pulse" />
        <div className="h-4 w-16 bg-slate-200 rounded animate-pulse" />
        <div className="h-4 w-20 bg-slate-200 rounded animate-pulse" />
        <div className="h-4 w-16 bg-slate-200 rounded animate-pulse" />
        <div className="h-4 w-24 bg-slate-200 rounded animate-pulse" />
        <div className="h-4 w-16 bg-slate-200 rounded animate-pulse" />
        <div className="h-4 w-16 bg-slate-200 rounded animate-pulse" />
        <div className="h-4 w-16 bg-slate-200 rounded animate-pulse justify-self-end" />
      </div>
      {/* Rows skeleton */}
      {[...Array(5)].map((_, i) => (
        <div key={i} className="flex items-center gap-4 p-4">
          <div className="h-4 w-4 bg-slate-100 rounded animate-pulse shrink-0" />
          <div className="h-10 w-10 bg-slate-100 rounded-full animate-pulse shrink-0" />
          <div className="space-y-2 flex-1">
            <div className="h-4 w-1/3 bg-slate-100 rounded animate-pulse" />
            <div className="h-3 w-1/4 bg-slate-50 rounded animate-pulse" />
          </div>
        </div>
      ))}
    </div>
  );
});

/** Empty state shown when no orders match the current filters. */
const EmptyState = React.memo(function EmptyState({
  searchQuery,
}: {
  searchQuery: string;
}) {
  const router = useRouter();
  return (
    <div className="p-16 text-center">
      <ShoppingCart className="w-12 h-12 text-slate-300 mx-auto mb-3" />
      <h3 className="text-lg font-semibold text-slate-900 mb-1">
        No Orders Found
      </h3>
      <p className="text-sm text-slate-500 max-w-sm mx-auto">
        {searchQuery
          ? `No orders matched your search for "${searchQuery}".`
          : "There are no orders yet in this branch."}
      </p>
      {!searchQuery && (
        <Button
          className="mt-6 bg-slate-900 text-white hover:bg-slate-800"
          onClick={() => router.push("/dashboard/orders/create")}
        >
          Create New Order
        </Button>
      )}
    </div>
  );
});

/** Status priority for sorting — more urgent statuses come first */
const STATUS_ORDER: Record<string, number> = {
  late_return: 0,
  flagged: 1,
  ongoing: 2,
  in_use: 3,
  partial: 4,
  delivered: 5,
  scheduled: 6,
  pending: 7,
  confirmed: 8,
  returned: 9,
  completed: 10,
  cancelled: 11,
};

/** Sort icon component for table headers */
function SortIcon({ field, sortState }: { field: SortField; sortState: SortState }) {
  if (sortState.field !== field) {
    return <ArrowUpDown className="w-3 h-3 text-slate-300 group-hover:text-slate-400 transition-colors" />;
  }
  return sortState.direction === "asc"
    ? <ArrowUp className="w-3 h-3 text-slate-700" />
    : <ArrowDown className="w-3 h-3 text-slate-700" />;
}

function OrderListTableInner({
  orders,
  isLoading,
  searchQuery,
  selectedOrders,
  onSelectAll,
  onToggleSelect,
  onCancel,
}: OrderListTableProps) {
  const [sortState, setSortState] = useState<SortState>({ field: null, direction: "asc" });

  const toggleSort = useCallback((field: SortField) => {
    setSortState(prev => {
      if (prev.field === field) {
        // Same field → toggle direction, or clear if already desc
        return prev.direction === "asc"
          ? { field, direction: "desc" as SortDirection }
          : { field: null, direction: "asc" as SortDirection };
      }
      // New field → default to ascending
      return { field, direction: "asc" as SortDirection };
    });
  }, []);

  const sortedOrders = useMemo(() => {
    if (!sortState.field) return orders;

    const sorted = [...orders].sort((a, b) => {
      let cmp = 0;

      switch (sortState.field) {
        case "customer":
          cmp = (a.customer?.name || "").localeCompare(b.customer?.name || "");
          break;
        case "created_at":
          cmp = new Date(a.created_at).getTime() - new Date(b.created_at).getTime();
          break;
        case "phone":
          cmp = (a.customer?.phone || "").localeCompare(b.customer?.phone || "");
          break;
        case "dates":
          cmp = new Date(a.start_date).getTime() - new Date(b.start_date).getTime();
          if (cmp === 0) cmp = new Date(a.end_date).getTime() - new Date(b.end_date).getTime();
          break;
        case "items":
          cmp = (a.items?.length || 0) - (b.items?.length || 0);
          break;
        case "amount":
          cmp = (a.total_amount || 0) - (b.total_amount || 0);
          break;
        case "status":
          cmp = (STATUS_ORDER[a.status] ?? 99) - (STATUS_ORDER[b.status] ?? 99);
          break;
      }

      return sortState.direction === "desc" ? -cmp : cmp;
    });

    return sorted;
  }, [orders, sortState]);

  const isSelected = useCallback(
    (id: string) => selectedOrders.includes(id),
    [selectedOrders]
  );

  // Items panel state
  const [panelOrder, setPanelOrder] = useState<OrderWithRelations | null>(null);
  const handleViewItems = useCallback((o: OrderWithRelations) => {
    setPanelOrder(prev => prev?.id === o.id ? null : o);
  }, []);
  const handleClosePanel = useCallback(() => setPanelOrder(null), []);

  if (isLoading) {
    return (
      <Card className="shadow-sm border-slate-200 overflow-hidden bg-white">
        <TableSkeleton />
      </Card>
    );
  }

  if (orders.length === 0) {
    return (
      <Card className="shadow-sm border-slate-200 overflow-hidden bg-white">
        <EmptyState searchQuery={searchQuery} />
      </Card>
    );
  }

  const headerClass = "px-4 py-3 select-none cursor-pointer group hover:bg-slate-100/50 transition-colors";

  return (
    <Card className="shadow-sm border-slate-200 overflow-hidden bg-white">
      <div className="overflow-x-auto">
        <table className="w-full text-sm text-left">
          <thead className="bg-slate-50/50 text-xs font-semibold text-slate-500 uppercase tracking-wider border-b border-slate-200">
            <tr>
              <th className="px-4 py-3 w-10 text-center">
                <input
                  type="checkbox"
                  checked={
                    selectedOrders.length === orders.length && orders.length > 0
                  }
                  onChange={onSelectAll}
                  className="rounded border-slate-300 text-slate-900 focus:ring-slate-900"
                />
              </th>
              <th className={headerClass} onClick={() => toggleSort("customer")}>
                <div className="flex items-center gap-1.5">
                  Customer
                  <SortIcon field="customer" sortState={sortState} />
                </div>
              </th>
              <th className={headerClass} onClick={() => toggleSort("created_at")}>
                <div className="flex items-center gap-1.5">
                  Booked On
                  <SortIcon field="created_at" sortState={sortState} />
                </div>
              </th>
              <th className={headerClass} onClick={() => toggleSort("phone")}>
                <div className="flex items-center gap-1.5">
                  Phone
                  <SortIcon field="phone" sortState={sortState} />
                </div>
              </th>
              <th className={headerClass} onClick={() => toggleSort("dates")}>
                <div className="flex items-center gap-1.5">
                  Dates
                  <SortIcon field="dates" sortState={sortState} />
                </div>
              </th>
              <th className={headerClass} onClick={() => toggleSort("items")}>
                <div className="flex items-center gap-1.5">
                  Items
                  <SortIcon field="items" sortState={sortState} />
                </div>
              </th>
              <th className={headerClass} onClick={() => toggleSort("amount")}>
                <div className="flex items-center gap-1.5">
                  Amount
                  <SortIcon field="amount" sortState={sortState} />
                </div>
              </th>
              <th className={headerClass} onClick={() => toggleSort("status")}>
                <div className="flex items-center gap-1.5">
                  Status
                  <SortIcon field="status" sortState={sortState} />
                </div>
              </th>
              <th className="px-4 py-3 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {sortedOrders.map((order) => (
              <OrderRow
                key={order.id}
                order={order}
                selected={isSelected(order.id)}
                onToggleSelect={onToggleSelect}
                onCancel={onCancel}
                onViewItems={handleViewItems}
              />
            ))}
          </tbody>
        </table>
      </div>

      {/* Items Side Panel */}
      <OrderItemsPanel order={panelOrder} onClose={handleClosePanel} />
    </Card>
  );
}

const OrderListTable = React.memo(OrderListTableInner);
OrderListTable.displayName = "OrderListTable";

export default OrderListTable;
