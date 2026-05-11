/**
 * OrderItemsPanel Component
 *
 * A slide-over panel on the right side of the orders table that shows
 * the items of a selected order. Triggered by clicking the "Items" cell
 * in a table row.
 *
 * @component
 * @module components/admin/orders/OrderItemsPanel
 */

"use client";

import React from "react";
import { X, Package, Calendar, User } from "lucide-react";
import { format } from "date-fns";
import { Button } from "@/components/ui/button";
import { formatCurrency } from "@/lib/shared-utils";
import { type OrderWithRelations } from "@/domain";

interface OrderItemsPanelProps {
  order: OrderWithRelations | null;
  onClose: () => void;
}

function OrderItemsPanelInner({ order, onClose }: OrderItemsPanelProps) {
  if (!order) return null;

  const getImageUrl = (product: any) => {
    if (!product?.images || !Array.isArray(product.images) || product.images.length === 0) return null;
    const img = product.images[0];
    return typeof img === "string" ? img : img?.url || null;
  };

  return (
    <>
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/20 z-40 transition-opacity"
        onClick={onClose}
      />

      {/* Panel */}
      <div className="fixed top-0 right-0 h-full w-full max-w-md bg-white shadow-2xl z-50 flex flex-col animate-in slide-in-from-right duration-200">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-200 bg-slate-50/80">
          <div className="min-w-0">
            <h2 className="text-sm font-bold text-slate-900 uppercase tracking-widest">
              Order Items
            </h2>
            <div className="flex items-center gap-3 mt-1.5">
              <span className="text-xs font-mono text-slate-500">
                #{order.id.slice(0, 8)}
              </span>
              <div className="flex items-center gap-1 text-xs text-slate-500">
                <User className="w-3 h-3" />
                <span className="font-medium text-slate-700">{order.customer?.name}</span>
              </div>
            </div>
            <div className="flex items-center gap-1 text-xs text-slate-400 mt-1">
              <Calendar className="w-3 h-3" />
              <span>
                {format(new Date(order.start_date), "MMM d")} – {format(new Date(order.end_date), "MMM d, yyyy")}
              </span>
            </div>
          </div>
          <Button
            variant="ghost"
            size="icon"
            onClick={onClose}
            className="w-8 h-8 text-slate-400 hover:text-slate-900 rounded-full"
          >
            <X className="w-4 h-4" />
          </Button>
        </div>

        {/* Items List */}
        <div className="flex-1 overflow-y-auto">
          <div className="divide-y divide-slate-100">
            {order.items?.map((item, index) => {
              const product = (item as any).product;
              const imgUrl = getImageUrl(product);
              return (
                <div key={item.id} className="flex items-center gap-4 px-6 py-4 hover:bg-slate-50/50 transition-colors">
                  {/* Thumbnail */}
                  <div className="w-16 h-16 rounded-xl bg-slate-100 flex-shrink-0 border border-slate-200 overflow-hidden">
                    {imgUrl ? (
                      <img src={imgUrl} alt={product?.name} className="w-full h-full object-cover" />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center text-slate-300">
                        <Package className="w-6 h-6" />
                      </div>
                    )}
                  </div>

                  {/* Details */}
                  <div className="flex-1 min-w-0">
                    <h4 className="text-sm font-bold text-slate-900 truncate">
                      {product?.name || `Product #${item.product_id?.slice(0, 6)}`}
                    </h4>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="text-xs font-medium text-slate-500">
                        Qty: {item.quantity}
                      </span>
                      <span className="text-xs text-slate-400">×</span>
                      <span className="text-xs font-medium text-slate-500">
                        {formatCurrency(item.price_per_day)}/day
                      </span>
                    </div>
                    {item.discount > 0 && (
                      <span className="inline-block mt-1 text-[10px] font-bold text-emerald-600 bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-100">
                        -{item.discount_type === 'percent' ? `${item.discount}%` : formatCurrency(item.discount)} Off
                      </span>
                    )}

                    {/* Damage info (for returned/flagged orders) */}
                    {item.condition_rating === 'damaged' && (
                      <div className="mt-1.5">
                        <span className="text-[10px] font-bold text-orange-600 bg-orange-50 px-1.5 py-0.5 rounded border border-orange-200">
                          Damaged
                        </span>
                        {item.damage_description && (
                          <p className="text-[10px] text-orange-500 mt-0.5 italic">{item.damage_description}</p>
                        )}
                        {(item.damage_charges || 0) > 0 && (
                          <p className="text-[10px] text-orange-600 font-bold mt-0.5">
                            Fee: {formatCurrency(item.damage_charges || 0)}
                          </p>
                        )}
                      </div>
                    )}
                  </div>

                  {/* Return status badge */}
                  {item.is_returned && (
                    <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 px-2 py-1 rounded-md border border-emerald-200 flex-shrink-0">
                      Returned
                    </span>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-slate-200 bg-slate-50/80">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-widest">
              {order.items?.length || 0} items total
            </span>
            <span className="text-lg font-black text-slate-900">
              {formatCurrency(order.total_amount)}
            </span>
          </div>
        </div>
      </div>
    </>
  );
}

const OrderItemsPanel = React.memo(OrderItemsPanelInner);
OrderItemsPanel.displayName = "OrderItemsPanel";

export default OrderItemsPanel;
