"use client";

import { ReportTable } from "../ReportTable";

interface DueOverdueViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
}

export function DueOverdueView({ 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell 
}: DueOverdueViewProps) {
  const columns = [
    { header: "Customer", key: "customer_name" },
    { header: "Phone", key: "customer_phone" },
    { header: "Products", key: "product_names" },
    { header: "Return Date", key: "end_date", format: "date" as const },
    { header: "Days Overdue", key: "days_overdue", format: "number" as const },
    { header: "Total Amount", key: "total_amount", format: "currency" as const },
    { header: "Paid", key: "amount_paid", format: "currency" as const },
    { header: "Balance", key: "balance", format: "currency" as const },
    { header: "Status", key: "status" },
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
