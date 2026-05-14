"use client";

import { useState, useMemo } from "react";
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
  PieChart, Pie, Cell
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { formatCurrency } from "@/lib/shared-utils";
import { ReportTable } from "../ReportTable";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { RevenueReportData, RevenueRow, RevenueDetailRow } from "@/domain";
import { AlertTriangle, ShieldAlert, Clock } from "lucide-react";

interface RevenueViewProps {
  data: RevenueRow[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
  reportSummary: RevenueReportData | null;
  filters: any;
  setFilters: (filters: any) => void;
}

const COLORS = {
  completed: "#10b981", // Emerald 500
  ongoing: "#3b82f6",   // Blue 500
  scheduled: "#94a3b8", // Slate 400
  cancelled: "#ef4444", // Red 500
  cash: "#0ea5e9",      // Sky 500
  upi: "#8b5cf6",       // Violet 500
  gpay: "#f59e0b",      // Amber 500
  other: "#64748b"      // Slate 500
};

export function RevenueView({ 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell,
  reportSummary,
  filters,
  setFilters
}: RevenueViewProps) {
  const summaryColumns = [
    { header: "Period", key: "period" },
    { header: "Booking Sales", key: "booking_sales", format: "currency" as const },
    { header: "Amount Collection", key: "amount_collection", format: "currency" as const },
    { header: "Net Revenue", key: "net_revenue", format: "currency" as const },
    { header: "GST", key: "gst_collected", format: "currency" as const },
    { header: "Refunded", key: "refund_amount", format: "currency" as const },
    { header: "Orders", key: "order_count" },
  ];

  const detailColumns = [
    { header: "Date", key: "date", format: "date" as const },
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
      )
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
      )
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
      }
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
      }
    },
  ];

  const netRevenue = reportSummary ? reportSummary.total_collected - reportSummary.total_refunded : 0;

  // Local sort state for the detail transaction table
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

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      {reportSummary && (
        <>
          {/* Refund Due Warning Banner */}
          {reportSummary.refund_due > 0 && (
            <div className="flex items-center gap-3 p-4 bg-amber-50 border border-amber-200 rounded-xl">
              <div className="w-10 h-10 rounded-full bg-amber-100 flex items-center justify-center flex-shrink-0">
                <AlertTriangle className="w-5 h-5 text-amber-600" />
              </div>
              <div className="flex-1">
                <p className="text-sm font-bold text-amber-800">Refund Due</p>
                <p className="text-xs text-amber-600 mt-0.5">
                  {formatCurrency(reportSummary.refund_due)} collected from cancelled orders hasn&apos;t been refunded yet. 
                  You can refund or mark as &quot;Keep Money&quot; from the order detail page.
                </p>
              </div>
              <div className="text-lg font-black text-amber-700">{formatCurrency(reportSummary.refund_due)}</div>
            </div>
          )}

          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-indigo-600">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-indigo-600/70 uppercase tracking-widest mb-1">Total Booking Sales</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_booking_sales)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">Value of business won (Order Creation Date)</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-emerald-600">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-emerald-600/70 uppercase tracking-widest mb-1">Amount Collection</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_amount_collection)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">Total payments received during this period</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-slate-900">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Net Revenue (Excl GST)</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_net_revenue)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">Actual income after removing 18% GST</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-amber-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-amber-600/70 uppercase tracking-widest mb-1">GST Collected</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_gst_collected)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">Tax portion to be paid to government</p>
              </CardContent>
            </Card>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-sky-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-sky-600/70 uppercase tracking-widest mb-1">Cash</p>
                <p className="text-xl font-black text-slate-900">{formatCurrency(reportSummary.total_cash)}</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-violet-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-violet-600/70 uppercase tracking-widest mb-1">UPI</p>
                <p className="text-xl font-black text-slate-900">{formatCurrency(reportSummary.total_upi)}</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-amber-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-amber-600/70 uppercase tracking-widest mb-1">GPay</p>
                <p className="text-xl font-black text-slate-900">{formatCurrency(reportSummary.total_gpay)}</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-orange-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-orange-600/70 uppercase tracking-widest mb-1">Refunded</p>
                <p className="text-xl font-black text-orange-600">-{formatCurrency(reportSummary.total_refunded)}</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-red-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-red-600/70 uppercase tracking-widest mb-1">Cancelled (Keep)</p>
                <p className="text-xl font-black text-red-600">{formatCurrency(reportSummary.cancelled_total)}</p>
              </CardContent>
            </Card>
          </div>

          {/* Due Amount Cards: Damage Charges + Late Fees */}
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

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Pie Chart: Mode Mix */}
            <Card className="shadow-sm border-slate-200 bg-white lg:col-span-1">
              <CardHeader className="py-3 px-6 border-b border-slate-100">
                <CardTitle className="text-sm font-semibold">Collection by Mode</CardTitle>
              </CardHeader>
              <CardContent className="p-6 h-[300px]">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={pieData}
                      innerRadius={60}
                      outerRadius={80}
                      paddingAngle={5}
                      dataKey="value"
                    >
                      {pieData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip formatter={(value: any) => formatCurrency(Number(value || 0))} />
                    <Legend verticalAlign="bottom" height={36}/>
                  </PieChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            {/* Bar Chart: Distribution Over Time */}
            <Card className="shadow-sm border-slate-200 bg-white lg:col-span-2">
              <CardHeader className="py-3 px-6 border-b border-slate-100">
                <CardTitle className="text-sm font-semibold">Revenue Trends (Cash Basis)</CardTitle>
              </CardHeader>
              <CardContent className="p-6 h-[300px]">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={data}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                    <XAxis dataKey="period" axisLine={false} tickLine={false} fontSize={10} />
                    <YAxis axisLine={false} tickLine={false} fontSize={10} tickFormatter={(v) => `₹${v/1000}k`} />
                    <Tooltip 
                      cursor={{fill: '#f8fafc'}}
                      contentStyle={{borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)'}}
                      formatter={(value: any) => formatCurrency(Number(value || 0))} 
                    />
                    <Legend verticalAlign="top" align="right" iconType="circle" />
                    <Bar dataKey="booking_sales" name="Sales (Orders)" fill="#6366f1" radius={[4, 4, 0, 0]} />
                    <Bar dataKey="amount_collection" name="Amount (Payments)" fill="#10b981" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </div>
        </>
      )}

      <div className="space-y-4">
        <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider px-1">Revenue Summary</h3>
        <ReportTable 
          columns={summaryColumns}
          data={data}
          loading={loading}
          error={error}
          sortConfig={sortConfig}
          onSort={onSort}
          formatCell={formatCell}
        />
      </div>

      {reportSummary && reportSummary.details.length > 0 && (
        <div className="space-y-4">
          <div className="flex items-center justify-between px-1">
            <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
              Detailed Transaction List
            </h3>
            <Badge variant="secondary" className="bg-slate-100 text-slate-600 border-none">
              {reportSummary.total_details_count} Total Transactions
            </Badge>
          </div>
          <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
            <ReportTable 
              columns={detailColumns}
              data={sortedDetails}
              loading={false}
              error={null}
              sortConfig={detailSort}
              onSort={handleDetailSort}
              formatCell={formatCell}
            />
            
            {/* Pagination Footer */}
            <div className="px-6 py-4 border-t border-slate-100 flex items-center justify-between bg-slate-50/50">
              <p className="text-xs text-slate-500 font-medium">
                Showing {((filters.page || 1) - 1) * (filters.limit || 50) + 1} to {Math.min((filters.page || 1) * (filters.limit || 50), reportSummary.total_details_count)} of {reportSummary.total_details_count} records
              </p>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={filters.page === 1}
                  onClick={() => setFilters({ ...filters, page: (filters.page || 1) - 1 })}
                  className="h-8 px-3 text-xs"
                >
                  Previous
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={(filters.page || 1) * (filters.limit || 50) >= reportSummary.total_details_count}
                  onClick={() => setFilters({ ...filters, page: (filters.page || 1) + 1 })}
                  className="h-8 px-3 text-xs"
                >
                  Next
                </Button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
