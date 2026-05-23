/**
 * Dashboard Loading Skeleton
 *
 * Renders instantly on the client side when the Dashboard route is clicked.
 * Provides a highly aesthetic shimmering placeholder matching the dashboard's exact layout.
 *
 * @module app/dashboard/loading
 */

import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { CalendarDays, BarChart3 } from "lucide-react";

export default function DashboardLoading() {
  return (
    <div className="space-y-8 pb-10 select-none">
      {/* 1. Header Skeleton */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="space-y-2">
          {/* Dashboard Title Skeleton */}
          <div className="h-9 w-48 bg-slate-200 animate-pulse rounded-lg" />
          {/* Subtitle / Date Skeleton */}
          <div className="h-4 w-64 bg-slate-100 animate-pulse rounded-md" />
        </div>
        {/* Toggle Button / Switches Skeletons */}
        <div className="h-10 w-36 bg-slate-100 animate-pulse rounded-lg" />
      </div>

      {/* 2. Today's Operations Section Skeleton */}
      <div>
        <h2 className="text-lg font-semibold text-slate-900 mb-4 flex items-center gap-2">
          <CalendarDays className="w-5 h-5 text-slate-300" />
          Today&apos;s Operations
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 7 }).map((_, idx) => (
            <Card key={idx} className="border border-slate-200 shadow-sm bg-white">
              <CardContent className="p-5 space-y-4">
                <div className="flex items-start justify-between">
                  {/* Icon Badge Skeleton */}
                  <div className="p-5 rounded-xl bg-slate-100 animate-pulse w-10 h-10 shrink-0" />
                  {/* Large Number Count Skeleton */}
                  <div className="h-8 w-16 bg-slate-200 animate-pulse rounded-lg" />
                </div>
                <div className="space-y-2 pt-1">
                  {/* Card Title Label Skeleton */}
                  <div className="h-4 w-32 bg-slate-200 animate-pulse rounded-md" />
                  {/* Card Sub-text Skeleton */}
                  <div className="h-3 w-40 bg-slate-100 animate-pulse rounded-md" />
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* 3. Revenue & Analytics Section Skeleton */}
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <h2 className="text-lg font-semibold text-slate-900 flex items-center gap-2">
            <BarChart3 className="w-5 h-5 text-slate-300" />
            Revenue &amp; Analytics
          </h2>
          {/* Branch Switcher & Date Filters Skeletons */}
          <div className="flex gap-3">
            <div className="h-9 w-32 bg-slate-100 animate-pulse rounded-lg" />
            <div className="h-9 w-36 bg-slate-100 animate-pulse rounded-lg" />
          </div>
        </div>

        {/* Sales Pacing & Cash Collection Large Cards Skeletons */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {Array.from({ length: 2 }).map((_, idx) => (
            <Card key={idx} className="border border-slate-200 shadow-sm bg-white">
              <CardHeader className="flex flex-row items-center justify-between pb-2 space-y-0">
                <div className="space-y-2">
                  <div className="h-4 w-28 bg-slate-200 animate-pulse rounded-md" />
                  <div className="h-3 w-40 bg-slate-100 animate-pulse rounded-md" />
                </div>
                <div className="text-right space-y-1.5">
                  <div className="h-7 w-28 bg-slate-200 animate-pulse rounded-lg" />
                  <div className="h-3 w-20 bg-slate-100 animate-pulse rounded-md ml-auto" />
                </div>
              </CardHeader>
              <CardContent className="pt-2">
                <div className="h-4 w-5/6 bg-slate-100 animate-pulse rounded-md" />
                {idx === 1 && (
                  <div className="flex gap-3 mt-4 pt-1">
                    <div className="h-8 w-16 bg-slate-100 animate-pulse rounded-lg" />
                    <div className="h-8 w-16 bg-slate-100 animate-pulse rounded-lg" />
                    <div className="h-8 w-16 bg-slate-100 animate-pulse rounded-lg" />
                    <div className="h-8 w-16 bg-slate-100 animate-pulse rounded-lg" />
                  </div>
                )}
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Collection Trends Chart Skeleton */}
        <Card className="border border-slate-200 shadow-sm bg-white overflow-hidden">
          <CardHeader className="pb-2 space-y-2">
            <div className="h-4 w-32 bg-slate-200 animate-pulse rounded-md" />
            <div className="h-3 w-44 bg-slate-100 animate-pulse rounded-md" />
          </CardHeader>
          <CardContent className="h-[200px] flex items-end gap-2 pt-6 px-6">
            {Array.from({ length: 15 }).map((_, idx) => (
              <div 
                key={idx} 
                className="flex-1 bg-slate-100 animate-pulse rounded-t-md" 
                style={{ 
                  height: `${[30, 45, 20, 60, 80, 50, 40, 95, 70, 35, 55, 65, 45, 75, 50][idx]}%` 
                }} 
              />
            ))}
          </CardContent>
        </Card>

        {/* Overview Stats (4 Cards Grid) Skeletons */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {Array.from({ length: 4 }).map((_, idx) => (
            <Card key={idx} className="border border-slate-200 shadow-sm bg-white">
              <CardHeader className="flex flex-row items-center justify-between pb-2 space-y-0">
                <div className="h-4 w-24 bg-slate-200 animate-pulse rounded-md" />
                <div className="h-4 w-4 bg-slate-200 animate-pulse rounded-full" />
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="h-8 w-24 bg-slate-200 animate-pulse rounded-lg" />
                <div className="h-3 w-40 bg-slate-100 animate-pulse rounded-md" />
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
}
