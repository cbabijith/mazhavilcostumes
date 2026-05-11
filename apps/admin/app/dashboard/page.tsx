/**
 * Dashboard Page
 *
 * Role-aware dashboard:
 *   - ALL roles see the 6-card Operational grid
 *   - Admin sees the additional Revenue & Analytics section
 *
 * Server component — calls dashboardService directly.
 *
 * @module app/dashboard/page
 */

import {
  TrendingUp,
  DollarSign,
  AlertCircle,
  CalendarDays,
  ArrowUpRight,
  ArrowDownRight,
  CheckCircle2,
  Clock,
  Package,
  CalendarPlus,
  Truck,
  PackageCheck,
  Boxes,
  AlertTriangle,
  ClockAlert,
  XCircle,
  BarChart3,
  Zap,
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { dashboardService } from "@/services/dashboardService";
import { getPageAuthUser } from "@/lib/pageAuth";
import Link from "next/link";
import { DashboardFilter } from "@/components/admin/dashboard/DashboardFilter";
import { DashboardLocalFilter } from "@/components/admin/dashboard/DashboardLocalFilter";
import DailyReportToggle from "@/components/admin/dashboard/DailyReportToggle";
import {
  startOfToday, endOfToday,
  startOfYesterday, endOfYesterday,
  startOfWeek, endOfWeek, subWeeks,
  startOfMonth, endOfMonth, subMonths,
  differenceInDays, subDays, startOfDay, endOfDay,
} from "date-fns";

// ─── Icon Map (operational cards) ──────────────────────────────────────────────

const iconMap: Record<string, any> = {
  'calendar-plus': CalendarPlus,
  'truck': Truck,
  'package-check': PackageCheck,
  'boxes': Boxes,
  'alert-triangle': AlertTriangle,
  'clock-alert': ClockAlert,
};

const colorMap: Record<string, { bg: string; text: string; border: string; badge: string }> = {
  blue:    { bg: 'bg-blue-50',    text: 'text-blue-700',    border: 'border-blue-200',    badge: 'bg-blue-100' },
  emerald: { bg: 'bg-emerald-50', text: 'text-emerald-700', border: 'border-emerald-200', badge: 'bg-emerald-100' },
  violet:  { bg: 'bg-violet-50',  text: 'text-violet-700',  border: 'border-violet-200',  badge: 'bg-violet-100' },
  amber:   { bg: 'bg-amber-50',   text: 'text-amber-700',   border: 'border-amber-200',   badge: 'bg-amber-100' },
  rose:    { bg: 'bg-rose-50',    text: 'text-rose-700',    border: 'border-rose-200',    badge: 'bg-rose-100' },
  red:     { bg: 'bg-red-50',     text: 'text-red-700',     border: 'border-red-200',     badge: 'bg-red-100' },
};

// ─── Helpers ───────────────────────────────────────────────────────────────────

const formatCurrency = (amount: number) =>
  new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(amount);

// ─── Page ──────────────────────────────────────────────────────────────────────

export default async function DashboardPage(props: {
  searchParams: Promise<{ [key: string]: string | undefined }>;
}) {
  const searchParams = await props.searchParams;
  const range = searchParams.range || "this_week";

  // Resolve user role
  const authUser = await getPageAuthUser();
  const isAdmin = ['admin', 'super_admin', 'owner'].includes(authUser?.role || '');

  // Date range calculations
  let startDate = startOfMonth(new Date());
  let endDate = new Date();
  let prevStartDate = startOfMonth(subMonths(new Date(), 1));
  let prevEndDate = endOfMonth(subMonths(new Date(), 1));
  const now = new Date();

  switch (range) {
    case "today":
      startDate = startOfToday(); endDate = endOfToday();
      prevStartDate = startOfYesterday(); prevEndDate = endOfYesterday();
      break;
    case "yesterday":
      startDate = startOfYesterday(); endDate = endOfYesterday();
      prevStartDate = startOfDay(subDays(now, 2)); prevEndDate = endOfDay(subDays(now, 2));
      break;
    case "this_week":
      startDate = startOfWeek(now, { weekStartsOn: 1 }); endDate = now;
      prevStartDate = startOfWeek(subWeeks(now, 1), { weekStartsOn: 1 }); prevEndDate = endOfWeek(subWeeks(now, 1), { weekStartsOn: 1 });
      break;
    case "last_week":
      startDate = startOfWeek(subWeeks(now, 1), { weekStartsOn: 1 }); endDate = endOfWeek(subWeeks(now, 1), { weekStartsOn: 1 });
      prevStartDate = startOfWeek(subWeeks(now, 2), { weekStartsOn: 1 }); prevEndDate = endOfWeek(subWeeks(now, 2), { weekStartsOn: 1 });
      break;
    case "this_month":
      startDate = startOfMonth(now); endDate = now;
      prevStartDate = startOfMonth(subMonths(now, 1)); prevEndDate = endOfMonth(subMonths(now, 1));
      break;
    case "last_month":
      startDate = startOfMonth(subMonths(now, 1)); endDate = endOfMonth(subMonths(now, 1));
      prevStartDate = startOfMonth(subMonths(now, 2)); prevEndDate = endOfMonth(subMonths(now, 2));
      break;
    case "custom":
      if (searchParams.from && searchParams.to) {
        startDate = startOfDay(new Date(searchParams.from));
        endDate = endOfDay(new Date(searchParams.to));
        const diff = differenceInDays(endDate, startDate);
        prevEndDate = endOfDay(subDays(startDate, 1));
        prevStartDate = startOfDay(subDays(prevEndDate, diff));
      }
      break;
  }

  const rangeLabels: Record<string, string> = {
    today: "Yesterday", yesterday: "Previous Day",
    this_week: "Last Week", last_week: "Previous Week",
    this_month: "Last Month", last_month: "Previous Month",
    custom: "Previous Period",
  };
  const prevLabel = rangeLabels[range] || "Previous Period";

  // Fetch data
  const catPeriod = (searchParams.cat_period as any) || 'month';
  const roiLimit = searchParams.roi_limit ? parseInt(searchParams.roi_limit) : 3;

  const [operational, metrics] = await Promise.all([
    dashboardService.getOperationalMetrics(),
    isAdmin ? dashboardService.getMetrics(startDate, endDate, prevStartDate, prevEndDate, {
      categoryPeriod: catPeriod,
      roiLimit: roiLimit,
    }) : null,
  ]);

  return (
    <div className="space-y-8 pb-10">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 tracking-tight">Dashboard</h1>
          <p className="text-slate-500 mt-1">
            {new Date().toLocaleDateString('en-IN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
          </p>
        </div>
        {isAdmin && <DailyReportToggle />}
      </div>

      {/* ═══════════════════════════════════════════════════════════════════════
          SECTION 1: Operational Cards (ALL ROLES) — 3×2 Grid
          ═══════════════════════════════════════════════════════════════════════ */}
      <div>
        <h2 className="text-lg font-semibold text-slate-900 mb-4 flex items-center gap-2">
          <CalendarDays className="w-5 h-5 text-slate-400" />
          Today&apos;s Operations
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {operational.cards.map((card) => {
            const Icon = iconMap[card.icon] || Package;
            const colors = colorMap[card.color] || colorMap.blue;
            const hasIssues = card.orderCount > 0 && (card.icon === 'alert-triangle' || card.icon === 'clock-alert');

            return (
              <Link key={card.label} href={card.filterUrl}>
                <Card className={`border shadow-sm hover:shadow-md transition-all cursor-pointer ${hasIssues ? `${colors.bg} ${colors.border}` : 'bg-white border-slate-200 hover:border-slate-300'}`}>
                  <CardContent className="p-5">
                    <div className="flex items-start justify-between">
                      <div className={`p-2.5 rounded-xl ${colors.badge}`}>
                        <Icon className={`w-5 h-5 ${colors.text}`} />
                      </div>
                      {card.orderCount > 0 && (
                        <span className={`text-3xl font-black ${hasIssues ? colors.text : 'text-slate-900'} tabular-nums`}>
                          {card.orderCount}
                        </span>
                      )}
                      {card.orderCount === 0 && (
                        <CheckCircle2 className="w-5 h-5 text-emerald-400" />
                      )}
                    </div>
                    <div className="mt-3">
                      <h3 className={`text-sm font-semibold ${hasIssues ? colors.text : 'text-slate-900'}`}>
                        {card.label}
                      </h3>
                      <p className="text-xs text-slate-500 mt-0.5">
                        {card.orderCount === 0
                          ? 'All clear'
                          : `${card.orderCount} Invoice${card.orderCount !== 1 ? 's' : ''} · ${card.productCount} Product${card.productCount !== 1 ? 's' : ''}`}
                      </p>
                    </div>
                  </CardContent>
                </Card>
              </Link>
            );
          })}
        </div>
      </div>

      {/* ═══════════════════════════════════════════════════════════════════════
          SECTION 2: Admin Revenue & Analytics (ADMIN ONLY)
          ═══════════════════════════════════════════════════════════════════════ */}
      {isAdmin && metrics && (
        <>
          {/* Revenue Overview Row */}
          <div className="space-y-6">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold text-slate-900 flex items-center gap-2">
                <BarChart3 className="w-5 h-5 text-slate-400" />
                Revenue &amp; Analytics
              </h2>
              <DashboardFilter />
            </div>

            {/* Revenue Trends Chart (Full Width) */}
            <Card className="border-0 shadow-sm bg-white overflow-hidden">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <div>
                  <CardTitle className="text-base font-bold">Revenue Trends</CardTitle>
                  <CardDescription>Daily collections for the selected period</CardDescription>
                </div>
                <div className="text-right">
                  <div className="text-2xl font-black text-slate-900 tabular-nums">
                    {formatCurrency(metrics.revenuePacing.current)}
                  </div>
                  <p className="text-[10px] font-bold flex items-center justify-end gap-1 mt-0.5 uppercase tracking-wider">
                    {metrics.revenuePacing.isPositive
                      ? <TrendingUp className="h-3 w-3 text-emerald-500" />
                      : <ArrowDownRight className="h-3 w-3 text-rose-500" />}
                    <span className={metrics.revenuePacing.isPositive ? "text-emerald-600" : "text-rose-600"}>
                      {metrics.revenuePacing.percentageChange}% {metrics.revenuePacing.isPositive ? 'Growth' : 'Decline'}
                    </span>
                  </p>
                </div>
              </CardHeader>
              <CardContent className="h-[200px] flex items-end gap-1.5 pt-6 px-6">
                {metrics.dailyRevenue.map((day, i) => {
                  const maxAmount = Math.max(...metrics.dailyRevenue.map(d => d.amount), 1000);
                  const heightPercent = (day.amount / maxAmount) * 100;
                  return (
                    <div key={i} className="flex-1 bg-slate-50 hover:bg-slate-100 rounded-t-md relative group transition-all duration-300" style={{ height: '100%' }}>
                      <div
                        className={`absolute bottom-0 w-full rounded-t-md transition-all duration-700 ease-out ${day.amount > 0 ? 'bg-emerald-500 shadow-[0_0_15px_rgba(16,185,129,0.2)]' : 'bg-slate-200'}`}
                        style={{ height: `${Math.max(heightPercent, 2)}%` }}
                      />
                      <div className="opacity-0 group-hover:opacity-100 absolute -top-10 left-1/2 -translate-x-1/2 bg-slate-900 text-white text-[10px] py-1.5 px-2.5 rounded shadow-xl pointer-events-none z-10 whitespace-nowrap transition-opacity">
                        <span className="font-bold">{formatCurrency(day.amount)}</span>
                        <span className="block text-slate-400 text-[8px]">{day.date}</span>
                      </div>
                    </div>
                  );
                })}
              </CardContent>
            </Card>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {/* Revenue: Completed */}
              <Card className="border-0 shadow-sm bg-white hover:shadow-md transition-shadow">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium text-slate-600">Completed Revenue</CardTitle>
                  <CheckCircle2 className="h-4 w-4 text-emerald-400" />
                </CardHeader>
                <CardContent>
                  <div className="text-3xl font-bold tracking-tight text-emerald-700">
                    {formatCurrency(metrics.revenueByStatus.completedRevenue)}
                  </div>
                  <p className="text-xs mt-2 text-slate-500">Orders finished in this period</p>
                </CardContent>
              </Card>

              {/* Revenue: Ongoing */}
              <Card className="border-0 shadow-sm bg-white hover:shadow-md transition-shadow">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium text-slate-600">Active Rentals Value</CardTitle>
                  <TrendingUp className="h-4 w-4 text-blue-400" />
                </CardHeader>
                <CardContent>
                  <div className="text-3xl font-bold tracking-tight text-blue-700">
                    {formatCurrency(metrics.revenueByStatus.ongoingRevenue)}
                  </div>
                  <p className="text-xs mt-2 text-slate-500">Contract value of active bookings</p>
                </CardContent>
              </Card>

              {/* Revenue: Scheduled (Advance) */}
              <Card className="border-0 shadow-sm bg-white hover:shadow-md transition-shadow">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium text-slate-600">Advances Collected</CardTitle>
                  <CalendarDays className="h-4 w-4 text-amber-400" />
                </CardHeader>
                <CardContent>
                  <div className="text-3xl font-bold tracking-tight text-amber-700">
                    {formatCurrency(metrics.revenueByStatus.scheduledRevenue)}
                  </div>
                  <p className="text-xs mt-2 text-slate-500">Cash received for future orders</p>
                </CardContent>
              </Card>

              {/* Pending Amount */}
              <Link href="/dashboard/orders?status=returned&status=completed&payment_status=partial&payment_status=pending&payment_status=due">
                <Card className={`border-0 shadow-sm hover:shadow-md transition-shadow cursor-pointer ${metrics.revenueByStatus.pendingAmount > 0 ? 'bg-rose-50/50' : 'bg-white'}`}>
                  <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle className="text-sm font-medium text-slate-600">Pending Collection</CardTitle>
                    <Clock className={`h-4 w-4 ${metrics.revenueByStatus.pendingAmount > 0 ? 'text-rose-400' : 'text-slate-400'}`} />
                  </CardHeader>
                  <CardContent>
                    <div className={`text-3xl font-bold tracking-tight ${metrics.revenueByStatus.pendingAmount > 0 ? 'text-rose-700' : 'text-slate-900'}`}>
                      {formatCurrency(metrics.revenueByStatus.pendingAmount)}
                    </div>
                    <p className="text-xs mt-2 text-slate-500">Returned orders with balance due →</p>
                  </CardContent>
                </Card>
              </Link>
            </div>
          </div>

          {/* Utilization + Cancellations Row */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {/* Inventory Utilization */}
            <Card className="border-0 shadow-sm bg-white">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-slate-600">Inventory Utilization</CardTitle>
                <Package className="h-4 w-4 text-slate-400" />
              </CardHeader>
              <CardContent>
                <div className="text-3xl font-bold tracking-tight text-slate-900">
                  {metrics.utilization.percentage}%
                </div>
                <p className="text-xs mt-2 text-slate-500">
                  {metrics.utilization.rentedOut} of {metrics.utilization.totalProducts} products rented
                </p>
              </CardContent>
            </Card>

            {/* Cancellations */}
            <Card className={`border-0 shadow-sm ${metrics.cancellationStats.currentCount > 0 ? 'bg-rose-50/50' : 'bg-white'}`}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-slate-600">Cancellations</CardTitle>
                <XCircle className={`h-4 w-4 ${metrics.cancellationStats.currentCount > 0 ? 'text-rose-500' : 'text-slate-400'}`} />
              </CardHeader>
              <CardContent>
                <div className={`text-3xl font-bold tracking-tight ${metrics.cancellationStats.currentCount > 0 ? 'text-rose-700' : 'text-slate-900'}`}>
                  {metrics.cancellationStats.currentCount}
                </div>
                <p className="text-xs flex items-center gap-1 mt-2">
                  {metrics.cancellationStats.isPositive
                    ? <ArrowDownRight className="h-3 w-3 text-emerald-500" />
                    : <ArrowUpRight className="h-3 w-3 text-rose-500" />}
                  <span className={metrics.cancellationStats.isPositive ? "text-emerald-600 font-medium" : "text-rose-600 font-medium"}>
                    {metrics.cancellationStats.percentageChange}%
                  </span>
                  <span className="text-slate-500">vs {prevLabel.toLowerCase()}</span>
                </p>
              </CardContent>
            </Card>

            {/* Action Required */}
            <Card className={`border-0 shadow-sm ${metrics.actionRequired.totalIssues > 0 ? 'bg-rose-50/50' : 'bg-white'}`}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-slate-600">Action Required</CardTitle>
                <AlertCircle className={`h-4 w-4 ${metrics.actionRequired.totalIssues > 0 ? 'text-rose-500' : 'text-slate-400'}`} />
              </CardHeader>
              <CardContent>
                <div className={`text-3xl font-bold tracking-tight ${metrics.actionRequired.totalIssues > 0 ? 'text-rose-700' : 'text-slate-900'}`}>
                  {metrics.actionRequired.totalIssues} Issues
                </div>
                <p className={`text-xs mt-2 ${metrics.actionRequired.totalIssues > 0 ? 'text-rose-600 font-medium' : 'text-slate-500'}`}>
                  {metrics.actionRequired.overdueCount} overdue orders
                </p>
              </CardContent>
            </Card>
          </div>

          {/* Booking Velocity + Category Revenue */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <Card className="lg:col-span-2 border-0 shadow-sm bg-white">
              <CardHeader>
                <CardTitle>Upcoming Booking Velocity</CardTitle>
                <CardDescription>Scheduled pickups for the next 15 days</CardDescription>
              </CardHeader>
              <CardContent className="h-[250px] flex items-end gap-2 pt-4">
                {metrics.bookingVelocity.map((day, i) => {
                  const maxCount = Math.max(...metrics.bookingVelocity.map(d => d.count), 5);
                  const heightPercent = (day.count / maxCount) * 100;
                  return (
                    <div key={i} className="flex-1 bg-slate-100 hover:bg-slate-200 rounded-t-sm relative group transition-colors" style={{ height: '100%' }}>
                      <div
                        className={`absolute bottom-0 w-full rounded-t-sm transition-all duration-500 ${heightPercent > 75 ? 'bg-amber-400' : 'bg-slate-800'}`}
                        style={{ height: `${Math.max(heightPercent, 2)}%` }}
                      />
                      <div className="opacity-0 group-hover:opacity-100 absolute -top-8 left-1/2 -translate-x-1/2 bg-slate-900 text-white text-[10px] py-1 px-2 rounded pointer-events-none z-10 whitespace-nowrap">
                        {day.count} pickups on {day.date}
                      </div>
                    </div>
                  );
                })}
              </CardContent>
            </Card>

            <Card className="border-0 shadow-sm bg-white">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <div>
                  <CardTitle className="text-base font-bold text-slate-900">Category Revenue</CardTitle>
                  <CardDescription className="text-[10px]">Selected period distribution</CardDescription>
                </div>
                <DashboardLocalFilter 
                  paramName="cat_period"
                  defaultValue="month"
                  options={[
                    { label: "This Period", value: "month" },
                    { label: "Last 12m", value: "year" },
                    { label: "All Time", value: "all" },
                  ]}
                />
              </CardHeader>
              <CardContent className="pt-6">
                {metrics.categoryRevenue.length > 0 ? (
                  <div className="space-y-6">
                    {metrics.categoryRevenue.map((cat, i) => {
                      const colors = ['bg-slate-800', 'bg-amber-400', 'bg-slate-300', 'bg-emerald-400', 'bg-violet-400'];
                      return (
                        <div key={cat.name} className="space-y-2">
                          <div className="flex justify-between text-sm">
                            <span className="font-medium text-slate-700">{cat.name}</span>
                            <span className="text-slate-500 font-medium">{cat.percentage}%</span>
                          </div>
                          <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
                            <div className={`h-full ${colors[i % colors.length]} rounded-full`} style={{ width: `${cat.percentage}%` }} />
                          </div>
                        </div>
                      );
                    })}
                  </div>
                ) : (
                  <div className="py-8 text-center text-slate-500 text-sm">No category revenue data for this period.</div>
                )}
              </CardContent>
            </Card>
          </div>

          {/* Top Performers + Dead Stock + Bottlenecks + Priority Cleaning */}
          <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
            <Card className="border-0 shadow-sm bg-white overflow-hidden flex flex-col">
              <CardHeader className="border-b border-slate-50 bg-slate-50/50 flex flex-row items-center justify-between space-y-0 py-3 px-6">
                <div>
                  <CardTitle className="text-base font-bold text-slate-900">Inventory ROI</CardTitle>
                  <CardDescription className="text-[10px]">Top {roiLimit} revenue contributors</CardDescription>
                </div>
                <DashboardLocalFilter 
                  paramName="roi_limit"
                  defaultValue="3"
                  options={[
                    { label: "Top 3", value: "3" },
                    { label: "Top 5", value: "5" },
                    { label: "Top 10", value: "10" },
                  ]}
                />
              </CardHeader>
              <div className="flex-1 p-0 flex flex-col">
                {metrics.topPerformers.length > 0 ? (
                  <table className="w-full text-sm text-left">
                    <thead className="bg-white text-slate-400 text-[10px] uppercase tracking-wider">
                      <tr>
                        <th className="px-6 py-3 font-semibold">Product</th>
                        <th className="px-6 py-3 font-semibold text-right">Rentals</th>
                        <th className="px-6 py-3 font-semibold text-right">Revenue</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-50">
                      {metrics.topPerformers.map((item) => (
                        <tr key={item.id} className="hover:bg-slate-50/50 transition-colors">
                          <td className="px-6 py-3.5 font-medium text-slate-900">{item.name}</td>
                          <td className="px-6 py-3.5 text-right text-slate-600">{item.rentals}</td>
                          <td className="px-6 py-3.5 text-right text-emerald-600 font-semibold">{formatCurrency(item.revenue)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                ) : (
                  <div className="p-8 text-center text-slate-500 text-sm">No rental data for this period.</div>
                )}

                <div className="bg-slate-50/50 px-6 py-2 text-[10px] font-semibold text-slate-400 uppercase tracking-wider border-y border-slate-100">
                  Dead Stock (90+ Days)
                </div>
                {metrics.deadStock.length > 0 ? (
                  <table className="w-full text-sm text-left">
                    <tbody className="divide-y divide-slate-50">
                      {metrics.deadStock.map((item) => (
                        <tr key={`dead-${item.id}`} className="hover:bg-slate-50/50 transition-colors">
                          <td className="px-6 py-3.5 font-medium text-slate-900">{item.name}</td>
                          <td className="px-6 py-3.5 text-right text-rose-600 font-medium">{item.daysIdle} days idle</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                ) : (
                  <div className="p-4 text-center text-sm text-slate-400">No dead stock detected.</div>
                )}
              </div>
            </Card>

            <Card className="border-0 shadow-sm bg-white">
              <CardHeader>
                <CardTitle>Operational Bottlenecks</CardTitle>
                <CardDescription>Items stuck in process preventing revenue</CardDescription>
              </CardHeader>
              <CardContent className="pt-4">
                {metrics.bottlenecks.length > 0 ? (
                  <div className="space-y-3">
                    {metrics.bottlenecks.map((item) => (
                      <div key={item.id} className="flex items-start gap-3 p-3.5 rounded-xl border border-slate-100 bg-slate-50/50 hover:bg-slate-50 transition-colors">
                        <div className={`p-2 rounded-lg shrink-0 ${item.severity === 'high' ? 'bg-rose-100 text-rose-600' : 'bg-amber-100 text-amber-600'}`}>
                          {item.type === 'cleaning' ? <Package className="w-4 h-4" /> : item.type === 'approval' ? <CheckCircle2 className="w-4 h-4" /> : <Clock className="w-4 h-4" />}
                        </div>
                        <div className="flex-1">
                          <p className="text-sm font-medium text-slate-900 leading-snug">{item.message}</p>
                          <div className="mt-2.5 flex gap-2">
                            <Button size="sm" variant="outline" className="h-6 text-[10px] px-2.5">
                              <Link href={`/dashboard/orders/${item.id}`}>View Order</Link>
                            </Button>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="py-8 text-center text-emerald-600 text-sm font-medium">
                    No active bottlenecks! Everything is running smoothly.
                  </div>
                )}
              </CardContent>
            </Card>

          </div>
        </>
      )}
    </div>
  );
}
