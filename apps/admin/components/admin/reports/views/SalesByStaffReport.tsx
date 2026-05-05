"use client";

import { useState, useEffect } from "react";
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend, ComposedChart, Line
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { UserCheck, Award, TrendingUp, XCircle, ArrowLeft, History, ExternalLink } from "lucide-react";
import { formatCurrency } from "@/lib/shared-utils";
import { ReportTable } from "../ReportTable";
import { Badge } from "@/components/ui/badge";

interface SalesByStaffViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
}

const COLORS = ["#6366f1", "#10b981", "#f59e0b", "#3b82f6", "#8b5cf6", "#ec4899"];

export function SalesByStaffView({ 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell 
}: SalesByStaffViewProps) {
  const [selectedStaff, setSelectedStaff] = useState<any | null>(null);
  const [history, setHistory] = useState<any[]>([]);
  const [historyLoading, setHistoryLoading] = useState(false);

  const columns = [
    { header: "Staff Member", key: "staff_name" },
    { header: "Orders Placed", key: "order_count", format: "number" as const },
    { header: "Orders Cancelled", key: "cancelled_order_count", format: "number" as const },
    { header: "Actual Revenue", key: "total_revenue", format: "currency" as const },
    { header: "Discount %", key: "discount_percentage", format: "percent" as const },
  ];

  const historyColumns = [
    { header: "Date", key: "date", format: "date" as const },
    { header: "Customer", key: "customer" },
    { header: "Products", key: "products" },
    { header: "Status", key: "status" },
    { header: "Amount", key: "amount", format: "currency" as const },
    { 
      header: "Action", 
      key: "id", 
      render: (id: string) => (
        <Button variant="ghost" size="sm" asChild>
          <a href={`/dashboard/orders/${id}`} target="_blank" rel="noreferrer">
            <ExternalLink className="w-4 h-4" />
          </a>
        </Button>
      )
    },
  ];

  useEffect(() => {
    if (selectedStaff) {
      fetchHistory(selectedStaff.staff_id);
    }
  }, [selectedStaff]);

  const fetchHistory = async (staffId: string) => {
    setHistoryLoading(true);
    try {
      const res = await fetch(`/api/reports/sales-by-staff?staffId=${staffId}`);
      const result = await res.json();
      if (result.success) {
        setHistory(result.data.rows);
      }
    } catch (err) {
      console.error("Failed to fetch history:", err);
    } finally {
      setHistoryLoading(false);
    }
  };

  // Calculate insights
  const totals = data.reduce((acc, curr) => ({
    revenue: acc.revenue + (Number(curr.total_revenue) || 0),
    orders: acc.orders + (Number(curr.order_count) || 0),
    cancelled: acc.cancelled + (Number(curr.cancelled_order_count) || 0),
  }), { revenue: 0, orders: 0, cancelled: 0 });

  const topStaff = data[0];

  if (selectedStaff) {
    return (
      <div className="space-y-6 animate-in slide-in-from-right duration-300">
        <div className="flex items-center justify-between">
          <Button variant="outline" size="sm" onClick={() => setSelectedStaff(null)} className="gap-2">
            <ArrowLeft className="w-4 h-4" /> Back to Team
          </Button>
          <div className="text-right">
            <h2 className="text-xl font-black text-slate-900">{selectedStaff.staff_name}</h2>
            <p className="text-xs text-slate-500">{selectedStaff.staff_email}</p>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Card className="shadow-sm border-slate-200">
            <CardContent className="p-4">
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Total Orders</p>
              <p className="text-xl font-black text-slate-900">{selectedStaff.order_count}</p>
            </CardContent>
          </Card>
          <Card className="shadow-sm border-slate-200">
            <CardContent className="p-4">
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Total Revenue</p>
              <p className="text-xl font-black text-emerald-600">{formatCurrency(selectedStaff.total_revenue)}</p>
            </CardContent>
          </Card>
          <Card className="shadow-sm border-slate-200">
            <CardContent className="p-4">
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Avg. Discount</p>
              <p className="text-xl font-black text-amber-600">{selectedStaff.discount_percentage}%</p>
            </CardContent>
          </Card>
          <Card className="shadow-sm border-slate-200">
            <CardContent className="p-4">
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Cancellation Rate</p>
              <p className="text-xl font-black text-rose-600">
                {((selectedStaff.cancelled_order_count / (selectedStaff.order_count + selectedStaff.cancelled_order_count || 1)) * 100).toFixed(1)}%
              </p>
            </CardContent>
          </Card>
        </div>

        <Card className="shadow-sm border-slate-200 bg-white">
          <CardHeader className="py-3 px-6 border-b border-slate-100 flex flex-row items-center gap-2">
            <History className="w-4 h-4 text-slate-400" />
            <CardTitle className="text-sm font-semibold">Order History</CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            <ReportTable 
              columns={historyColumns}
              data={history}
              loading={historyLoading}
              error={null}
              sortConfig={null}
              onSort={() => {}}
              formatCell={formatCell}
            />
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      {data.length > 0 && (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card className="shadow-sm border-slate-200 bg-white">
              <CardContent className="p-5 flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-indigo-50 flex items-center justify-center text-indigo-600">
                  <Award className="w-5 h-5" />
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Team Leader</p>
                  <p className="text-sm font-black text-slate-900 truncate max-w-[120px]">{topStaff?.staff_name}</p>
                </div>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white">
              <CardContent className="p-5 flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center text-emerald-600">
                  <TrendingUp className="w-5 h-5" />
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Actual Revenue</p>
                  <p className="text-sm font-black text-slate-900">{formatCurrency(totals.revenue)}</p>
                </div>
              </CardContent>
            </Card>
            <CardContent className="p-5 flex items-center gap-4 border rounded-xl border-slate-200 bg-white">
                <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600">
                  <UserCheck className="w-5 h-5" />
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Total Orders</p>
                  <p className="text-sm font-black text-slate-900">{totals.orders}</p>
                </div>
            </CardContent>
            <CardContent className="p-5 flex items-center gap-4 border rounded-xl border-slate-200 bg-white">
                <div className="w-10 h-10 rounded-xl bg-rose-50 flex items-center justify-center text-rose-600">
                  <XCircle className="w-5 h-5" />
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Cancelled Orders</p>
                  <p className="text-sm font-black text-slate-900">{totals.cancelled}</p>
                </div>
            </CardContent>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Chart 1: Revenue Share % */}
            <Card className="shadow-sm border-slate-200 bg-white">
              <CardHeader className="py-3 px-6 border-b border-slate-100">
                <CardTitle className="text-sm font-semibold">Revenue Contribution Share %</CardTitle>
              </CardHeader>
              <CardContent className="p-6 h-[350px]">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={data}
                      cx="50%"
                      cy="45%"
                      innerRadius={60}
                      outerRadius={85}
                      paddingAngle={5}
                      dataKey="total_revenue"
                      nameKey="staff_name"
                      label={({percent}) => `${((percent || 0) * 100).toFixed(0)}%`}
                    >
                      {data.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip formatter={(v) => formatCurrency(Number(v))} />
                    <Legend verticalAlign="bottom" height={36} wrapperStyle={{fontSize: '10px'}} />
                  </PieChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            {/* Chart 2: Productivity (Placed vs Cancelled) */}
            <Card className="shadow-sm border-slate-200 bg-white">
              <CardHeader className="py-3 px-6 border-b border-slate-100">
                <CardTitle className="text-sm font-semibold">Staff Productivity: Placed vs. Cancelled</CardTitle>
              </CardHeader>
              <CardContent className="p-6 h-[350px]">
                <ResponsiveContainer width="100%" height="100%">
                  <ComposedChart data={data}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                    <XAxis dataKey="staff_name" fontSize={10} fontWeight={600} axisLine={false} tickLine={false} />
                    <YAxis fontSize={10} axisLine={false} tickLine={false} />
                    <Tooltip 
                      contentStyle={{borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)'}}
                    />
                    <Legend verticalAlign="top" align="right" height={36} wrapperStyle={{fontSize: '11px'}} />
                    <Bar dataKey="order_count" name="Orders Placed" fill="#6366f1" radius={[4, 4, 0, 0]} barSize={30} />
                    <Bar dataKey="cancelled_order_count" name="Cancelled" fill="#f43f5e" radius={[4, 4, 0, 0]} barSize={30} />
                  </ComposedChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </div>
        </>
      )}

      <div className="space-y-2">
        <p className="text-xs font-medium text-slate-500 ml-1 italic flex items-center gap-1">
          <UserCheck className="w-3 h-3" /> Click on a staff member below to view their full order history.
        </p>
        <ReportTable 
          columns={columns}
          data={data}
          loading={loading}
          error={error}
          sortConfig={sortConfig}
          onSort={onSort}
          formatCell={formatCell}
          onRowClick={(row) => setSelectedStaff(row)}
        />
      </div>
    </div>
  );
}
