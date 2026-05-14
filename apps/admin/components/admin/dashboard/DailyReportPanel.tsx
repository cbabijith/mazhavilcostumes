/**
 * Daily Report Panel
 *
 * Admin-only client component that shows today's cash reconciliation stats.
 * Fetches data from /api/dashboard/daily-report and renders 8 clickable cards.
 * Each card navigates to the orders page with appropriate filters.
 *
 * @component
 * @module components/admin/dashboard/DailyReportPanel
 */

"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import {
  CalendarPlus,
  Truck,
  PackageCheck,
  IndianRupee,
  ShieldAlert,
  ArrowDownLeft,
  Banknote,
  Clock,
  Loader2,
  CheckCircle2,
  X,
  Download,
  FileText,
} from "lucide-react";
import { jsPDF } from "jspdf";
import autoTable from "jspdf-autotable";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

interface DailyReportStats {
  todaysBookings: number;
  todaysSales: number;
  todaysCollection: number;
  todaysDelivery: { delivered: number; total: number };
  todaysReturn: { returned: number; total: number };
  todaysRevenue: number; // Legacy alias
  damagedOrders: number;
  todaysRefunds: number;
  damageIncome: number;
  lateFeeIncome: number;
  mode_breakdown: {
    cash: number;
    upi: number;
    gpay: number;
    bank_transfer: number;
    other: number;
  };
  details: {
    bookings: { id: string; customer: string; amount: number }[];
    deliveries: { id: string; customer: string; status: string }[];
    returns: { id: string; customer: string; status: string }[];
    collections: { amount: number; mode: string; customer: string; orderId: string }[];
  };
}

const formatCurrency = (amount: number) =>
  new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);

interface DailyReportPanelProps {
  onClose: () => void;
}

export default function DailyReportPanel({ onClose }: DailyReportPanelProps) {
  const router = useRouter();
  const [stats, setStats] = useState<DailyReportStats | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const res = await fetch("/api/dashboard/daily-report");
        const json = await res.json();
        if (json.success && json.data) {
          setStats(json.data);
        }
      } catch (err) {
        console.error("Failed to load daily report:", err);
      } finally {
        setIsLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (isLoading) {
    return (
      <div className="rounded-2xl border border-slate-200 bg-white p-8">
        <div className="flex items-center justify-center gap-3 text-slate-500">
          <Loader2 className="w-5 h-5 animate-spin" />
          <span className="text-sm font-medium">Loading today&apos;s report...</span>
        </div>
      </div>
    );
  }

  if (!stats) return null;

  const deliveryPending = stats.todaysDelivery.total - stats.todaysDelivery.delivered;
  const returnPending = stats.todaysReturn.total - stats.todaysReturn.returned;

  const downloadPDF = () => {
    const formatPDFCurrency = (amount: number) => 
      `Rs. ${new Intl.NumberFormat("en-IN", { maximumFractionDigits: 0 }).format(amount)}`;

    const doc = new jsPDF();
    const now = new Date();
    const dateStr = new Intl.DateTimeFormat("en-IN", {
      timeZone: "Asia/Kolkata",
      day: "numeric",
      month: "long",
      year: "numeric",
    }).format(now);

    // Header
    doc.setFontSize(22);
    doc.setTextColor(15, 23, 42); // slate-900
    doc.text("Mazhavil Dance Costumes", 14, 20);
    
    doc.setFontSize(12);
    doc.setTextColor(100, 116, 139); // slate-500
    doc.text("Daily Operational Report", 14, 28);
    doc.text(dateStr, 14, 34);

    // Summary Section
    doc.setFontSize(14);
    doc.setTextColor(15, 23, 42);
    doc.text("Business Summary", 14, 48);

    autoTable(doc, {
      startY: 52,
      head: [["Metric", "Value", "Status"]],
      body: [
        ["Total Bookings Today", String(stats.todaysBookings), `${formatPDFCurrency(stats.todaysSales)} Value`],
        ["Amount Collection (Net)", formatPDFCurrency(stats.todaysCollection - stats.todaysRefunds), `Gross: ${formatPDFCurrency(stats.todaysCollection)}${stats.todaysRefunds > 0 ? ` (Refund: ${formatPDFCurrency(stats.todaysRefunds)})` : ""}`],
        ["Deliveries", `${stats.todaysDelivery.delivered}/${stats.todaysDelivery.total}`, stats.todaysDelivery.total - stats.todaysDelivery.delivered > 0 ? "Pending" : "Completed"],
        ["Returns", `${stats.todaysReturn.returned}/${stats.todaysReturn.total}`, stats.todaysReturn.total - stats.todaysReturn.returned > 0 ? "Pending" : "Completed"],
        ["Damaged Items Today", String(stats.damagedOrders), stats.damagedOrders > 0 ? "Flagged" : "None"],
      ],
      theme: 'striped',
      headStyles: { fillColor: [15, 23, 42] },
    });

    // Collection Breakdown
    doc.text("Collection Breakdown", 14, (doc as any).lastAutoTable.finalY + 15);
    autoTable(doc, {
      startY: (doc as any).lastAutoTable.finalY + 20,
      head: [["Mode", "Amount"]],
      body: [
        ["Cash", formatPDFCurrency(stats.mode_breakdown.cash)],
        ["UPI", formatPDFCurrency(stats.mode_breakdown.upi)],
        ["GPay", formatPDFCurrency(stats.mode_breakdown.gpay)],
        ["Bank Transfer", formatPDFCurrency(stats.mode_breakdown.bank_transfer)],
      ],
      theme: 'grid',
      headStyles: { fillColor: [15, 23, 42] },
    });

    const istIsoDate = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Asia/Kolkata',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }).format(now);
    doc.save(`Daily_Report_${istIsoDate}.pdf`);
  };

  const cards = [
    {
      label: "Today's Bookings",
      value: String(stats.todaysBookings),
      subtitle: stats.todaysBookings === 0
        ? "No orders created today"
        : `${stats.todaysBookings} order${stats.todaysBookings !== 1 ? "s" : ""} created`,
      icon: CalendarPlus,
      color: "blue",
      href: "/dashboard/orders?date_filter=today&exclude_status=cancelled",
      isEmpty: stats.todaysBookings === 0,
    },
    {
      label: "Today's Delivery",
      value: stats.todaysDelivery.total > 0
        ? `${stats.todaysDelivery.delivered}/${stats.todaysDelivery.total}`
        : "0",
      subtitle: stats.todaysDelivery.total === 0
        ? "No deliveries scheduled"
        : deliveryPending > 0
          ? `${deliveryPending} yet to deliver`
          : "All delivered ✓",
      icon: Truck,
      color: "emerald",
      href: "/dashboard/orders?date_filter=today&date_field=start_date&exclude_status=cancelled",
      isEmpty: stats.todaysDelivery.total === 0,
      hasWarning: deliveryPending > 0,
    },
    {
      label: "Today's Return",
      value: stats.todaysReturn.total > 0
        ? `${stats.todaysReturn.returned}/${stats.todaysReturn.total}`
        : "0",
      subtitle: stats.todaysReturn.total === 0
        ? "No returns expected"
        : returnPending > 0
          ? `${returnPending} yet to receive`
          : "All received ✓",
      icon: PackageCheck,
      color: "violet",
      href: "/dashboard/orders?date_filter=today&date_field=end_date&exclude_status=cancelled",
      isEmpty: stats.todaysReturn.total === 0,
      hasWarning: returnPending > 0,
    },
    {
      label: "Today's Sales",
      value: formatCurrency(stats.todaysSales),
      subtitle: "Total value of bookings today",
      icon: IndianRupee,
      color: "indigo",
      href: "/dashboard/orders?date_filter=today&exclude_status=cancelled",
      isEmpty: stats.todaysSales === 0,
      isCurrency: true,
    },
    {
      label: "Amount Collection",
      value: formatCurrency(stats.todaysCollection - stats.todaysRefunds),
      subtitle: stats.todaysRefunds > 0 
        ? `Net of ${formatCurrency(stats.todaysRefunds)} refund (Gross: ${formatCurrency(stats.todaysCollection)})`
        : `C: ${formatCurrency(stats.mode_breakdown.cash)} • U: ${formatCurrency(stats.mode_breakdown.upi)} • G: ${formatCurrency(stats.mode_breakdown.gpay)} • B: ${formatCurrency(stats.mode_breakdown.bank_transfer)}`,
      icon: Banknote,
      color: "green",
      href: null,
      isEmpty: stats.todaysCollection === 0 && stats.todaysRefunds === 0,
      isCurrency: true,
    },
    {
      label: "Damaged Orders",
      value: String(stats.damagedOrders),
      subtitle: stats.damagedOrders === 0
        ? "No new items flagged today"
        : `${stats.damagedOrders} item${stats.damagedOrders !== 1 ? "s" : ""} flagged today`,
      icon: ShieldAlert,
      color: "rose",
      href: "/dashboard/orders?status=flagged&date_filter=today&date_field=updated_at",
      isEmpty: stats.damagedOrders === 0,
    },
    {
      label: "Today's Refunds",
      value: formatCurrency(stats.todaysRefunds),
      subtitle: stats.todaysRefunds === 0
        ? "No refunds processed"
        : "Refunded to customers",
      icon: ArrowDownLeft,
      color: "orange",
      href: "/dashboard/orders?status=cancelled&date_filter=today&date_field=cancelled_at",
      isEmpty: stats.todaysRefunds === 0,
      isCurrency: true,
    },
    {
      label: "Damage Income",
      value: formatCurrency(stats.damageIncome),
      subtitle: "Collected damage charges",
      icon: ShieldAlert,
      color: "teal",
      href: "/dashboard/orders?date_filter=today&date_field=updated_at&has_damage_charges=true",
      isEmpty: stats.damageIncome === 0,
      isCurrency: true,
    },
    {
      label: "Late Fee Income",
      value: formatCurrency(stats.lateFeeIncome),
      subtitle: stats.lateFeeIncome === 0
        ? "No late fees collected"
        : "From late return fees",
      icon: Clock,
      color: "amber",
      href: "/dashboard/orders?status=late_return&date_filter=today&date_field=updated_at",
      isEmpty: stats.lateFeeIncome === 0,
      isCurrency: true,
    },
  ];

  const colorMap: Record<string, { bg: string; text: string; badge: string; border: string }> = {
    blue:    { bg: "bg-blue-50",    text: "text-blue-700",    badge: "bg-blue-100",    border: "border-blue-200" },
    emerald: { bg: "bg-emerald-50", text: "text-emerald-700", badge: "bg-emerald-100", border: "border-emerald-200" },
    violet:  { bg: "bg-violet-50",  text: "text-violet-700",  badge: "bg-violet-100",  border: "border-violet-200" },
    green:   { bg: "bg-emerald-50", text: "text-emerald-700", badge: "bg-emerald-100", border: "border-emerald-200" },
    rose:    { bg: "bg-rose-50",    text: "text-rose-700",    badge: "bg-rose-100",    border: "border-rose-200" },
    orange:  { bg: "bg-orange-50",  text: "text-orange-700",  badge: "bg-orange-100",  border: "border-orange-200" },
    teal:    { bg: "bg-teal-50",    text: "text-teal-700",    badge: "bg-teal-100",    border: "border-teal-200" },
    amber:   { bg: "bg-amber-50",   text: "text-amber-700",   badge: "bg-amber-100",   border: "border-amber-200" },
    indigo:  { bg: "bg-indigo-50",  text: "text-indigo-700",  badge: "bg-indigo-100",  border: "border-indigo-200" },
  };

  return (
    <div className="rounded-2xl border border-slate-200 bg-gradient-to-br from-slate-50 via-white to-slate-50 shadow-sm overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-white/80 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-xl bg-slate-900">
            <IndianRupee className="w-4 h-4 text-white" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-slate-900 tracking-tight">
              Today&apos;s Report (Amount Collection)
            </h3>
            <p className="text-[10px] text-slate-500 font-medium uppercase tracking-wider">
              {new Date().toLocaleDateString("en-IN", { weekday: "long", month: "short", day: "numeric" })}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button
            variant="outline"
            size="sm"
            className="h-8 gap-2 border-slate-200 text-slate-600 hover:text-slate-900"
            onClick={downloadPDF}
          >
            <Download className="w-3.5 h-3.5" />
            Download PDF
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className="w-8 h-8 text-slate-400 hover:text-slate-600"
            onClick={onClose}
          >
            <X className="w-4 h-4" />
          </Button>
        </div>
      </div>

      {/* Cards Grid */}
      <div className="p-5 grid grid-cols-2 lg:grid-cols-3 gap-3">
        {cards.map((card) => {
          const Icon = card.icon;
          const colors = colorMap[card.color] || colorMap.blue;
          const isClickable = !!card.href;

          return (
            <Card
              key={card.label}
              className={`border shadow-sm transition-all overflow-hidden ${
                isClickable
                  ? "cursor-pointer hover:shadow-md hover:scale-[1.02]"
                  : ""
              } ${
                card.hasWarning
                  ? `${colors.bg} ${colors.border}`
                  : "bg-white border-slate-200 hover:border-slate-300"
              }`}
              onClick={() => card.href && router.push(card.href)}
            >
              <CardContent className="p-4">
                <div className="flex items-start justify-between mb-3">
                  <div className={`p-2 rounded-xl ${colors.badge}`}>
                    <Icon className={`w-4 h-4 ${colors.text}`} />
                  </div>
                  {card.isEmpty ? (
                    <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                  ) : null}
                </div>
                <div>
                  <p className={`text-2xl font-black tracking-tight tabular-nums ${
                    card.hasWarning ? colors.text : "text-slate-900"
                  }`}>
                    {card.value}
                  </p>
                  <p className="text-[10px] font-semibold text-slate-500 mt-1 uppercase tracking-wider leading-tight">
                    {card.label}
                  </p>
                  <p className={`text-[10px] mt-0.5 ${
                    card.hasWarning
                      ? `${colors.text} font-bold`
                      : "text-slate-400"
                  }`}>
                    {card.subtitle}
                  </p>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Revenue Summary Footer */}
      <div className="px-6 py-3 border-t border-slate-100 bg-slate-50/50 flex items-center justify-between text-[10px]">
        <span className="text-slate-500 font-medium">
          Net Collection: <span className="text-slate-900 font-bold">{formatCurrency(stats.todaysCollection - stats.todaysRefunds)}</span>
          <span className="text-slate-400 mx-1.5">•</span>
          Collected {formatCurrency(stats.todaysCollection)} − Refunds {formatCurrency(stats.todaysRefunds)}
        </span>
        {(stats.damageIncome > 0 || stats.lateFeeIncome > 0) && (
          <span className="text-slate-400">
            Includes: {stats.damageIncome > 0 && `Damage ${formatCurrency(stats.damageIncome)}`}
            {stats.damageIncome > 0 && stats.lateFeeIncome > 0 && " + "}
            {stats.lateFeeIncome > 0 && `Late Fee ${formatCurrency(stats.lateFeeIncome)}`}
          </span>
        )}
      </div>
    </div>
  );
}
