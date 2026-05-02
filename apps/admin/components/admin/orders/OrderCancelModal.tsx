/**
 * OrderCancelModal Component
 *
 * Enhanced cancellation dialog with:
 *   - Mandatory cancellation reason textarea
 *   - Refund warning when amount_paid > 0
 *   - Stores cancellation_reason, cancelled_by, cancelled_at
 *
 * @component
 * @module components/admin/orders/OrderCancelModal
 */

"use client";

import React, { useState } from "react";
import { XCircle, AlertTriangle, Banknote } from "lucide-react";
import { Button } from "@/components/ui/button";
import Modal from "@/components/admin/Modal";
import { type OrderWithRelations } from "@/domain";
import { formatCurrency } from "@/lib/shared-utils";

interface OrderCancelModalProps {
  open: boolean;
  order: OrderWithRelations | null;
  onClose: () => void;
  onConfirm: (reason: string) => void;
  isPending?: boolean;
}

function OrderCancelModalInner({
  open,
  order,
  onClose,
  onConfirm,
  isPending = false,
}: OrderCancelModalProps) {
  const [reason, setReason] = useState("");
  const hasPaidAmount = (order?.amount_paid || 0) > 0;

  const handleClose = () => {
    setReason("");
    onClose();
  };

  const handleConfirm = () => {
    if (!reason.trim()) return;
    onConfirm(reason.trim());
    setReason("");
  };

  return (
    <Modal open={open} onClose={handleClose} title="Cancel Order" maxWidth="max-w-lg">
      <div className="p-6 space-y-5">
        <div className="flex items-start gap-4">
          <div className="w-10 h-10 rounded-full bg-orange-50 flex items-center justify-center shrink-0">
            <XCircle className="w-5 h-5 text-orange-600" />
          </div>
          <div>
            <h4 className="text-sm font-semibold text-slate-900 mb-1">
              Confirm Cancellation
            </h4>
            <p className="text-sm text-slate-600 leading-relaxed">
              Are you sure you want to cancel order{" "}
              <span className="font-semibold text-slate-900">
                #{order?.id.slice(0, 8)}
              </span>
              {order?.customer?.name && (
                <> for <span className="font-semibold text-slate-900">{order.customer.name}</span></>
              )}
              ?
            </p>
          </div>
        </div>

        {/* Refund Warning */}
        {hasPaidAmount && (
          <div className="flex items-start gap-3 p-3.5 bg-amber-50 border border-amber-200 rounded-lg">
            <Banknote className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
            <div>
              <p className="text-sm font-semibold text-amber-800">
                Payment Collected: {formatCurrency(order!.amount_paid)}
              </p>
              <p className="text-xs text-amber-700 mt-1 leading-relaxed">
                This order has payments recorded. After cancellation, you can
                process a refund from the order detail page.
              </p>
            </div>
          </div>
        )}

        {/* Mandatory Reason */}
        <div className="space-y-2">
          <label className="text-sm font-semibold text-slate-900">
            Reason for Cancellation <span className="text-red-500">*</span>
          </label>
          <textarea
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="Enter the reason for cancelling this order..."
            className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-sm focus:border-orange-500 focus:ring-1 focus:ring-orange-500 outline-none resize-y min-h-[80px]"
            rows={3}
            autoFocus
          />
          {reason.trim().length === 0 && (
            <p className="text-xs text-slate-400 flex items-center gap-1">
              <AlertTriangle className="w-3 h-3" /> A reason is required to cancel the order.
            </p>
          )}
        </div>

        <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
          <Button variant="outline" onClick={handleClose} className="border-slate-200">
            Keep Order
          </Button>
          <Button
            onClick={handleConfirm}
            disabled={!reason.trim() || isPending}
            className={`text-white ${!reason.trim() ? 'bg-slate-300 cursor-not-allowed' : 'bg-orange-600 hover:bg-orange-700'}`}
          >
            {isPending ? "Cancelling..." : "Cancel Order"}
          </Button>
        </div>
      </div>
    </Modal>
  );
}

const OrderCancelModal = React.memo(OrderCancelModalInner);
OrderCancelModal.displayName = "OrderCancelModal";

export default OrderCancelModal;
