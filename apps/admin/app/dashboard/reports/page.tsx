"use client";

import { useState, useEffect, useCallback } from "react";
import { useRouter } from "next/navigation";
import {
  CalendarDays, AlertTriangle, TrendingUp, Trophy, Users, BarChart3,
  PiggyBank, PackageX, UserCheck, Boxes, MessageSquare, Download,
  FileSpreadsheet, FileText, Search, Plus, Loader2, ArrowLeft, X
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { REPORT_LIST, type ReportType, type ReportMeta } from "@/domain";
import { exportToExcel, exportToPDF } from "@/lib/exportUtils";
import { formatCurrency } from "@/lib/shared-utils";

const ICONS: Record<string, any> = {
  CalendarDays, AlertTriangle, TrendingUp, Trophy, Users, BarChart3,
  PiggyBank, PackageX, UserCheck, Boxes, MessageSquare,
};

const CATEGORY_COLORS: Record<string, string> = {
  booking: "bg-blue-50 text-blue-700 border-blue-200",
  due: "bg-red-50 text-red-700 border-red-200",
  sale: "bg-emerald-50 text-emerald-700 border-emerald-200",
  inventory: "bg-amber-50 text-amber-700 border-amber-200",
  reminder: "bg-purple-50 text-purple-700 border-purple-200",
};

/** Column definitions per report — used for table rendering + export */
function getColumns(type: ReportType): { header: string; key: string; format?: "currency" | "number" | "date" | "percent" }[] {
  switch (type) {
    case "day-wise-booking": return [
      { header: "Order ID", key: "order_id" }, { header: "Customer", key: "customer_name" },
      { header: "Phone", key: "customer_phone" }, { header: "Products", key: "product_names" },
      { header: "Start", key: "start_date", format: "date" }, { header: "End", key: "end_date", format: "date" },
      { header: "Amount", key: "total_amount", format: "currency" }, { header: "Status", key: "status" },
    ];
    case "due-overdue": return [
      { header: "Order ID", key: "order_id" }, { header: "Customer", key: "customer_name" },
      { header: "Phone", key: "customer_phone" }, { header: "Products", key: "product_names" },
      { header: "Due Date", key: "end_date", format: "date" }, { header: "Days Overdue", key: "days_overdue" },
      { header: "Total", key: "total_amount", format: "currency" }, { header: "Paid", key: "amount_paid", format: "currency" },
      { header: "Balance", key: "balance", format: "currency" },
    ];
    case "revenue": return [
      { header: "Period", key: "period" }, { header: "Completed", key: "completed_revenue", format: "currency" },
      { header: "Ongoing", key: "ongoing_revenue", format: "currency" }, { header: "Scheduled", key: "scheduled_revenue", format: "currency" },
      { header: "Total", key: "total_revenue", format: "currency" }, { header: "Orders", key: "order_count" },
    ];
    case "top-costumes": return [
      { header: "Product", key: "product_name" }, { header: "Category", key: "category_name" },
      { header: "Rentals", key: "rental_count" }, { header: "Revenue", key: "revenue", format: "currency" },
      { header: "Avg Days", key: "avg_rental_days" },
    ];
    case "top-customers": return [
      { header: "Customer", key: "customer_name" }, { header: "Phone", key: "customer_phone" },
      { header: "Orders", key: "order_count" }, { header: "Total Spent", key: "total_spent", format: "currency" },
      { header: "Last Order", key: "last_order_date", format: "date" },
    ];
    case "rental-frequency": return [
      { header: "Product", key: "product_name" }, { header: "Category", key: "category_name" },
      { header: "Rental Count", key: "rental_count" }, { header: "Last Rented", key: "last_rented", format: "date" },
    ];
    case "roi": return [
      { header: "Product", key: "product_name" }, { header: "Purchase Price", key: "purchase_price", format: "currency" },
      { header: "Revenue", key: "total_revenue", format: "currency" }, { header: "Profit", key: "profit", format: "currency" },
      { header: "ROI %", key: "roi_percentage", format: "percent" }, { header: "Rentals", key: "rental_count" },
    ];
    case "dead-stock": return [
      { header: "Product", key: "product_name" }, { header: "Category", key: "category_name" },
      { header: "Price/Day", key: "price_per_day", format: "currency" }, { header: "Stock", key: "quantity" },
      { header: "Days Since Last Rental", key: "days_since_last_rental" },
    ];
    case "sales-by-staff": return [
      { header: "Staff", key: "staff_name" }, { header: "Email", key: "staff_email" },
      { header: "Orders", key: "order_count" }, { header: "Revenue", key: "total_revenue", format: "currency" },
      { header: "Avg Order", key: "avg_order_value", format: "currency" },
    ];
    case "inventory-revenue": return [
      { header: "Product", key: "product_name" }, { header: "Category", key: "category_name" },
      { header: "Total Qty", key: "quantity" }, { header: "Available", key: "available_quantity" },
      { header: "Price/Day", key: "price_per_day", format: "currency" },
      { header: "Lifetime Revenue", key: "lifetime_revenue", format: "currency" }, { header: "Rentals", key: "rental_count" },
    ];
    case "enquiry-log": return [
      { header: "Date", key: "created_at", format: "date" }, { header: "Product Query", key: "product_query" },
      { header: "Customer", key: "customer_name" }, { header: "Phone", key: "customer_phone" },
      { header: "Notes", key: "notes" }, { header: "Logged By", key: "staff_name" },
    ];
    default: return [];
  }
}

export default function ReportsPage() {
  const [selectedReport, setSelectedReport] = useState<ReportType | null>(null);
  const [data, setData] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Filters
  const [date, setDate] = useState(() => {
    const tmr = new Date(); tmr.setDate(tmr.getDate() + 1);
    return tmr.toISOString().split("T")[0];
  });
  const [fromDate, setFromDate] = useState(() => {
    const d = new Date(); d.setMonth(d.getMonth() - 1);
    return d.toISOString().split("T")[0];
  });
  const [toDate, setToDate] = useState(() => new Date().toISOString().split("T")[0]);
  const [period, setPeriod] = useState<string>("month");
  const [rankBy, setRankBy] = useState<string>("count");

  // Enquiry form
  const [showEnquiryForm, setShowEnquiryForm] = useState(false);
  const [enquiryForm, setEnquiryForm] = useState({ product_query: "", customer_name: "", customer_phone: "", notes: "" });
  const [enquiryLoading, setEnquiryLoading] = useState(false);

  const fetchReport = useCallback(async (type: ReportType) => {
    setLoading(true);
    setError("");
    try {
      const params = new URLSearchParams();
      if (type === "day-wise-booking") params.set("date", date);
      if (["revenue", "dead-stock", "sales-by-staff", "enquiry-log"].includes(type)) {
        params.set("from_date", fromDate);
        params.set("to_date", toDate);
        if (type === "revenue") params.set("period", period);
      }
      if (type === "top-costumes") params.set("rank_by", rankBy);

      const res = await fetch(`/api/reports/${type}?${params.toString()}`);
      const json = await res.json();
      if (json.success && json.data) {
        let rows = json.data.rows || [];
        if (type === "enquiry-log") {
          rows = rows.map((r: any) => ({ ...r, staff_name: r.staff?.name || "Unknown" }));
        }
        setData(rows);
      } else {
        setError(json.error || "Failed to fetch report");
      }
    } catch {
      setError("Network error");
    } finally {
      setLoading(false);
    }
  }, [date, fromDate, toDate, period, rankBy]);

  useEffect(() => {
    if (selectedReport) fetchReport(selectedReport);
  }, [selectedReport, fetchReport]);

  const handleExportExcel = () => {
    if (!selectedReport || data.length === 0) return;
    const meta = REPORT_LIST.find(r => r.id === selectedReport)!;
    exportToExcel(data, getColumns(selectedReport), `${meta.name}_${toDate}`);
  };

  const handleExportPDF = () => {
    if (!selectedReport || data.length === 0) return;
    const meta = REPORT_LIST.find(r => r.id === selectedReport)!;
    exportToPDF(data, getColumns(selectedReport), meta.name, `${meta.name}_${toDate}`);
  };

  const handleSubmitEnquiry = async () => {
    if (!enquiryForm.product_query.trim()) return;
    setEnquiryLoading(true);
    try {
      const res = await fetch("/api/enquiries", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(enquiryForm),
      });
      const json = await res.json();
      if (json.success) {
        setEnquiryForm({ product_query: "", customer_name: "", customer_phone: "", notes: "" });
        setShowEnquiryForm(false);
        if (selectedReport === "enquiry-log") fetchReport("enquiry-log");
      }
    } catch { /* silent */ } finally {
      setEnquiryLoading(false);
    }
  };

  const formatCell = (val: any, format?: string) => {
    if (val == null || val === "") return "—";
    if (format === "currency") return formatCurrency(Number(val));
    if (format === "percent") return `${Number(val).toFixed(1)}%`;
    if (format === "date") {
      try { return new Date(val).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" }); }
      catch { return val; }
    }
    return String(val);
  };

  // ── Report selector view ──
  if (!selectedReport) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Reports</h1>
          <p className="text-sm text-slate-500 mt-1">Generate, view, and export operational and financial reports</p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {REPORT_LIST.map((report) => {
            const Icon = ICONS[report.icon] || BarChart3;
            return (
              <button
                key={report.id}
                onClick={() => setSelectedReport(report.id)}
                className="text-left bg-white border border-slate-200 rounded-xl p-5 hover:border-slate-300 hover:shadow-md transition-all group"
              >
                <div className="flex items-start gap-4">
                  <div className={`w-10 h-10 rounded-lg flex items-center justify-center shrink-0 ${CATEGORY_COLORS[report.category] || "bg-slate-100 text-slate-600"}`}>
                    <Icon className="w-5 h-5" />
                  </div>
                  <div className="min-w-0">
                    <h3 className="text-sm font-semibold text-slate-900 group-hover:text-slate-700">{report.name}</h3>
                    <p className="text-xs text-slate-500 mt-0.5">{report.description}</p>
                    <Badge variant="outline" className={`mt-2 text-[10px] uppercase tracking-wider ${CATEGORY_COLORS[report.category]}`}>
                      {report.category}
                    </Badge>
                  </div>
                </div>
              </button>
            );
          })}
        </div>
      </div>
    );
  }

  // ── Report detail view ──
  const meta = REPORT_LIST.find(r => r.id === selectedReport)!;
  const columns = getColumns(selectedReport);
  const Icon = ICONS[meta.icon] || BarChart3;
  const needsDateFilter = selectedReport === "day-wise-booking";
  const needsRangeFilter = ["revenue", "dead-stock", "sales-by-staff", "enquiry-log"].includes(selectedReport);
  const needsRankBy = selectedReport === "top-costumes";
  const isEnquiry = selectedReport === "enquiry-log";

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <Button variant="outline" size="icon" onClick={() => { setSelectedReport(null); setData([]); }} className="w-9 h-9 border-slate-200 text-slate-500 hover:text-slate-900 bg-white">
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${CATEGORY_COLORS[meta.category]}`}>
            <Icon className="w-5 h-5" />
          </div>
          <div>
            <h1 className="text-xl font-bold tracking-tight text-slate-900">{meta.name}</h1>
            <p className="text-sm text-slate-500">{meta.description}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {isEnquiry && (
            <Button variant="outline" size="sm" onClick={() => setShowEnquiryForm(true)} className="gap-2 border-purple-200 text-purple-700 hover:bg-purple-50">
              <Plus className="w-4 h-4" /> Log Enquiry
            </Button>
          )}
          <Button variant="outline" size="sm" onClick={handleExportExcel} disabled={data.length === 0} className="gap-2 border-slate-200 text-slate-600 hover:text-slate-900">
            <FileSpreadsheet className="w-4 h-4" /> Excel
          </Button>
          <Button variant="outline" size="sm" onClick={handleExportPDF} disabled={data.length === 0} className="gap-2 border-slate-200 text-slate-600 hover:text-slate-900">
            <FileText className="w-4 h-4" /> PDF
          </Button>
        </div>
      </div>

      {/* Filters */}
      <Card className="shadow-sm border-slate-200 bg-white">
        <CardContent className="p-4">
          <div className="flex flex-wrap items-end gap-4">
            {needsDateFilter && (
              <div className="space-y-1">
                <label className="text-xs font-medium text-slate-500 uppercase">Delivery Date</label>
                <Input type="date" value={date} onChange={e => setDate(e.target.value)} className="h-9 w-44 border-slate-200" />
              </div>
            )}
            {needsRangeFilter && (
              <>
                <div className="space-y-1">
                  <label className="text-xs font-medium text-slate-500 uppercase">From</label>
                  <Input type="date" value={fromDate} onChange={e => setFromDate(e.target.value)} className="h-9 w-40 border-slate-200" />
                </div>
                <div className="space-y-1">
                  <label className="text-xs font-medium text-slate-500 uppercase">To</label>
                  <Input type="date" value={toDate} onChange={e => setToDate(e.target.value)} className="h-9 w-40 border-slate-200" />
                </div>
              </>
            )}
            {selectedReport === "revenue" && (
              <div className="space-y-1">
                <label className="text-xs font-medium text-slate-500 uppercase">Group By</label>
                <select value={period} onChange={e => setPeriod(e.target.value)} className="h-9 px-3 rounded-lg border border-slate-200 bg-white text-sm">
                  <option value="day">Day</option>
                  <option value="week">Week</option>
                  <option value="month">Month</option>
                  <option value="year">Year</option>
                </select>
              </div>
            )}
            {needsRankBy && (
              <div className="space-y-1">
                <label className="text-xs font-medium text-slate-500 uppercase">Rank By</label>
                <select value={rankBy} onChange={e => setRankBy(e.target.value)} className="h-9 px-3 rounded-lg border border-slate-200 bg-white text-sm">
                  <option value="count">Rental Count</option>
                  <option value="revenue">Revenue</option>
                </select>
              </div>
            )}
            <Button size="sm" onClick={() => fetchReport(selectedReport)} className="h-9 gap-2 bg-slate-900 text-white hover:bg-slate-800">
              <Search className="w-4 h-4" /> Generate
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Results table */}
      <Card className="shadow-sm border-slate-200 bg-white">
        <CardHeader className="border-b border-slate-200 py-3 px-6 flex flex-row items-center justify-between">
          <CardTitle className="text-sm font-semibold text-slate-900">
            {loading ? "Loading..." : `${data.length} result${data.length !== 1 ? "s" : ""}`}
          </CardTitle>
        </CardHeader>
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-left">
            <thead className="bg-slate-50/50 text-slate-500">
              <tr>
                {columns.map((col, i) => (
                  <th key={i} className="px-5 py-3 font-medium border-b border-slate-200 whitespace-nowrap">{col.header}</th>
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
                  <tr key={idx} className="hover:bg-slate-50 transition-colors">
                    {columns.map((col, ci) => (
                      <td key={ci} className={`px-5 py-3 whitespace-nowrap ${col.format === "currency" ? "tabular-nums font-medium" : ""}`}>
                        {formatCell(row[col.key], col.format)}
                      </td>
                    ))}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Enquiry Form Modal */}
      {showEnquiryForm && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={() => setShowEnquiryForm(false)}>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden" onClick={e => e.stopPropagation()}>
            <div className="p-6 border-b border-slate-100 flex items-center justify-between">
              <h3 className="text-lg font-bold text-slate-900">Log Customer Enquiry</h3>
              <button onClick={() => setShowEnquiryForm(false)} className="text-slate-400 hover:text-slate-600"><X className="w-5 h-5" /></button>
            </div>
            <div className="p-6 space-y-4">
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-700">What did the customer ask for? <span className="text-red-500">*</span></label>
                <Input value={enquiryForm.product_query} onChange={e => setEnquiryForm({ ...enquiryForm, product_query: e.target.value })} placeholder="e.g., Red bridal lehenga for Dec wedding" className="border-slate-200" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-sm font-medium text-slate-700">Customer Name</label>
                  <Input value={enquiryForm.customer_name} onChange={e => setEnquiryForm({ ...enquiryForm, customer_name: e.target.value })} placeholder="Optional" className="border-slate-200" />
                </div>
                <div className="space-y-1.5">
                  <label className="text-sm font-medium text-slate-700">Phone</label>
                  <Input value={enquiryForm.customer_phone} onChange={e => setEnquiryForm({ ...enquiryForm, customer_phone: e.target.value })} placeholder="Optional" className="border-slate-200" />
                </div>
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-700">Notes</label>
                <textarea value={enquiryForm.notes} onChange={e => setEnquiryForm({ ...enquiryForm, notes: e.target.value })} placeholder="Any additional notes..." rows={2} className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-sm focus:border-slate-900 focus:ring-1 focus:ring-slate-900 outline-none resize-y" />
              </div>
            </div>
            <div className="p-6 border-t border-slate-100 flex justify-end gap-3">
              <Button variant="outline" onClick={() => setShowEnquiryForm(false)} className="border-slate-200">Cancel</Button>
              <Button onClick={handleSubmitEnquiry} disabled={!enquiryForm.product_query.trim() || enquiryLoading} className="bg-slate-900 text-white hover:bg-slate-800">
                {enquiryLoading ? "Saving..." : "Log Enquiry"}
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
