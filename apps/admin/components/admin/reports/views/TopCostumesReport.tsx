"use client";

import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Trophy, TrendingUp, Boxes, Star } from "lucide-react";
import { formatCurrency } from "@/lib/shared-utils";
import { ReportTable } from "../ReportTable";

interface TopCostumesViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
  rankBy: 'count' | 'revenue';
}

const COLORS = ["#6366f1", "#10b981", "#f59e0b", "#3b82f6", "#8b5cf6", "#ec4899"];

export function TopCostumesView({ 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell,
  rankBy
}: TopCostumesViewProps) {
  const columns = [
    { header: "Costume Name", key: "product_name" },
    { header: "Category", key: "category_name" },
    { header: "Rental Count", key: "rental_count", format: "number" as const },
    { header: "Total Revenue", key: "revenue", format: "currency" as const },
    { header: "Avg. Days", key: "avg_rental_days", format: "number" as const },
  ];

  const chartDataKey = rankBy === 'revenue' ? 'revenue' : 'rental_count';
  const chartLabel = rankBy === 'revenue' ? 'Total Revenue' : 'Rental Count';

  // Calculate insights
  const top10 = data.slice(0, 10);
  const totalRentals = data.reduce((sum, item) => sum + (item.rental_count || 0), 0);
  const totalRevenue = data.reduce((sum, item) => sum + (item.revenue || 0), 0);
  
  // Category distribution for top items
  const catMap = new Map();
  top10.forEach(item => {
    const cat = item.category_name || "Uncategorized";
    catMap.set(cat, (catMap.get(cat) || 0) + 1);
  });
  const categoryData = Array.from(catMap.entries()).map(([name, value]) => ({ name, value }));

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      {data.length > 0 && (
        <>
          {/* Performance Highlights */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card className="shadow-sm border-slate-200 bg-white">
              <CardContent className="p-5 flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-indigo-50 flex items-center justify-center text-indigo-600">
                  <Trophy className="w-5 h-5" />
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Best Performer</p>
                  <p className="text-sm font-black text-slate-900 truncate max-w-[150px]">{data[0]?.product_name}</p>
                </div>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white">
              <CardContent className="p-5 flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center text-amber-600">
                  <TrendingUp className="w-5 h-5" />
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Total Top Rentals</p>
                  <p className="text-sm font-black text-slate-900">{totalRentals} Bookings</p>
                </div>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white">
              <CardContent className="p-5 flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center text-emerald-600">
                  <Star className="w-5 h-5" />
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Total Top Revenue</p>
                  <p className="text-sm font-black text-slate-900">{formatCurrency(totalRevenue)}</p>
                </div>
              </CardContent>
            </Card>
            <Card className="shadow-sm border-slate-200 bg-white">
              <CardContent className="p-5 flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-slate-50 flex items-center justify-center text-slate-600">
                  <Boxes className="w-5 h-5" />
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Categories Represented</p>
                  <p className="text-sm font-black text-slate-900">{categoryData.length} Types</p>
                </div>
              </CardContent>
            </Card>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Horizontal Bar Chart: Top 10 */}
            <Card className="shadow-sm border-slate-200 bg-white lg:col-span-2">
              <CardHeader className="py-3 px-6 border-b border-slate-100">
                <CardTitle className="text-sm font-semibold">Top 10 Costumes by {chartLabel}</CardTitle>
              </CardHeader>
              <CardContent className="p-6 h-[400px]">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={top10} layout="vertical" margin={{ left: 20, right: 40 }}>
                    <CartesianGrid strokeDasharray="3 3" horizontal={true} vertical={false} stroke="#f1f5f9" />
                    <XAxis type="number" hide />
                    <YAxis 
                      dataKey="product_name" 
                      type="category" 
                      axisLine={false} 
                      tickLine={false} 
                      width={140} 
                      fontSize={10}
                      fontWeight={600}
                    />
                    <Tooltip 
                      cursor={{ fill: '#f8fafc' }}
                      contentStyle={{borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)'}}
                      formatter={(value: any) => [
                        rankBy === 'revenue' ? formatCurrency(value) : `${value} Rentals`, 
                        chartLabel
                      ]}
                    />
                    <Bar 
                      dataKey={chartDataKey} 
                      name={chartLabel} 
                      fill={rankBy === 'revenue' ? "#6366f1" : "#f59e0b"} 
                      radius={[0, 4, 4, 0]} 
                      barSize={20} 
                    />
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            {/* Category Mix Pie Chart */}
            <Card className="shadow-sm border-slate-200 bg-white lg:col-span-1">
              <CardHeader className="py-3 px-6 border-b border-slate-100">
                <CardTitle className="text-sm font-semibold">Top Items Category Mix</CardTitle>
              </CardHeader>
              <CardContent className="p-6 h-[400px]">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={categoryData}
                      cx="50%"
                      cy="45%"
                      innerRadius={60}
                      outerRadius={85}
                      paddingAngle={5}
                      dataKey="value"
                      label={({percent}) => `${((percent || 0) * 100).toFixed(0)}%`}
                    >
                      {categoryData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip />
                    <Legend verticalAlign="bottom" height={36} wrapperStyle={{fontSize: '10px'}} />
                  </PieChart>
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
