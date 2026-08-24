"use client";

import { ReportTable } from "../ReportTable";

interface DayWiseBookingViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
}

export function DayWiseBookingView({ 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell 
}: DayWiseBookingViewProps) {
  const columns = [
    { header: "Customer", key: "customer_name" },
    { header: "Phone", key: "customer_phone" },
    { header: "Products", key: "product_names" },
    { header: "Start Date", key: "start_date", format: "date" as const },
    { header: "End Date", key: "end_date", format: "date" as const },
    { header: "Amount", key: "total_amount", format: "currency" as const },
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
