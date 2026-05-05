"use client";

import { ReportTable } from "../ReportTable";

interface TopCustomersViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
}

export function TopCustomersView({ 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell 
}: TopCustomersViewProps) {
  const columns = [
    { header: "Customer", key: "customer_name" },
    { header: "Phone", key: "customer_phone" },
    { header: "Orders", key: "order_count", format: "number" as const },
    { header: "Total Spent", key: "total_spent", format: "currency" as const },
    { header: "Last Order", key: "last_order_date", format: "date" as const },
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
