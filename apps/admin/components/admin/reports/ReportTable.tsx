"use client";

import { TrendingUp, Loader2, ArrowUpDown } from "lucide-react";
import { Card, CardHeader, CardTitle } from "@/components/ui/card";
import { cn } from "@/lib/utils";

interface Column {
  header: string;
  key: string;
  format?: "currency" | "date" | "number" | "percent" | "string";
  render?: (value: any, row: any) => React.ReactNode;
}

interface ReportTableProps {
  columns: Column[];
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: { key: string; direction: 'asc' | 'desc' } | null;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => string | React.ReactNode;
  footer?: React.ReactNode;
  onRowClick?: (row: any) => void;
}

export function ReportTable({ 
  columns, 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell,
  footer,
  onRowClick
}: ReportTableProps) {
  return (
    <Card className="shadow-sm border-slate-200 bg-white">
      <CardHeader className="border-b border-slate-200 py-3 px-6 flex flex-row items-center justify-between">
        <CardTitle className="text-sm font-semibold text-slate-900 uppercase tracking-wider">
          Report Data
        </CardTitle>
        <div className="text-xs text-slate-400 font-medium">
          Showing {data.length} records
        </div>
      </CardHeader>
      <div className="overflow-x-auto">
        <table className="w-full text-sm text-left">
          <thead className="bg-slate-50/50 text-slate-500">
            <tr>
              {columns.map((col, i) => (
                <th 
                  key={i} 
                  className={cn(
                    "px-5 py-3 font-medium border-b border-slate-200 whitespace-nowrap cursor-pointer hover:text-slate-900 transition-colors group",
                    sortConfig?.key === col.key && "text-slate-900 bg-slate-100/50"
                  )}
                  onClick={() => onSort(col.key)}
                >
                  <div className="flex items-center gap-1">
                    {col.header}
                    {sortConfig?.key === col.key ? (
                      <TrendingUp className={cn("w-3 h-3 transition-transform text-slate-900", sortConfig.direction === 'desc' && "rotate-180")} />
                    ) : (
                      <ArrowUpDown className="w-3 h-3 text-slate-300 group-hover:text-slate-400 transition-colors" />
                    )}
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {loading ? (
              <tr><td colSpan={columns.length} className="px-5 py-12 text-center"><Loader2 className="w-6 h-6 animate-spin mx-auto text-slate-400" /></td></tr>
            ) : error ? (
              <tr><td colSpan={columns.length} className="px-5 py-12 text-center text-red-600">{error}</td></tr>
            ) : data.length === 0 ? (
              <tr><td colSpan={columns.length} className="px-5 py-12 text-center text-slate-500">No data found. Adjust filters and try again.</td></tr>
            ) : (
              data.map((row, idx) => (
                <tr 
                  key={idx} 
                  className={cn(
                    "hover:bg-slate-50 transition-colors",
                    onRowClick && "cursor-pointer"
                  )}
                  onClick={() => onRowClick?.(row)}
                >
                  {columns.map((col, ci) => (
                    <td key={ci} className={cn(
                      "px-5 py-3 whitespace-nowrap",
                      col.format === "currency" && "tabular-nums font-medium"
                    )}>
                      {col.render ? col.render(row[col.key], row) : formatCell(row[col.key], col.format)}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
          {footer}
        </table>
      </div>
    </Card>
  );
}
