"use client";

import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatCurrency } from "@/lib/shared-utils";
import { ReportTable } from "../ReportTable";

interface InventoryRevenueViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
}

export function InventoryRevenueView({ 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell 
}: InventoryRevenueViewProps) {
  const columns = [
    { header: "Product", key: "product_name" },
    { header: "Category", key: "category_name" },
    { header: "Total Stock", key: "quantity", format: "number" as const },
    { header: "Available", key: "available_quantity", format: "number" as const },
    { header: "Daily Price", key: "price_per_day", format: "currency" as const },
    { header: "Lifetime Revenue", key: "lifetime_revenue", format: "currency" as const },
    { header: "Rentals", key: "rental_count", format: "number" as const },
  ];

  // Calculate efficiency: Revenue per unit
  const chartData = data
    .map(d => ({
      ...d,
      revenue_per_unit: d.quantity > 0 ? Math.round(d.lifetime_revenue / d.quantity) : 0
    }))
    .sort((a, b) => b.lifetime_revenue - a.lifetime_revenue)
    .slice(0, 15);

  return (
    <div className="space-y-6">
      {chartData.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Card className="shadow-sm border-slate-200 bg-white">
            <CardHeader className="py-3 px-6 border-b border-slate-100">
              <CardTitle className="text-sm font-semibold">Stock vs Availability (Top 15 Earners)</CardTitle>
            </CardHeader>
            <CardContent className="p-6 h-[350px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartData} margin={{ bottom: 40 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="product_name" angle={-45} textAnchor="end" interval={0} fontSize={9} hide />
                  <YAxis axisLine={false} tickLine={false} />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="quantity" name="Total Stock" fill="#94a3b8" radius={[4, 4, 0, 0]} />
                  <Bar dataKey="available_quantity" name="Available Now" fill="#10b981" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          <Card className="shadow-sm border-slate-200 bg-white">
            <CardHeader className="py-3 px-6 border-b border-slate-100">
              <CardTitle className="text-sm font-semibold">Revenue Efficiency (Lifetime Revenue)</CardTitle>
            </CardHeader>
            <CardContent className="p-6 h-[350px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartData} margin={{ bottom: 40 }}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="product_name" angle={-45} textAnchor="end" interval={0} fontSize={9} hide />
                  <YAxis axisLine={false} tickLine={false} tickFormatter={(v) => `₹${v/1000}k`} />
                  <Tooltip formatter={(value: any) => formatCurrency(Number(value || 0))} />
                  <Bar dataKey="lifetime_revenue" name="Lifetime Revenue" fill="#6366f1" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>
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
