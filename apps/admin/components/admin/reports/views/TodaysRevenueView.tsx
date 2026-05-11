"use client";

/**
 * Today's Revenue View
 *
 * Simplified revenue report for staff/manager users.
 * Shows today's revenue snapshot with the same data structure
 * as the admin Revenue Report but locked to today's date.
 *
 * @module components/admin/reports/views/TodaysRevenueView
 */

import { useState, useMemo } from "react";
import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatCurrency } from "@/lib/shared-utils";
import { ReportTable } from "../ReportTable";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { RevenueReportData } from "@/domain";
import { AlertTriangle, ShieldAlert, Clock, IndianRupee } from "lucide-react";

interface TodaysRevenueViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
  reportSummary: RevenueReportData | null;
}

const COLORS = {
  cash: "#0ea5e9",
  upi: "#8b5cf6",
  gpay: "#f59e0b",
  other: "#64748b",
};

export function TodaysRevenueView({
  data,
  loading,
  error,
  sortConfig,
  onSort,
  formatCell,
  reportSummary,
}: TodaysRevenueViewProps) {
  const detailColumns = [
    { header: "Order ID", key: "order_id" },
    { header: "Customer", key: "customer_name" },
    {
      header: "Type",
      key: "payment_type",
      render: (type: string) => (
        <Badge variant="outline" className={cn("capitalize font-bold text-[10px] px-2 py-0",
          type === 'refund' ? "bg-orange-50 text-orange-700 border-orange-200" :
          type === 'advance' ? "bg-blue-50 text-blue-700 border-blue-100" :
          "bg-slate-50 text-slate-600 border-slate-100"
        )}>
          {type}
        </Badge>
      ),
    },
    {
      header: "Mode",
      key: "payment_mode",
      render: (mode: string) => (
        <Badge variant="outline" className={cn("capitalize font-bold text-[10px] px-2 py-0",
          mode === 'cash' ? "bg-sky-50 text-sky-700 border-sky-100" :
          mode === 'upi' ? "bg-violet-50 text-violet-700 border-violet-100" :
          mode === 'gpay' ? "bg-amber-50 text-amber-700 border-amber-100" :
          "bg-slate-50 text-slate-700"
        )}>
          {mode}
        </Badge>
      ),
    },
    {
      header: "Amount",
      key: "amount",
      render: (_: any, row: any) => {
        const isRefund = row?.payment_type === 'refund';
        return (
          <span className={cn("font-bold", isRefund ? "text-orange-600" : "text-slate-900")}>
            {isRefund ? '-' : ''}{formatCurrency(row?.amount || 0)}
          </span>
        );
      },
    },
    {
      header: "Order Status",
      key: "status",
      render: (status: string) => {
        const colors: any = {
          completed: "bg-emerald-50 text-emerald-700 border-emerald-100",
          returned: "bg-emerald-50 text-emerald-700 border-emerald-100",
          ongoing: "bg-blue-50 text-blue-700 border-blue-100",
          in_use: "bg-blue-50 text-blue-700 border-blue-100",
          delivered: "bg-blue-50 text-blue-700 border-blue-100",
          scheduled: "bg-slate-50 text-slate-700 border-slate-100",
          pending: "bg-slate-50 text-slate-700 border-slate-100",
          cancelled: "bg-red-50 text-red-700 border-red-100",
        };
        return (
          <Badge variant="outline" className={cn("capitalize font-bold text-[10px] px-2 py-0", colors[status] || "bg-slate-50 text-slate-700")}>
            {status}
          </Badge>
        );
      },
    },
  ];

  const netRevenue = reportSummary ? reportSummary.total_collected - reportSummary.total_refunded : 0;

  // Local sort state for detail table
  const [detailSort, setDetailSort] = useState<{ key: string; direction: 'asc' | 'desc' } | null>(null);
  const handleDetailSort = (key: string) => {
    setDetailSort(prev => {
      if (prev?.key === key && prev.direction === 'asc') return { key, direction: 'desc' };
      return { key, direction: 'asc' };
    });
  };
  const sortedDetails = useMemo(() => {
    if (!reportSummary?.details || !detailSort) return reportSummary?.details || [];
    return [...reportSummary.details].sort((a: any, b: any) => {
      const aVal = a[detailSort.key];
      const bVal = b[detailSort.key];
      if (aVal === undefined || bVal === undefined) return 0;
      if (aVal < bVal) return detailSort.direction === 'asc' ? -1 : 1;
      if (aVal > bVal) return detailSort.direction === 'asc' ? 1 : -1;
      return 0;
    });
  }, [reportSummary?.details, detailSort]);

  const pieData = reportSummary ? [
    { name: "Cash", value: reportSummary.total_cash, color: COLORS.cash },
    { name: "UPI", value: reportSummary.total_upi, color: COLORS.upi },
    { name: "GPay", value: reportSummary.total_gpay, color: COLORS.gpay },
  ].filter(d => d.value > 0) : [];

  const todayStr = new Date().toLocaleDateString('en-IN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      {/* Today's Date Banner */}
      <div className="flex items-center gap-3 px-1">
        <div className="w-8 h-8 rounded-full bg-emerald-100 flex items-center justify-center">
          <IndianRupee className="w-4 h-4 text-emerald-600" />
        </div>
        <div>
          <p className="text-xs text-slate-500 font-medium">Revenue snapshot for</p>
          <p className="text-sm font-bold text-slate-900">{todayStr}</p>
        </div>
      </div>

      {reportSummary && (
        <>
          {/* Refund Due Warning */}
          {reportSummary.refund_due > 0 && (
            <div className="flex items-center gap-3 p-4 bg-amber-50 border border-amber-200 rounded-xl">
              <div className="w-10 h-10 rounded-full bg-amber-100 flex items-center justify-center flex-shrink-0">
                <AlertTriangle className="w-5 h-5 text-amber-600" />
              </div>
              <div className="flex-1">
                <p className="text-sm font-bold text-amber-800">Refund Due</p>
                <p className="text-xs text-amber-600 mt-0.5">
                  {formatCurrency(reportSummary.refund_due)} collected from cancelled orders hasn&apos;t been refunded yet.
                </p>
              </div>
              <div className="text-lg font-black text-amber-700">{formatCurrency(reportSummary.refund_due)}</div>
            </div>
          )}

          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-slate-900">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Net Revenue</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(netRevenue)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{reportSummary.details.length} Transactions</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-sky-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-sky-600/70 uppercase tracking-widest mb-1">Cash</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_cash)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{reportSummary.total_collected > 0 ? ((reportSummary.total_cash / reportSummary.total_collected) * 100).toFixed(1) : '0.0'}% of collected</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-violet-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-violet-600/70 uppercase tracking-widest mb-1">UPI</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_upi)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{reportSummary.total_collected > 0 ? ((reportSummary.total_upi / reportSummary.total_collected) * 100).toFixed(1) : '0.0'}% of collected</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-amber-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-amber-600/70 uppercase tracking-widest mb-1">GPay / Other</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_gpay)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{reportSummary.total_collected > 0 ? ((reportSummary.total_gpay / reportSummary.total_collected) * 100).toFixed(1) : '0.0'}% of collected</p>
              </CardContent>
            </Card>
          </div>

          {/* Due Amount Cards */}
          {(reportSummary.total_damage_charges > 0 || reportSummary.total_late_fees > 0) && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {reportSummary.total_damage_charges > 0 && (
                <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-rose-500">
                  <CardContent className="p-5">
                    <div className="flex items-center gap-2 mb-1">
                      <ShieldAlert className="w-3.5 h-3.5 text-rose-500" />
                      <p className="text-[10px] font-bold text-rose-600/70 uppercase tracking-widest">Damage Charges Collected</p>
                    </div>
                    <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_damage_charges)}</p>
                    <p className="text-[10px] text-slate-500 mt-1 font-medium">From damaged product assessments</p>
                  </CardContent>
                </Card>
              )}
              {reportSummary.total_late_fees > 0 && (
                <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-amber-500">
                  <CardContent className="p-5">
                    <div className="flex items-center gap-2 mb-1">
                      <Clock className="w-3.5 h-3.5 text-amber-500" />
                      <p className="text-[10px] font-bold text-amber-600/70 uppercase tracking-widest">Late Fee Income</p>
                    </div>
                    <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_late_fees)}</p>
                    <p className="text-[10px] text-slate-500 mt-1 font-medium">From late return penalties</p>
                  </CardContent>
                </Card>
              )}
            </div>
          )}

          {/* Pie Chart: Mode Mix */}
          {pieData.length > 0 && (
            <Card className="shadow-sm border-slate-200 bg-white">
              <CardHeader className="py-3 px-6 border-b border-slate-100">
                <CardTitle className="text-sm font-semibold">Collection by Mode</CardTitle>
              </CardHeader>
              <CardContent className="p-6 h-[280px]">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie data={pieData} innerRadius={60} outerRadius={80} paddingAngle={5} dataKey="value">
                      {pieData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip formatter={(value: any) => formatCurrency(Number(value || 0))} />
                    <Legend verticalAlign="bottom" height={36} />
                  </PieChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          )}
        </>
      )}

      {/* Detail Table */}
      {reportSummary && reportSummary.details.length > 0 && (
        <div className="space-y-4">
          <div className="flex items-center justify-between px-1">
            <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
              Today&apos;s Transactions
            </h3>
            <Badge variant="secondary" className="bg-slate-100 text-slate-600 border-none">
              {reportSummary.details.length} Transactions
            </Badge>
          </div>
          <ReportTable
            columns={detailColumns}
            data={sortedDetails}
            loading={false}
            error={null}
            sortConfig={detailSort}
            onSort={handleDetailSort}
            formatCell={formatCell}
          />
        </div>
      )}

      {/* Empty State */}
      {reportSummary && reportSummary.details.length === 0 && !loading && (
        <div className="text-center py-16">
          <IndianRupee className="w-12 h-12 text-slate-300 mx-auto mb-4" />
          <p className="text-sm font-medium text-slate-500">No transactions recorded today yet</p>
          <p className="text-xs text-slate-400 mt-1">Revenue will appear here as payments are collected</p>
        </div>
      )}
    </div>
  );
}
