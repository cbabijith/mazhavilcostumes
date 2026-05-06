/**
 * Cleaning Queue Page
 *
 * Dedicated page for managing the cleaning lifecycle of returned products.
 *
 * @module app/dashboard/cleaning/page
 */

import { getPageAuthUser } from "@/lib/pageAuth";
import { CleaningQueue } from "@/components/admin/dashboard/CleaningQueue";
import { Sparkles, Info, Zap, Package, Link as LinkIcon } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { dashboardService } from "@/services/dashboardService";
import { Button } from "@/components/ui/button";
import Link from "next/link";

export default async function CleaningPage() {
  const authUser = await getPageAuthUser();
  const metrics = await dashboardService.getOperationalMetrics();

  return (
    <div className="space-y-6 pb-10">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 tracking-tight flex items-center gap-3">
            <Sparkles className="w-8 h-8 text-blue-600" />
            Cleaning Queue
          </h1>
          <p className="text-slate-500 mt-1">
            Manage products that have been returned and need cleaning/prep before the next rental.
          </p>
        </div>
      </div>

      {/* Info Card */}
      <Card className="bg-blue-50/50 border-blue-100 shadow-none">
        <CardContent className="py-3 px-4 flex items-start gap-3">
          <Info className="w-5 h-5 text-blue-600 shrink-0 mt-0.5" />
          <div className="text-sm text-blue-800">
            <p className="font-semibold">How it works:</p>
            <p className="mt-1 opacity-90">
              This page tracks items that require **Priority Cleaning** because they are needed for an upcoming <span className="font-bold text-amber-700">Skip Gap</span> booking starting very soon.
            </p>
            <div className="mt-2 grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="bg-white/50 p-2 rounded border border-blue-100">
                <p className="font-bold text-xs text-blue-900">Priority Notifications:</p>
                <p className="text-[11px] opacity-80 text-blue-800">Only items needed for urgent rentals appear here. This keeps your queue focused on what matters most.</p>
              </div>
              <div className="bg-white/50 p-2 rounded border border-blue-100">
                <p className="font-bold text-xs text-blue-900">Marking as Done:</p>
                <p className="text-[11px] opacity-80 text-blue-800">Clicking "Done" clears the item from this list. It does not block inventory, but serves as a workflow tracker for your staff.</p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Queue (2/3 width) */}
        <div className="lg:col-span-2">
          <CleaningQueue branchId={authUser?.branch_id || ''} />
        </div>

        {/* Sidebar Alerts (1/3 width) */}
        <div className="space-y-6">
          <Card className="border-0 shadow-sm bg-white overflow-hidden">
            <CardHeader className="bg-amber-50/50 border-b border-amber-50 py-4">
              <div className="flex items-center gap-2">
                <Zap className="w-4 h-4 text-amber-500 fill-amber-500" />
                <CardTitle className="text-base font-bold text-slate-900">
                  Priority Required
                </CardTitle>
              </div>
              <CardDescription className="text-[10px]">Upcoming Skip Gap orders needing items</CardDescription>
            </CardHeader>
            <CardContent className="pt-4">
              {(metrics?.priorityCleaning || []).length > 0 ? (
                <div className="space-y-4">
                  {metrics?.priorityCleaning.map((order) => (
                    <div key={order.id} className="p-3 rounded-xl border border-amber-100 bg-amber-50/20">
                      <div className="flex justify-between items-start mb-2">
                        <span className="text-xs font-bold text-slate-900">Order #{order.id.substring(0, 8)}</span>
                        <span className="text-[10px] font-medium bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">
                          {new Date(order.startDate).toLocaleDateString('en-IN', { month: 'short', day: 'numeric' })}
                        </span>
                      </div>
                      <div className="space-y-1 mb-3">
                        {order.products.map((p, idx) => (
                          <div key={idx} className="text-[10px] text-slate-500 flex justify-between">
                            <span>• {p.name}</span>
                            <span className="font-bold">× {p.quantity}</span>
                          </div>
                        ))}
                      </div>
                      <Button size="sm" variant="outline" className="h-7 w-full text-[10px] bg-white border-amber-200 text-amber-700 hover:bg-amber-50" asChild>
                        <Link href={`/dashboard/orders/${order.id}`}>Manage Order</Link>
                      </Button>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="py-8 text-center">
                  <div className="inline-flex items-center justify-center w-10 h-10 rounded-full bg-slate-50 mb-2">
                    <Zap className="w-5 h-5 text-slate-200" />
                  </div>
                  <p className="text-xs text-slate-400">No urgent priority cleaning needed.</p>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
