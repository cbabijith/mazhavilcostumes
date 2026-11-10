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
import { type OrderWithRelations, type UpdateOrderDTO } from "@/domain";
import { formatCurrency } from "@/lib/shared-utils";

interface OrderCancelModalProps {
  open: boolean;
  order: OrderWithRelations | null;
  onClose: () => void;
  onConfirm: (data: UpdateOrderDTO) => Promise<unknown>;
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
  const [refund, setRefund] = useState("0");
  const [mode, setMode] = useState<NonNullable<UpdateOrderDTO['refund_payment_mode']>>('cash');
  const [stockReturned, setStockReturned] = useState(false);
  const [error, setError] = useState('');
  const [saving, setSaving] = useState(false);
  const needsStockConfirmation = ['ongoing', 'in_use'].includes(order?.status || '');
  const busy = isPending || saving;
  const hasPaidAmount = (order?.amount_paid || 0) > 0;

  const handleClose = () => {
    if (busy) return;
    setReason("");
    setRefund('0');
    setStockReturned(false);
    setError('');
    onClose();
  };

  const handleConfirm = async () => {
    const amount = Number(refund);
    if (!reason.trim() || reason.trim().length > 2000) { setError('Enter a cancellation reason (maximum 2000 characters).'); return; }
    if (!refund.trim() || !Number.isFinite(amount) || amount < 0 || amount > (order?.amount_paid || 0) || Math.abs(amount * 100 - Math.round(amount * 100)) > 0.000001) {
      setError('Refund must be between zero and the paid amount, with at most two decimal places.'); return;
    }
    if (needsStockConfirmation && !stockReturned) { setError('Confirm all outstanding costumes are back in usable condition.'); return; }
    setSaving(true);
    setError('');
    try {
      await onConfirm({ cancellation_reason: reason.trim(), refund_amount: amount,
        refund_payment_mode: mode, stock_returned: stockReturned });
      setReason(''); setRefund('0'); setStockReturned(false);
      onClose();
    } catch (failure) {
      setError(failure instanceof Error ? failure.message : 'Cancellation failed. Please retry.');
    } finally { setSaving(false); }
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
                {order?.invoice_number || `#${order?.id.slice(0, 8)}`}
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
                Record money refunded now. Any remainder stays Refund due;
                use Keep Amount separately if the shop will retain it.
              </p>
            </div>
          </div>
        )}

        {hasPaidAmount && (
          <div className="space-y-3">
            <label className="block text-sm font-semibold">Refund now (₹)
              <input aria-label="Refund now" type="number" min="0" max={order!.amount_paid} step="0.01"
                value={refund} disabled={busy} onChange={e => setRefund(e.target.value)} className="mt-1 w-full rounded border p-2" />
            </label>
            <Button variant="outline" disabled={busy} onClick={() => setRefund(String(order!.amount_paid))}>Full refund</Button>
            <label className="block text-sm font-semibold">Refund mode
              <select value={mode} disabled={busy} onChange={e => setMode(e.target.value as typeof mode)} className="mt-1 w-full rounded border p-2">
                <option value="cash">Cash</option><option value="upi">UPI</option><option value="gpay">GPay</option>
                <option value="bank_transfer">Bank transfer</option><option value="cheque">Cheque</option>
              </select>
            </label>
          </div>
        )}
        {needsStockConfirmation && (
          <label className="flex items-start gap-2 text-sm">
            <input type="checkbox" checked={stockReturned} disabled={busy} onChange={e => setStockReturned(e.target.checked)} />
            All outstanding costumes are back in usable condition. Restore them to stock.
          </label>
        )}
        {error && <p role="alert" className="text-sm text-red-600">{error}</p>}

        {/* Mandatory Reason */}
        <div className="space-y-2">
          <label className="text-sm font-semibold text-slate-900">
            Reason for Cancellation <span className="text-red-500">*</span>
          </label>
          <textarea
            value={reason}
            disabled={busy}
            maxLength={2000}
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
          <Button variant="outline" disabled={busy} onClick={handleClose} className="border-slate-200">
            Keep Order
          </Button>
          <Button
            onClick={handleConfirm}
            disabled={!reason.trim() || busy || (needsStockConfirmation && !stockReturned)}
            className={`text-white ${!reason.trim() ? 'bg-slate-300 cursor-not-allowed' : 'bg-orange-600 hover:bg-orange-700'}`}
          >
            {busy ? "Cancelling..." : "Cancel Order"}
          </Button>
        </div>
      </div>
    </Modal>
  );
}

const OrderCancelModal = React.memo(OrderCancelModalInner);
OrderCancelModal.displayName = "OrderCancelModal";

export default OrderCancelModal;
