/**
 * OrderFilters Component
 *
 * Filter bar for the orders list page. Contains:
 *   - Status filter chips (All, Ongoing, Scheduled, Late, etc.)
 *   - Date range filter (presets + custom range)
 *   - Search input with debounced callback
 *   - Bulk selection info bar
 *
 * Memoized to prevent re-rendering when the table data changes
 * but filter state remains the same.
 *
 * @component
 * @module components/admin/orders/OrderFilters
 */

"use client";

import React, {
  useState,
  useEffect,
  useRef,
  useCallback,
} from "react";
import { Search, AlertTriangle, Sparkles } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import { OrderStatus } from "@/domain";

/** Pre-defined status filter options */
const FILTER_CHIPS = [
  { label: "All", value: "ALL" },
  { label: "Pending", value: OrderStatus.PENDING },
  { label: "Ongoing", value: OrderStatus.ONGOING },
  { label: "Scheduled", value: OrderStatus.SCHEDULED },
  { label: "Late", value: OrderStatus.LATE_RETURN },
  { label: "Partial", value: OrderStatus.PARTIAL },
  { label: "Returned", value: OrderStatus.RETURNED },
  { label: "Completed", value: OrderStatus.COMPLETED },
  { label: "Cancelled", value: OrderStatus.CANCELLED },
  { label: "Flagged", value: OrderStatus.FLAGGED },
] as const;

interface OrderFiltersProps {
  statusFilter: string;
  dateFilter: string;
  dateFrom: string;
  dateTo: string;
  initialQuery: string;
  selectedCount: number;
  actionNeededCount: number;
  conflictCount: number;
  onStatusChange: (status: string) => void;
  onDateFilterChange: (filter: string) => void;
  onDateFromChange: (date: string) => void;
  onDateToChange: (date: string) => void;
  onSearchChange: (query: string) => void;
  onClearSelection: () => void;
  onResetFilters: () => void;
}

function OrderFiltersInner({
  statusFilter,
  dateFilter,
  dateFrom,
  dateTo,
  initialQuery,
  selectedCount,
  actionNeededCount,
  conflictCount,
  onStatusChange,
  onDateFilterChange,
  onDateFromChange,
  onDateToChange,
  onSearchChange,
  onClearSelection,
  onResetFilters,
}: OrderFiltersProps) {
  const [searchInput, setSearchInput] = useState(initialQuery);
  const debounceRef = useRef<NodeJS.Timeout | null>(null);
  const isFirstRender = useRef(true);

  // Sync external query changes (e.g. URL navigation)
  useEffect(() => {
    if (isFirstRender.current) {
      isFirstRender.current = false;
      return;
    }
    setSearchInput(initialQuery);
  }, [initialQuery]);

  // Debounce search input by 300ms
  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => {
      onSearchChange(searchInput);
    }, 300);
    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, [searchInput, onSearchChange]);

  const handleSearchInput = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      setSearchInput(e.target.value);
    },
    []
  );

  return (
    <Card className="shadow-sm border-slate-200 bg-white">
      <CardContent className="p-4 space-y-4">
        <div className="flex flex-col lg:flex-row gap-4 items-start lg:items-center justify-between">
          {/* Status Chips */}
          <div className="flex flex-wrap items-center gap-2">
            {FILTER_CHIPS.map((chip) => (
              <button
                key={chip.value}
                onClick={() => onStatusChange(chip.value)}
                className={`px-3 py-1.5 text-xs font-semibold rounded-full border transition-colors ${
                  statusFilter === chip.value
                    ? "bg-slate-900 text-white border-slate-900"
                    : "bg-white text-slate-600 border-slate-200 hover:bg-slate-50 hover:border-slate-300"
                }`}
              >
                {chip.label}
              </button>
            ))}

            {/* Action Needed chip — only visible when there are overdue scheduled orders */}
            {actionNeededCount > 0 && (
              <button
                onClick={() => onStatusChange('action_needed')}
                className={`flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-full border transition-colors ${
                  statusFilter === 'action_needed'
                    ? "bg-amber-500 text-white border-amber-500"
                    : "bg-amber-50 text-amber-700 border-amber-300 hover:bg-amber-100 hover:border-amber-400"
                }`}
              >
                <span className="relative flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-75"></span>
                  <span className={`relative inline-flex rounded-full h-2 w-2 ${
                    statusFilter === 'action_needed' ? 'bg-white' : 'bg-amber-500'
                  }`}></span>
                </span>
                Action Needed
                <span className={`inline-flex items-center justify-center min-w-[18px] h-[18px] rounded-full text-[10px] font-bold px-1 ${
                  statusFilter === 'action_needed'
                    ? 'bg-white/20 text-white'
                    : 'bg-amber-200 text-amber-800'
                }`}>
                  {actionNeededCount}
                </span>
              </button>
            )}

            {/* Stock Conflict chip — only visible when there are conflicts */}
            {conflictCount > 0 && (
              <button
                onClick={() => onStatusChange('stock_conflict')}
                className={`flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-full border transition-colors ${
                  statusFilter === 'stock_conflict'
                    ? "bg-red-600 text-white border-red-600 shadow-sm"
                    : "bg-red-50 text-red-700 border-red-200 hover:bg-red-100 hover:border-red-300"
                }`}
              >
                <AlertTriangle className={`w-3.5 h-3.5 ${
                  statusFilter === 'stock_conflict' ? 'fill-white text-white' : 'fill-red-500 text-red-500'
                } ${statusFilter !== 'stock_conflict' && 'animate-pulse'}`} />
                Stock Conflict
                <span className={`inline-flex items-center justify-center min-w-[18px] h-[18px] rounded-full text-[10px] font-bold px-1 ${
                  statusFilter === 'stock_conflict'
                    ? 'bg-white/20 text-white'
                    : 'bg-red-200 text-red-800'
                }`}>
                  {conflictCount}
                </span>
              </button>
            )}

            {/* Priority Cleaning chip */}
            <button
              onClick={() => onStatusChange('priority_cleaning')}
              className={`flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-full border transition-colors ${
                statusFilter === 'priority_cleaning'
                  ? "bg-amber-500 text-white border-amber-500"
                  : "bg-white text-amber-700 border-amber-200 hover:bg-amber-50 hover:border-amber-300"
              }`}
            >
              <Sparkles className={`w-3 h-3 ${
                statusFilter === 'priority_cleaning' ? 'fill-white text-white' : 'fill-amber-500 text-amber-500'
              }`} />
              Priority Cleaning
            </button>
          </div>

          {/* Date Filters */}
          <div className="flex items-center gap-2 w-full lg:w-auto overflow-x-auto pb-2 lg:pb-0 hide-scrollbar">
            <span className="text-sm font-medium text-slate-600 shrink-0">
              Date:
            </span>
            <select
              value={dateFilter}
              onChange={(e) => onDateFilterChange(e.target.value)}
              className="h-8 rounded-md border border-slate-200 bg-white px-2 text-xs font-medium text-slate-700 focus:outline-none focus:ring-1 focus:ring-slate-900 shrink-0"
            >
              <option value="ALL">All Time</option>
              <option value="today">Today</option>
              <option value="yesterday">Yesterday</option>
              <option value="this_week">This Week</option>
              <option value="this_month">This Month</option>
              <option value="custom">Custom Range</option>
            </select>

            {dateFilter === "custom" && (
              <div className="flex items-center gap-2 shrink-0">
                <Input
                  type="date"
                  className="h-8 text-xs w-[120px]"
                  value={dateFrom}
                  onChange={(e) => onDateFromChange(e.target.value)}
                />
                <span className="text-slate-400 text-xs">to</span>
                <Input
                  type="date"
                  className="h-8 text-xs w-[120px]"
                  value={dateTo}
                  onChange={(e) => onDateToChange(e.target.value)}
                />
              </div>
            )}
          </div>
        </div>

        <div className="flex flex-col sm:flex-row sm:items-center gap-4 pt-4 border-t border-slate-100">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
            <Input
              type="text"
              placeholder="Search by customer name..."
              className="pl-9 border-slate-200 focus:border-slate-900"
              value={searchInput}
              onChange={handleSearchInput}
            />
          </div>

          {(selectedCount > 0 || statusFilter !== "ALL" || dateFilter !== "ALL" || initialQuery !== "") && (
            <div className="flex flex-wrap items-center gap-3">
              {selectedCount > 0 && (
                <span className="text-sm font-semibold text-slate-900 bg-slate-100 px-2.5 py-1 rounded-md">
                  {selectedCount} selected
                </span>
              )}
              <div className="flex items-center gap-2">
                {selectedCount > 0 && (
                  <Button size="sm" variant="ghost" onClick={onClearSelection}>
                    Clear Selection
                  </Button>
                )}
                {(statusFilter !== "ALL" || dateFilter !== "ALL" || initialQuery !== "") && (
                  <Button 
                    size="sm" 
                    variant="outline" 
                    onClick={onResetFilters}
                    className="text-xs border-slate-200 hover:bg-slate-50 hover:text-slate-900"
                  >
                    Reset Filters
                  </Button>
                )}
              </div>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}

const OrderFilters = React.memo(OrderFiltersInner);
OrderFilters.displayName = "OrderFilters";

export default OrderFilters;
