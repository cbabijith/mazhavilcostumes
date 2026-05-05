"use client";

import { ReportTable } from "../ReportTable";

interface RentalFrequencyViewProps {
  data: any[];
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
}

export function RentalFrequencyView({ 
  data, 
  loading, 
  error, 
  sortConfig, 
  onSort, 
  formatCell 
}: RentalFrequencyViewProps) {
  const columns = [
    { header: "Product", key: "product_name" },
    { header: "Category", key: "category_name" },
    { header: "Rental Count", key: "rental_count", format: "number" as const },
    { header: "Last Rented", key: "last_rented", format: "date" as const },
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
