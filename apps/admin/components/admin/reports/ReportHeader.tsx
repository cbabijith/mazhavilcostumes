"use client";

import { ArrowLeft, Download, FileSpreadsheet, FileText } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useRouter } from "next/navigation";
import { ReportMeta } from "@/domain";
import { ICONS, CATEGORY_COLORS } from "@/lib/reports-shared";

interface ReportHeaderProps {
  meta: ReportMeta;
  onExportExcel: () => void;
  onExportPDF: () => void;
  hasData: boolean;
  extraActions?: React.ReactNode;
}

export function ReportHeader({ meta, onExportExcel, onExportPDF, hasData, extraActions }: ReportHeaderProps) {
  const router = useRouter();
  const Icon = (ICONS as any)[meta.icon] || Download;

  return (
    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <div className="flex items-center gap-3">
        <Button 
          variant="outline" 
          size="icon" 
          onClick={() => router.push("/dashboard/reports")} 
          className="w-9 h-9 border-slate-200 text-slate-500 hover:text-slate-900 bg-white"
        >
          <ArrowLeft className="h-4 w-4" />
        </Button>
        <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${(CATEGORY_COLORS as any)[meta.category]}`}>
          <Icon className="w-5 h-5" />
        </div>
        <div>
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">{meta.name}</h1>
          <p className="text-xs text-slate-500">{meta.description}</p>
        </div>
      </div>
      
      <div className="flex items-center gap-2">
        {extraActions}
        <div className="h-10 w-px bg-slate-200 mx-2 hidden sm:block" />
        <Button 
          variant="outline" 
          onClick={onExportExcel} 
          disabled={!hasData}
          className="border-slate-200 text-slate-600 hover:bg-slate-50 h-10 px-4 rounded-xl font-medium"
        >
          <FileSpreadsheet className="w-4 h-4 mr-2 text-emerald-600" />
          Excel
        </Button>
        <Button 
          variant="outline" 
          onClick={onExportPDF} 
          disabled={!hasData}
          className="border-slate-200 text-slate-600 hover:bg-slate-50 h-10 px-4 rounded-xl font-medium"
        >
          <FileText className="w-4 h-4 mr-2 text-red-600" />
          PDF
        </Button>
      </div>
    </div>
  );
}
