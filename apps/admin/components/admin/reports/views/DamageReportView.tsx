/**
 * Damage / Flagged Report View (R14)
 *
 * Three sections:
 *  1. Totals — damage fee charged / collected / pending + units + live flagged state
 *  2. Flagged orders RIGHT NOW (live snapshot, ignores the date filter) — what's
 *     stuck pending damage assessment, with reasons and pending-decision counts
 *  3. Damaged products (period) — which products keep getting damaged and why,
 *     plus the per-order item detail rows (sortable/exportable summary table)
 *
 * @component
 * @module components/admin/reports/views/DamageReportView
 */

"use client";

import Link from "next/link";
import {
  ShieldAlert,
  AlertTriangle,
  PackageX,
  IndianRupee,
  CheckCircle2,
  Clock,
  ClipboardCheck,
} from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ReportTable } from "../ReportTable";
import { formatCurrency } from "@/lib/shared-utils";

interface DamageReportViewProps {
  data: any[];
  reportSummary: any;
  loading: boolean;
  error: string | null;
  sortConfig: any;
  onSort: (key: string) => void;
  formatCell: (value: any, format?: string) => any;
}

const PAYMENT_STYLES: Record<string, string> = {
  paid: "bg-emerald-50 text-emerald-700 border-emerald-200",
  partial: "bg-amber-50 text-amber-700 border-amber-200",
  pending: "bg-red-50 text-red-600 border-red-200",
};

export function DamageReportView({
  data,
  reportSummary,
  loading,
  error,
  sortConfig,
  onSort,
  formatCell,
}: DamageReportViewProps) {
  if (loading) {
    return <div className="p-8 text-center text-slate-500 font-medium">Loading damage report…</div>;
  }
  if (error) {
    return <div className="p-8 text-center text-red-600 font-medium">{error}</div>;
  }

  const totals = reportSummary?.totals || {};
  const flagged = reportSummary?.flagged_orders || [];
  const products = reportSummary?.damaged_products || [];
  const period = reportSummary?.period || {};

  const itemColumns = [
    { header: "Invoice", key: "invoice_number" },
    { header: "Customer", key: "customer_name" },
    { header: "Product", key: "product_name" },
    { header: "Damaged Units", key: "damaged_units", format: "number" as const },
    { header: "Returned / Ordered", key: "returned_units" },
    { header: "Damage Fee", key: "damage_fee", format: "currency" as const },
    { header: "Reason", key: "reason" },
    { header: "Payment", key: "payment_status" },
    { header: "Order Date", key: "created_at", format: "date" as const },
    { header: "Status", key: "order_status" },
  ];

  return (
    <div className="space-y-8">
      {/* 1. Damage money + volume */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-orange-500">
          <CardContent className="p-5">
            <p className="text-[10px] font-bold text-orange-600/70 uppercase tracking-widest mb-1 flex items-center gap-1.5">
              <IndianRupee className="w-3 h-3" /> Damage Fees Charged
            </p>
            <p className="text-2xl font-black text-slate-900">{formatCurrency(totals.damage_fees_charged || 0)}</p>
            <p className="text-[10px] text-slate-500 mt-1 font-medium">
              {totals.damaged_orders || 0} damaged order{(totals.damaged_orders || 0) !== 1 ? 's' : ''} · {totals.damaged_units || 0} units
            </p>
          </CardContent>
        </Card>
        <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-emerald-500">
          <CardContent className="p-5">
            <p className="text-[10px] font-bold text-emerald-600/70 uppercase tracking-widest mb-1 flex items-center gap-1.5">
              <CheckCircle2 className="w-3 h-3" /> Collected (Paid Orders)
            </p>
            <p className="text-2xl font-black text-slate-900">{formatCurrency(totals.damage_fees_collected || 0)}</p>
            <p className="text-[10px] text-slate-500 mt-1 font-medium">Damage fees on fully-paid orders</p>
          </CardContent>
        </Card>
        <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-red-500">
          <CardContent className="p-5">
            <p className="text-[10px] font-bold text-red-600/70 uppercase tracking-widest mb-1 flex items-center gap-1.5">
              <Clock className="w-3 h-3" /> Pending Collection
            </p>
            <p className="text-2xl font-black text-slate-900">{formatCurrency(totals.damage_fees_pending || 0)}</p>
            <p className="text-[10px] text-slate-500 mt-1 font-medium">On orders not fully paid yet</p>
          </CardContent>
        </Card>
        <Card className="shadow-sm border-slate-200 bg-white border-l-4 border-l-purple-500">
          <CardContent className="p-5">
            <p className="text-[10px] font-bold text-purple-600/70 uppercase tracking-widest mb-1 flex items-center gap-1.5">
              <ShieldAlert className="w-3 h-3" /> Flagged Right Now
            </p>
            <p className="text-2xl font-black text-slate-900">{totals.flagged_orders_now || 0}</p>
            <p className="text-[10px] text-slate-500 mt-1 font-medium">
              {totals.pending_assessments_now || 0} damaged unit{(totals.pending_assessments_now || 0) !== 1 ? 's' : ''} awaiting reuse/write-off decision
            </p>
          </CardContent>
        </Card>
      </div>

      {/* 2. Flagged orders — action needed (live, ignores date filter) */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider flex items-center gap-2">
            <AlertTriangle className="w-4 h-4 text-orange-500" /> Flagged Orders — Action Needed
          </h3>
          <span className="text-[10px] font-semibold text-slate-400 uppercase tracking-wider">Live snapshot (not date-filtered)</span>
        </div>
        {flagged.length === 0 ? (
          <div className="p-6 bg-emerald-50 border border-emerald-200 rounded-xl text-sm font-semibold text-emerald-700 flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4" /> No flagged orders — all damage assessments are resolved.
          </div>
        ) : (
          <div className="border border-orange-200 rounded-xl overflow-hidden divide-y divide-orange-100">
            {flagged.map((f: any) => (
              <div key={f.order_id} className="p-4 bg-white hover:bg-orange-50/40 transition-colors">
                <div className="flex flex-wrap items-center gap-2">
                  <Link href={`/dashboard/orders/${f.order_id}`} className="text-sm font-bold text-slate-900 hover:text-primary underline decoration-slate-300">
                    {f.invoice_number || 'Order'}
                  </Link>
                  <span className="text-sm text-slate-600">{f.customer_name}</span>
                  {f.pending_assessments > 0 ? (
                    <Badge variant="secondary" className="text-[10px] font-black uppercase bg-amber-100 text-amber-800 border border-amber-300">
                      <ClipboardCheck className="w-3 h-3 mr-1" /> {f.pending_assessments} to assess
                    </Badge>
                  ) : f.assessments_missing ? (
                    <Badge variant="secondary" className="text-[10px] font-black uppercase bg-orange-100 text-orange-800 border border-orange-300">
                      <AlertTriangle className="w-3 h-3 mr-1" /> assessments missing — open order → Create Damage Assessments
                    </Badge>
                  ) : (
                    <Badge variant="secondary" className="text-[10px] font-black uppercase bg-sky-50 text-sky-700 border border-sky-200">
                      assessed — awaiting close
                    </Badge>
                  )}
                  <span className={`text-[10px] font-black uppercase px-2 py-0.5 rounded-md border ${PAYMENT_STYLES[f.payment_status] || PAYMENT_STYLES.pending}`}>
                    {f.payment_status}
                  </span>
                  <span className="ml-auto text-xs font-bold text-slate-700">
                    Damage {formatCurrency(f.damage_fees)}
                    {f.balance_due > 0 && <span className="text-red-600"> · Due {formatCurrency(f.balance_due)}</span>}
                  </span>
                </div>
                {f.products_summary && (
                  <p className="text-xs text-slate-500 mt-1.5 leading-relaxed">
                    <span className="font-bold text-slate-600">Damaged:</span> {f.products_summary}
                  </p>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* 3. Damaged products — what keeps getting damaged and why */}
      <div>
        <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider mb-3 flex items-center gap-2">
          <PackageX className="w-4 h-4 text-red-500" /> Damaged Products ({period.from} → {period.to})
        </h3>
        {products.length === 0 ? (
          <div className="p-6 bg-slate-50 border border-slate-200 rounded-xl text-sm font-semibold text-slate-500">
            No damaged items in this period.
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            {products.map((p: any) => (
              <div key={p.product_id} className="bg-white border border-slate-200 rounded-xl p-4">
                <div className="flex items-center justify-between gap-2">
                  <p className="text-sm font-bold text-slate-900">{p.product_name}</p>
                  <span className="text-xs font-black text-red-600">{formatCurrency(p.damage_fees)}</span>
                </div>
                <div className="flex gap-2 mt-1.5 text-[10px] font-bold uppercase tracking-wider">
                  <span className="text-slate-600 bg-slate-100 px-2 py-0.5 rounded border border-slate-200">
                    {p.orders_count} order{p.orders_count !== 1 ? 's' : ''}
                  </span>
                  <span className="text-red-600 bg-red-50 px-2 py-0.5 rounded border border-red-200">
                    {p.units_damaged} unit{p.units_damaged !== 1 ? 's' : ''} damaged
                  </span>
                </div>
                {p.reasons.length > 0 && (
                  <ul className="mt-2.5 space-y-1">
                    {p.reasons.map((r: string, i: number) => (
                      <li key={i} className="text-xs text-slate-600 flex items-start gap-1.5">
                        <span className="text-orange-400 mt-0.5">—</span> {r}
                      </li>
                    ))}
                  </ul>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* 4. Item-level detail (sortable + exportable) */}
      <div>
        <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider mb-3">
          Damage Detail by Order Item
        </h3>
        <ReportTable
          columns={itemColumns}
          data={data}
          loading={loading}
          error={error}
          sortConfig={sortConfig}
          onSort={onSort}
          formatCell={formatCell}
        />
      </div>
    </div>
  );
}
