/**
 * DamageAssessmentPanel Component
 *
 * Shows on the order details page when an order has damaged items (flagged status).
 * Lets admin review each damaged unit individually and mark it as:
 * - Reuse: unit goes back to inventory (no stock change)
 * - Write Off: unit is retired, stock is permanently decremented
 *
 * Assessments are auto-created during return processing, so this panel
 * simply displays existing assessments — no manual creation step needed.
 *
 * Only visible to admin/super_admin users.
 *
 * @component
 * @module components/admin/orders/DamageAssessmentPanel
 */

"use client";

import React, { useState } from "react";
import {
  Package,
  CheckCircle2,
  XCircle,
  AlertTriangle,
  Loader2,
  RotateCcw,
  Trash2,
  ShieldAlert,
  ClipboardCheck,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { formatCurrency } from "@/lib/shared-utils";
import Modal from "@/components/admin/Modal";
import {
  useDamageAssessments,
  useAssessDamageUnit,
} from "@/hooks";
import { usePermissions } from "@/hooks/usePermissions";
import { DamageDecision } from "@/domain";
import type { DamageAssessmentWithProduct, OrderWithRelations } from "@/domain";

interface DamageAssessmentPanelProps {
  order: OrderWithRelations;
}

export default function DamageAssessmentPanel({ order }: DamageAssessmentPanelProps) {
  const { isAdmin } = usePermissions();
  const { data, isLoading } = useDamageAssessments(order.id);
  const { assessUnit, isAssessing } = useAssessDamageUnit();

  const [confirmWriteOff, setConfirmWriteOff] = useState<DamageAssessmentWithProduct | null>(null);
  const [writeOffNotes, setWriteOffNotes] = useState("");

  const assessments = data?.assessments || [];
  const summary = data?.summary || { allDone: false, pending: 0, total: 0 };

  // ── Admin-only guard ──
  // Only admin/super_admin users can see the damage assessment panel
  if (!isAdmin) return null;

  // Don't show if there are no assessments and no damaged items
  const hasDamagedItems = order.items.some(
    item => item.condition_rating === 'damaged'
  );
  if (!hasDamagedItems && assessments.length === 0) return null;

  // If assessments haven't been created yet (edge case: old orders before auto-creation),
  // show a simple message instead of a create button
  if (!isLoading && assessments.length === 0 && hasDamagedItems) {
    return (
      <div className="bg-amber-50/50 border border-amber-200 rounded-xl p-5">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-amber-100 flex items-center justify-center shrink-0">
            <AlertTriangle className="w-5 h-5 text-amber-600" />
          </div>
          <div>
            <p className="text-sm font-bold text-amber-900">Damage Assessments Pending</p>
            <p className="text-xs text-amber-700 mt-0.5">
              Assessments were not created for this order. This may be an older order processed before auto-assessment was enabled.
            </p>
          </div>
        </div>
      </div>
    );
  }

  const handleReuse = (assessment: DamageAssessmentWithProduct) => {
    assessUnit({
      orderId: order.id,
      assessmentId: assessment.id,
      decision: DamageDecision.REUSE,
      notes: "Marked as reusable",
    });
  };

  const handleWriteOff = () => {
    if (!confirmWriteOff) return;
    assessUnit(
      {
        orderId: order.id,
        assessmentId: confirmWriteOff.id,
        decision: DamageDecision.NOT_REUSE,
        notes: writeOffNotes || "Written off — removed from stock",
      },
      {
        onSuccess: () => {
          setConfirmWriteOff(null);
          setWriteOffNotes("");
        },
      }
    );
  };

  const getImageUrl = (product: any) => {
    if (!product?.images || !Array.isArray(product.images) || product.images.length === 0) return null;
    const img = product.images[0];
    return typeof img === "string" ? img : img?.url || null;
  };

  // Group by product for display
  const grouped = assessments.reduce((acc, a) => {
    const key = a.product_id;
    if (!acc[key]) acc[key] = [];
    acc[key].push(a);
    return acc;
  }, {} as Record<string, DamageAssessmentWithProduct[]>);

  // Count stats
  const reuseCount = assessments.filter(a => a.decision === DamageDecision.REUSE).length;
  const writeOffCount = assessments.filter(a => a.decision === DamageDecision.NOT_REUSE).length;
  const pendingCount = summary.pending;

  return (
    <>
      <div className="bg-white border border-slate-200 rounded-xl overflow-hidden">
        {/* Header */}
        <div className="px-6 py-4 bg-gradient-to-r from-orange-50 to-amber-50/50 border-b border-orange-200/60">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-lg bg-orange-100 flex items-center justify-center">
                <ShieldAlert className="w-4.5 h-4.5 text-orange-600" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-slate-900 uppercase tracking-widest">
                  Damage Assessment
                </h3>
                <p className="text-[11px] text-slate-500 mt-0.5">
                  {assessments.length} unit{assessments.length !== 1 ? 's' : ''} require assessment
                </p>
              </div>
            </div>

            {/* Status badges */}
            <div className="flex items-center gap-2">
              {summary.allDone && assessments.length > 0 ? (
                <span className="text-xs font-bold text-emerald-600 bg-emerald-50 px-3 py-1.5 rounded-lg border border-emerald-200 flex items-center gap-1.5">
                  <CheckCircle2 className="w-3.5 h-3.5" /> All Assessed
                </span>
              ) : (
                <>
                  {pendingCount > 0 && (
                    <span className="text-xs font-bold text-amber-700 bg-amber-50 px-2.5 py-1 rounded-lg border border-amber-200">
                      {pendingCount} pending
                    </span>
                  )}
                  {reuseCount > 0 && (
                    <span className="text-xs font-bold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-lg border border-emerald-200">
                      {reuseCount} reuse
                    </span>
                  )}
                  {writeOffCount > 0 && (
                    <span className="text-xs font-bold text-red-700 bg-red-50 px-2.5 py-1 rounded-lg border border-red-200">
                      {writeOffCount} written off
                    </span>
                  )}
                </>
              )}
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="p-5">
          {isLoading ? (
            <div className="flex items-center justify-center py-10 text-slate-400">
              <Loader2 className="w-5 h-5 animate-spin mr-2" />
              Loading assessments...
            </div>
          ) : (
            <div className="space-y-4">
              {Object.entries(grouped).map(([productId, units]) => {
                const firstUnit = units[0];
                const product = firstUnit.product;
                const imgUrl = getImageUrl(product);
                const orderItem = firstUnit.order_item;
                const totalQty = orderItem?.quantity || 0;
                const damagedQty = units.length;
                const goodQty = totalQty - damagedQty;

                // Per-product stats
                const productPending = units.filter(u => u.decision === DamageDecision.PENDING).length;
                const productReuse = units.filter(u => u.decision === DamageDecision.REUSE).length;
                const productWriteOff = units.filter(u => u.decision === DamageDecision.NOT_REUSE).length;

                return (
                  <div key={productId} className="border border-slate-200 rounded-xl overflow-hidden">
                    {/* Product header */}
                    <div className="flex items-center gap-4 px-5 py-4 bg-slate-50/70 border-b border-slate-100">
                      <div className="w-14 h-14 rounded-xl bg-slate-100 border border-slate-200 overflow-hidden flex-shrink-0">
                        {imgUrl ? (
                          <img src={imgUrl} alt={product?.name} className="w-full h-full object-cover" />
                        ) : (
                          <div className="w-full h-full flex items-center justify-center text-slate-300">
                            <Package className="w-6 h-6" />
                          </div>
                        )}
                      </div>
                      <div className="flex-1 min-w-0">
                        <h4 className="text-sm font-bold text-slate-900 truncate">{product?.name || 'Product'}</h4>
                        <div className="flex flex-wrap items-center gap-2 mt-1.5">
                          {/* Quantity breakdown */}
                          <span className="text-xs font-bold text-orange-700 bg-orange-50 px-2 py-0.5 rounded border border-orange-200">
                            {damagedQty} of {totalQty} damaged
                          </span>
                          {goodQty > 0 && (
                            <span className="text-xs font-medium text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-100">
                              {goodQty} good
                            </span>
                          )}
                          {orderItem?.damage_description && (
                            <span className="text-[10px] text-orange-600 italic truncate max-w-[200px]">
                              — {orderItem.damage_description}
                            </span>
                          )}
                          {(orderItem?.damage_charges || 0) > 0 && (
                            <span className="text-[10px] font-bold text-orange-800 bg-orange-100 px-1.5 py-0.5 rounded">
                              Fee: {formatCurrency(orderItem!.damage_charges || 0)}
                            </span>
                          )}
                        </div>
                      </div>
                      {/* Mini progress */}
                      {productPending === 0 && (
                        <div className="flex items-center gap-1 shrink-0">
                          <ClipboardCheck className="w-4 h-4 text-emerald-500" />
                          <span className="text-[10px] font-bold text-emerald-600">Done</span>
                        </div>
                      )}
                    </div>

                    {/* Units list */}
                    <div className="divide-y divide-slate-100">
                      {units.map(unit => {
                        const isPending = unit.decision === DamageDecision.PENDING;
                        const isReuse = unit.decision === DamageDecision.REUSE;
                        const isWriteOff = unit.decision === DamageDecision.NOT_REUSE;

                        return (
                          <div
                            key={unit.id}
                            className={`flex items-center justify-between px-5 py-3.5 transition-colors ${
                              isWriteOff ? 'bg-red-50/40' : isReuse ? 'bg-emerald-50/40' : 'hover:bg-slate-50/50'
                            }`}
                          >
                            <div className="flex items-center gap-3">
                              {/* Unit indicator */}
                              <div className={`w-7 h-7 rounded-lg flex items-center justify-center text-xs font-bold ${
                                isPending
                                  ? 'bg-amber-100 text-amber-700'
                                  : isReuse
                                    ? 'bg-emerald-100 text-emerald-700'
                                    : 'bg-red-100 text-red-700'
                              }`}>
                                {unit.unit_index}
                              </div>

                              <span className={`text-xs font-bold px-2.5 py-1 rounded-lg border ${
                                isPending
                                  ? 'bg-amber-50 text-amber-700 border-amber-200'
                                  : isReuse
                                    ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                                    : 'bg-red-50 text-red-700 border-red-200'
                              }`}>
                                {isPending ? 'Pending Review' : isReuse ? 'Reuse ✓' : 'Written Off ✗'}
                              </span>

                              {unit.notes && !isPending && (
                                <span
                                  className="text-[11px] text-slate-500 italic max-w-[250px] truncate"
                                  title={unit.notes}
                                >
                                  — {unit.notes}
                                </span>
                              )}
                            </div>

                            {isPending && (
                              <div className="flex items-center gap-2">
                                <Button
                                  size="sm"
                                  variant="outline"
                                  onClick={() => handleReuse(unit)}
                                  disabled={isAssessing}
                                  className="h-8 px-3.5 text-xs font-bold border-emerald-200 text-emerald-700 hover:bg-emerald-50 hover:text-emerald-800 rounded-lg transition-colors"
                                >
                                  <RotateCcw className="w-3 h-3 mr-1.5" /> Reuse
                                </Button>
                                <Button
                                  size="sm"
                                  variant="outline"
                                  onClick={() => {
                                    setConfirmWriteOff(unit);
                                    setWriteOffNotes("");
                                  }}
                                  disabled={isAssessing}
                                  className="h-8 px-3.5 text-xs font-bold border-red-200 text-red-700 hover:bg-red-50 hover:text-red-800 rounded-lg transition-colors"
                                >
                                  <Trash2 className="w-3 h-3 mr-1.5" /> Write Off
                                </Button>
                              </div>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* Write Off Confirmation Modal */}
      <Modal
        open={confirmWriteOff !== null}
        onClose={() => { setConfirmWriteOff(null); setWriteOffNotes(""); }}
        title="Confirm Write Off"
        maxWidth="max-w-md"
      >
        <div className="p-6 space-y-5">
          <div className="flex items-start gap-4">
            <div className="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center shrink-0">
              <Trash2 className="w-5 h-5 text-red-600" />
            </div>
            <div>
              <h4 className="text-sm font-semibold text-slate-900 mb-1">Permanent Stock Reduction</h4>
              <p className="text-sm text-slate-600 leading-relaxed">
                Writing off this unit will <strong>permanently reduce</strong> the product's total stock by 1.
                This action cannot be undone.
              </p>
            </div>
          </div>

          {confirmWriteOff?.product && (
            <div className="p-3 bg-slate-50 border border-slate-200 rounded-lg">
              <p className="text-sm font-bold text-slate-900">
                {confirmWriteOff.product.name}
              </p>
              <p className="text-xs text-slate-500">
                Unit {confirmWriteOff.unit_index} will be removed from inventory
              </p>
            </div>
          )}

          <div className="space-y-2">
            <label className="text-xs font-bold text-slate-500 uppercase tracking-widest">
              Notes <span className="text-slate-400 font-normal">(Optional)</span>
            </label>
            <Input
              value={writeOffNotes}
              onChange={(e) => setWriteOffNotes(e.target.value)}
              placeholder="Reason for write off..."
              className="h-10 border-slate-300"
            />
          </div>

          <div className="flex justify-end gap-3 pt-3 border-t border-slate-100">
            <Button
              variant="outline"
              onClick={() => { setConfirmWriteOff(null); setWriteOffNotes(""); }}
              className="h-10 px-5 rounded-xl font-bold border-slate-200"
            >
              Cancel
            </Button>
            <Button
              onClick={handleWriteOff}
              disabled={isAssessing}
              className="h-10 px-5 rounded-xl font-bold text-white bg-red-600 hover:bg-red-700 shadow-md"
            >
              {isAssessing ? 'Processing...' : 'Confirm Write Off'}
            </Button>
          </div>
        </div>
      </Modal>
    </>
  );
}
