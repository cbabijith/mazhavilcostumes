/**
 * OrderRow Component
 *
 * A single table row representing one order in the list.
 * Uses `React.memo` with a custom comparator to prevent
 * re-renders unless the order data or selection state changes.
 *
 * Performance:
 *   - Memoized with shallow comparison on id + selected state
 *   - Callbacks are stable (passed from parent via useCallback)
 *   - Status badge is a separate memoized component
 *
 * @component
 * @module components/admin/orders/OrderRow
 */

"use client";

import React from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  Edit,
  Download,
  Printer,
  XCircle,
  Calendar,
  Package,
  Sparkles,
  Clock,
  AlertTriangle,
} from "lucide-react";
import { format } from "date-fns";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { formatCurrency } from "@/lib/shared-utils";
import { type OrderWithRelations, OrderStatus } from "@/domain";
import OrderStatusBadge from "./OrderStatusBadge";

/** Inline WhatsApp brand SVG icon */
function WhatsAppIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="currentColor">
      <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" />
    </svg>
  );
}

interface OrderRowProps {
  order: OrderWithRelations;
  selected: boolean;
  onToggleSelect: (id: string) => void;
  onCancel: (order: OrderWithRelations) => void;
  onViewItems?: (order: OrderWithRelations) => void;
}

function OrderRowInner({
  order,
  selected,
  onToggleSelect,
  onCancel,
  onViewItems,
}: OrderRowProps) {
  const router = useRouter();
  const itemCount = order.items?.length || 0;

  const handleRowClick = (e: React.MouseEvent<HTMLTableRowElement>) => {
    const target = e.target as HTMLElement;
    if (
      target.closest("button") ||
      target.closest("input") ||
      target.closest("a")
    )
      return;
    router.push(`/dashboard/orders/${order.id}`);
  };

  return (
    <tr
      onClick={handleRowClick}
      className={`hover:bg-slate-50 transition-colors group cursor-pointer ${
        selected ? "bg-slate-50/80" : ""
      }`}
    >
      {/* Checkbox */}
      <td className="px-4 py-4 text-center">
        <input
          type="checkbox"
          checked={selected}
          onChange={() => onToggleSelect(order.id)}
          className="rounded border-slate-300 text-slate-900 focus:ring-slate-900"
        />
      </td>

      {/* Customer */}
      <td className="px-4 py-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center shrink-0 border border-slate-200 text-slate-600 font-bold">
            {order.customer?.name?.charAt(0).toUpperCase() || "C"}
          </div>
          <div>
            <p className="font-semibold text-slate-900 group-hover:text-slate-600 transition-colors">
              {order.customer?.name || "Unknown Customer"}
            </p>
            <p className="text-xs text-slate-400 font-mono mt-0.5">
              ID: {order.id.slice(0, 8)}
            </p>
          </div>
        </div>
      </td>

      {/* Created Date */}
      <td className="px-4 py-4">
        <div className="flex items-center gap-1.5 text-xs text-slate-500">
          <Clock className="w-3.5 h-3.5 text-slate-400" />
          {format(new Date(order.created_at), "MMM d, yyyy")}
        </div>
      </td>

      {/* Phone - Clickable Badge */}
      <td className="px-4 py-4">
        {order.customer?.phone ? (
          <a
            href={`tel:${order.customer.phone}`}
            onClick={(e) => e.stopPropagation()}
          >
            <Badge variant="outline" className="bg-slate-50 text-slate-700 border-slate-200 hover:bg-emerald-50 hover:text-emerald-700 hover:border-emerald-200 transition-colors cursor-pointer gap-1.5">
              <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
              </svg>
              {order.customer.phone}
            </Badge>
          </a>
        ) : (
          <span className="text-sm text-slate-400">—</span>
        )}
      </td>

      {/* Dates */}
      <td className="px-4 py-4">
        <div className="flex flex-col gap-1 text-xs">
          <div className="flex items-center gap-1.5 text-slate-600">
            <Calendar className="w-3.5 h-3.5 text-slate-400" />
            {format(new Date(order.start_date), "MMM d, yyyy")}
          </div>
          <div className="text-slate-400 ml-5 flex items-center gap-1">
            to{" "}
            <span className="font-medium text-slate-600">
              {format(new Date(order.end_date), "MMM d, yyyy")}
            </span>
          </div>
        </div>
      </td>

      {/* Items — clickable to show side panel */}
      <td
        className="px-4 py-4 cursor-pointer"
        onClick={(e) => {
          e.stopPropagation();
          onViewItems?.(order);
        }}
        title="Click to preview items"
      >
        <div className="flex items-center gap-1.5 text-slate-600 hover:text-blue-600 transition-colors">
          <Package className="w-4 h-4 text-slate-400 group-hover:text-blue-500" />
          <span className="font-medium underline decoration-dashed underline-offset-2 decoration-slate-300 hover:decoration-blue-400">
            {itemCount} item{itemCount !== 1 ? "s" : ""}
          </span>
        </div>
      </td>

      {/* Amount */}
      <td className="px-4 py-4">
        <div className="flex flex-col">
          <span className="font-bold text-slate-900">
            {formatCurrency(order.total_amount)}
          </span>
          {(order.amount_paid || 0) > 0 && (
            <span className="text-[10px] text-emerald-600 font-medium">
              Paid: {formatCurrency(order.amount_paid)}
            </span>
          )}
        </div>
      </td>

      {/* Status */}
      <td className="px-4 py-4">
        <div className="flex flex-col items-start gap-1">
          <OrderStatusBadge status={order.status} />

          {/* Priority Cleaning badge */}
          {order.has_priority_cleaning && (
            <Badge className="bg-amber-100 text-amber-700 hover:bg-amber-100 border-amber-200 text-[10px] font-black tracking-tight px-1.5 py-0 gap-1 shadow-none">
              <Sparkles className="w-3 h-3 fill-amber-500" />
              Priority Cleaning
            </Badge>
          )}
          
          {/* Stock Conflict badge */}
          {order.has_stock_conflict && (
            <Badge className="bg-red-100 text-red-700 hover:bg-red-100 border-red-200 text-[10px] font-black tracking-tight px-1.5 py-0 gap-1 shadow-none animate-pulse">
              <AlertTriangle className="w-3 h-3 fill-red-500" />
              Stock Conflict
            </Badge>
          )}

          {/* Show payment badge for active (non-terminal) orders */}
          {order.status !== OrderStatus.COMPLETED && order.status !== OrderStatus.CANCELLED && (
            (() => {
              const ps = order.payment_status;
              if (ps === 'paid') return <Badge variant="outline" className="bg-emerald-50 text-emerald-600 border-emerald-200 text-[10px] py-0 px-1.5">Paid</Badge>;
              if (ps === 'partial') return <Badge variant="outline" className="bg-amber-50 text-amber-600 border-amber-200 text-[10px] py-0 px-1.5">Partial</Badge>;
              return <Badge variant="outline" className="bg-red-50 text-red-600 border-red-200 text-[10px] py-0 px-1.5">Unpaid</Badge>;
            })()
          )}

          {/* Show refund-due indicator for cancelled orders with payments */}
          {order.status === OrderStatus.CANCELLED && order.amount_paid > 0 && (
            <Badge variant="outline" className="bg-amber-50 text-amber-600 border-amber-200 text-[10px] py-0 px-1.5">Refund Due</Badge>
          )}

          {/* Action Needed Indicator for today's scheduled orders */}
          {order.status === OrderStatus.SCHEDULED && new Date(order.start_date) <= new Date(new Date().toDateString()) && (
            <div className="flex items-center gap-1 mt-1">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-amber-500"></span>
              </span>
              <span className="text-[10px] font-bold text-amber-600 uppercase tracking-wider">Action Needed</span>
            </div>
          )}
        </div>
      </td>

      {/* Actions */}
      <td className="px-4 py-4 text-right">
        <div className="flex items-center justify-end gap-1">
          {/* WhatsApp Button */}
          {order.customer?.phone && (
            <Button
              variant="ghost"
              size="icon"
              className="w-8 h-8 text-emerald-600 hover:text-emerald-700 hover:bg-emerald-50"
              onClick={(e) => {
                e.stopPropagation();
                const phone = order.customer?.phone?.replace(/\D/g, '');
                if (!phone) return;
                
                const customerName = order.customer?.name || 'Customer';
                const orderIdShort = order.id.slice(0, 8);
                const startDate = format(new Date(order.start_date), 'MMM d, yyyy');
                const endDate = format(new Date(order.end_date), 'MMM d, yyyy');
                
                let message = '';
                switch (order.status) {
                  case OrderStatus.PENDING:
                  case OrderStatus.SCHEDULED:
                    message = `Hi ${customerName}, this is regarding your upcoming order #${orderIdShort} scheduled for ${startDate}. Please confirm your availability.`;
                    break;
                  case OrderStatus.ONGOING:
                  case OrderStatus.IN_USE:
                    message = `Hi ${customerName}, your order #${orderIdShort} is currently active. Please remember to return by ${endDate}.`;
                    break;
                  case OrderStatus.LATE_RETURN:
                    message = `Hi ${customerName}, your order #${orderIdShort} is overdue. Please return immediately to avoid additional charges.`;
                    break;
                  case OrderStatus.PARTIAL:
                    message = `Hi ${customerName}, your order #${orderIdShort} has partial returns pending. Please complete the return process.`;
                    break;
                  case OrderStatus.DELIVERED:
                    message = `Hi ${customerName}, your order #${orderIdShort} has been delivered. Enjoy your event! Please return by ${endDate}.`;
                    break;
                  case OrderStatus.RETURNED:
                    message = `Hi ${customerName}, thank you for returning your order #${orderIdShort}. We hope you had a great experience!`;
                    break;
                  case OrderStatus.COMPLETED:
                    message = `Hi ${customerName}, your order #${orderIdShort} has been completed. Thank you for choosing Mazhavil Dance Costumes!`;
                    break;
                  case OrderStatus.CANCELLED:
                    message = `Hi ${customerName}, your order #${orderIdShort} has been cancelled. Contact us if you need assistance.`;
                    break;
                  case OrderStatus.FLAGGED:
                    message = `Hi ${customerName}, there is an issue with your order #${orderIdShort}. Please contact us immediately.`;
                    break;
                  default:
                    message = `Hi ${customerName}, this is regarding your order #${orderIdShort} at Mazhavil Dance Costumes.`;
                }
                
                const encodedMessage = encodeURIComponent(message);
                window.open(`https://wa.me/${phone}?text=${encodedMessage}`, '_blank');
              }}
              title="Send WhatsApp Message"
            >
              <WhatsAppIcon className="w-4 h-4" />
            </Button>
          )}

          <Button
            variant="ghost"
            size="icon"
            className="w-8 h-8 text-slate-400 hover:text-slate-900"
            onClick={(e) => {
              e.stopPropagation();
              window.open(
                `/api/orders/${order.id}/invoice?type=final`,
                "_blank"
              );
            }}
            title="Download Invoice"
          >
            <Download className="w-4 h-4" />
          </Button>

          <Button
            variant="ghost"
            size="icon"
            className="w-8 h-8 text-slate-400 hover:text-slate-900"
            onClick={(e) => {
              e.stopPropagation();
              // Use a hidden iframe to load the PDF inline and trigger print dialog
              // This avoids downloading the PDF (which the Download button already does)
              const iframe = document.createElement("iframe");
              iframe.style.position = "fixed";
              iframe.style.right = "0";
              iframe.style.bottom = "0";
              iframe.style.width = "0";
              iframe.style.height = "0";
              iframe.style.border = "none";
              iframe.src = `/api/orders/${order.id}/invoice?type=final&disposition=inline`;
              document.body.appendChild(iframe);
              iframe.onload = () => {
                try {
                  iframe.contentWindow?.print();
                } catch {
                  // Cross-origin fallback: open in new tab for manual print
                  window.open(
                    `/api/orders/${order.id}/invoice?type=final&disposition=inline`,
                    "_blank"
                  );
                }
                // Clean up iframe after a delay
                setTimeout(() => {
                  document.body.removeChild(iframe);
                }, 5000);
              };
            }}
            title="Print Invoice"
          >
            <Printer className="w-4 h-4" />
          </Button>

          {order.status === "scheduled" && (
            <Button
              variant="ghost"
              size="icon"
              className="w-8 h-8 text-slate-400 hover:text-orange-600"
              onClick={(e) => {
                e.stopPropagation();
                onCancel(order);
              }}
              title="Cancel Order"
            >
              <XCircle className="w-4 h-4" />
            </Button>
          )}

          {(() => {
            const isEditDisabled = [
              OrderStatus.CANCELLED,
              OrderStatus.COMPLETED,
              OrderStatus.RETURNED,
              OrderStatus.ONGOING,
              OrderStatus.IN_USE,
            ].includes(order.status);

            return (
              <Button
                variant="ghost"
                size="icon"
                className={`w-8 h-8 ${
                  isEditDisabled
                    ? "text-slate-200 cursor-not-allowed"
                    : "text-slate-400 hover:text-slate-900"
                }`}
                disabled={isEditDisabled}
                asChild={!isEditDisabled}
                onClick={(e) => {
                  if (isEditDisabled) e.stopPropagation();
                }}
                title={isEditDisabled ? "Cannot edit in current status" : "Edit Order"}
              >
                {!isEditDisabled ? (
                  <Link href={`/dashboard/orders/${order.id}/edit`}>
                    <Edit className="w-4 h-4" />
                  </Link>
                ) : (
                  <span>
                    <Edit className="w-4 h-4" />
                  </span>
                )}
              </Button>
            );
          })()}


        </div>
      </td>
    </tr>
  );
}

const OrderRow = React.memo(OrderRowInner, (prev, next) => {
  return (
    prev.order.id === next.order.id &&
    prev.order.status === next.order.status &&
    prev.order.total_amount === next.order.total_amount &&
    prev.order.amount_paid === next.order.amount_paid &&
    prev.order.has_priority_cleaning === next.order.has_priority_cleaning &&
    prev.order.has_stock_conflict === next.order.has_stock_conflict &&
    prev.selected === next.selected &&
    prev.onViewItems === next.onViewItems
  );
});

OrderRow.displayName = "OrderRow";

export default OrderRow;
