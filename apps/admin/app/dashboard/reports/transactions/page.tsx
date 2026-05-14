"use client";

import { useState, useEffect, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { ReportTable } from "@/components/admin/reports/ReportTable";
import { Badge } from "@/components/ui/badge";
import { formatCurrency } from "@/lib/shared-utils";
import { cn } from "@/lib/utils";
import { Loader2, ArrowLeft, ReceiptText } from "lucide-react";
import Link from "next/link";
import { Button } from "@/components/ui/button";

function TransactionListContent() {
  const searchParams = useSearchParams();
  const [data, setData] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fromDate = searchParams.get('from_date');
  const toDate = searchParams.get('to_date');
  const branchId = searchParams.get('branchId');

  useEffect(() => {
    async function fetchTransactions() {
      setLoading(true);
      try {
        const params = new URLSearchParams();
        if (fromDate) params.append('fromDate', fromDate);
        if (toDate) params.append('toDate', toDate);
        if (branchId) params.append('branchId', branchId);

        const res = await fetch(`/api/reports/revenue?${params.toString()}`);
        if (!res.ok) throw new Error('Failed to fetch transactions');
        
        const json = await res.json();
        setData(json.data.details || []);
      } catch (err: any) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    fetchTransactions();
  }, [fromDate, toDate, branchId]);

  const columns = [
    { header: "Date", key: "date", format: "date" as const },
    { header: "Order ID", key: "order_id" },
    { header: "Customer", key: "customer_name" },
    { 
      header: "Type", 
      key: "payment_type",
      render: (type: string) => (
        <Badge variant="outline" className={cn("capitalize font-bold text-[10px] px-2 py-0", 
          type === 'refund' ? "bg-orange-50 text-orange-700 border-orange-200" :
          type === 'advance' ? "bg-blue-50 text-blue-700 border-blue-100" :
          "bg-slate-50 text-slate-600 border-slate-100"
        )}>
          {type}
        </Badge>
      )
    },
    { 
      header: "Mode", 
      key: "payment_mode",
      render: (mode: string) => (
        <Badge variant="outline" className={cn("capitalize font-bold text-[10px] px-2 py-0", 
          mode === 'cash' ? "bg-sky-50 text-sky-700 border-sky-100" :
          mode === 'upi' ? "bg-violet-50 text-violet-700 border-violet-100" :
          mode === 'gpay' ? "bg-amber-50 text-amber-700 border-amber-100" :
          "bg-slate-50 text-slate-700"
        )}>
          {mode}
        </Badge>
      )
    },
    { 
      header: "Amount", 
      key: "amount",
      render: (_: any, row: any) => {
        const isRefund = row?.payment_type === 'refund';
        return (
          <span className={cn("font-bold text-base", isRefund ? "text-rose-600" : "text-slate-900")}>
            {isRefund ? '-' : ''}{formatCurrency(row?.amount || 0)}
          </span>
        );
      }
    },
    { 
      header: "Order Status", 
      key: "status",
      render: (status: string) => {
        const colors: any = {
          completed: "bg-emerald-50 text-emerald-700 border-emerald-100",
          returned: "bg-emerald-50 text-emerald-700 border-emerald-100",
          ongoing: "bg-blue-50 text-blue-700 border-blue-100",
          in_use: "bg-blue-50 text-blue-700 border-blue-100",
          delivered: "bg-blue-50 text-blue-700 border-blue-100",
          scheduled: "bg-slate-50 text-slate-700 border-slate-100",
          pending: "bg-slate-50 text-slate-700 border-slate-100",
          cancelled: "bg-red-50 text-red-700 border-red-100",
        };
        return (
          <Badge variant="outline" className={cn("capitalize font-bold text-[10px] px-2 py-0", colors[status] || "bg-slate-50 text-slate-700")}>
            {status}
          </Badge>
        );
      }
    },
  ];

  const [sortConfig, setSortConfig] = useState<{ key: string; direction: 'asc' | 'desc' } | null>(null);

  const handleSort = (key: string) => {
    let direction: 'asc' | 'desc' = 'asc';
    if (sortConfig && sortConfig.key === key && sortConfig.direction === 'asc') {
      direction = 'desc';
    }
    setSortConfig({ key, direction });
  };

  const sortedData = [...data].sort((a, b) => {
    if (!sortConfig) return 0;
    const { key, direction } = sortConfig;
    if (a[key] < b[key]) return direction === 'asc' ? -1 : 1;
    if (a[key] > b[key]) return direction === 'asc' ? 1 : -1;
    return 0;
  });

  const formatCell = (value: any, format?: string) => {
    if (value === null || value === undefined) return "-";
    if (format === "currency") return formatCurrency(value);
    if (format === "date") return new Date(value).toLocaleDateString();
    return String(value);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link href="/dashboard">
            <Button variant="outline" size="icon" className="rounded-full w-8 h-8">
              <ArrowLeft className="w-4 h-4" />
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-black text-slate-900 flex items-center gap-2">
              <ReceiptText className="w-6 h-6 text-emerald-600" />
              Detailed Transaction List
            </h1>
            <p className="text-sm text-slate-500 font-medium">
              Showing all payments from {fromDate} to {toDate}
            </p>
          </div>
        </div>
      </div>

      <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
        <ReportTable 
          columns={columns} 
          data={sortedData} 
          loading={loading}
          error={error}
          sortConfig={sortConfig}
          onSort={handleSort}
          formatCell={formatCell}
        />
      </div>
    </div>
  );
}

export default function TransactionsPage() {
  return (
    <Suspense fallback={<div className="p-8 text-center"><Loader2 className="w-8 h-8 animate-spin inline-block mr-2" /> Loading...</div>}>
      <TransactionListContent />
    </Suspense>
  );
}
