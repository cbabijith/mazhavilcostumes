"use client";

import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
  PieChart, Pie, Cell
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatCurrency } from "@/lib/shared-utils";
import { ReportTable } from "../ReportTable";

interface RevenueViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
}

const COLORS = {
  completed: "#10b981", // Emerald 500
  ongoing: "#3b82f6",   // Blue 500
  scheduled: "#94a3b8"  // Slate 400
};

export function RevenueView({ 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell 
}: RevenueViewProps) {
  const columns = [
    { header: "Period", key: "period" },
    { header: "Completed", key: "completed_revenue", format: "currency" as const },
    { header: "Ongoing", key: "ongoing_revenue", format: "currency" as const },
    { header: "Scheduled", key: "scheduled_revenue", format: "currency" as const },
    { header: "Total", key: "total_revenue", format: "currency" as const },
    { header: "Orders", key: "order_count" },
  ];

  // Calculate totals for summary and pie chart
  const totals = data.reduce((acc, curr) => ({
    completed: acc.completed + (Number(curr.completed_revenue) || 0),
    ongoing: acc.ongoing + (Number(curr.ongoing_revenue) || 0),
    scheduled: acc.scheduled + (Number(curr.scheduled_revenue) || 0),
    total: acc.total + (Number(curr.total_revenue) || 0),
    orders: acc.orders + (Number(curr.order_count) || 0),
  }), { completed: 0, ongoing: 0, scheduled: 0, total: 0, orders: 0 });

  const pieData = [
    { name: "Completed", value: totals.completed, color: COLORS.completed },
    { name: "Ongoing", value: totals.ongoing, color: COLORS.ongoing },
    { name: "Scheduled", value: totals.scheduled, color: COLORS.scheduled },
  ].filter(d => d.value > 0);

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      {data.length > 0 && (
        <>
          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card className="shadow-sm border-slate-200 bg-white">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Total Revenue</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(totals.total)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{totals.orders} Orders processed</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-emerald-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-emerald-600/70 uppercase tracking-widest mb-1">Completed</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(totals.completed)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{((totals.completed / totals.total) * 100).toFixed(1)}% of total</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-blue-500">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-blue-600/70 uppercase tracking-widest mb-1">Ongoing</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(totals.ongoing)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{((totals.ongoing / totals.total) * 100).toFixed(1)}% of total</p>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-slate-400">
              <CardContent className="p-5">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Scheduled</p>
                <p className="text-2xl font-black text-slate-900">{formatCurrency(totals.scheduled)}</p>
                <p className="text-[10px] text-slate-500 mt-1 font-medium">{((totals.scheduled / totals.total) * 100).toFixed(1)}% of total</p>
              </CardContent>
            </Card>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Pie Chart: Overall Mix */}
            <Card className="shadow-sm border-slate-200 bg-white lg:col-span-1">
              <CardHeader className="py-3 px-6 border-b border-slate-100">
                <CardTitle className="text-sm font-semibold">Revenue Mix</CardTitle>
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
                <CardTitle className="text-sm font-semibold">Revenue Distribution by Period</CardTitle>
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
                    <Bar dataKey="completed_revenue" name="Completed" fill={COLORS.completed} radius={[4, 4, 0, 0]} />
                    <Bar dataKey="ongoing_revenue" name="Ongoing" fill={COLORS.ongoing} radius={[4, 4, 0, 0]} />
                    <Bar dataKey="scheduled_revenue" name="Scheduled" fill={COLORS.scheduled} radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </div>
        </>
      )}

      <ReportTable 
        columns={columns}
        data={data}
        loading={loading}
        error={error}
        sortConfig={sortConfig}
        onSort={onSort}
        formatCell={formatCell}
      />
    </div>
  );
}
