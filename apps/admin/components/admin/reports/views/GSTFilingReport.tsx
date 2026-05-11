"use client";

import { useState } from "react";
import { 
  PieChart, Pie, Cell, Tooltip, Legend,
  BarChart, Bar, XAxis, YAxis, CartesianGrid, ResponsiveContainer
} from "recharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { GSTFilingReport as GSTReportType, GSTFilingRow } from "@/domain";
import { formatCurrency } from "@/lib/shared-utils";
import { ReportTable } from "../ReportTable";
import { cn } from "@/lib/utils";
import { Badge } from "@/components/ui/badge";

import Link from "next/link";
import { AlertTriangle, Settings } from "lucide-react";

interface GSTFilingViewProps {
  data: GSTFilingRow[];
  reportSummary: any;
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
  gstDetails: any[];
}

export function GSTFilingView({ 
  data, 
  reportSummary, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell,
  gstDetails
}: GSTFilingViewProps) {
  const GST_DETAILED_COLUMNS = [
    { header: "Date", key: "date", format: "date" as const },
    { header: "Invoice No", key: "invoice_no" },
    { header: "Customer", key: "customer_name" },
    { 
      header: "Status", 
      key: "status",
      render: (status: string) => {
        const colors: any = {
          completed: "bg-emerald-50 text-emerald-700 border-emerald-100",
          ongoing: "bg-blue-50 text-blue-700 border-blue-100",
          scheduled: "bg-amber-50 text-amber-700 border-amber-100",
          cancelled: "bg-rose-50 text-rose-700 border-rose-100",
        };
        return (
          <Badge variant="outline" className={cn("capitalize font-bold text-[10px] px-2 py-0", colors[status] || "bg-slate-50 text-slate-700")}>
            {status}
          </Badge>
        );
      }
    },
    { header: "Taxable Value", key: "taxable_value", format: "currency" as const },
    { header: "GST Slab", key: "slabs" },
    { header: "CGST", key: "cgst", format: "currency" as const },
    { header: "SGST", key: "sgst", format: "currency" as const },
    { header: "Total GST", key: "gst_amount", format: "currency" as const },
  ];

  const SUMMARY_COLUMNS = [
    { header: "GST Slab", key: "slab", format: "percent" as const },
    { header: "Taxable Value", key: "taxable_value", format: "currency" as const },
    { header: "CGST", key: "cgst", format: "currency" as const },
    { header: "SGST", key: "sgst", format: "currency" as const },
    { header: "Total GST", key: "total_gst", format: "currency" as const },
  ];

  return (
    <div className="space-y-8">
      {/* GST Disabled Warning */}
      {reportSummary && reportSummary.is_gst_enabled === false && (
        <div className="flex items-start gap-4 p-5 bg-amber-50 border border-amber-200 rounded-xl">
          <div className="w-10 h-10 rounded-full bg-amber-100 flex items-center justify-center flex-shrink-0 mt-0.5">
            <AlertTriangle className="w-5 h-5 text-amber-600" />
          </div>
          <div className="flex-1">
            <p className="text-sm font-bold text-amber-800">GST is currently disabled</p>
            <p className="text-xs text-amber-600 mt-1 leading-relaxed">
              GST is turned off in your store settings. Orders created while GST is disabled will not have any tax data, 
              so they won&apos;t appear in this report. To start collecting GST on new orders, enable it from Settings.
            </p>
          </div>
          <Link
            href="/dashboard/settings"
            className="flex items-center gap-1.5 px-3 py-1.5 bg-amber-100 hover:bg-amber-200 text-amber-800 text-xs font-bold rounded-lg transition-colors flex-shrink-0"
          >
            <Settings className="w-3.5 h-3.5" />
            Settings
          </Link>
        </div>
      )}

      {/* Summary Cards */}
      {reportSummary && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <Card className="shadow-sm border-slate-200 bg-white">
            <CardContent className="p-5">
              <p className="text-xs font-bold text-slate-500 uppercase tracking-widest mb-1">Total Taxable Value</p>
              <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_taxable)}</p>
            </CardContent>
          </Card>
          <Card className="shadow-sm border-slate-200 bg-white">
            <CardContent className="p-5">
              <p className="text-xs font-bold text-slate-500 uppercase tracking-widest mb-1">Total CGST</p>
              <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_cgst)}</p>
            </CardContent>
          </Card>
          <Card className="shadow-sm border-slate-200 bg-white">
            <CardContent className="p-5">
              <p className="text-xs font-bold text-slate-500 uppercase tracking-widest mb-1">Total SGST</p>
              <p className="text-2xl font-black text-slate-900">{formatCurrency(reportSummary.total_sgst)}</p>
            </CardContent>
          </Card>
          <Card className="shadow-sm border-slate-200 bg-white">
            <CardContent className="p-5">
              <p className="text-xs font-bold text-slate-500 uppercase tracking-widest mb-1">Total GST Liability</p>
              <p className="text-2xl font-black text-emerald-600">{formatCurrency(reportSummary.total_gst)}</p>
            </CardContent>
          </Card>
        </div>
      )}

      {/* GST Adoption Transparency */}
      {reportSummary?.composition && (
        <Card className="shadow-sm border-slate-200 bg-slate-50/50 border-l-4 border-l-slate-900">
          <CardContent className="p-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
              <div className="space-y-1">
                <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider">Tax Filing Composition</h3>
                <p className="text-sm text-slate-600">
                  Out of <span className="font-bold text-slate-900">{reportSummary.composition.total_orders}</span> total orders, 
                  <span className="font-bold text-slate-900"> {reportSummary.composition.gst_orders}</span> have GST included.
                </p>
              </div>
              <div className="flex items-center gap-8">
                <div className="text-center">
                  <p className="text-2xl font-black text-slate-900">{reportSummary.composition.gst_percentage}%</p>
                  <p className="text-[10px] font-bold text-slate-500 uppercase">GST Included</p>
                </div>
                <div className="w-px h-10 bg-slate-200" />
                <div className="text-center">
                  <p className="text-2xl font-black text-slate-400">{100 - reportSummary.composition.gst_percentage}%</p>
                  <p className="text-[10px] font-bold text-slate-500 uppercase">GST Exempted</p>
                </div>
              </div>
            </div>
            <div className="mt-4 w-full h-2 bg-slate-200 rounded-full overflow-hidden flex">
              <div 
                className="h-full bg-slate-900 transition-all duration-500" 
                style={{ width: `${reportSummary.composition.gst_percentage}%` }} 
              />
            </div>
          </CardContent>
        </Card>
      )}

      {/* Charts */}
      {data.length > 0 && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <Card className="shadow-sm border-slate-200 bg-white">
            <CardHeader className="py-3 px-6 border-b border-slate-100">
              <CardTitle className="text-sm font-semibold">Tax Liability by Slab</CardTitle>
            </CardHeader>
            <CardContent className="p-6 h-[300px]">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={data}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={5}
                    dataKey="total_gst"
                    nameKey="slab"
                    label={(props: any) => `${props.name}% Slab`}
                  >
                    {data.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={["#10b981", "#3b82f6", "#f59e0b", "#ef4444"][index % 4]} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(value: any) => formatCurrency(Number(value || 0))} />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          <Card className="shadow-sm border-slate-200 bg-white">
            <CardHeader className="py-3 px-6 border-b border-slate-100">
              <CardTitle className="text-sm font-semibold">Taxable Value vs GST</CardTitle>
            </CardHeader>
            <CardContent className="p-6 h-[300px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={data}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                  <XAxis dataKey="slab" tickFormatter={(v) => `${v}%`} axisLine={false} tickLine={false} />
                  <YAxis axisLine={false} tickLine={false} />
                  <Tooltip formatter={(value: any) => formatCurrency(Number(value || 0))} />
                  <Bar dataKey="taxable_value" name="Taxable Value" fill="#94a3b8" radius={[4, 4, 0, 0]} />
                  <Bar dataKey="total_gst" name="Total GST" fill="#10b981" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>
      )}

      <ReportTable 
        columns={SUMMARY_COLUMNS}
        data={data}
        loading={loading}
        error={error}
        sortConfig={sortConfig}
        onSort={onSort}
        formatCell={formatCell}
        footer={reportSummary && (
          <tfoot className="bg-slate-50 font-bold text-slate-900">
            <tr>
              <td className="px-5 py-3 border-t border-slate-200 uppercase text-xs">Total Liability</td>
              <td className="px-5 py-3 border-t border-slate-200">{formatCurrency(reportSummary.total_taxable)}</td>
              <td className="px-5 py-3 border-t border-slate-200">{formatCurrency(reportSummary.total_cgst)}</td>
              <td className="px-5 py-3 border-t border-slate-200">{formatCurrency(reportSummary.total_sgst)}</td>
              <td className="px-5 py-3 border-t border-slate-200">{formatCurrency(reportSummary.total_gst)}</td>
            </tr>
          </tfoot>
        )}
      />

      {/* Detailed Invoice List */}
      {gstDetails.length > 0 && (
        <div className="mt-8 space-y-4">
          <div className="flex items-center justify-between px-1">
            <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
              Detailed Invoice List (GSTR-1 B2C)
            </h3>
            <Badge variant="secondary" className="bg-slate-100 text-slate-600 border-none">
              {gstDetails.length} Invoices
            </Badge>
          </div>
          <ReportTable 
            columns={GST_DETAILED_COLUMNS}
            data={gstDetails}
            loading={false}
            error={null}
            sortConfig={null}
            onSort={() => {}}
            formatCell={formatCell}
          />
        </div>
      )}
    </div>
  );
}
