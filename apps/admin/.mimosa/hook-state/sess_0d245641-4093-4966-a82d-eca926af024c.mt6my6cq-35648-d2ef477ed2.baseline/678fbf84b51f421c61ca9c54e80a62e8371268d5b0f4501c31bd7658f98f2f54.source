/**
 * Daily Report Toggle
 *
 * Client component that renders the "Today's Report" button (admin-only)
 * and toggles the DailyReportPanel on click.
 *
 * @component
 * @module components/admin/dashboard/DailyReportToggle
 */

"use client";

import { useState } from "react";
import { BarChart4 } from "lucide-react";
import { Button } from "@/components/ui/button";
import DailyReportPanel from "./DailyReportPanel";

export default function DailyReportToggle() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <Button
        variant={isOpen ? "default" : "outline"}
        size="sm"
        className={`gap-2 transition-all ${
          isOpen
            ? "bg-slate-900 text-white hover:bg-slate-800"
            : "border-slate-200 text-slate-600 hover:text-slate-900 bg-white hover:bg-slate-50"
        }`}
        onClick={() => setIsOpen(!isOpen)}
      >
        <BarChart4 className="w-4 h-4" />
        Today&apos;s Report
      </Button>

      {isOpen && (
        <div className="col-span-full mt-2 animate-in fade-in slide-in-from-top-2 duration-300">
          <DailyReportPanel onClose={() => setIsOpen(false)} />
        </div>
      )}
    </>
  );
}
