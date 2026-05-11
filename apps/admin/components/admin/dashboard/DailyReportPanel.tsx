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
} from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

interface DailyReportStats {
  todaysBookings: number;
  todaysDelivery: { delivered: number; total: number };
  todaysReturn: { returned: number; total: number };
  todaysRevenue: number;
  damagedOrders: number;
  todaysRefunds: number;
  damageIncome: number;
  lateFeeIncome: number;
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

  const cards = [
    {
      label: "Today's Bookings",
      value: String(stats.todaysBookings),
      subtitle: stats.todaysBookings === 0
        ? "No orders created today"
        : `${stats.todaysBookings} order${stats.todaysBookings !== 1 ? "s" : ""} created`,
      icon: CalendarPlus,
      color: "blue",
      href: "/dashboard/orders?date_filter=today",
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
      href: "/dashboard/orders?status=scheduled&date_filter=today&date_field=start_date",
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
      href: "/dashboard/orders?status=ongoing&date_filter=today&date_field=end_date",
      isEmpty: stats.todaysReturn.total === 0,
      hasWarning: returnPending > 0,
    },
    {
      label: "Today's Revenue",
      value: formatCurrency(stats.todaysRevenue),
      subtitle: "Total cash collected today",
      icon: IndianRupee,
      color: "green",
      href: null, // Revenue is from payments, not directly filterable on orders
      isEmpty: stats.todaysRevenue === 0,
      isCurrency: true,
    },
    {
      label: "Damaged Orders",
      value: String(stats.damagedOrders),
      subtitle: stats.damagedOrders === 0
        ? "No flagged orders"
        : `${stats.damagedOrders} order${stats.damagedOrders !== 1 ? "s" : ""} flagged`,
      icon: ShieldAlert,
      color: "rose",
      href: "/dashboard/orders?status=flagged",
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
      href: "/dashboard/orders?status=cancelled",
      isEmpty: stats.todaysRefunds === 0,
      isCurrency: true,
    },
    {
      label: "Damage Income",
      value: formatCurrency(stats.damageIncome),
      subtitle: stats.damageIncome === 0
        ? "No damage charges collected"
        : "From damage charges",
      icon: Banknote,
      color: "teal",
      href: "/dashboard/orders?status=flagged",
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
      href: "/dashboard/orders?status=late_return",
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
              Today&apos;s Report
            </h3>
            <p className="text-[10px] text-slate-500 font-medium uppercase tracking-wider">
              {new Date().toLocaleDateString("en-IN", { weekday: "long", month: "short", day: "numeric" })}
            </p>
          </div>
        </div>
        <Button
          variant="ghost"
          size="icon"
          className="w-8 h-8 text-slate-400 hover:text-slate-600"
          onClick={onClose}
        >
          <X className="w-4 h-4" />
        </Button>
      </div>

      {/* Cards Grid */}
      <div className="p-5 grid grid-cols-2 lg:grid-cols-4 gap-3">
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
      <div className="px-6 py-3 border-t border-slate-100 bg-slate-50/50 flex items-center justify-between text-xs">
        <span className="text-slate-500 font-medium">
          Net Today: <span className="text-slate-900 font-bold">{formatCurrency(stats.todaysRevenue - stats.todaysRefunds)}</span>
          <span className="text-slate-400 mx-1.5">•</span>
          Revenue {formatCurrency(stats.todaysRevenue)} − Refunds {formatCurrency(stats.todaysRefunds)}
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
