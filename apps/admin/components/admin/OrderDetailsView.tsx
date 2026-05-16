"use client";

import { useState, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import { format } from "date-fns";
import {
  Package, CheckCircle2, AlertTriangle, Loader2, Info,
  ArrowLeft, XCircle, Phone, Banknote, Smartphone, Building2, Edit3, ReceiptText, ScanBarcode, Save
} from "lucide-react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import Modal from "@/components/admin/Modal";
import { 
  useOrder, 
  useOrderStatusHistory, 
  useProcessOrderReturn, 
  useUpdateOrder, 
  useCreatePayment, 
  useOrderPayments, 
  useLookupProductByBarcode,
  useUpdateOrderItemDamage
} from "@/hooks";
import { useAppStore } from "@/stores";
import { formatCurrency } from "@/lib/shared-utils";
import { OrderStatus, ConditionRating, PaymentStatus } from "@/domain/types/order";
import { PaymentType, PaymentMode } from "@/domain/types/payment";
import { startOfDay } from "date-fns";
import dynamic from 'next/dynamic';

const BarcodeScanner = dynamic(() => import('./BarcodeScanner'), { ssr: false });
import DamageAssessmentPanel from './orders/DamageAssessmentPanel';

export default function OrderDetailsView({ orderId }: { orderId: string }) {
  const router = useRouter();
  const { data: orderResponse, isLoading } = useOrder(orderId);
  // We keep history for potential future use but hide it from the 2-second UX glance
  const { data: historyResponse } = useOrderStatusHistory(orderId);
  const { processOrderReturn, isPending: isReturning } = useProcessOrderReturn();
  const { updateOrder, isLoading: isUpdating } = useUpdateOrder();
  const { createPayment, isPending: isCreatingPayment } = useCreatePayment();
  const { showSuccess, showError } = useAppStore();
  const { lookupByBarcode } = useLookupProductByBarcode();
  const { updateOrderItemDamage, isUpdating: isSavingItem } = useUpdateOrderItemDamage();

  const [isPaymentModalOpen, setIsPaymentModalOpen] = useState(false);
  const [isRefundModalOpen, setIsRefundModalOpen] = useState(false);
  const [isCancelModalOpen, setIsCancelModalOpen] = useState(false);
  const [paymentForm, setPaymentForm] = useState({
    amount: "0",
    paymentMode: PaymentMode.CASH,
    paymentType: PaymentType.FINAL,
    notes: ""
  });
  const [refundForm, setRefundForm] = useState({
    paymentMode: PaymentMode.CASH,
    notes: "",
    amount: "0",
  });
  const [isCancellationRefund, setIsCancellationRefund] = useState(false);
  const [cancelReason, setCancelReason] = useState("");
  const [isReturnConfirmOpen, setIsReturnConfirmOpen] = useState(false);

  const [isAdjustmentModalOpen, setIsAdjustmentModalOpen] = useState(false);
  const [adjustmentForm, setAdjustmentForm] = useState({
    type: 'discount' as 'discount' | 'late_fee' | 'damage_fee' | 'extra_charge',
    amount: "0",
    notes: ""
  });
  const [isEditingDeposit, setIsEditingDeposit] = useState(false);
  const [editDepositValue, setEditDepositValue] = useState("");
  const [isScannerOpen, setIsScannerOpen] = useState(false);
  const [isKeepMoneyModalOpen, setIsKeepMoneyModalOpen] = useState(false);
  const [highlightedItemId, setHighlightedItemId] = useState<string | null>(null);
  const [barcodeInput, setBarcodeInput] = useState('');  
  const barcodeInputRef = useRef<HTMLInputElement>(null);

  // Start Rental stock check
  const [isCheckingStock, setIsCheckingStock] = useState(false);
  const [isStockErrorModalOpen, setIsStockErrorModalOpen] = useState(false);
  const [stockCheckResults, setStockCheckResults] = useState<{ product_name: string; requested: number; available: number; isAvailable: boolean }[]>([]);

  // Local state for the return checklist
  const [returnItems, setReturnItems] = useState<Record<string, {
    status: 'excellent' | 'damaged' | 'missing' | null,
    damage_fee: number,
    damaged_quantity: number,
    notes: string,
  }>>({});

  const [lateFee, setLateFee] = useState<number>(0);
  const [discount, setDiscount] = useState<number>(0);

  const order = orderResponse?.data;
  const { data: paymentsResponse, isLoading: isLoadingPayments } = useOrderPayments(orderId);
  const payments = paymentsResponse || [];
  
  const isReturnable = order?.status === OrderStatus.IN_USE || order?.status === OrderStatus.ONGOING || order?.status === OrderStatus.LATE_RETURN || order?.status === OrderStatus.PARTIAL;
  const isFinalized = order?.status === OrderStatus.COMPLETED || order?.status === OrderStatus.CANCELLED;

  useEffect(() => {
    if (order && Object.keys(returnItems).length === 0 && isReturnable) {
      const initial: any = {};
      order.items.forEach(item => {
        // Pre-fill from existing data if it exists (for incremental save recovery)
        let status: any = null;
        if (item.condition_rating === 'damaged') status = 'damaged';
        else if (item.condition_rating === 'excellent') status = 'excellent';
        
        initial[item.id] = { 
          status: status, 
          damage_fee: item.damage_charges || 0, 
          damaged_quantity: item.damaged_quantity || item.quantity, 
          notes: item.damage_description || "" 
        };
      });
      setReturnItems(initial);
    }
  }, [order, isReturnable]);

  // Projected amount due including pending return fees (live preview)
  const calculatedDamage = Object.values(returnItems).reduce((sum, item) => sum + (item.damage_fee || 0), 0);
  
  // To avoid double-counting, we calculate the projected total by starting from the "clean" base 
  // (Order Total - Persisted Damage - Persisted Late Fee + Persisted Discount) 
  // and then adding our local return-time adjustments.
  const baseTotalBeforeReturn = order 
    ? (order.total_amount - (order.damage_charges_total || 0) - (order.late_fee || 0) + (order.discount || 0)) 
    : 0;

  const projected_total = order ? baseTotalBeforeReturn + calculatedDamage + lateFee - discount : 0;
  const amount_due = order ? Math.max(0, projected_total - (order.amount_paid || 0)) : 0;
  const base_amount_due = order ? Math.max(0, order.total_amount - (order.amount_paid || 0)) : 0;
  const totalDeductions = calculatedDamage + lateFee - discount;

  const getImageUrl = (product: any) => {
    if (!product?.images || !Array.isArray(product.images) || product.images.length === 0) return null;
    const img = product.images[0];
    return typeof img === "string" ? img : img?.url || null;
  };

  const handleMarkAllExcellent = () => {
    const updated: any = {};
    Object.keys(returnItems).forEach(key => {
      updated[key] = { ...returnItems[key], status: 'excellent', damage_fee: 0, damaged_quantity: 0, notes: "" };
    });
    setReturnItems(updated);
  };

  // Barcode scan handler for return
  const handleBarcodeScan = async (barcode: string) => {
    if (!barcode.trim() || !order || !isReturnable) return;
    try {
      const product = await lookupByBarcode(barcode.trim());
      if (!product) return;

      // Find matching item in the order
      const matchingItem = order.items.find(item => {
        const itemProduct = (item as any).product;
        return itemProduct?.id === product.id || item.product_id === product.id;
      });

      if (!matchingItem) {
        showError('Barcode Scan', 'This item is not in this order');
        return;
      }

      // Highlight the item with a green flash
      setHighlightedItemId(matchingItem.id);
      setTimeout(() => setHighlightedItemId(null), 2000);

      // Auto-mark as excellent
      setReturnItems(prev => ({
        ...prev,
        [matchingItem.id]: { ...prev[matchingItem.id], status: 'excellent', damage_fee: 0, notes: '' }
      }));
      showSuccess('Item Scanned', `${product.name} marked as Good condition`);
      setBarcodeInput('');
    } catch {
      // Error already shown by the hook
    }
  };

  // Handle barcode text input (supports USB scanner which fires Enter after scan)
  const handleBarcodeInputKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && barcodeInput.trim()) {
      e.preventDefault();
      handleBarcodeScan(barcodeInput);
    }
  };

  const handleStartOrder = async () => {
    if (!order) return;
    setIsCheckingStock(true);
    try {
      const today = new Date().toISOString().split('T')[0];
      const items = order.items.map(item => ({
        product_id: item.product_id,
        quantity: item.quantity,
        product_name: (item as any).product?.name || `Product #${item.product_id?.slice(0, 6)}`,
      }));

      const res = await fetch('/api/orders/check-availability', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          items,
          start_date: today,
          end_date: order.end_date,
          exclude_order_id: order.id,
        }),
      });
      const result = await res.json();

      if (!result.success || !result.data?.allAvailable) {
        // Stock insufficient — block
        setStockCheckResults(result.data?.items || []);
        setIsStockErrorModalOpen(true);
        setIsCheckingStock(false);
        return;
      }

      // All stock available — proceed
      updateOrder({
        id: order.id,
        data: {
          status: OrderStatus.ONGOING,
          start_date: today,
        }
      });
    } catch (err) {
      showError('Stock Check Failed', 'Could not verify stock availability. Please try again.');
    } finally {
      setIsCheckingStock(false);
    }
  };

  const handleItemUpdate = (itemId: string, field: string, value: any) => {
    setReturnItems(prev => {
      const updated = { ...prev, [itemId]: { ...prev[itemId], [field]: value } };
      // Auto-set damaged_quantity to full quantity when status changes to damaged
      if (field === 'status' && value === 'damaged') {
        const item = order?.items.find(i => i.id === itemId);
        if (item && !updated[itemId].damaged_quantity) {
          updated[itemId].damaged_quantity = item.quantity;
        }
      }
      // Auto-set damaged_quantity to 0 when status changes to excellent
      if (field === 'status' && value === 'excellent') {
        updated[itemId].damaged_quantity = 0;
        updated[itemId].damage_fee = 0;
        updated[itemId].notes = '';
      }
      return updated;
    });
  };

  const handleSaveItemDamage = (itemId: string) => {
    const rItem = returnItems[itemId];
    if (!rItem) return;

    updateOrderItemDamage({
      itemId,
      data: {
        condition_rating: rItem.status === 'damaged' ? ConditionRating.DAMAGED : ConditionRating.EXCELLENT,
        damage_description: rItem.notes || null,
        damage_charges: rItem.damage_fee || 0,
        damaged_quantity: rItem.damaged_quantity || 0,
      }
    });
  };

  const handleCollectPayment = async () => {
    const amountVal = parseFloat(paymentForm.amount) || 0;
    const maxAmount = amount_due;

    if (!order || amountVal <= 0) {
      showError("Validation Error", "Amount must be greater than 0");
      return;
    }

    if (amountVal > maxAmount) {
      showError("Validation Error", `Amount cannot exceed ${formatCurrency(maxAmount)}`);
      return;
    }

    try {
      createPayment(
        {
          order_id: order.id,
          payment_type: paymentForm.paymentType,
          amount: amountVal,
          payment_mode: paymentForm.paymentMode,
          notes: paymentForm.notes,
        },
        {
          onSuccess: () => {
            const newAmountPaid = (order.amount_paid || 0) + amountVal;
            const newStatus = newAmountPaid >= order.total_amount ? PaymentStatus.PAID : PaymentStatus.PARTIAL;
            updateOrder({
              id: order.id,
              data: {
                amount_paid: newAmountPaid,
                payment_status: newStatus,
              },
            });
            setIsPaymentModalOpen(false);
            setPaymentForm({ amount: "0", paymentMode: PaymentMode.CASH, paymentType: PaymentType.FINAL, notes: "" });
            showSuccess("Payment Recorded", "Payment was successfully processed.");
          },
        }
      );
    } catch (e) {
      console.error(e);
    }
  };

  const handleRefundDeposit = async () => {
    // Deposit refund is no longer applicable — security deposit has been removed.
    // This function is kept as a stub for backwards compatibility.
    return;
  };

  const submitReturn = () => {
    if (!order) return;
    setIsReturnConfirmOpen(false);

    const returnPayload = {
      order_id: order.id,
      notes: `Late Fee: ${lateFee}, Discount: ${discount}`,
      items: order.items.map(item => {
        const rItem = returnItems[item.id];
        const isDamaged = rItem.status === 'damaged';
        const damagedQty = isDamaged ? (rItem.damaged_quantity || item.quantity) : 0;
        // Auto-mark remaining quantity as Good
        const returnedQty = rItem.status === 'missing' ? 0 : item.quantity;
        return {
          item_id: item.id,
          returned_quantity: returnedQty,
          condition_rating: isDamaged ? ConditionRating.DAMAGED : ConditionRating.EXCELLENT,
          damage_description: rItem.notes,
          damage_charges: rItem.damage_fee,
          damaged_quantity: damagedQty,
          // The good quantity is implicitly: item.quantity - damagedQty
        };
      }),
      late_fee: lateFee,
      discount: discount,
    };

    processOrderReturn({ orderId: order.id, returnData: returnPayload });
  };

  const handleReturnClick = () => {
    if (!order) return;

    const unmarked = Object.entries(returnItems).filter(([_, val]) => val.status === null);
    if (unmarked.length > 0) {
      showError("Incomplete", "Please mark the condition of all items before settling.");
      return;
    }

    // Warn if any damaged items have ₹0 damage fee (but don't block)
    const zeroDamage = Object.entries(returnItems).filter(
      ([_, val]) => val.status === 'damaged' && (val.damage_fee || 0) <= 0
    );
    if (zeroDamage.length > 0) {
      // Show warning but proceed — user can still complete
      // The warning is shown via the confirmation modal
    }

    setIsReturnConfirmOpen(true);
  };

  if (isLoading || !order) {
    return (
      <div className="flex flex-col items-center justify-center h-96">
        <div className="w-8 h-8 border-4 border-slate-300 border-t-slate-900 rounded-full animate-spin"></div>
      </div>
    );
  }

  const getStatusDisplay = (status: string) => {
    switch (status) {
      case OrderStatus.CONFIRMED: case OrderStatus.SCHEDULED: return { color: 'bg-blue-100 text-blue-800 border-blue-200', label: 'Scheduled' };
      case OrderStatus.ONGOING: case OrderStatus.IN_USE: return { color: 'bg-emerald-100 text-emerald-800 border-emerald-200', label: 'Ongoing' };
      case OrderStatus.LATE_RETURN: return { color: 'bg-red-100 text-red-800 border-red-300 shadow-[0_0_10px_rgba(239,68,68,0.3)]', label: 'Late' };
      case OrderStatus.PARTIAL: return { color: 'bg-orange-100 text-orange-800 border-orange-200', label: 'Partial' };
      case OrderStatus.RETURNED: case OrderStatus.COMPLETED: return { color: 'bg-slate-100 text-slate-600 border-slate-200', label: 'Returned' };
      case OrderStatus.FLAGGED: return { color: 'bg-purple-100 text-purple-800 border-purple-200', label: '⚠️ Flagged' };
      case OrderStatus.CANCELLED: return { color: 'bg-slate-800 text-slate-300 border-slate-700 line-through', label: 'Cancelled' };
      default: return { color: 'bg-slate-100 text-slate-600 border-slate-200', label: status };
    }
  };

  const statusDisplay = getStatusDisplay(order.status);

  return (
    <div className="space-y-6 max-w-7xl mx-auto pb-20">
      {/* STOCK CONFLICT ALERT */}
      {order?.has_stock_conflict && (
        <div className="bg-red-50 border-2 border-red-200 rounded-2xl p-5 animate-in slide-in-from-top duration-300">
          <div className="flex items-start gap-4">
            <div className="bg-red-100 p-2.5 rounded-xl shrink-0">
              <AlertTriangle className="w-6 h-6 text-red-600 animate-pulse" />
            </div>
            <div className="flex-1">
              <h3 className="text-lg font-black text-red-900 uppercase tracking-tight">
                Inventory Fulfillment Conflict Detected
              </h3>
              <p className="text-sm text-red-700 mt-1 font-medium leading-relaxed">
                Total inventory for one or more items in this order has dropped below required levels due to damage or write-offs. 
                This order is currently at risk of incomplete fulfillment.
              </p>
              
              {order.conflict_details && Array.isArray(order.conflict_details) && order.conflict_details.length > 0 && (
                <div className="mt-4 flex flex-wrap gap-3">
                  {order.conflict_details.map((conflict: any, idx: number) => (
                    <div key={idx} className="bg-white/80 border border-red-100 rounded-xl px-3 py-2 flex items-center gap-3 shadow-sm">
                      <div className="bg-red-50 px-2 py-0.5 rounded text-[10px] font-black text-red-700 uppercase tracking-wider">Conflict</div>
                      <span className="text-xs font-bold text-red-900 uppercase tracking-tight">{conflict.productName}</span>
                      <div className="w-px h-3 bg-red-200" />
                      <span className="text-xs text-red-700 font-bold">
                        Shortfall: {conflict.shortfall} unit(s)
                      </span>
                    </div>
                  ))}
                </div>
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Button 
                variant="outline" 
                size="sm" 
                className="bg-white border-red-200 text-red-700 hover:bg-red-50 hover:border-red-300 h-10 font-black uppercase tracking-wider text-xs rounded-xl"
                onClick={() => router.push(`/dashboard/orders/${orderId}/edit`)}
              >
                Modify Order
              </Button>
            </div>
          </div>
        </div>
      )}
      
      {/* 1. Hero Banner (The 2-Second Glance) */}
      <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 space-y-5">
        {/* Top Row: Order ID + Status */}
        <div className="flex items-center gap-5">
          <Button variant="ghost" size="icon" onClick={() => router.push("/dashboard/orders")} className="h-12 w-12 rounded-full bg-slate-50 hover:bg-slate-100 shrink-0">
            <ArrowLeft className="w-5 h-5 text-slate-700" />
          </Button>
          <div className="min-w-0">
            <h1 className="text-3xl font-black text-slate-900 tracking-tight leading-none mb-1">
              #{order.id.slice(0, 6).toUpperCase()}
            </h1>
            <p className="text-slate-500 font-bold uppercase tracking-wide text-sm truncate">{order.customer?.name}</p>
          </div>
          <div className={`px-4 py-1.5 rounded-full border-2 font-black uppercase tracking-wider text-sm whitespace-nowrap shrink-0 ${statusDisplay.color}`}>
            {statusDisplay.label}
          </div>
        </div>

        {/* Bottom Row: Actions */}
        <div className="flex items-center gap-3 flex-wrap pl-[68px]">
          {/* Payment Pill — only for active orders */}
          {!isFinalized && (
            amount_due > 0 ? (
              <div className="bg-red-50 border-2 border-red-200 text-red-700 px-4 py-2 rounded-xl text-base font-black text-center whitespace-nowrap">
                DUE: {formatCurrency(amount_due)}
              </div>
            ) : (
              <div className="bg-emerald-50 border border-emerald-200 text-emerald-700 px-4 py-2 rounded-xl text-sm font-black text-center">
                PAID
              </div>
            )
          )}

          {/* Primary Action Button — Start Rental for confirmed + scheduled */}
          {(order.status === OrderStatus.CONFIRMED || order.status === OrderStatus.SCHEDULED) && (() => {
            const today = startOfDay(new Date());
            const rentalStart = startOfDay(new Date(order.start_date));
            const isEarlyStart = today < rentalStart;
            return (
              <>
                <Button 
                  onClick={handleStartOrder} 
                  disabled={isUpdating || isCheckingStock || !!order.has_stock_conflict} 
                  className="h-11 px-6 bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm rounded-xl disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isCheckingStock ? (
                    <><Loader2 className="w-4 h-4 mr-1.5 animate-spin" /> Checking...</>
                  ) : (
                    order.has_stock_conflict ? 'Stock Conflict (Blocked)' : 'Start Rental'
                  )}
                </Button>
                <Button
                  onClick={() => setIsCancelModalOpen(true)}
                  disabled={isUpdating}
                  variant="outline"
                  className="h-11 px-4 border-2 border-red-200 text-red-600 hover:bg-red-50 hover:border-red-300 font-bold text-sm rounded-xl"
                >
                  <XCircle className="w-4 h-4 mr-1.5" /> Cancel Order
                </Button>
                {isEarlyStart && (
                  <p className="text-xs text-amber-600 font-semibold bg-amber-50 border border-amber-200 px-3 py-1.5 rounded-lg whitespace-nowrap">
                    Original pickup: {format(rentalStart, "dd MMM, yyyy")}
                  </p>
                )}
              </>
            );
          })()}
          {order.status !== OrderStatus.SCHEDULED && !isFinalized && amount_due > 0 && (
            <Button onClick={() => setIsPaymentModalOpen(true)} className="h-11 px-6 bg-red-600 hover:bg-red-700 text-white font-bold text-sm rounded-xl">
              Collect Payment
            </Button>
          )}
        </div>
      </div>

      {/* 2. Logistics Bar */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-2xl border border-slate-200 p-5">
          <p className="text-xs text-slate-500 font-bold uppercase tracking-widest mb-1">Out (Pickup)</p>
          <p className="text-2xl font-bold text-slate-900">{format(new Date(order.start_date), "dd/MM/yyyy")}</p>
        </div>
        <div className={`bg-white rounded-2xl border p-5 ${order.status === OrderStatus.LATE_RETURN ? 'border-red-400 bg-red-50 ring-4 ring-red-50' : 'border-slate-200'}`}>
          <p className={`text-xs font-bold uppercase tracking-widest mb-1 ${order.status === OrderStatus.LATE_RETURN ? 'text-red-600' : 'text-slate-500'}`}>
            In (Return)
          </p>
          <p className={`text-2xl font-bold ${order.status === OrderStatus.LATE_RETURN ? 'text-red-700' : 'text-slate-900'}`}>
            {format(new Date(order.end_date), "dd/MM/yyyy")}
          </p>
        </div>
        <div className="bg-white rounded-2xl border border-slate-200 p-5">
          <p className="text-xs text-slate-500 font-bold uppercase tracking-widest mb-1">Items</p>
          <p className="text-2xl font-bold text-slate-900">{order.items.length} Pieces</p>
        </div>
      </div>


      {/* Payment History Block */}
      <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="bg-slate-50 px-6 py-4 border-b border-slate-200 flex justify-between items-center">
          <h2 className="text-sm font-bold text-slate-900 uppercase tracking-widest flex items-center gap-2">
            <Banknote className="w-5 h-5 text-slate-500" /> Payment History
          </h2>
        </div>
        {isLoadingPayments ? (
          <div className="p-8 text-center text-slate-500 font-medium">Loading payments...</div>
        ) : payments.length === 0 ? (
          <div className="p-8 text-center text-slate-500 font-medium bg-slate-50/50">No payments recorded yet.</div>
        ) : (
          <div className="divide-y divide-slate-100 overflow-x-auto">
            <table className="w-full text-left border-collapse min-w-[600px]">
              <thead>
                <tr className="bg-white">
                  <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider w-1/4">Date & Time</th>
                  <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider w-1/4">Type & Mode</th>
                  <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider w-1/4 text-right">Amount</th>
                  <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider w-1/4">Handled By</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-slate-100">
                {payments.map((payment: any) => (
                  <tr key={payment.id} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-bold text-slate-900">{format(new Date(payment.payment_date || payment.created_at), "dd MMM, yyyy")}</div>
                      <div className="text-xs text-slate-500">{format(new Date(payment.payment_date || payment.created_at), "h:mm a")}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center gap-2">
                        <span className={`px-2.5 py-1 text-[10px] font-black uppercase tracking-wider rounded-md border ${
                          payment.payment_type === PaymentType.REFUND ? 'bg-orange-50 text-orange-700 border-orange-200' :
                          payment.payment_type === PaymentType.DEPOSIT ? 'bg-blue-50 text-blue-700 border-blue-200' :
                          'bg-emerald-50 text-emerald-700 border-emerald-200'
                        }`}>
                          {payment.payment_type}
                        </span>
                        <span className="text-xs font-bold text-slate-600 bg-slate-100 px-2.5 py-1 rounded-md uppercase border border-slate-200">
                          {payment.payment_mode}
                        </span>
                      </div>
                      {payment.notes && <div className="text-xs text-slate-500 mt-1.5 truncate max-w-[200px]" title={payment.notes}>{payment.notes}</div>}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right">
                      <span className={`text-base font-black ${payment.payment_type === PaymentType.REFUND ? 'text-orange-600' : 'text-emerald-600'}`}>
                        {payment.payment_type === PaymentType.REFUND ? '-' : '+'}{formatCurrency(payment.amount)}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-bold text-slate-700">{(payment as any).staff?.name || (payment.created_by ? `Staff #${payment.created_by.slice(0,6)}` : 'System')}</div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* 3. Split View */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
        
        {/* Left Column: Order Items */}
        <div className="xl:col-span-2 space-y-6">
          <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
            <div className="bg-slate-50 px-6 py-5 border-b border-slate-200 flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4">
              <h2 className="text-lg font-bold text-slate-900 uppercase tracking-wide">Order Items</h2>
              {isReturnable && (
                <div className="flex items-center gap-2">
                  <Button onClick={handleMarkAllExcellent} variant="outline" className="font-bold border-slate-300 text-slate-700">
                    <CheckCircle2 className="w-4 h-4 mr-2 text-emerald-600" /> Mark All Good
                  </Button>
                </div>
              )}
            </div>

            
            <div className="divide-y divide-slate-100">
              {order.items.map((item) => {
                const rItem = returnItems[item.id] || { status: null, damage_fee: 0, notes: "" };
                const isExcellent = rItem.status === 'excellent';
                const isDamaged = rItem.status === 'damaged';
                const isMissing = rItem.status === 'missing';
                const product = (item as any).product;
                const imgUrl = getImageUrl(product);

                return (
                  <div key={item.id} className={`p-6 transition-all duration-300 ${highlightedItemId === item.id ? 'bg-emerald-100/80 ring-2 ring-emerald-400' : isExcellent ? 'bg-emerald-50/50' : isDamaged ? 'bg-orange-50/50' : isMissing ? 'bg-red-50/50' : ''}`}>
                    <div className="flex flex-col sm:flex-row sm:items-center gap-6">
                      <div className="w-20 h-20 rounded-xl bg-slate-100 flex-shrink-0 border-2 border-slate-200 overflow-hidden shadow-sm">
                        {imgUrl ? (
                          <img src={imgUrl} alt={product?.name} className="w-full h-full object-cover" />
                        ) : (
                          <div className="w-full h-full flex items-center justify-center text-slate-300">
                            <Package className="w-8 h-8" />
                          </div>
                        )}
                      </div>
                      <div className="flex-1">
                        <h4 className="text-lg font-bold text-slate-900">{product?.name || `Product #${item.product_id?.slice(0, 6).toUpperCase()}`}</h4>
                        <div className="flex flex-wrap items-center gap-x-3 gap-y-1 mt-1">
                          <p className="text-sm font-bold text-slate-700">
                            Qty: {item.quantity} × {formatCurrency(item.price_per_day)}
                          </p>
                          
                          {item.discount > 0 && (
                            <span className="text-xs font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-100">
                              -{item.discount_type === 'percent' ? `${item.discount}%` : formatCurrency(item.discount)} Off
                            </span>
                          )}

                          {item.gst_percentage > 0 && (
                            <span className="text-[10px] font-bold text-blue-600 bg-blue-50 px-2 py-0.5 rounded border border-blue-100 uppercase tracking-tight">
                              {item.gst_percentage}% GST Incl.
                            </span>
                          )}
                        </div>
                        
                        {(item.gst_amount > 0 || item.discount > 0) && (
                          <p className="text-[10px] text-slate-400 mt-1 font-medium">
                            Base: {formatCurrency(item.base_amount)} + GST: {formatCurrency(item.gst_amount)}
                          </p>
                        )}
                      </div>

                      {isReturnable ? (
                        <div className="flex flex-wrap items-center gap-2">
                          <Button
                            type="button"
                            onClick={() => handleItemUpdate(item.id, 'status', 'excellent')}
                            variant="outline"
                            className={`h-12 px-4 font-bold rounded-xl transition-all ${isExcellent ? 'bg-emerald-600 text-white border-emerald-600 hover:bg-emerald-700 hover:text-white' : 'border-slate-200 text-slate-600 hover:bg-emerald-50 hover:text-emerald-700 hover:border-emerald-200'}`}
                          >
                            <CheckCircle2 className={`w-5 h-5 mr-2 ${isExcellent ? 'text-white' : 'text-emerald-500'}`} /> Good
                          </Button>
                          <Button
                            type="button"
                            onClick={() => handleItemUpdate(item.id, 'status', 'damaged')}
                            variant="outline"
                            className={`h-12 px-4 font-bold rounded-xl transition-all ${isDamaged ? 'bg-orange-500 text-white border-orange-500 hover:bg-orange-600 hover:text-white' : 'border-slate-200 text-slate-600 hover:bg-orange-50 hover:text-orange-700 hover:border-orange-200'}`}
                          >
                            <AlertTriangle className={`w-5 h-5 mr-2 ${isDamaged ? 'text-white' : 'text-orange-500'}`} /> Damaged
                          </Button>
                        </div>
                      ) : (
                        <span className={`text-sm font-bold px-3 py-1.5 rounded-lg border-2 ${item.is_returned ? 'bg-emerald-50 text-emerald-700 border-emerald-200' : 'bg-slate-50 text-slate-600 border-slate-200'}`}>
                          {item.is_returned ? "Returned" : "Pending"}
                        </span>
                      )}
                    </div>

                    {isReturnable && isDamaged && (
                      <div className="mt-4 p-4 bg-white border-2 border-orange-200 rounded-xl space-y-3 shadow-sm">
                        <div className="flex flex-col sm:flex-row gap-4 items-start">
                          <div className="flex-1 space-y-2 w-full">
                            <label className="text-xs font-bold text-slate-500 uppercase tracking-widest">Damage Notes</label>
                            <Input
                              value={rItem.notes}
                              onChange={(e) => handleItemUpdate(item.id, 'notes', e.target.value)}
                              placeholder="Describe damage (e.g. Broken clasp)"
                              className="h-12 border-slate-300 focus:border-orange-400 text-base rounded-lg"
                            />
                          </div>
                          <div className="w-full sm:w-32 space-y-2">
                            <label className="text-xs font-bold text-slate-500 uppercase tracking-widest">Damaged Qty</label>
                            <Input
                              type="number"
                              value={rItem.damaged_quantity || ""}
                              min={1}
                              max={item.quantity}
                              onChange={(e) => {
                                const raw = e.target.value;
                                if (raw === '') {
                                  handleItemUpdate(item.id, 'damaged_quantity', 0);
                                  return;
                                }
                                const parsed = parseInt(raw);
                                if (!isNaN(parsed)) {
                                  handleItemUpdate(item.id, 'damaged_quantity', parsed);
                                }
                              }}
                              onBlur={() => {
                                // Clamp to valid range on blur
                                const clamped = Math.max(1, Math.min(item.quantity, rItem.damaged_quantity || 1));
                                handleItemUpdate(item.id, 'damaged_quantity', clamped);
                              }}
                              placeholder="0"
                              className="h-12 border-slate-300 focus:border-orange-400 font-bold text-lg rounded-lg"
                            />
                            <p className="text-[10px] text-slate-400">of {item.quantity} total</p>
                          </div>
                          <div className="w-full sm:w-40 space-y-2">
                            <label className="text-xs font-bold text-slate-500 uppercase tracking-widest">Fee (₹)</label>
                            <Input
                              type="number"
                              value={rItem.damage_fee || ""}
                              onChange={(e) => handleItemUpdate(item.id, 'damage_fee', parseFloat(e.target.value) || 0)}
                              placeholder="0"
                              className="h-12 border-slate-300 focus:border-orange-400 font-bold text-lg rounded-lg"
                            />
                          </div>
                          <div className="w-full sm:w-32 space-y-2">
                            <label className="text-xs font-bold text-transparent select-none uppercase tracking-widest">Save</label>
                            {(() => {
                              const dbItem = order.items.find(i => i.id === item.id);
                              if (!dbItem) return null;

                              const dbStatus = dbItem.condition_rating === 'damaged' ? 'damaged' : (dbItem.condition_rating === 'excellent' ? 'excellent' : null);
                              const dbDamagedQty = dbItem.condition_rating === 'damaged' ? (dbItem.damaged_quantity || 0) : 0;
                              const currentDamagedQty = rItem.status === 'damaged' ? (rItem.damaged_quantity || 0) : 0;
                              
                              const isDirty = 
                                rItem.status !== dbStatus ||
                                rItem.damage_fee !== (dbItem.damage_charges || 0) ||
                                currentDamagedQty !== dbDamagedQty ||
                                rItem.notes !== (dbItem.damage_description || "");

                              if (isDirty) {
                                return (
                                  <Button
                                    type="button"
                                    onClick={() => handleSaveItemDamage(item.id)}
                                    disabled={isSavingItem}
                                    className="h-12 w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-lg shadow-sm flex items-center justify-center gap-2"
                                  >
                                    {isSavingItem ? (
                                      <Loader2 className="w-4 h-4 animate-spin" />
                                    ) : (
                                      <Save className="w-4 h-4" />
                                    )}
                                    <span>Save</span>
                                  </Button>
                                );
                              }

                              if (rItem.status === null) {
                                return (
                                  <Button
                                    type="button"
                                    disabled
                                    className="h-12 w-full bg-slate-100 text-slate-400 font-bold rounded-lg border border-slate-200 flex items-center justify-center gap-2"
                                  >
                                    <span>Pending</span>
                                  </Button>
                                );
                              }

                              return (
                                <div className="h-12 w-full bg-emerald-50 text-emerald-700 font-bold rounded-lg border-2 border-emerald-200 flex items-center justify-center gap-2 shadow-sm animate-in fade-in zoom-in duration-300">
                                  <CheckCircle2 className="w-5 h-5 text-emerald-600" />
                                  <span>Saved</span>
                                </div>
                              );
                            })()}
                          </div>
                        </div>
                        {/* Auto-good info */}
                        {rItem.damaged_quantity < item.quantity && (
                          <div className="flex items-center gap-1.5 text-xs text-emerald-600 bg-emerald-50 px-3 py-2 rounded-lg border border-emerald-200">
                            <CheckCircle2 className="w-3.5 h-3.5" />
                            <span>{item.quantity - rItem.damaged_quantity} of {item.quantity} units auto-marked as <strong>Good</strong></span>
                          </div>
                        )}
                      </div>
                    )}

                    {/* Show damage/return info for already-returned items */}
                    {!isReturnable && item.is_returned && (
                      <div className="mt-3 space-y-2">
                        {item.condition_rating && (
                          <span className={`inline-block text-[10px] font-bold px-2 py-1 rounded border ${
                            item.condition_rating === 'damaged' || item.condition_rating === 'fair'
                              ? 'bg-orange-50 text-orange-700 border-orange-200'
                              : 'bg-emerald-50 text-emerald-700 border-emerald-200'
                          }`}>
                            Condition: {item.condition_rating.charAt(0).toUpperCase() + item.condition_rating.slice(1)}
                          </span>
                        )}
                        {item.damage_description && (
                          <div className="px-3 py-2 bg-orange-50 border border-orange-200 rounded-lg">
                            <p className="text-[10px] font-bold text-orange-600 uppercase tracking-widest mb-0.5">Damage Notes</p>
                            <p className="text-xs text-orange-700">{item.damage_description}</p>
                          </div>
                        )}
                        {(item.damage_charges || 0) > 0 && (
                          <div className="flex items-center gap-1.5 text-xs text-orange-700 font-bold">
                            <AlertTriangle className="w-3 h-3" />
                            <span>Damage Fee: {formatCurrency(item.damage_charges || 0)}</span>
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
            
            {/* Damage Assessment Panel — for flagged/returned orders with damage */}
            {(order.status === OrderStatus.FLAGGED || order.items.some(i => i.condition_rating === 'damaged')) && !isReturnable && (
              <div className="p-6 border-t border-slate-200">
                <DamageAssessmentPanel order={order} />
              </div>
            )}

            {/* Settlement Footer (Only visible when processing returns) */}
            {isReturnable && (
               <div className="bg-slate-50 p-6 border-t border-slate-200 space-y-4">
                  {/* Live projected total with damage fees */}
                  {(calculatedDamage > 0 || lateFee > 0 || discount > 0) && (
                    <div className="p-4 bg-amber-50 border-2 border-amber-200 rounded-xl space-y-2">
                      <p className="text-xs font-bold text-amber-700 uppercase tracking-widest">Projected Settlement</p>
                      <div className="flex justify-between text-sm text-slate-700">
                        <span>Base Order Total</span>
                        <span className="font-bold">{formatCurrency(baseTotalBeforeReturn)}</span>
                      </div>
                      {calculatedDamage > 0 && (
                        <div className="flex justify-between text-sm text-orange-700">
                          <span>+ Damage Fees</span>
                          <span className="font-bold">{formatCurrency(calculatedDamage)}</span>
                        </div>
                      )}
                      {lateFee > 0 && (
                        <div className="flex justify-between text-sm text-red-700">
                          <span>+ Late Fee</span>
                          <span className="font-bold">{formatCurrency(lateFee)}</span>
                        </div>
                      )}
                      {discount > 0 && (
                        <div className="flex justify-between text-sm text-emerald-700">
                          <span>− Discount</span>
                          <span className="font-bold">−{formatCurrency(discount)}</span>
                        </div>
                      )}
                      <div className="flex justify-between text-sm font-black text-slate-900 pt-2 border-t border-amber-300">
                        <span>New Total</span>
                        <span>{formatCurrency(projected_total)}</span>
                      </div>
                      <div className="flex justify-between text-sm">
                        <span className="text-slate-500">Less: Paid</span>
                        <span className="font-bold text-emerald-600">−{formatCurrency(order.amount_paid || 0)}</span>
                      </div>
                      <div className="flex justify-between text-lg font-black text-slate-900 pt-1">
                        <span>Balance Due</span>
                        <span className={amount_due > 0 ? 'text-red-600' : 'text-emerald-600'}>{formatCurrency(amount_due)}</span>
                      </div>
                    </div>
                  )}

                  {/* Payment Due Warning */}
                  {amount_due > 0 && (
                    <div className="flex items-center gap-3 p-4 bg-red-50 border-2 border-red-200 rounded-xl">
                      <div className="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center flex-shrink-0">
                        <AlertTriangle className="w-5 h-5 text-red-600" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-bold text-red-800">Payment Due — {formatCurrency(amount_due)}</p>
                        <p className="text-xs text-red-600 mt-0.5">Collect the remaining balance before or after completing the return.</p>
                      </div>
                      <Button
                        type="button"
                        onClick={() => {
                          setPaymentForm({ amount: amount_due.toString(), paymentMode: PaymentMode.CASH, paymentType: PaymentType.FINAL, notes: "" });
                          setIsPaymentModalOpen(true);
                        }}
                        className="h-10 px-5 bg-red-600 hover:bg-red-700 text-white font-bold text-sm rounded-xl whitespace-nowrap flex-shrink-0"
                      >
                        Collect Payment
                      </Button>
                    </div>
                  )}

                  <div className="flex flex-col sm:flex-row items-end justify-between gap-4">
                      <div className="flex gap-4 w-full sm:w-auto">
                        <div className="space-y-1">
                          <label className="text-xs font-bold text-slate-500 uppercase tracking-widest">Extra Late Fee</label>
                          <Input type="number" value={lateFee || ""} onChange={(e) => setLateFee(parseFloat(e.target.value) || 0)} className="w-32 h-12 font-bold text-lg" placeholder="0" />
                        </div>
                        <div className="space-y-1">
                          <label className="text-xs font-bold text-slate-500 uppercase tracking-widest">Discount</label>
                          <Input type="number" value={discount || ""} onChange={(e) => setDiscount(parseFloat(e.target.value) || 0)} className="w-32 h-12 font-bold text-lg" placeholder="0" />
                        </div>
                      </div>
                     <Button
                        onClick={handleReturnClick}
                        disabled={isReturning}
                        className="w-full sm:w-auto h-14 px-8 bg-slate-900 hover:bg-slate-800 text-white font-bold text-lg rounded-xl shadow-md"
                     >
                        {isReturning ? "Processing..." : "Complete Return Process"}
                     </Button>
                  </div>
               </div>
            )}
          </div>
        </div>

        {/* Right Column: Customer & Money */}
        <div className="space-y-6">
          
          {/* Customer Card */}
          <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
            <h2 className="text-xs font-bold text-slate-500 uppercase tracking-widest mb-4">Customer</h2>
            <p className="text-2xl font-black text-slate-900 leading-tight">{order.customer?.name}</p>
            <a 
               href={`tel:${order.customer?.phone}`} 
               className="mt-6 flex items-center justify-center gap-3 w-full bg-green-50 hover:bg-green-100 text-green-700 border-2 border-green-200 py-4 rounded-xl font-black text-lg transition-colors shadow-sm"
            >
               <Phone className="w-5 h-5" /> {order.customer?.phone}
            </a>
            {order.customer?.alt_phone && (
              <a 
                 href={`tel:${order.customer.alt_phone}`} 
                 className="mt-3 flex items-center justify-center gap-3 w-full bg-slate-50 hover:bg-slate-100 text-slate-600 border border-slate-200 py-3 rounded-xl font-bold text-sm transition-colors"
              >
                 <Phone className="w-4 h-4" /> {order.customer.alt_phone}
                 <span className="text-xs text-slate-400 font-medium">(Alt)</span>
              </a>
            )}
          </div>

          {/* Receipt Card */}
          <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-sm">
            <div className="flex items-center justify-between mb-5">
              <h2 className="text-xs font-bold text-slate-500 uppercase tracking-widest flex items-center gap-2">
                <ReceiptText className="w-4 h-4" /> Financial Receipt
              </h2>
              {!isFinalized && <Button variant="ghost" size="sm" className="text-xs text-primary" onClick={() => setIsAdjustmentModalOpen(true)}>
                <Edit3 className="w-3 h-3 mr-1" /> Adjust
              </Button>}
            </div>
            
            {(() => {
              // Calculate breakdown from items (more accurate than order summary fields)
              const rawSubtotal = order.items.reduce((sum, item) => sum + (item.subtotal || 0), 0);
              const afterItemDiscountTotal = order.items.reduce((sum, item) => sum + (item.base_amount || 0) + (item.gst_amount || 0), 0);
              const itemDiscountsTotal = rawSubtotal - afterItemDiscountTotal;
              
              // Base amount excluding GST is the sum of all item base_amounts
              const totalBaseExclGst = order.items.reduce((sum, item) => sum + (item.base_amount || 0), 0);
              const totalGst = order.items.reduce((sum, item) => sum + (item.gst_amount || 0), 0);
              
              // The order-level discount is applied on the afterItemDiscountTotal
              const orderLevelDiscount = Math.max(0, afterItemDiscountTotal - order.total_amount);

              return (
                <div className="space-y-4">
                  {/* 1. Raw Subtotal */}
                  <div className="flex justify-between text-slate-600 font-medium text-sm">
                    <span>Subtotal</span>
                    <span>{formatCurrency(rawSubtotal)}</span>
                  </div>

                  {/* 2. Item Discounts Breakdown */}
                  {itemDiscountsTotal > 0 && (
                    <div className="space-y-1.5 pt-1">
                      <div className="flex justify-between text-orange-600 font-bold text-sm">
                        <span className="flex items-center gap-1 uppercase text-[10px] tracking-wider">
                          <Info className="w-3 h-3" /> Item Discounts
                        </span>
                        <span>- {formatCurrency(itemDiscountsTotal)}</span>
                      </div>
                      <div className="pl-4 space-y-1">
                        {order.items.map((item) => {
                          const itemRaw = item.subtotal || 0;
                          const itemAfter = (item.base_amount || 0) + (item.gst_amount || 0);
                          const itemDisc = itemRaw - itemAfter;
                          if (itemDisc <= 0) return null;
                          
                          return (
                            <div key={item.id} className="flex justify-between text-[11px] text-orange-500 font-medium italic">
                              <span className="truncate max-w-[150px]">{item.product?.name}</span>
                              <span>- {formatCurrency(itemDisc)}</span>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  )}

                  {/* 3. Base & GST Breakdown */}
                  <div className="pt-3 border-t border-dashed border-slate-100 space-y-2">
                    <div className="flex justify-between text-xs text-slate-500">
                      <span>Base Amount (excl. GST)</span>
                      <span className="font-medium">{formatCurrency(totalBaseExclGst)}</span>
                    </div>
                    <div className="flex justify-between text-xs text-blue-600">
                      <span className="flex items-center gap-1">
                        <Info className="w-3 h-3" /> GST (included)
                      </span>
                      <span className="font-semibold">{formatCurrency(totalGst)}</span>
                    </div>
                  </div>

                  {/* 4. Order-Level Discount */}
                  {orderLevelDiscount > 0 && (
                    <div className="flex justify-between text-purple-600 font-bold text-sm pt-2 border-t border-slate-50">
                      <span className="uppercase text-[10px] tracking-wider">Order Discount</span>
                      <span>- {formatCurrency(orderLevelDiscount)}</span>
                    </div>
                  )}

                  {/* 5. Extra Fees (Late/Damage) */}
                  {(order.late_fee || 0) > 0 && (
                    <div className="flex justify-between text-red-600 font-bold text-sm pt-2 border-t border-slate-50">
                      <span className="uppercase text-[10px] tracking-wider">Late Fee</span>
                      <span>+ {formatCurrency(order.late_fee)}</span>
                    </div>
                  )}
                  {(order.damage_charges_total || 0) > 0 && (
                    <div className="flex justify-between text-amber-600 font-bold text-sm">
                      <span className="uppercase text-[10px] tracking-wider">Damage Charges</span>
                      <span>+ {formatCurrency(order.damage_charges_total)}</span>
                    </div>
                  )}

                  {/* 6. Grand Total */}
                  <div className="flex justify-between text-slate-800 font-black text-sm pt-4 border-t-2 border-slate-100">
                    <div>
                      <span className="text-base">Grand Total</span>
                      {totalGst > 0 && (
                        <span className="block text-[10px] text-slate-400 font-medium mt-0.5">Inclusive of GST</span>
                      )}
                    </div>
                    <span className="text-2xl">{formatCurrency(order.total_amount)}</span>
                  </div>

                  {/* 7. Payments & Balance — contextual based on order status */}
                  {order.status === OrderStatus.CANCELLED ? (
                    <div className="pt-4 space-y-2.5">
                      {/* Show what was originally paid */}
                      {(order.advance_amount || 0) > 0 && (
                        <div className="flex justify-between text-slate-500 font-medium text-xs px-1">
                          <span>Original Advance</span>
                          <span>{formatCurrency(order.advance_amount || 0)}</span>
                        </div>
                      )}

                      {/* Show refund status */}
                      {(order.amount_paid || 0) === 0 ? (
                        <>
                          {/* Fully refunded */}
                          <div className="flex justify-between text-orange-600 font-bold text-sm p-3 bg-orange-50 rounded-xl border border-orange-100">
                            <span className="flex items-center gap-1">Advance Refunded</span>
                            <span>- {formatCurrency(order.advance_amount || 0)}</span>
                          </div>
                          <div className="flex justify-between text-slate-400 font-black text-lg px-1">
                            <span>No Balance Due</span>
                            <span>{formatCurrency(0)}</span>
                          </div>
                        </>
                      ) : order.payment_status === PaymentStatus.REFUND_WAIVED ? (
                        <>
                          {/* Refund waived — money kept */}
                          <div className="flex justify-between text-teal-600 font-bold text-sm p-3 bg-teal-50 rounded-xl border border-teal-100">
                            <span className="flex items-center gap-1">Money Kept (No Refund)</span>
                            <span>{formatCurrency(order.amount_paid)}</span>
                          </div>
                          <div className="flex justify-between text-slate-400 font-black text-lg px-1">
                            <span>No Balance Due</span>
                            <span>{formatCurrency(0)}</span>
                          </div>
                        </>
                      ) : (
                        <>
                          {/* Money still held — pending refund */}
                          <div className="flex justify-between text-amber-600 font-bold text-sm p-3 bg-amber-50 rounded-xl border border-amber-200">
                            <span className="flex items-center gap-1">Amount Held</span>
                            <span>{formatCurrency(order.amount_paid)}</span>
                          </div>
                          <div className="flex justify-between text-amber-700 font-black text-lg px-1">
                            <span>Refundable</span>
                            <span>{formatCurrency(order.amount_paid)}</span>
                          </div>
                        </>
                      )}

                      {/* Cancellation info */}
                      <div className="pt-2 space-y-2">
                        <span className="text-lg font-black text-slate-400 uppercase tracking-wider text-xs">Order Cancelled</span>
                        {order.cancellation_reason && (
                          <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
                            <p className="text-xs font-semibold text-red-700 mb-1">Cancellation Reason</p>
                            <p className="text-sm text-red-600">{order.cancellation_reason}</p>
                            {order.cancelled_at && (
                              <p className="text-[10px] text-red-400 mt-1">
                                Cancelled on {new Date(order.cancelled_at).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}
                              </p>
                            )}
                          </div>
                        )}
                      </div>
                    </div>
                  ) : order.status === OrderStatus.COMPLETED ? (
                    <div className="pt-6 mt-4 border-t-2 border-slate-100 flex justify-between items-center">
                      <span className="text-lg font-black text-emerald-700">Total Settled</span>
                      <span className="text-2xl font-black text-emerald-600">{formatCurrency(order.amount_paid || 0)}</span>
                    </div>
                  ) : (
                    <div className="pt-4 space-y-2.5">
                      <div className="flex justify-between text-emerald-600 font-bold text-sm p-3 bg-emerald-50 rounded-xl border border-emerald-100">
                        <span className="flex items-center gap-1">Less: Amount Paid</span>
                        <span>- {formatCurrency(order.amount_paid || 0)}</span>
                      </div>
                      
                      <div className="flex justify-between items-center pt-2 px-1">
                        <span className="text-lg font-black text-slate-900">Balance Due</span>
                        <span className={`text-2xl font-black ${amount_due > 0 ? "text-red-600" : "text-emerald-600"}`}>
                          {formatCurrency(amount_due)}
                        </span>
                      </div>
                    </div>
                  )}
                </div>
              );
            })()}
            </div>

            {/* Record Payment — only for active orders */}
            {!isFinalized && amount_due > 0 && (
              <Button 
                onClick={() => {
                  setPaymentForm({ amount: amount_due.toString(), paymentMode: PaymentMode.CASH, paymentType: PaymentType.FINAL, notes: "" });
                  setIsPaymentModalOpen(true);
                }} 
                className="w-full mt-6 h-12 bg-slate-900 hover:bg-slate-800 text-white font-bold text-base rounded-xl shadow-md"
              >
                Record Payment
              </Button>
            )}



            {/* Cancellation Refund — for cancelled orders */}
            {order.status === OrderStatus.CANCELLED && (
              <div className="space-y-3 mt-4">
                {/* Rental payment refund */}
                {(order.amount_paid || 0) > 0 && (
                  <>
                    <Button 
                      onClick={() => {
                        setIsCancellationRefund(true);
                        setRefundForm({ paymentMode: PaymentMode.CASH, notes: "Cancellation Refund", amount: String(order.amount_paid || 0) });
                        setIsRefundModalOpen(true);
                      }} 
                      className="w-full h-12 bg-amber-100 hover:bg-amber-200 text-amber-800 border border-amber-300 font-bold text-sm rounded-xl shadow-sm transition-colors truncate"
                    >
                      Refund Payment ({formatCurrency(order.amount_paid)})
                    </Button>
                    {order.payment_status !== PaymentStatus.REFUND_WAIVED && (
                      <Button
                        onClick={() => setIsKeepMoneyModalOpen(true)}
                        className="w-full h-10 bg-teal-50 hover:bg-teal-100 text-teal-700 border border-teal-200 font-bold text-sm rounded-xl transition-colors"
                      >
                        Keep Money — No Refund Needed
                      </Button>
                    )}
                    {order.payment_status === PaymentStatus.REFUND_WAIVED && (
                      <div className="px-3 py-2.5 bg-teal-50 border border-teal-200 rounded-xl text-xs text-teal-700 font-bold text-center flex items-center justify-center gap-1.5">
                        <CheckCircle2 className="w-3.5 h-3.5" /> Refund waived — money kept
                      </div>
                    )}
                  </>
                )}
                {/* Deposit refund removed - no longer applicable */}
              </div>
            )}
          </div>

        </div>

      {/* Payment Modal */}
      <Modal
        open={isPaymentModalOpen}
        onClose={() => setIsPaymentModalOpen(false)}
        title={paymentForm.paymentType === PaymentType.DEPOSIT ? "Collect Security Deposit" : "Collect Payment"}
      >
        <div className="p-6 space-y-6">
          {/* Summary Box */}
          <div className="bg-slate-50 p-5 rounded-2xl border border-slate-200 flex justify-between items-center shadow-sm">
            <div>
              <p className="text-xs font-bold text-slate-500 uppercase tracking-widest mb-1">
                {'Remaining Due'}
              </p>
              <p className="text-2xl font-black text-slate-900">
                {formatCurrency(amount_due)}
              </p>
            </div>
            <div className="text-right">
              <p className="text-xs font-bold text-slate-500 uppercase tracking-widest mb-1">Paying</p>
              <p className={`text-2xl font-black ${parseFloat(paymentForm.amount) > (amount_due) ? 'text-red-600' : 'text-emerald-600'}`}>
                {formatCurrency(parseFloat(paymentForm.amount) || 0)}
              </p>
            </div>
          </div>

          <div className="space-y-3">
            <Label className="font-bold text-slate-700 uppercase tracking-wider text-xs">Payment Method</Label>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
              {[
                { id: PaymentMode.CASH, label: "Cash", icon: Banknote },
                { id: PaymentMode.UPI, label: "UPI", icon: Smartphone },
                { id: PaymentMode.GPAY, label: "GPay", icon: Smartphone },
                { id: PaymentMode.BANK_TRANSFER, label: "Bank", icon: Building2 },
              ].map((method) => {
                const Icon = method.icon;
                const isSelected = paymentForm.paymentMode === method.id;
                return (
                  <button
                    key={method.id}
                    type="button"
                    onClick={() => setPaymentForm({ ...paymentForm, paymentMode: method.id })}
                    className={`flex flex-col items-center justify-center p-4 rounded-xl border-2 transition-all ${
                      isSelected 
                        ? 'border-slate-900 bg-slate-900 text-white shadow-md' 
                        : 'border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:bg-slate-50'
                    }`}
                  >
                    <Icon className={`w-6 h-6 mb-2 ${isSelected ? 'text-white' : 'text-slate-400'}`} />
                    <span className="text-sm font-bold">{method.label}</span>
                  </button>
                )
              })}
            </div>
          </div>
          
          <div className="space-y-3">
            <Label className="font-bold text-slate-700 uppercase tracking-wider text-xs flex justify-between items-center">
              <span>Amount (₹)</span>
              <button 
                type="button" 
                onClick={() => setPaymentForm({ ...paymentForm, amount: (amount_due).toString() })}
                className="text-emerald-600 hover:text-emerald-700 font-bold bg-emerald-50 px-3 py-1 rounded-full text-[10px]"
              >
                PAY FULL AMOUNT
              </button>
            </Label>
            <Input
              type="number"
              value={paymentForm.amount}
              onChange={(e) => {
                 const val = e.target.value;
                 const maxPayable = amount_due;
                 if (parseFloat(val) > maxPayable) {
                    setPaymentForm({ ...paymentForm, amount: maxPayable.toString() });
                 } else {
                    setPaymentForm({ ...paymentForm, amount: val });
                 }
              }}
              className="w-full h-14 text-2xl font-black rounded-xl border-slate-300 bg-slate-50 focus:bg-white shadow-inner px-4"
              placeholder="0"
            />
          </div>

          <div className="space-y-3">
            <Label className="font-bold text-slate-700 uppercase tracking-wider text-xs">Notes / Ref ID <span className="text-slate-400 font-normal capitalize">(Optional)</span></Label>
            <Input
              value={paymentForm.notes}
              onChange={(e) => setPaymentForm({ ...paymentForm, notes: e.target.value })}
              className="w-full h-12 rounded-xl border-slate-300 bg-slate-50 focus:bg-white px-4"
              placeholder="E.g. UPI Ref #123456"
            />
          </div>

            <div className="pt-6 flex justify-end gap-3 border-t border-slate-100">
              <Button variant="outline" onClick={() => setIsPaymentModalOpen(false)} className="h-12 px-6 rounded-xl font-bold border-slate-200 text-slate-600 hover:bg-slate-50">Cancel</Button>
              <Button onClick={handleCollectPayment} disabled={isCreatingPayment} className="h-12 px-8 rounded-xl font-bold text-white bg-emerald-600 hover:bg-emerald-700 shadow-md">
                {isCreatingPayment ? "Processing..." : "Confirm Payment"}
              </Button>
            </div>
          </div>
        </Modal>

        {/* Refund Modal (Deposit or Cancellation) */}
        <Modal
          open={isRefundModalOpen}
          onClose={() => { setIsRefundModalOpen(false); setIsCancellationRefund(false); }}
          title={isCancellationRefund ? "Refund Payment" : "Refund Security Deposit"}
        >
          <div className="p-6 space-y-6">
            {/* Amount Display / Edit */}
            {isCancellationRefund ? (
              <div className="space-y-3">
                <Label className="font-bold text-slate-700 uppercase tracking-wider text-xs">Refund Amount (₹)</Label>
                <Input
                  type="number"
                  value={refundForm.amount}
                  onChange={(e) => {
                    const val = e.target.value;
                    const maxRefund = order?.amount_paid || 0;
                    if (parseFloat(val) > maxRefund) {
                      setRefundForm({ ...refundForm, amount: maxRefund.toString() });
                    } else {
                      setRefundForm({ ...refundForm, amount: val });
                    }
                  }}
                  className="w-full h-14 text-2xl font-black rounded-xl border-slate-300 bg-slate-50 focus:bg-white shadow-inner px-4"
                  placeholder="0"
                />
                <p className="text-xs text-slate-500">Maximum refundable: {formatCurrency(order?.amount_paid || 0)}</p>
              </div>
            ) : (
              <div className="bg-orange-50 p-5 rounded-2xl border border-orange-200 flex justify-between items-center shadow-sm">
                <div>
                  <p className="text-xs font-bold text-orange-600 uppercase tracking-widest mb-1">Refund Amount</p>
                  <p className="text-2xl font-black text-orange-900">{formatCurrency(0 || 0)}</p>
                </div>
              </div>
            )}

            <div className="space-y-3">
              <Label className="font-bold text-slate-700 uppercase tracking-wider text-xs">Refund Method</Label>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                {[
                  { id: PaymentMode.CASH, label: "Cash", icon: Banknote },
                  { id: PaymentMode.UPI, label: "UPI", icon: Smartphone },
                  { id: PaymentMode.GPAY, label: "GPay", icon: Smartphone },
                  { id: PaymentMode.BANK_TRANSFER, label: "Bank", icon: Building2 },
                ].map((method) => {
                  const Icon = method.icon;
                  const isSelected = refundForm.paymentMode === method.id;
                  return (
                    <button
                      key={method.id}
                      type="button"
                      onClick={() => setRefundForm({ ...refundForm, paymentMode: method.id })}
                      className={`flex flex-col items-center justify-center p-4 rounded-xl border-2 transition-all ${
                        isSelected 
                          ? 'border-orange-500 bg-orange-500 text-white shadow-md' 
                          : 'border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:bg-slate-50'
                      }`}
                    >
                      <Icon className={`w-6 h-6 mb-2 ${isSelected ? 'text-white' : 'text-slate-400'}`} />
                      <span className="text-sm font-bold">{method.label}</span>
                    </button>
                  )
                })}
              </div>
            </div>

            <div className="space-y-3">
              <Label className="font-bold text-slate-700 uppercase tracking-wider text-xs">Notes / Ref ID</Label>
              <Input
                value={refundForm.notes}
                onChange={(e) => setRefundForm({ ...refundForm, notes: e.target.value })}
                className="w-full h-12 rounded-xl border-slate-300 bg-slate-50 focus:bg-white px-4"
                placeholder="E.g. Refunded via UPI"
              />
            </div>

            <div className="pt-6 flex justify-end gap-3 border-t border-slate-100">
              <Button variant="outline" onClick={() => { setIsRefundModalOpen(false); setIsCancellationRefund(false); }} className="h-12 px-6 rounded-xl font-bold border-slate-200 text-slate-600 hover:bg-slate-50">Cancel</Button>
              <Button 
                onClick={() => {
                  if (isCancellationRefund) {
                    // Cancellation refund — server handles order update atomically
                    const refundAmount = parseFloat(refundForm.amount) || 0;
                    if (!order || refundAmount <= 0) {
                      showError("Validation Error", "Amount must be greater than 0");
                      return;
                    }
                    if (refundAmount > (order.amount_paid || 0)) {
                      showError("Validation Error", `Refund cannot exceed paid amount (${formatCurrency(order.amount_paid)})`);
                      return;
                    }
                    createPayment({
                      order_id: order.id,
                      payment_type: PaymentType.REFUND,
                      amount: refundAmount,
                      payment_mode: refundForm.paymentMode,
                      notes: refundForm.notes || "Cancellation Refund",
                    }, {
                      onSuccess: () => {
                        setIsRefundModalOpen(false);
                        setIsCancellationRefund(false);
                        setRefundForm({ paymentMode: PaymentMode.CASH, notes: "", amount: "0" });
                        showSuccess("Refund Processed", `${formatCurrency(refundAmount)} has been refunded.`);
                      },
                    });
                  } else {
                    // Deposit refund
                    handleRefundDeposit();
                  }
                }} 
                disabled={isCreatingPayment || isUpdating} 
                className="h-12 px-8 rounded-xl font-bold text-white bg-orange-600 hover:bg-orange-700 shadow-md"
              >
                {isCreatingPayment || isUpdating ? "Processing..." : "Confirm Refund"}
              </Button>
            </div>
          </div>
        </Modal>

        {/* Adjustment Modal */}
        <Modal
          open={isAdjustmentModalOpen}
          onClose={() => setIsAdjustmentModalOpen(false)}
          title="Apply Financial Adjustment"
        >
          <div className="p-6 space-y-6">
            <div className="space-y-3">
              <Label className="font-bold text-slate-700 uppercase tracking-wider text-xs">Adjustment Type</Label>
              <Select value={adjustmentForm.type} onValueChange={(v: any) => setAdjustmentForm({ ...adjustmentForm, type: v })}>
                <SelectTrigger className="h-12"><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="discount">Discount (reduces total)</SelectItem>
                  <SelectItem value="late_fee">Late Fee (increases total)</SelectItem>
                  <SelectItem value="damage_fee">Damage Fee (increases total)</SelectItem>
                  <SelectItem value="extra_charge">Extra Charge (increases total)</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-3">
              <Label className="font-bold text-slate-700 uppercase tracking-wider text-xs">Amount (₹)</Label>
              <Input type="number" value={adjustmentForm.amount} onChange={e => setAdjustmentForm({ ...adjustmentForm, amount: e.target.value })} className="h-14 text-2xl font-black" placeholder="0" />
            </div>
            <div className="space-y-3">
              <Label className="font-bold text-slate-700 uppercase tracking-wider text-xs">Reason / Notes</Label>
              <Input value={adjustmentForm.notes} onChange={e => setAdjustmentForm({ ...adjustmentForm, notes: e.target.value })} className="h-12" placeholder="E.g. Loyal customer discount" />
            </div>
            <div className="pt-6 flex justify-end gap-3 border-t border-slate-100">
              <Button variant="outline" onClick={() => setIsAdjustmentModalOpen(false)} className="h-12 px-6 rounded-xl font-bold">Cancel</Button>
              <Button className="h-12 px-8 rounded-xl font-bold text-white bg-slate-900 hover:bg-slate-800" disabled={isUpdating || isCreatingPayment} onClick={() => {
                if (!order) return;
                const val = parseFloat(adjustmentForm.amount) || 0;
                if (val <= 0) { showError('Invalid', 'Amount must be greater than 0'); return; }

                const isDeduction = adjustmentForm.type === 'discount';
                const newTotal = isDeduction ? Math.max(0, order.total_amount - val) : order.total_amount + val;
                const newLateFee = adjustmentForm.type === 'late_fee' ? (order.late_fee || 0) + val : (order.late_fee || 0);
                const newDiscount = adjustmentForm.type === 'discount' ? (order.discount || 0) + val : (order.discount || 0);
                const newDamage = adjustmentForm.type === 'damage_fee' ? (order.damage_charges_total || 0) + val : (order.damage_charges_total || 0);
                const newAmountPaid = order.amount_paid || 0;
                const newPaymentStatus = newAmountPaid >= newTotal ? 'paid' : newAmountPaid > 0 ? 'partial' : 'pending';

                // Record as adjustment payment
                const label = adjustmentForm.type === 'discount' ? 'Discount' : adjustmentForm.type === 'late_fee' ? 'Late Fee' : adjustmentForm.type === 'damage_fee' ? 'Damage Fee' : 'Extra Charge';
                createPayment({
                  order_id: order.id,
                  payment_type: PaymentType.ADJUSTMENT,
                  amount: val,
                  payment_mode: PaymentMode.CASH,
                  notes: `${label}: ${adjustmentForm.notes || 'N/A'}`,
                }, {
                  onSuccess: () => {
                    updateOrder({ id: order.id, data: {
                      total_amount: newTotal,
                      late_fee: newLateFee,
                      discount: newDiscount,
                      damage_charges_total: newDamage,
                      payment_status: newPaymentStatus,
                    }});
                    setIsAdjustmentModalOpen(false);
                    setAdjustmentForm({ type: 'discount', amount: '0', notes: '' });
                    showSuccess('Adjustment Applied', `${label} of ${formatCurrency(val)} has been applied.`);
                  }
                });
              }}>
                {isUpdating || isCreatingPayment ? 'Processing...' : 'Apply Adjustment'}
              </Button>
            </div>
          </div>
        </Modal>

        {/* Cancel Order Modal — with mandatory reason */}
        {(() => {
          const hasPaid = (order.amount_paid || 0) > 0;
          return (
            <Modal
              open={isCancelModalOpen}
              onClose={() => { setIsCancelModalOpen(false); setCancelReason(""); }}
              title="Cancel Order"
              maxWidth="max-w-lg"
            >
              <div className="p-6 space-y-5">
                <div className="flex items-start gap-4">
                  <div className="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center shrink-0">
                    <XCircle className="w-5 h-5 text-red-600" />
                  </div>
                  <div>
                    <h4 className="text-sm font-semibold text-slate-900 mb-1">Confirm Cancellation</h4>
                    <p className="text-sm text-slate-600 leading-relaxed">
                      Are you sure you want to cancel order <span className="font-semibold text-slate-900">#{order.id.slice(0, 6).toUpperCase()}</span>? This action cannot be undone.
                    </p>
                  </div>
                </div>

                {/* Refund Warning */}
                {hasPaid && (
                  <div className="flex items-start gap-3 p-3.5 bg-amber-50 border border-amber-200 rounded-lg">
                    <Banknote className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
                    <div>
                      <p className="text-sm font-semibold text-amber-800">
                        Payment Collected: {formatCurrency(order.amount_paid)}
                      </p>
                      <p className="text-xs text-amber-700 mt-1 leading-relaxed">
                        After cancellation, you can process a refund from the order detail page.
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
                    value={cancelReason}
                    onChange={(e) => setCancelReason(e.target.value)}
                    placeholder="Enter the reason for cancelling this order..."
                    className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-sm focus:border-red-500 focus:ring-1 focus:ring-red-500 outline-none resize-y min-h-[80px]"
                    rows={3}
                    autoFocus
                  />
                </div>

                <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
                  <Button variant="outline" onClick={() => { setIsCancelModalOpen(false); setCancelReason(""); }} className="h-12 px-6 rounded-xl font-bold border-slate-200 text-slate-600 hover:bg-slate-50">Keep Order</Button>
                  <Button
                    onClick={() => {
                      updateOrder({
                        id: order.id,
                        data: {
                          status: OrderStatus.CANCELLED,
                          cancellation_reason: cancelReason.trim(),
                          cancelled_at: new Date().toISOString(),
                        } as any,
                      });
                      setIsCancelModalOpen(false);
                      setCancelReason("");
                    }}
                    disabled={isUpdating || !cancelReason.trim()}
                    className={`h-12 px-8 rounded-xl font-bold text-white shadow-md ${!cancelReason.trim() ? 'bg-slate-300 cursor-not-allowed' : 'bg-red-600 hover:bg-red-700'}`}
                  >
                    {isUpdating ? "Cancelling..." : "Cancel Order"}
                  </Button>
                </div>
              </div>
            </Modal>
          );
        })()}

        {/* Stock Insufficient Modal */}
        <Modal
          open={isStockErrorModalOpen}
          onClose={() => setIsStockErrorModalOpen(false)}
          title="Cannot Start Rental"
          maxWidth="max-w-lg"
        >
          <div className="p-6">
            <div className="flex items-start gap-4 mb-5">
              <div className="w-10 h-10 rounded-full bg-red-50 flex items-center justify-center shrink-0">
                <AlertTriangle className="w-5 h-5 text-red-600" />
              </div>
              <div>
                <h4 className="text-sm font-semibold text-slate-900 mb-1">Insufficient Stock</h4>
                <p className="text-sm text-slate-600 leading-relaxed">
                  Some items don't have enough stock for today. Please edit the order to adjust quantities before starting the rental.
                </p>
              </div>
            </div>

            {/* Per-item breakdown */}
            <div className="border border-slate-200 rounded-xl overflow-hidden mb-5">
              <table className="w-full text-sm">
                <thead className="bg-slate-50 border-b border-slate-200">
                  <tr>
                    <th className="text-left px-4 py-2.5 text-xs font-bold text-slate-500 uppercase">Item</th>
                    <th className="text-center px-4 py-2.5 text-xs font-bold text-slate-500 uppercase">Ordered</th>
                    <th className="text-center px-4 py-2.5 text-xs font-bold text-slate-500 uppercase">Available</th>
                    <th className="text-center px-4 py-2.5 text-xs font-bold text-slate-500 uppercase">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {stockCheckResults.map((item, idx) => (
                    <tr key={idx} className={!item.isAvailable ? 'bg-red-50/50' : ''}>
                      <td className="px-4 py-3 font-medium text-slate-900">{item.product_name}</td>
                      <td className="px-4 py-3 text-center text-slate-600">{item.requested}</td>
                      <td className="px-4 py-3 text-center font-bold text-slate-900">{item.available}</td>
                      <td className="px-4 py-3 text-center">
                        {item.isAvailable ? (
                          <span className="inline-flex items-center gap-1 text-emerald-700 font-semibold text-xs">
                            <CheckCircle2 className="w-3.5 h-3.5" /> OK
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1 text-red-600 font-semibold text-xs">
                            <XCircle className="w-3.5 h-3.5" /> Short
                          </span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
              <Button variant="outline" onClick={() => setIsStockErrorModalOpen(false)} className="h-12 px-6 rounded-xl font-bold border-slate-200 text-slate-600 hover:bg-slate-50">Close</Button>
              <Button
                onClick={() => {
                  setIsStockErrorModalOpen(false);
                  router.push(`/dashboard/orders/${order.id}/edit`);
                }}
                className="h-12 px-8 rounded-xl font-bold text-white bg-slate-900 hover:bg-slate-800 shadow-md"
              >
                <Edit3 className="w-4 h-4 mr-2" /> Edit Order
              </Button>
            </div>
          </div>
        </Modal>

        {/* Return Confirmation Modal */}
        <Modal open={isReturnConfirmOpen} onClose={() => setIsReturnConfirmOpen(false)} title="Confirm Return">
          <div className="p-6 space-y-5">
            <p className="text-sm text-slate-600">Please review the return summary before confirming.</p>

            {/* Items Summary */}
            <div className="space-y-2">
              <h3 className="text-xs font-bold text-slate-500 uppercase tracking-widest">Items</h3>
              <div className="divide-y divide-slate-100 border border-slate-200 rounded-xl overflow-hidden">
                {order.items.map((item) => {
                  const rItem = returnItems[item.id] || { status: null, damage_fee: 0, damaged_quantity: 0, notes: '' };
                  const product = (item as any).product;
                  return (
                    <div key={item.id} className="flex items-center justify-between px-4 py-3 bg-white">
                      <div className="flex items-center gap-3 min-w-0 flex-1">
                        <span className="text-sm font-semibold text-slate-900 truncate">{product?.name || 'Product'}</span>
                        <span className="text-xs text-slate-400">×{item.quantity}</span>
                        {rItem.status === 'damaged' && rItem.damaged_quantity < item.quantity && (
                          <span className="text-[10px] text-emerald-600 bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-200">
                            {rItem.damaged_quantity} damaged, {item.quantity - rItem.damaged_quantity} good
                          </span>
                        )}
                      </div>
                      <span className={`text-xs font-bold px-2.5 py-1 rounded-md border ${
                        rItem.status === 'excellent' ? 'bg-emerald-50 text-emerald-700 border-emerald-200' :
                        rItem.status === 'damaged' ? 'bg-orange-50 text-orange-700 border-orange-200' :
                        rItem.status === 'missing' ? 'bg-red-50 text-red-700 border-red-200' :
                        'bg-slate-50 text-slate-500 border-slate-200'
                      }`}>
                        {rItem.status === 'excellent' ? 'Good' : rItem.status === 'damaged' ? 'Damaged' : rItem.status === 'missing' ? 'Missing' : 'Unmarked'}
                      </span>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Zero Damage Fee Warning */}
            {Object.values(returnItems).some(r => r.status === 'damaged' && (r.damage_fee || 0) <= 0) && (
              <div className="flex items-center gap-3 p-3 bg-amber-50 border border-amber-200 rounded-xl">
                <AlertTriangle className="w-5 h-5 text-amber-500 flex-shrink-0" />
                <div>
                  <p className="text-sm font-bold text-amber-800">Warning: ₹0 Damage Fee</p>
                  <p className="text-xs text-amber-600">One or more damaged items have no damage fee set. You can still complete the return, but the fee won't be charged.</p>
                </div>
              </div>
            )}

            {/* Fees Summary — only show when there's still a balance due */}
            {(calculatedDamage > 0 || lateFee > 0 || discount > 0) && amount_due > 0 && (
              <div className="space-y-2 bg-slate-50 rounded-xl p-4 border border-slate-200">
                {calculatedDamage > 0 && (
                  <div className="flex justify-between text-sm">
                    <span className="text-orange-700 font-medium">Damage Charges</span>
                    <span className="font-bold text-orange-700">{formatCurrency(calculatedDamage)}</span>
                  </div>
                )}
                {lateFee > 0 && (
                  <div className="flex justify-between text-sm">
                    <span className="text-red-700 font-medium">Late Fee</span>
                    <span className="font-bold text-red-700">{formatCurrency(lateFee)}</span>
                  </div>
                )}
                {discount > 0 && (
                  <div className="flex justify-between text-sm">
                    <span className="text-emerald-700 font-medium">Discount</span>
                    <span className="font-bold text-emerald-700">−{formatCurrency(discount)}</span>
                  </div>
                )}
              </div>
            )}

            {/* Fully Paid indicator */}
            {amount_due <= 0 && (
              <div className="flex items-center gap-3 p-3 bg-emerald-50 border border-emerald-200 rounded-xl">
                <CheckCircle2 className="w-5 h-5 text-emerald-500 flex-shrink-0" />
                <div>
                  <p className="text-sm font-bold text-emerald-800">Fully Paid</p>
                  <p className="text-xs text-emerald-600">All charges including fees have been collected.</p>
                </div>
              </div>
            )}

            {/* Payment Due Warning */}
            {amount_due > 0 && (
              <div className="flex items-center gap-3 p-3 bg-red-50 border border-red-200 rounded-xl">
                <AlertTriangle className="w-5 h-5 text-red-500 flex-shrink-0" />
                <div>
                  <p className="text-sm font-bold text-red-800">Payment still due: {formatCurrency(amount_due)}</p>
                  <p className="text-xs text-red-600">You can collect the payment after completing the return.</p>
                </div>
              </div>
            )}

            {/* Action Buttons */}
            <div className="flex justify-end gap-3 pt-3 border-t border-slate-100">
              <Button variant="outline" onClick={() => setIsReturnConfirmOpen(false)} className="h-12 px-6 rounded-xl font-bold border-slate-200">
                Go Back
              </Button>
              <Button
                onClick={submitReturn}
                disabled={isReturning}
                className="h-12 px-8 rounded-xl font-bold text-white bg-slate-900 hover:bg-slate-800 shadow-md"
              >
                {isReturning ? 'Processing...' : 'Confirm & Complete Return'}
              </Button>
            </div>
          </div>
        </Modal>

        {/* Keep Money Confirmation Modal */}
        <Modal
          open={isKeepMoneyModalOpen}
          onClose={() => setIsKeepMoneyModalOpen(false)}
          title="Keep Money — Confirm"
        >
          <div className="p-6 space-y-5">
            <div className="p-4 bg-teal-50 border border-teal-200 rounded-xl">
              <p className="text-sm font-bold text-teal-800 mb-1">No refund will be issued</p>
              <p className="text-xs text-teal-600 leading-relaxed">
                You are choosing to keep <span className="font-black">{formatCurrency(order?.amount_paid || 0)}</span> from this cancelled order.
                This action will mark the refund as waived and the amount will remain in your revenue.
              </p>
            </div>

            <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl text-center">
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Amount to Keep</p>
              <p className="text-3xl font-black text-slate-900">{formatCurrency(order?.amount_paid || 0)}</p>
            </div>

            <div className="flex gap-3 pt-2">
              <Button 
                variant="outline" 
                onClick={() => setIsKeepMoneyModalOpen(false)} 
                className="flex-1 h-12 rounded-xl font-bold border-slate-200 text-slate-600 hover:bg-slate-50"
              >
                Cancel
              </Button>
              <Button
                onClick={() => {
                  updateOrder({ id: orderId, data: { payment_status: PaymentStatus.REFUND_WAIVED } as any });
                  setIsKeepMoneyModalOpen(false);
                }}
                disabled={isUpdating}
                className="flex-1 h-12 rounded-xl font-bold text-white bg-teal-600 hover:bg-teal-700 shadow-md"
              >
                {isUpdating ? 'Processing...' : 'Confirm — Keep Money'}
              </Button>
            </div>
          </div>
        </Modal>
      </div>
  );
}
