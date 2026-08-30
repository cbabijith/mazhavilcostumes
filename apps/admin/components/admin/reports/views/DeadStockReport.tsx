'use client';

import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { ReportTable } from "../ReportTable";

interface DeadStockViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
}

export function DeadStockView({
  data,
  loading,
  error,
  sortConfig,
  onSort,
  formatCell,
}: DeadStockViewProps) {
  const columns = [
    { header: "Product", key: "product_name" },
    { header: "Category", key: "category_name" },
    { header: "Daily Price", key: "price_per_day", format: "currency" as const },
    { header: "Quantity", key: "quantity", format: "number" as const },
    { header: "Stock Value", key: "stock_value", format: "currency" as const },
    {
      header: "Days Idle",
      key: "days_since_last_rental",
      format: "number" as const,
      // Render never-rented products with a distinct badge so staff can tell
      // "newly added, never rented" apart from "previously rented, now stale".
      render: (value: any, row?: any) => {
        if (row?.never_rented) {
          return (
            <span className="inline-flex items-center gap-1.5">
              <span className="font-bold text-slate-700">{value}</span>
              <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-200 text-[9px] px-1 py-0">
                New
              </Badge>
            </span>
          );
        }
        // Color-code staleness: >180 days red, >90 days amber, else slate.
        const days = Number(value);
        const tone = days > 180
          ? "text-red-600 font-bold"
          : days > 90
            ? "text-amber-600 font-bold"
            : "text-slate-700";
        return <span className={cn(tone)}>{value}</span>;
      },
    },
    { header: "Added On", key: "created_at", format: "date" as const },
  ];

  return (
    <ReportTable
      columns={columns}
      data={data}
      loading={loading}
      error={error}
      sortConfig={sortConfig}
      onSort={onSort}
      formatCell={formatCell}
    />
  );
}
