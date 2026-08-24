"use client";

import { Search, Loader2, ChevronDown, Check } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { cn } from "@/lib/utils";
import { ReportFilters as FilterType } from "@/domain";

interface ReportFiltersProps {
  filters: FilterType;
  setFilters: (filters: FilterType) => void;
  onGenerate: () => void;
  loading: boolean;
  needsDateFilter?: boolean;
  needsRangeFilter?: boolean;
  needsRankBy?: boolean;
  needsStatusFilter?: boolean;
  needsPaymentModeFilter?: boolean;
}

export function ReportFilters({ 
  filters, 
  setFilters, 
  onGenerate, 
  loading,
  needsDateFilter,
  needsRangeFilter,
  needsRankBy,
  needsStatusFilter,
  needsPaymentModeFilter
}: ReportFiltersProps) {
  const STATUS_OPTIONS = [
    { label: "Scheduled", value: "scheduled" },
    { label: "Ongoing", value: "ongoing" },
    { label: "Returned", value: "returned" },
    { label: "Completed", value: "completed" },
    // Late Return removed - now handled by is_late boolean flag
    { label: "Flagged", value: "flagged" },
  ];

  const toggleStatus = (statusValue: string) => {
    const current = filters.status || [];
    let updated: string[];
    if (current.includes(statusValue)) {
      updated = current.filter(v => v !== statusValue);
    } else {
      updated = [...current, statusValue];
    }
    setFilters({ ...filters, status: updated, page: 1 });
  };

  return (
    <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm mb-6">
      <div className="flex flex-wrap items-end gap-4">
        {needsDateFilter && (
          <div className="space-y-1.5">
            <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider ml-1">As of Date</label>
            <Input 
              type="date" 
              value={filters.date || ""} 
              onChange={e => setFilters({ ...filters, date: e.target.value })}
              className="w-[180px] h-10 border-slate-200 focus:ring-slate-900 rounded-lg"
            />
          </div>
        )}

        {needsRangeFilter && (
          <>
            <div className="space-y-1.5">
              <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider ml-1">From Date</label>
              <Input 
                type="date" 
                value={filters.from_date || ""} 
                onChange={e => setFilters({ ...filters, from_date: e.target.value })}
                className="w-[180px] h-10 border-slate-200 focus:ring-slate-900 rounded-lg"
              />
            </div>
            <div className="space-y-1.5">
              <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider ml-1">To Date</label>
              <Input 
                type="date" 
                value={filters.to_date || ""} 
                onChange={e => setFilters({ ...filters, to_date: e.target.value })}
                className="w-[180px] h-10 border-slate-200 focus:ring-slate-900 rounded-lg"
              />
            </div>
          </>
        )}

        {needsRankBy && (
          <div className="space-y-1.5">
            <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider ml-1">Rank By</label>
            <select 
              value={filters.rank_by} 
              onChange={e => setFilters({ ...filters, rank_by: e.target.value as any })}
              className="w-[180px] h-10 border border-slate-200 rounded-lg px-3 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900"
            >
              <option value="count">Rental Count</option>
              <option value="revenue">Total Revenue</option>
            </select>
          </div>
        )}

        {needsStatusFilter && (
          <div className="space-y-1.5 flex flex-col">
            <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider ml-1">Order Status</label>
            <Popover>
              <PopoverTrigger asChild>
                <Button
                  variant="outline"
                  className="w-[200px] h-10 border-slate-200 justify-between text-left font-normal text-sm hover:bg-slate-50 focus:ring-2 focus:ring-slate-900 rounded-lg px-3 bg-white"
                >
                  <span className="truncate">
                    {filters.status && filters.status.length > 0
                      ? STATUS_OPTIONS.filter(opt => filters.status?.includes(opt.value))
                          .map(opt => opt.label)
                          .join(", ")
                      : "All Statuses"}
                  </span>
                  <ChevronDown className="h-4 w-4 opacity-50 shrink-0 ml-2" />
                </Button>
              </PopoverTrigger>
              <PopoverContent className="w-[200px] p-2 bg-white border border-slate-200 rounded-xl shadow-lg z-50" align="start">
                <div className="space-y-1 max-h-[250px] overflow-y-auto">
                  {/* Select All / Clear option */}
                  <button
                    onClick={() => setFilters({ ...filters, status: [], page: 1 })}
                    className="w-full text-left px-2 py-1.5 text-xs font-semibold text-slate-500 hover:bg-slate-50 rounded flex items-center justify-between transition-colors"
                  >
                    <span>Clear All (All Statuses)</span>
                    {!filters.status?.length && <Check className="h-3 w-3 text-slate-900" />}
                  </button>
                  <div className="h-px bg-slate-100 my-1" />
                  {STATUS_OPTIONS.map((opt) => {
                    const isSelected = filters.status?.includes(opt.value);
                    return (
                      <button
                        key={opt.value}
                        onClick={() => toggleStatus(opt.value)}
                        className={cn(
                          "w-full text-left px-2.5 py-1.5 text-xs rounded flex items-center justify-between transition-colors font-medium",
                          isSelected ? "bg-slate-900 text-white" : "text-slate-700 hover:bg-slate-50"
                        )}
                      >
                        <span>{opt.label}</span>
                        {isSelected && <Check className="h-3.5 w-3.5 text-white" />}
                      </button>
                    );
                  })}
                </div>
              </PopoverContent>
            </Popover>
          </div>
        )}

        {needsPaymentModeFilter && (
          <div className="space-y-1.5">
            <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider ml-1">Payment Mode</label>
            <select 
              value={filters.payment_mode || "all"} 
              onChange={e => setFilters({ ...filters, payment_mode: e.target.value })}
              className="w-[180px] h-10 border border-slate-200 rounded-lg px-3 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900"
            >
              <option value="all">All Modes</option>
              <option value="cash">Cash Only</option>
              <option value="upi">UPI Only</option>
              <option value="gpay">GPay Only</option>
              <option value="bank_transfer">Bank Transfer Only</option>
            </select>
          </div>
        )}

        <Button 
          onClick={onGenerate} 
          disabled={loading}
          className="bg-slate-900 text-white hover:bg-slate-800 h-10 px-6 rounded-lg font-semibold transition-all active:scale-95 disabled:opacity-70 gap-2 ml-auto"
        >
          {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Search className="w-4 h-4" />}
          Generate Report
        </Button>
      </div>
    </div>
  );
}
