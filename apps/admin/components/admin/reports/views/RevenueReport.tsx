"use client";

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
  cash: "#0ea5e9",      // Sky 500
  upi: "#8b5cf6",       // Violet 500
  card: "#f59e0b",      // Amber 500
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
    { header: "Completed", key: "completed_revenue", format: "currency" as const },
    { header: "Ongoing", key: "ongoing_revenue", format: "currency" as const },
    { header: "Scheduled", key: "scheduled_revenue", format: "currency" as const },
    { header: "Cash", key: "cash_revenue", format: "currency" as const },
    { header: "UPI", key: "upi_revenue", format: "currency" as const },
    { header: "Total", key: "total_revenue", format: "currency" as const },
    { header: "Orders", key: "order_count" },
  ];

  const detailColumns = [
    { header: "Date", key: "date", format: "date" as const },
    { header: "Order ID", key: "order_id" },
    { header: "Customer", key: "customer_name" },
    { 
      header: "Mode", 
      key: "payment_mode",
      render: (mode: string) => (
        <Badge variant="outline" className={cn("capitalize font-bold text-[10px] px-2 py-0", 
          mode === 'cash' ? "bg-sky-50 text-sky-700 border-sky-100" :
          mode === 'upi' ? "bg-violet-50 text-violet-700 border-violet-100" :
          "bg-slate-50 text-slate-700"
        )}>
          {mode}
        </Badge>
      )
    },
    { header: "Amount", key: "amount", format: "currency" as const },
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
        };
        return (
          <Badge variant="outline" className={cn("capitalize font-bold text-[10px] px-2 py-0", colors[status] || "bg-slate-50 text-slate-700")}>
            {status}
          </Badge>
        );
      }
    },
  ];

  const pieData = reportSummary ? [
    { name: "Cash", value: reportSummary.total_cash, color: COLORS.cash },
    { name: "UPI", value: reportSummary.total_upi, color: COLORS.upi },
    { name: "Card", value: reportSummary.total_card, color: COLORS.card },
  ].filter(d => d.value > 0) : [];

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      {reportSummary && (
        <>
          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-slate-900">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Total Collected</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_collected)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{reportSummary.details.length} Transactions</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-sky-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-sky-600/70 uppercase tracking-widest mb-1">Cash Collection</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_cash)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{((reportSummary.total_cash / reportSummary.total_collected) * 100).toFixed(1)}% of total</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-violet-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-violet-600/70 uppercase tracking-widest mb-1">UPI Collection</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_upi)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{((reportSummary.total_upi / reportSummary.total_collected) * 100).toFixed(1)}% of total</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-amber-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-amber-600/70 uppercase tracking-widest mb-1">Card / Other</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_card)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{((reportSummary.total_card / reportSummary.total_collected) * 100).toFixed(1)}% of total</p>
              </CardContent>
            </Card>
          </div>

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
                    <Bar dataKey="cash_revenue" name="Cash" fill={COLORS.cash} radius={[4, 4, 0, 0]} />
                    <Bar dataKey="upi_revenue" name="UPI" fill={COLORS.upi} radius={[4, 4, 0, 0]} />
                    <Bar dataKey="total_revenue" name="Total" fill="#e2e8f0" radius={[4, 4, 0, 0]} />
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
              data={reportSummary.details}
              loading={false}
              error={null}
              sortConfig={null}
              onSort={() => {}}
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

