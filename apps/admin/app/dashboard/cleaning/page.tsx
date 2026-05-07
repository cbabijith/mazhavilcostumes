/**
 * Cleaning Queue Page
 *
 * Dedicated page for managing the cleaning lifecycle of returned products.
 *
 * @module app/dashboard/cleaning/page
 */

import { getPageAuthUser } from "@/lib/pageAuth";
import { CleaningQueue } from "@/components/admin/dashboard/CleaningQueue";
import { Sparkles, Info, Package, Link as LinkIcon } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { dashboardService } from "@/services/dashboardService";
import { Button } from "@/components/ui/button";
import Link from "next/link";

export default async function CleaningPage() {
  const authUser = await getPageAuthUser();

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
            Track products currently in their cleaning/buffer period before becoming available for the next rental.
          </p>
        </div>
      </div>

      {/* Info Card */}
      <Card className="bg-blue-50/50 border-blue-100 shadow-none">
        <CardContent className="py-3 px-4 flex items-start gap-3">
          <Info className="w-5 h-5 text-blue-600 shrink-0 mt-0.5" />
          <div className="text-sm text-blue-800">
            <p className="font-semibold">Workflow Information:</p>
            <p className="mt-1 opacity-90">
              All returned items with buffer requirements appear here automatically. Use the <span className="font-bold text-amber-700">Prior Cleaning</span> filter to prioritize items needed for urgent upcoming bookings.
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Main Content — Full Width Table */}
      <div className="w-full">
        <CleaningQueue branchId={authUser?.branch_id || ''} />
      </div>
    </div>
  );
}
