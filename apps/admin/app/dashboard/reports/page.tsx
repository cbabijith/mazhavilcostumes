"use client";

import { useState, useEffect, useCallback, useMemo, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { 
  BarChart3, CalendarDays, AlertTriangle, TrendingUp, Trophy, Users, 
  PiggyBank, PackageX, UserCheck, Boxes, MessageSquare, ArrowLeft,
  FileSpreadsheet, FileText, Search, Loader2, Plus, X
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { REPORT_LIST, type ReportType, type ReportMeta, type CreateEnquiryDTO, type ReportFilters as FilterType } from "@/domain";
import { exportToExcel, exportToPDF } from "@/lib/exportUtils";
import { formatCurrency } from "@/lib/shared-utils";
import { reportService } from "@/services/reportService";
import { useAppStore } from "@/stores/appStore";

// Shared Components
import { ReportHeader } from "@/components/admin/reports/ReportHeader";
import { ReportFilters } from "@/components/admin/reports/ReportFilters";

// Modular Views
import { 
  DayWiseBookingView, DueOverdueView, RevenueView, TopCostumesView,
  TopCustomersView, RentalFrequencyView, ROIView, DeadStockView,
  SalesByStaffView, InventoryRevenueView, EnquiryLogView, GSTFilingView
} from "@/components/admin/reports/views";

import { ICONS, CATEGORY_COLORS } from "@/lib/reports-shared";

type SortConfig = {
  key: string;
  direction: 'asc' | 'desc';
} | null;

function ReportsPageContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const reportFromUrl = searchParams.get("type") as ReportType | null;

  const [data, setData] = useState<any[]>([]);
  const [reportSummary, setReportSummary] = useState<any>(null);
  const [gstDetails, setGstDetails] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState<FilterType>({
    period: 'month',
    date: new Date().toLocaleDateString('en-CA'),
    from_date: new Date(new Date().getFullYear(), new Date().getMonth(), 1).toLocaleDateString('en-CA'),
    to_date: new Date().toLocaleDateString('en-CA'),
    rank_by: 'count',
    limit: 50
  });

  const selectedReport = reportFromUrl;
  const [sortConfig, setSortConfig] = useState<SortConfig>(null);

  const fetchReport = useCallback(async () => {
    if (!selectedReport) return;
    setLoading(true);
    setError(null);
    const queryParams = new URLSearchParams();
    if (filters.date) queryParams.append('date', filters.date);
    if (filters.from_date) queryParams.append('from_date', filters.from_date);
    if (filters.to_date) queryParams.append('to_date', filters.to_date);
    if (filters.period) queryParams.append('period', filters.period);
    if (filters.rank_by) queryParams.append('rank_by', filters.rank_by);
    if (filters.limit) queryParams.append('limit', filters.limit.toString());
    if (filters.status?.length) queryParams.append('status', filters.status.join(','));

    try {
      const response = await fetch(`/api/reports/${selectedReport}?${queryParams.toString()}`);
      const json = await response.json();
      
      if (!json.success) {
        throw new Error(json.error?.message || "Failed to fetch report data");
      }

      // Robust check for rows wrapper (some reports might not have it depending on API version)
      const result = json.data.rows !== undefined ? json.data.rows : json.data;

      if (selectedReport === 'gst-filing') {
        setData(result.summary || []);
        setReportSummary(result);
        setGstDetails(result.details || []);
      } else {
        setData(result || []);
        setReportSummary(null);
        setGstDetails([]);
      }
    } catch (err: any) {
      setError(err.message || "Failed to fetch report data");
    } finally {
      setLoading(false);
    }
  }, [selectedReport, filters]);

  useEffect(() => {
    if (selectedReport) {
      fetchReport();
    } else {
      setData([]);
      setReportSummary(null);
      setGstDetails([]);
    }
  }, [selectedReport, filters]);

  const handleSort = (key: string) => {
    let direction: 'asc' | 'desc' = 'asc';
    if (sortConfig && sortConfig.key === key && sortConfig.direction === 'asc') {
      direction = 'desc';
    }
    setSortConfig({ key, direction });
  };

  const sortedData = useMemo(() => {
    if (!sortConfig) return data;
    return [...data].sort((a, b) => {
      const aValue = a[sortConfig.key];
      const bValue = b[sortConfig.key];
      if (aValue === undefined || bValue === undefined) return 0;
      if (aValue < bValue) return sortConfig.direction === 'asc' ? -1 : 1;
      if (aValue > bValue) return sortConfig.direction === 'asc' ? 1 : -1;
      return 0;
    });
  }, [data, sortConfig]);

  const getExportColumns = () => {
    if (!selectedReport) return [];
    switch (selectedReport) {
      case 'day-wise-booking':
        return [
          { header: "Customer", key: "customer_name" },
          { header: "Phone", key: "customer_phone" },
          { header: "Products", key: "product_names" },
          { header: "Start Date", key: "start_date", format: "date" as const },
          { header: "End Date", key: "end_date", format: "date" as const },
          { header: "Amount", key: "total_amount", format: "currency" as const },
          { header: "Status", key: "status" },
        ];
      case 'due-overdue':
        return [
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
      case 'revenue':
        return [
          { header: "Period", key: "period" },
          { header: "Completed", key: "completed_revenue", format: "currency" as const },
          { header: "Ongoing", key: "ongoing_revenue", format: "currency" as const },
          { header: "Scheduled", key: "scheduled_revenue", format: "currency" as const },
          { header: "Total", key: "total_revenue", format: "currency" as const },
          { header: "Orders", key: "order_count" },
        ];
      case 'top-costumes':
        return [
          { header: "Costume Name", key: "product_name" },
          { header: "Category", key: "category_name" },
          { header: "Rentals", key: "rental_count", format: "number" as const },
          { header: "Revenue", key: "revenue", format: "currency" as const },
          { header: "Avg. Days", key: "avg_rental_days", format: "number" as const },
        ];
      case 'top-customers':
        return [
          { header: "Customer", key: "customer_name" },
          { header: "Phone", key: "customer_phone" },
          { header: "Orders", key: "order_count", format: "number" as const },
          { header: "Total Spent", key: "total_spent", format: "currency" as const },
          { header: "Last Order", key: "last_order_date", format: "date" as const },
        ];
      case 'rental-frequency':
        return [
          { header: "Product", key: "product_name" },
          { header: "Category", key: "category_name" },
          { header: "Rental Count", key: "rental_count", format: "number" as const },
          { header: "Last Rented", key: "last_rented", format: "date" as const },
        ];
      case 'roi':
        return [
          { header: "Product", key: "product_name" },
          { header: "Purchase Price", key: "purchase_price", format: "currency" as const },
          { header: "Revenue", key: "total_revenue", format: "currency" as const },
          { header: "Profit", key: "profit", format: "currency" as const },
          { header: "ROI %", key: "roi_percentage", format: "percent" as const },
        ];
      case 'dead-stock':
        return [
          { header: "Product", key: "product_name" },
          { header: "Category", key: "category_name" },
          { header: "Price/Day", key: "price_per_day", format: "currency" as const },
          { header: "Quantity", key: "quantity", format: "number" as const },
          { header: "Days Idle", key: "days_since_last_rental", format: "number" as const },
        ];
      case 'sales-by-staff':
        return [
          { header: "Staff Member", key: "staff_name" },
          { header: "Orders", key: "order_count", format: "number" as const },
          { header: "Total Revenue", key: "total_revenue", format: "currency" as const },
          { header: "Avg. Order", key: "avg_order_value", format: "currency" as const },
        ];
      case 'inventory-revenue':
        return [
          { header: "Product", key: "product_name" },
          { header: "Category", key: "category_name" },
          { header: "Quantity", key: "quantity", format: "number" as const },
          { header: "Daily Price", key: "price_per_day", format: "currency" as const },
          { header: "Lifetime Revenue", key: "lifetime_revenue", format: "currency" as const },
        ];
      case 'enquiry-log':
        return [
          { header: "Date", key: "created_at", format: "date" as const },
          { header: "Query", key: "product_query" },
          { header: "Customer", key: "customer_name" },
          { header: "Phone", key: "customer_phone" },
          { header: "Logged By", key: "staff_name" },
        ];
      case 'gst-filing':
        return [
          { header: "GST Slab", key: "slab", format: "percent" as const },
          { header: "Taxable Value", key: "taxable_value", format: "currency" as const },
          { header: "CGST", key: "cgst", format: "currency" as const },
          { header: "SGST", key: "sgst", format: "currency" as const },
          { header: "Total GST", key: "total_gst", format: "currency" as const },
        ];
      default: return [];
    }
  };

  const handleExportExcel = () => {
    const meta = REPORT_LIST.find(r => r.id === selectedReport);
    if (!meta) return;
    
    let exportData = sortedData;
    let exportColumns = getExportColumns();
    
    if (selectedReport === 'gst-filing' && gstDetails.length > 0) {
      exportData = gstDetails;
      exportColumns = [
        { header: "Order ID", key: "order_id" },
        { header: "Invoice No", key: "invoice_no" },
        { header: "Date", key: "date", format: "date" as const },
        { header: "Customer", key: "customer_name" },
        { header: "Total Value", key: "total_value", format: "currency" as const },
        { header: "Taxable Value", key: "taxable_value", format: "currency" as const },
        { header: "GST Slabs", key: "slabs" },
        { header: "Total GST", key: "gst_amount", format: "currency" as const },
      ];
    } else if (selectedReport === 'enquiry-log') {
      exportData = sortedData.map(d => ({ ...d, staff_name: d.staff?.name || "System" }));
    }
    
    exportToExcel(exportData, exportColumns as any, `${meta.name}_${new Date().toISOString().split('T')[0]}`);
  };

  const handleExportPDF = () => {
    const meta = REPORT_LIST.find(r => r.id === selectedReport);
    if (!meta) return;
    
    let exportData = sortedData;
    let exportColumns = getExportColumns();
    
    if (selectedReport === 'enquiry-log') {
      exportData = sortedData.map(d => ({ ...d, staff_name: d.staff?.name || "System" }));
    }
    
    exportToPDF(exportData, exportColumns as any, meta.name, `${meta.name}_${new Date().toISOString().split('T')[0]}`);
  };

  const { user } = useAppStore();

  const handleLogEnquiry = async (dto: CreateEnquiryDTO) => {
    try {
      const response = await fetch(`/api/reports/enquiry-log`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(dto)
      });
      const json = await response.json();
      if (!json.success) throw new Error(json.error?.message || "Failed to log enquiry");
      fetchReport();
    } catch (err: any) {
      setError(err.message || "Failed to log enquiry");
    }
  };

  const formatCell = (value: any, format?: string) => {
    if (value === null || value === undefined) return "-";
    switch (format) {
      case "currency": return formatCurrency(Number(value));
      case "date": return new Date(value).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
      case "percent": return `${value}%`;
      case "number": return typeof value === 'number' ? value.toLocaleString() : value;
      default: return value.toString();
    }
  };

  if (!selectedReport) {
    return (
      <div className="space-y-8 animate-in fade-in duration-500">
        <div className="flex flex-col gap-1">
          <h1 className="text-3xl font-black text-slate-900 tracking-tight">Business Intelligence</h1>
          <p className="text-slate-500 font-medium">Select a specialized report to analyze your business performance.</p>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {REPORT_LIST.map((report) => {
            const Icon = ICONS[report.icon] || BarChart3;
            return (
              <button
                key={report.id}
                onClick={() => router.push(`/dashboard/reports?type=${report.id}`)}
                className="group p-6 bg-white rounded-2xl border border-slate-200 shadow-sm hover:shadow-md hover:border-slate-900 transition-all text-left flex flex-col h-full active:scale-[0.98]"
              >
                <div className={`w-12 h-12 rounded-xl mb-6 flex items-center justify-center transition-transform group-hover:scale-110 group-hover:rotate-3 ${CATEGORY_COLORS[report.category]}`}>
                  <Icon className="w-6 h-6" />
                </div>
                <div className="mt-auto">
                  <h3 className="font-bold text-slate-900 group-hover:text-slate-900 mb-1">{report.name}</h3>
                  <p className="text-xs text-slate-500 line-clamp-2 leading-relaxed">{report.description}</p>
                </div>
              </button>
            );
          })}
        </div>
      </div>
    );
  }

  const meta = REPORT_LIST.find(r => r.id === selectedReport)!;
  const needsDateFilter = ["day-wise-booking", "due-overdue"].includes(selectedReport);
  const needsRangeFilter = ["revenue", "dead-stock", "sales-by-staff", "enquiry-log", "gst-filing", "top-customers", "rental-frequency", "roi"].includes(selectedReport);
  const needsRankBy = selectedReport === "top-costumes";

  return (
    <div className="space-y-6">
      <ReportHeader 
        meta={meta}
        onExportExcel={handleExportExcel}
        onExportPDF={handleExportPDF}
        hasData={data.length > 0 || gstDetails.length > 0}
      />

      <ReportFilters 
        filters={filters}
        setFilters={setFilters}
        onGenerate={fetchReport}
        loading={loading}
        needsDateFilter={needsDateFilter}
        needsRangeFilter={needsRangeFilter}
        needsRankBy={needsRankBy}
        needsStatusFilter={selectedReport === 'gst-filing'}
      />

      {error && (
        <div className="p-4 bg-red-50 border border-red-200 text-red-600 rounded-xl flex items-center gap-3">
          <AlertTriangle className="w-5 h-5" />
          <p className="text-sm font-medium">{error}</p>
        </div>
      )}

      <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
        {selectedReport === 'day-wise-booking' && <DayWiseBookingView data={sortedData} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} />}
        {selectedReport === 'due-overdue' && <DueOverdueView data={sortedData} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} />}
        {selectedReport === 'revenue' && <RevenueView data={sortedData} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} />}
        {selectedReport === 'top-costumes' && <TopCostumesView data={sortedData} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} rankBy={filters.rank_by || 'count'} />}
        {selectedReport === 'top-customers' && <TopCustomersView data={sortedData} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} />}
        {selectedReport === 'rental-frequency' && <RentalFrequencyView data={sortedData} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} />}
        {selectedReport === 'roi' && <ROIView data={sortedData} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} />}
        {selectedReport === 'dead-stock' && <DeadStockView data={sortedData} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} />}
        {selectedReport === 'sales-by-staff' && <SalesByStaffView data={sortedData} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} />}
        {selectedReport === 'inventory-revenue' && <InventoryRevenueView data={sortedData} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} />}
        {selectedReport === 'enquiry-log' && <EnquiryLogView data={sortedData} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} onLogEnquiry={handleLogEnquiry} />}
        {selectedReport === 'gst-filing' && <GSTFilingView data={sortedData} reportSummary={reportSummary} loading={loading} error={error} sortConfig={sortConfig} onSort={handleSort} formatCell={formatCell} gstDetails={gstDetails} />}
      </div>
    </div>
  );
}

export default function ReportsPage() {
  return (
    <Suspense fallback={<div className="p-8 text-center flex flex-col items-center gap-4">
      <Loader2 className="w-10 h-10 animate-spin text-slate-400" />
      <p className="text-sm font-medium text-slate-500">Loading Business Intelligence...</p>
    </div>}>
      <ReportsPageContent />
    </Suspense>
  );
}
  