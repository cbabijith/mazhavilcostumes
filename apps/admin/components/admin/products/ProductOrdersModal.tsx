/**
 * ProductOrdersModal Component
 *
 * "View All" popup on the products list: shows every order containing a
 * specific product with infinite-scroll pagination (IntersectionObserver on
 * a sentinel row → fetchNextPage).
 *
 * Only visible to admin/manager (order data); staff sees it too — the orders
 * module is staff-accessible by design.
 *
 * @component
 * @module components/admin/products/ProductOrdersModal
 */

"use client";

import React, { useEffect, useRef } from "react";
import { ClipboardList, Loader2, PackageSearch } from "lucide-react";
import Modal from "@/components/admin/Modal";
import { useProductOrdersInfinite } from "@/hooks";
import { formatCurrency } from "@/lib/shared-utils";

interface ProductOrdersModalProps {
  product: { id: string; name: string } | null;
  onClose: () => void;
}

const STATUS_STYLES: Record<string, string> = {
  completed: "bg-emerald-50 text-emerald-700 border-emerald-200",
  returned: "bg-teal-50 text-teal-700 border-teal-200",
  ongoing: "bg-sky-50 text-sky-700 border-sky-200",
  in_use: "bg-sky-50 text-sky-700 border-sky-200",
  delivered: "bg-indigo-50 text-indigo-700 border-indigo-200",
  partial: "bg-amber-50 text-amber-700 border-amber-200",
  flagged: "bg-orange-50 text-orange-700 border-orange-200",
  scheduled: "bg-slate-100 text-slate-700 border-slate-200",
  pending: "bg-slate-100 text-slate-600 border-slate-200",
  confirmed: "bg-slate-100 text-slate-600 border-slate-200",
  cancelled: "bg-red-50 text-red-600 border-red-200",
};

export default function ProductOrdersModal({ product, onClose }: ProductOrdersModalProps) {
  const { data, isLoading, isFetchingNextPage, hasNextPage, fetchNextPage } =
    useProductOrdersInfinite(product?.id ?? null);

  const sentinelRef = useRef<HTMLDivElement>(null);

  // Infinite scroll: when the sentinel row becomes visible, load the next page
  useEffect(() => {
    const el = sentinelRef.current;
    if (!el || !hasNextPage) return;
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !isFetchingNextPage) {
          fetchNextPage();
        }
      },
      { rootMargin: "120px" },
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, [hasNextPage, isFetchingNextPage, fetchNextPage]);

  const orders = data ? data.pages.flatMap((p: any) => p.data || []) : [];
  const total = data?.pages[0]?.meta?.total ?? 0;

  return (
    <Modal
      open={product !== null}
      onClose={onClose}
      title={product ? `Orders — ${product.name}` : "Orders"}
      maxWidth="max-w-3xl"
    >
      <div className="p-6 space-y-4">
        <div className="flex items-center justify-between">
          <p className="text-xs font-bold text-slate-500 uppercase tracking-widest flex items-center gap-2">
            <ClipboardList className="w-4 h-4" />
            {isLoading ? "Loading orders…" : `${total} order${total !== 1 ? "s" : ""} with this product`}
          </p>
        </div>

        <div className="max-h-[60vh] overflow-y-auto border border-slate-200 rounded-xl divide-y divide-slate-100">
          {isLoading ? (
            <div className="p-10 flex items-center justify-center text-slate-400">
              <Loader2 className="w-5 h-5 animate-spin mr-2" /> Loading orders…
            </div>
          ) : orders.length === 0 ? (
            <div className="p-10 flex flex-col items-center justify-center text-slate-400 gap-2">
              <PackageSearch className="w-8 h-8" />
              <p className="text-sm font-semibold">No orders contain this product yet.</p>
            </div>
          ) : (
            <>
              {orders.map((o: any) => {
                const qty = (o.order_items || []).reduce(
                  (n: number, it: any) => n + (Number(it.quantity) || 0),
                  0,
                );
                return (
                  <div key={o.id} className="px-4 py-3.5 flex items-center justify-between gap-3 bg-white hover:bg-slate-50/60 transition-colors">
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className="text-sm font-bold text-slate-900">{o.invoice_number || o.id.slice(0, 8).toUpperCase()}</span>
                        <span className={`text-[10px] font-black uppercase tracking-wider px-2 py-0.5 rounded-md border ${STATUS_STYLES[o.status] || STATUS_STYLES.scheduled}`}>
                          {o.status?.replace('_', ' ')}
                        </span>
                        <span className="text-[10px] font-bold text-slate-600 bg-slate-100 border border-slate-200 px-1.5 py-0.5 rounded">
                          ×{qty} unit{qty !== 1 ? 's' : ''}
                        </span>
                      </div>
                      <div className="text-xs text-slate-500 mt-1 truncate">
                        {o.customer?.name || "Unknown customer"} · {o.start_date} → {o.end_date}
                      </div>
                    </div>
                    <div className="text-right shrink-0">
                      <div className="text-sm font-black text-slate-900">{formatCurrency(o.total_amount)}</div>
                      <div className={`text-[10px] font-bold uppercase ${o.payment_status === 'paid' ? 'text-emerald-600' : o.payment_status === 'partial' ? 'text-amber-600' : 'text-red-500'}`}>
                        {o.payment_status}
                      </div>
                    </div>
                  </div>
                );
              })}

              {/* Infinite-scroll sentinel */}
              <div ref={sentinelRef} className="p-3 flex items-center justify-center text-xs font-semibold text-slate-400">
                {isFetchingNextPage ? (
                  <><Loader2 className="w-4 h-4 animate-spin mr-2" /> Loading more…</>
                ) : hasNextPage ? (
                  "Scroll for more…"
                ) : (
                  `End of list — ${orders.length} of ${total}`
                )}
              </div>
            </>
          )}
        </div>
      </div>
    </Modal>
  );
}
