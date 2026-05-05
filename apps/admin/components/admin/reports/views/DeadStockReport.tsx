"use client";

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
  formatCell 
}: DeadStockViewProps) {
  const columns = [
    { header: "Product", key: "product_name" },
    { header: "Category", key: "category_name" },
    { header: "Daily Price", key: "price_per_day", format: "currency" as const },
    { header: "Quantity", key: "quantity", format: "number" as const },
    { header: "Days Since Last Rental", key: "days_since_last_rental", format: "number" as const },
    { header: "Created At", key: "created_at", format: "date" as const },
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
