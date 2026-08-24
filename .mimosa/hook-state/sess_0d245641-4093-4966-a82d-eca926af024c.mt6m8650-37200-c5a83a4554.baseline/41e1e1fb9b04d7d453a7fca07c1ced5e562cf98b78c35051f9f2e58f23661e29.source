"use client";

import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell,
  ComposedChart, Line
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatCurrency } from "@/lib/shared-utils";
import { ReportTable } from "../ReportTable";

interface ROIViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
}

export function ROIView({ 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell 
}: ROIViewProps) {
  const columns = [
    { header: "Product", key: "product_name" },
    { header: "Purchase Price", key: "purchase_price", format: "currency" as const },
    { header: "Lifetime Revenue", key: "total_revenue", format: "currency" as const },
    { header: "Total Profit", key: "profit", format: "currency" as const },
    { header: "ROI %", key: "roi_percentage", format: "percent" as const },
    { header: "Rentals", key: "rental_count", format: "number" as const },
  ];

  // Prepare chart data: Top 15 by ROI
  const chartData = data
    .filter(d => d.purchase_price > 0)
    .sort((a, b) => b.roi_percentage - a.roi_percentage)
    .slice(0, 15);

  return (
    <div className="space-y-6">
      {chartData.length > 0 && (
        <Card className="shadow-sm border-slate-200 bg-white">
          <CardHeader className="py-3 px-6 border-b border-slate-100">
            <CardTitle className="text-sm font-semibold">Profitability Analysis (Top 15 ROI)</CardTitle>
          </CardHeader>
          <CardContent className="p-6 h-[400px]">
            <ResponsiveContainer width="100%" height="100%">
              <ComposedChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 60 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis 
                  dataKey="product_name" 
                  angle={-45} 
                  textAnchor="end" 
                  interval={0} 
                  height={80} 
                  fontSize={10} 
                  axisLine={false}
                  tickLine={false}
                />
                <YAxis yAxisId="left" orientation="left" axisLine={false} tickLine={false} tickFormatter={(v) => `₹${v/1000}k`} />
                <YAxis yAxisId="right" orientation="right" axisLine={false} tickLine={false} tickFormatter={(v) => `${v}%`} />
                <Tooltip 
                  formatter={(value: any, name: any) => {
                    if (name === "ROI %") return [`${value}%`, name];
                    return [formatCurrency(Number(value || 0)), name];
                  }}
                />
                <Bar 
                  yAxisId="left" 
                  dataKey="total_revenue" 
                  name="Lifetime Revenue" 
                  fill="#94a3b8" 
                  radius={[4, 4, 0, 0]} 
                  barSize={30} 
                />
                <Bar 
                  yAxisId="left" 
                  dataKey="profit" 
                  name="Total Profit" 
                  radius={[4, 4, 0, 0]} 
                  barSize={30}
                >
                  {chartData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.profit >= 0 ? "#10b981" : "#ef4444"} />
                  ))}
                </Bar>
                <Line 
                  yAxisId="right" 
                  type="monotone" 
                  dataKey="roi_percentage" 
                  name="ROI %" 
                  stroke="#6366f1" 
                  strokeWidth={3} 
                  dot={{ r: 4, fill: "#6366f1" }} 
                />
              </ComposedChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
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
