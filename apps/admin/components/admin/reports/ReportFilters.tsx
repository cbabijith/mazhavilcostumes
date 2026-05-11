"use client";

import { Search, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
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
          <div className="space-y-1.5">
            <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider ml-1">Order Status</label>
            <select 
              value={filters.status?.join(',') || ""} 
              onChange={e => setFilters({ ...filters, status: e.target.value ? e.target.value.split(',') : [], page: 1 })}
              className="w-[180px] h-10 border border-slate-200 rounded-lg px-3 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900"
            >
              <option value="">All Statuses</option>
              <option value="completed,returned">Completed</option>
              <option value="ongoing,in_use,delivered,late_return">Active</option>
              <option value="scheduled,pending">Scheduled</option>
              <option value="cancelled">Cancelled</option>
              <option value="flagged">Flagged</option>
            </select>
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
