"use client";

import { useState, useMemo, useEffect, useRef, useCallback } from "react";
import { useRouter } from "next/navigation";
import { useQueryClient } from "@tanstack/react-query";
import { format, addDays, startOfDay } from "date-fns";
import {
  Search, Plus, Minus, Trash2, Calendar, User, Package, UserPlus,
  ArrowLeft, ArrowRight, AlertTriangle, CheckCircle2, Loader2, Info, ScanBarcode, Banknote, Percent, Tag, Zap, CalendarDays, X, ChevronDown
} from "lucide-react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useCustomers, useProducts, useCreateOrder, useUpdateOrder, useCreateCustomer, useIsGSTEnabled, useCheckOrderAvailability, useLookupProductByBarcode } from "@/hooks";
import { useAppStore } from "@/stores";
import { formatCurrency } from "@/lib/shared-utils";
import { PaymentMethod } from "@/domain/types/order";
import dynamic from 'next/dynamic';

const BarcodeScanner = dynamic(() => import('./BarcodeScanner'), { ssr: false });

interface OrderFormProps {
  initialData?: any;
}

export default function OrderForm({ initialData }: OrderFormProps) {
  const router = useRouter();
  const queryClient = useQueryClient();
  const { showSuccess, showError } = useAppStore();
  const selectedBranchId = useAppStore((s: any) => s.selectedBranchId);
  const isEditing = !!initialData;

  const { createOrder, isPending: isCreating } = useCreateOrder();
  const { updateOrder, isPending: isUpdating } = useUpdateOrder();
  const { createCustomer, isPending: isCreatingCustomer } = useCreateCustomer();
  const { lookupByBarcode, isLooking: isScanningBarcode } = useLookupProductByBarcode();
  
  // Settings
  const { data: isGstEnabledResult } = useIsGSTEnabled();
  
  const isGstEnabled = (isGstEnabledResult?.success && isGstEnabledResult.data !== null) ? isGstEnabledResult.data : false;

  // Data Fetching for comboboxes
  const [customerSearch, setCustomerSearch] = useState("");
  const [productSearch, setProductSearch] = useState("");

  const { data: customersData } = useCustomers({ query: customerSearch, limit: 10 });
  const { data: productsData } = useProducts({ query: productSearch, limit: 10, branch_id: selectedBranchId || undefined });

  const customers = customersData?.customers || [];
  const products = productsData?.products || [];

  // Local State
  const [selectedCustomer, setSelectedCustomer] = useState<any>(initialData?.customer || null);
  const [isCustomerDropdownOpen, setIsCustomerDropdownOpen] = useState(false);
  const [isProductDropdownOpen, setIsProductDropdownOpen] = useState(false);

  const [isQuickAddMode, setIsQuickAddMode] = useState(false);
  const [quickAddName, setQuickAddName] = useState("");
  const [quickAddPhone, setQuickAddPhone] = useState("");
  const [quickAddAltPhone, setQuickAddAltPhone] = useState("");
  const [quickAddAddress, setQuickAddAddress] = useState("");

  // Delivery / Customer Address
  const [deliveryAddress, setDeliveryAddress] = useState(initialData?.delivery_address || "");

  // Cart State
  const [cartItems, setCartItems] = useState<any[]>(
    initialData?.items?.map((item: any) => ({
      product: item.product || { id: item.product_id, name: "Product", price_per_day: item.price_per_day },
      quantity: item.quantity,
      price_per_day: item.price_per_day,
      discount: item.discount || 0,
      discount_type: item.discount_type || 'flat' as 'flat' | 'percent',
    })) || []
  );

  // Date State — parse bare "YYYY-MM-DD" strings as local time to avoid UTC→local day shift
  const parseDateLocal = (dateStr: string) => {
    // "2026-05-04" → parsed as local midnight, not UTC midnight
    const s = dateStr.includes('T') ? dateStr : `${dateStr}T00:00:00`;
    const d = new Date(s);
    return isNaN(d.getTime()) ? new Date() : d;
  };
  const [startDate, setStartDate] = useState<Date>(initialData ? parseDateLocal(initialData.start_date || initialData.rental_start_date) : new Date());
  const [endDate, setEndDate] = useState<Date>(initialData ? parseDateLocal(initialData.end_date || initialData.rental_end_date) : addDays(new Date(), 2));

  // Notes
  const [notes, setNotes] = useState(initialData?.notes || "");

  // Order-Level Discount State
  const [orderDiscount, setOrderDiscount] = useState<number>(initialData?.discount || 0);
  const [orderDiscountType, setOrderDiscountType] = useState<'flat' | 'percent'>(initialData?.discount_type || 'flat');

  // Advance Payment State
  const [advanceAmount, setAdvanceAmount] = useState<number>(initialData?.advance_amount || 0);
  const [advancePaymentMethod, setAdvancePaymentMethod] = useState<string>(initialData?.advance_payment_method || PaymentMethod.CASH);

  // Barcode Scanner
  const [isScannerOpen, setIsScannerOpen] = useState(false);

  // Close dropdowns when clicking outside
  const customerRef = useRef<HTMLDivElement>(null);
  const productRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (customerRef.current && !customerRef.current.contains(event.target as Node)) setIsCustomerDropdownOpen(false);
      if (productRef.current && !productRef.current.contains(event.target as Node)) setIsProductDropdownOpen(false);
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Auto-fill delivery address when a customer is selected (new orders)
  useEffect(() => {
    if (selectedCustomer && !isEditing) {
      setDeliveryAddress(selectedCustomer.address || "");
    }
  }, [selectedCustomer, isEditing]);

  // Set Dates Quick Action — uses the currently selected start date
  const handleQuickDate = (days: number) => {
    setEndDate(addDays(startDate, days));
  };

  const rentalDays = useMemo(() => {
    const diffTime = Math.abs(endDate.getTime() - startDate.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return Math.max(1, diffDays + 1); // +1 for inclusive counting (pickup day + return day)
  }, [startDate, endDate]);

  // Pricing multiplier: base price covers first 3 days, each extra day adds 1×
  const pricingMultiplier = useMemo(() => Math.max(1, rentalDays - 2), [rentalDays]);

  // Date validation: return date must be strictly after pickup date
  const isDateInvalid = useMemo(() => {
    // Compare dates only (ignore time)
    const start = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
    const end = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate());
    return end <= start;
  }, [startDate, endDate]);

  // Cart Calculations — with per-item discounts + order discount + GST-inclusive breakdown
  const cartTotals = useMemo(() => {
    let subtotal = 0;
    let itemDiscountTotal = 0;
    let totalGstAmount = 0;
    let totalBaseAmount = 0;

    // Per-item GST breakdown for display
    const itemGstBreakdown: { productId: string; gstRate: number; baseAmount: number; gstAmount: number; lineAfterDiscount: number }[] = [];

    cartItems.forEach((item) => {
      const lineTotal = item.price_per_day * item.quantity * pricingMultiplier;
      const itemDisc = item.discount_type === 'percent'
        ? lineTotal * (item.discount / 100)
        : (item.discount || 0) * item.quantity;
      const effectiveDisc = Math.min(itemDisc, lineTotal);
      subtotal += lineTotal;
      itemDiscountTotal += effectiveDisc;

      const lineAfterDiscount = lineTotal - effectiveDisc;

      // GST-inclusive: the rent amount ALREADY includes GST
      // Formula: base = amount / (1 + rate/100), gst = amount - base
      const gstRate = item.product?.category?.gst_percentage ?? 0;
      if (isGstEnabled && gstRate > 0) {
        const base = lineAfterDiscount / (1 + gstRate / 100);
        const gst = lineAfterDiscount - base;
        totalBaseAmount += base;
        totalGstAmount += gst;
        itemGstBreakdown.push({
          productId: item.product.id,
          gstRate,
          baseAmount: Math.round(base * 100) / 100,
          gstAmount: Math.round(gst * 100) / 100,
          lineAfterDiscount,
        });
      } else {
        totalBaseAmount += lineAfterDiscount;
        itemGstBreakdown.push({
          productId: item.product.id,
          gstRate: 0,
          baseAmount: lineAfterDiscount,
          gstAmount: 0,
          lineAfterDiscount,
        });
      }
    });

    const afterItemDiscount = subtotal - itemDiscountTotal;

    // Order-level discount applied AFTER item discounts
    const orderDiscAmt = orderDiscountType === 'percent'
      ? afterItemDiscount * (orderDiscount / 100)
      : (orderDiscount || 0);
    const effectiveOrderDiscount = Math.min(orderDiscAmt, afterItemDiscount); // can't exceed

    // When there's an order-level discount, proportionally reduce GST
    const afterAllDiscounts = afterItemDiscount - effectiveOrderDiscount;
    let gstAmount = totalGstAmount;
    let baseAmount = totalBaseAmount;
    if (effectiveOrderDiscount > 0 && afterItemDiscount > 0) {
      // Proportional reduction: if 10% order discount applied, reduce GST by 10% too
      const ratio = afterAllDiscounts / afterItemDiscount;
      gstAmount = totalGstAmount * ratio;
      baseAmount = afterAllDiscounts - gstAmount;
    }

    // Grand total = afterAllDiscounts (GST is WITHIN, not added on top)
    const grandTotal = afterAllDiscounts;

    return {
      subtotal,
      itemDiscountTotal,
      effectiveOrderDiscount,
      afterItemDiscount,
      gstAmount: Math.round(gstAmount * 100) / 100,
      baseAmount: Math.round(baseAmount * 100) / 100,
      grandTotal,
      itemGstBreakdown,
    };
  }, [cartItems, isGstEnabled, orderDiscount, orderDiscountType, pricingMultiplier]);

  // Payment validation
  const advanceExceedsTotal = advanceAmount > 0 && advanceAmount > cartTotals.grandTotal;
  const isFullAdvancePayment = advanceAmount > 0 && advanceAmount === cartTotals.grandTotal;
  const isPaymentInvalid = advanceExceedsTotal;

  // ─── Live Availability Check (Search Dropdown) ──────────────────
  const availableProducts = useMemo(() => {
    return products.filter((p: any) => !cartItems.some((item: any) => item.product.id === p.id));
  }, [products, cartItems]);

  const searchItems = useMemo(() => {
    if (!isProductDropdownOpen || productSearch.length === 0) return [];
    return availableProducts.map((p: any) => ({
      product_id: p.id,
      quantity: 1,
      product_name: p.name,
    }));
  }, [availableProducts, isProductDropdownOpen, productSearch]);

  const { data: searchAvailabilityData, isLoading: isCheckingSearch } = useCheckOrderAvailability(
    searchItems,
    format(startDate, "yyyy-MM-dd"),
    format(endDate, "yyyy-MM-dd"),
    selectedBranchId || undefined,
    initialData?.id,
    searchItems.length > 0 && isProductDropdownOpen,
  );

  const searchAvailabilityMap = useMemo(() => {
    const map = new Map<string, { available: number; isAvailable: boolean; peakReserved: number; overlappingOrders: any[] }>();
    if (searchAvailabilityData?.data?.items) {
      for (const item of searchAvailabilityData.data.items) {
        map.set(item.product_id, item);
      }
    }
    return map;
  }, [searchAvailabilityData]);

  // ─── Live Availability Check (Interval Scheduling) ─────────────────
  // Debounce the availability items so rapid qty clicks don't spam the API
  const availabilityItems = useMemo(() => {
    return cartItems.map(item => ({
      product_id: item.product.id,
      quantity: item.quantity,
      product_name: item.product.name,
    }));
  }, [cartItems]);

  const [debouncedAvailItems, setDebouncedAvailItems] = useState(availabilityItems);
  useEffect(() => {
    const timer = setTimeout(() => setDebouncedAvailItems(availabilityItems), 500);
    return () => clearTimeout(timer);
  }, [availabilityItems]);

  const { data: availabilityData, isLoading: isCheckingAvailability } = useCheckOrderAvailability(
    debouncedAvailItems,
    format(startDate, "yyyy-MM-dd"),
    format(endDate, "yyyy-MM-dd"),
    selectedBranchId || undefined,
    initialData?.id, // exclude current order when editing
    debouncedAvailItems.length > 0, // enabled
  );

  const availabilityMap = useMemo(() => {
    const map = new Map<string, { available: number; isAvailable: boolean; peakReserved: number; overlappingOrders: any[] }>();
    if (availabilityData?.data?.items) {
      for (const item of availabilityData.data.items) {
        map.set(item.product_id, item);
      }
    }
    return map;
  }, [availabilityData]);



  const hasUnavailableItems = availabilityData?.data ? !availabilityData.data.allAvailable : false;

  // Handlers
  const addToCart = (product: any) => {
    if (product.available_quantity !== undefined && product.available_quantity < 1) {
      showError("Out of Stock", "This product is currently out of stock.");
      return;
    }

    const searchAvail = searchAvailabilityMap.get(product.id);
    const searchMaxAvail = (searchAvail as any)?.availableWithPriority ?? searchAvail?.available ?? 0;
    if (searchAvail && searchMaxAvail < 1) {
      showError("Unavailable for Dates", `0 available for the selected dates (even with priority cleaning).`);
      return;
    }

    const existing = cartItems.find(p => p.product.id === product.id);
    const cartAvail = availabilityMap.get(product.id);
    
    if (existing && cartAvail) {
      const maxQty = (cartAvail as any)?.availableWithPriority ?? cartAvail?.available ?? 0;
      if (existing.quantity >= maxQty) {
        showError("Unavailable for Dates", `Maximum ${maxQty} available for these dates.`);
        return;
      }
    }

    setCartItems(prev => {
      const ex = prev.find(p => p.product.id === product.id);
      if (ex) {
        return prev.map(p => p.product.id === product.id ? { ...p, quantity: p.quantity + 1 } : p);
      }
      return [...prev, { product, quantity: 1, price_per_day: product.price_per_day, discount: 0, discount_type: 'flat' as const }];
    });
    setProductSearch("");
    setIsProductDropdownOpen(false);
  };

  const updateCartQty = (productId: string, delta: number) => {
    if (delta > 0) {
      const itemToUpdate = cartItems.find(p => p.product.id === productId);
      const cartAvail = availabilityMap.get(productId);
      
      const maxQty = (cartAvail as any)?.availableWithPriority ?? cartAvail?.available ?? 0;
      if (cartAvail && itemToUpdate && itemToUpdate.quantity >= maxQty) {
        showError("Unavailable for Dates", `Maximum ${maxQty} available for these dates (${cartAvail.available} free + ${maxQty - cartAvail.available} with priority cleaning).`);
        return;
      }
    }

    setCartItems(prev => prev.map(p => {
      if (p.product.id === productId) {
        const newQty = Math.max(1, p.quantity + delta);
        return { ...p, quantity: newQty };
      }
      return p;
    }));
  };

  const removeCartItem = (productId: string) => {
    setCartItems(prev => prev.filter(p => p.product.id !== productId));
  };

  // Barcode scan handler — used by both camera scanner and USB/keyboard
  // Uses functional setCartItems to avoid stale closure over cartItems
  const scanInProgressRef = useRef<string | null>(null);
  const handleBarcodeScan = async (barcode: string) => {
    // Prevent concurrent lookups for the same barcode
    if (scanInProgressRef.current === barcode) return;
    scanInProgressRef.current = barcode;

    try {
      const product = await lookupByBarcode(barcode);
      if (!product) return;

      // Use functional update — always reads the latest cart state
      let wasExisting = false;
      setCartItems(prev => {
        const existing = prev.find(p => p.product.id === product.id);
        if (existing) {
          wasExisting = true;
          return prev.map(p =>
            p.product.id === product.id ? { ...p, quantity: p.quantity + 1 } : p
          );
        }
        return [...prev, { product, quantity: 1, price_per_day: product.price_per_day, discount: 0, discount_type: 'flat' as const }];
      });
      showSuccess(wasExisting ? `${product.name} — quantity increased` : `${product.name} added to cart`);
    } catch {
      // Error already shown by the hook
    } finally {
      scanInProgressRef.current = null;
    }
  };

  // USB/Bluetooth keyboard scanner support — detect rapid input + Enter
  const handleProductSearchKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && productSearch.trim().length > 0) {
      const val = productSearch.trim();
      // Heuristic: if the value looks like a barcode (alphanumeric, no spaces, 4+ chars)
      if (/^[a-zA-Z0-9\-_]+$/.test(val) && val.length >= 4) {
        e.preventDefault();
        handleBarcodeScan(val);
        setProductSearch('');
        setIsProductDropdownOpen(false);
      }
    }
  };

  // Get product primary image URL
  const getImageUrl = (product: any) => {
    if (!product?.images || !Array.isArray(product.images) || product.images.length === 0) return null;
    const img = product.images[0];
    return typeof img === "string" ? img : img?.url || null;
  };

  // Quick Add Customer
  const openQuickAddDialog = () => {
    // Pre-fill from search text
    const trimmed = customerSearch.trim();
    const isPhone = /^\d+$/.test(trimmed);
    if (isPhone) {
      setQuickAddPhone(trimmed);
      setQuickAddName("");
    } else {
      setQuickAddName(trimmed);
      setQuickAddPhone("");
    }
    setQuickAddAltPhone("");
    setQuickAddAddress("");
    setIsQuickAddMode(true);
    setIsCustomerDropdownOpen(false);
  };

  const handleQuickAddSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!quickAddName.trim() || !quickAddPhone.trim()) {
      showError("Validation Error", "Name and Phone are required.");
      return;
    }
    createCustomer({ name: quickAddName, phone: quickAddPhone, alt_phone: quickAddAltPhone || undefined, address: quickAddAddress || undefined }, {
      onSuccess: (res: any) => {
        const newCustomer = res.data;
        if (!newCustomer) return;
        setSelectedCustomer(newCustomer);
        setIsCustomerDropdownOpen(false);
        setIsQuickAddMode(false);
        setCustomerSearch("");
        setQuickAddName("");
        setQuickAddPhone("");
        setQuickAddAltPhone("");
        setQuickAddAddress("");
      }
    });
  };

  // Submit
  const handleCheckout = async () => {
    if (!selectedCustomer) {
      showError("Missing Customer", "Please select or create a customer.");
      return;
    }
    if (cartItems.length === 0) {
      showError("Empty Cart", "Please add at least one item to the order.");
      return;
    }
    if (!selectedBranchId) {
      showError("Missing Branch", "Please select a branch from the top navigation.");
      return;
    }

    if (startOfDay(endDate) < startOfDay(startDate)) {
      showError("Invalid Dates", "Return date cannot be earlier than the pickup date.");
      return;
    }

    const basePayload = {
      notes: notes || undefined,
      delivery_address: deliveryAddress || undefined,
      discount: orderDiscount || 0,
      discount_type: orderDiscountType,
      advance_amount: advanceAmount > 0 ? advanceAmount : 0,
      advance_collected: advanceAmount > 0,
      advance_payment_method: advanceAmount > 0 ? advancePaymentMethod : undefined,
      subtotal: cartTotals.subtotal,
      gst_amount: cartTotals.gstAmount,
      total_amount: cartTotals.grandTotal,
      amount_paid: advanceAmount > 0 ? advanceAmount : 0,
      payment_status: advanceAmount > 0 
        ? (advanceAmount >= cartTotals.grandTotal ? 'paid' : 'partial')
        : 'pending',
      items: cartItems.map(item => ({
        product_id: item.product.id,
        quantity: item.quantity,
        price_per_day: item.price_per_day,
        discount: item.discount || 0,
        discount_type: item.discount_type || 'flat',
      }))
    };

    // Check if any items ACTUALLY need priority cleaning based on requested quantity
    const priorityItems = cartItems.filter(item => {
      const avail = availabilityMap.get(item.product.id);
      return (avail as any)?.priorityCleaningNeeded && item.quantity > (avail?.available || 0);
    });

    if (priorityItems.length > 0 && !isEditing) {
      // Collect only the priority info needed for each item's quantity
      const infoList = priorityItems.flatMap(item => {
        const avail = availabilityMap.get(item.product.id) as any;
        const allInfo = avail?.priorityCleaningInfo || [];
        const neededExtra = item.quantity - (avail?.available || 0);
        if (neededExtra <= 0) return [];

        // Accumulate from sorted list until we have enough
        let accumulated = 0;
        const result: any[] = [];
        for (const info of allInfo) {
          if (accumulated >= neededExtra) break;
          const useFromThis = Math.min(info.returningQuantity, neededExtra - accumulated);
          result.push({ ...info, usedQuantity: useFromThis });
          accumulated += useFromThis;
        }
        return result;
      });
      setPriorityCleaningItems(infoList);
      setPendingOrderPayload(basePayload);
      setShowPriorityConfirmDialog(true);
      return;
    }

    submitOrder(basePayload, false);
  };

  // Actual order submission (called directly or after priority confirmation)
  const submitOrder = (payload: any, priorityCleaning: boolean) => {
    if (isEditing) {
      updateOrder({ id: initialData.id, data: { ...payload, start_date: format(startDate, "yyyy-MM-dd"), end_date: format(endDate, "yyyy-MM-dd") } as any }, {
        onSuccess: async () => {
          await queryClient.invalidateQueries({ queryKey: ['orders'] });
          router.push("/dashboard/orders");
        }
      });
    } else {
      createOrder({
        ...payload,
        customer_id: selectedCustomer.id,
        branch_id: selectedBranchId,
        rental_start_date: startDate.toISOString(),
        rental_end_date: endDate.toISOString(),
        priority_cleaning_confirmed: priorityCleaning,
        items: cartItems.map(item => ({
          product_id: item.product.id,
          quantity: item.quantity,
          price_per_day: item.price_per_day,
          discount: item.discount || 0,
          discount_type: item.discount_type || 'flat',
        }))
      } as any, {
        onSuccess: async () => {
          await queryClient.invalidateQueries({ queryKey: ['orders'] });
          router.push("/dashboard/orders");
        },
        onError: async (error: any) => {
          // Handle priority cleaning required from server (fallback)
          if (error?.message?.includes('PRIORITY_CLEANING_REQUIRED')) {
            showError('Priority Cleaning Required', 'Please confirm priority cleaning before placing this order.');
          }
        }
      });
    }
  };

  // Priority cleaning confirmation state
  const [priorityCleaningItems, setPriorityCleaningItems] = useState<any[]>([]);
  const [showPriorityConfirmDialog, setShowPriorityConfirmDialog] = useState(false);
  const [pendingOrderPayload, setPendingOrderPayload] = useState<any>(null);

  // Accordion state for existing bookings per product
  const [expandedBookings, setExpandedBookings] = useState<Set<string>>(new Set());

  const handleConfirmPriorityCleaning = () => {
    setShowPriorityConfirmDialog(false);
    if (pendingOrderPayload) {
      submitOrder(pendingOrderPayload, true);
      setPendingOrderPayload(null);
    }
  };

  return (
    <>
    <div className="space-y-6">
      {/* Page header — same as product module */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Button
            variant="outline"
            size="icon"
            onClick={() => router.push("/dashboard/orders")}
            className="w-9 h-9 border-slate-200 text-slate-500 hover:text-slate-900 bg-white"
          >
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <div>
            <h1 className="text-xl font-bold tracking-tight text-slate-900">
              {isEditing ? "Edit Order" : "New Order"}
            </h1>
            <p className="text-sm text-slate-500">
              {isEditing ? "Update order details" : "Search customer, add items, and confirm"}
            </p>
          </div>
        </div>
      </div>

      {/* Two-column layout — 50/50 split */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

        {/* LEFT COLUMN */}
        <div className="space-y-6">

          {/* Customer Section */}
          <div className="bg-white border border-slate-200 rounded-lg p-5 space-y-4">
            <h3 className="text-sm font-semibold text-slate-900 flex items-center gap-2">
              <User className="w-4 h-4 text-slate-400" />
              Customer
            </h3>
            {!selectedCustomer ? (
              <div className="space-y-3">
                <div className="flex items-center gap-2">
                  <div className="relative flex-1" ref={customerRef}>
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                    <Input
                      placeholder="Search customer by name or phone..."
                      className="pl-10 h-12 border-slate-200 focus:border-slate-900 text-base"
                      value={customerSearch}
                      onChange={(e) => {
                        setCustomerSearch(e.target.value);
                        setIsCustomerDropdownOpen(true);
                      }}
                      onFocus={() => setIsCustomerDropdownOpen(true)}
                    />
                    {isCustomerDropdownOpen && customerSearch.length > 0 && (
                      <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-slate-200 rounded-lg shadow-lg z-50 max-h-64 overflow-y-auto">
                        {customers.length > 0 ? (
                          <ul className="py-1">
                            {customers.map((c: any) => (
                              <li
                                key={c.id}
                                className="px-4 py-2.5 hover:bg-slate-50 cursor-pointer flex flex-col"
                                onClick={() => { setSelectedCustomer(c); setIsCustomerDropdownOpen(false); setCustomerSearch(""); }}
                              >
                                <span className="font-medium text-slate-900 text-sm">{c.name}</span>
                                <span className="text-xs text-slate-500">{c.phone}</span>
                              </li>
                            ))}
                          </ul>
                        ) : (
                          <div className="p-4 text-center">
                            <p className="text-sm text-slate-500 mb-2">No customer found.</p>
                            <Button
                              size="sm"
                              variant="outline"
                              className="w-full h-9 border-slate-200 text-slate-700 hover:bg-slate-50 font-medium"
                              onClick={openQuickAddDialog}
                            >
                              <Plus className="w-4 h-4 mr-1" /> Create &quot;{customerSearch}&quot;
                            </Button>
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                  <Button
                    type="button"
                    variant="outline"
                    size="icon"
                    onClick={openQuickAddDialog}
                    className="h-12 w-12 flex-shrink-0 border-slate-200 text-slate-600 hover:text-slate-900 hover:bg-slate-50"
                    title="Create New Customer"
                  >
                    <UserPlus className="w-5 h-5" />
                  </Button>
                </div>
              </div>
            ) : (
              <div className="flex items-center justify-between p-3 bg-slate-50 border border-slate-200 rounded-lg">
                <div>
                  <h4 className="font-semibold text-slate-900">{selectedCustomer.name}</h4>
                  <p className="text-xs text-slate-500">{selectedCustomer.phone}</p>
                </div>
                <Button variant="outline" size="sm" onClick={() => setSelectedCustomer(null)} className="h-8 border-slate-200 text-slate-500 hover:text-slate-900 text-xs">
                  Change
                </Button>
              </div>
            )}
          </div>

          {/* Rental Period */}
          <div className="bg-white border border-slate-200 rounded-lg p-5 space-y-4">
            <h3 className="text-sm font-semibold text-slate-900 flex items-center gap-2">
              <Calendar className="w-4 h-4 text-slate-400" />
              Rental Period
            </h3>
            <div className="flex flex-wrap gap-1.5">
              {[1, 2].map(extraDays => (
                <Button
                  key={extraDays}
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() => handleQuickDate(extraDays)}
                  className={`h-8 text-xs border-slate-200 ${rentalDays === extraDays + 1 ? 'bg-slate-900 text-white border-slate-900 hover:bg-slate-800 hover:text-white' : 'text-slate-600 hover:bg-slate-50'}`}
                >
                  +{extraDays} {extraDays === 1 ? 'Day' : 'Days'}
                </Button>
              ))}
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-600">Pickup Date</label>
                <Input
                  type="date"
                  className="h-12 border-slate-200 focus:border-slate-900 text-base"
                  value={format(startDate, "yyyy-MM-dd")}
                  onChange={(e) => {
                    const newDate = new Date(e.target.value);
                    if (!isNaN(newDate.getTime())) {
                      setStartDate(newDate);
                      setEndDate(addDays(newDate, 2));
                    }
                  }}
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-600">Return Date</label>
                <Input
                  type="date"
                  className="h-12 border-slate-200 focus:border-slate-900 text-base"
                  value={format(endDate, "yyyy-MM-dd")}
                  min={format(startDate, "yyyy-MM-dd")}
                  onChange={(e) => {
                    const newDate = new Date(e.target.value);
                    if (!isNaN(newDate.getTime())) {
                      setEndDate(newDate);
                    }
                  }}
                />
              </div>
            </div>
            {isDateInvalid && (
              <div className="flex items-center gap-2 p-2.5 bg-amber-50 border border-amber-200 rounded-lg text-sm text-amber-800">
                <AlertTriangle className="w-4 h-4 flex-shrink-0 text-amber-500" />
                <span>Return date must be after the pickup date. Please choose a valid return date.</span>
              </div>
            )}

            <div className="flex items-center gap-2 text-sm text-slate-600 bg-slate-50 rounded-lg p-2.5 border border-slate-100">
              <span className="w-7 h-7 rounded-full bg-slate-900 text-white flex items-center justify-center font-bold text-xs">{rentalDays}</span>
              <span>Total rental days</span>
            </div>

            {/* Buffer days info */}
            <div className="flex items-center gap-2 p-2.5 bg-blue-50 border border-blue-200 rounded-lg text-xs text-blue-700">
              <Info className="w-4 h-4 flex-shrink-0 text-blue-500" />
              <span className="flex-1">Most products are blocked <strong>1 day before pickup</strong> and <strong>1 day after return</strong> for preparation. (Note: Some categories like Ornaments are exempt from this gap).</span>
            </div>
          </div>

          {/* Address & Notes */}
          <div className="bg-white border border-slate-200 rounded-lg p-5 space-y-5">
            <div className="space-y-3">
              <h3 className="text-sm font-semibold text-slate-900">Customer / Delivery Address</h3>
              <textarea
                value={deliveryAddress}
                onChange={(e) => setDeliveryAddress(e.target.value)}
                placeholder="Enter address for delivery or record..."
                className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-sm focus:border-slate-900 focus:ring-1 focus:ring-slate-900 outline-none resize-y"
                rows={2}
              />
            </div>
            <div className="space-y-3">
              <h3 className="text-sm font-semibold text-slate-900">Notes</h3>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Optional notes about this order..."
                className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-sm focus:border-slate-900 focus:ring-1 focus:ring-slate-900 outline-none resize-y"
                rows={2}
              />
            </div>
          </div>
        </div>

        {/* RIGHT COLUMN — Cart & Totals */}
        <div className="space-y-6">
          <div className="bg-white border border-slate-200 rounded-lg overflow-visible">

            {/* Cart header with search */}
            <div className="p-5 border-b border-slate-200">
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-semibold text-slate-900 flex items-center gap-2">
                  <Package className="w-4 h-4 text-slate-400" />
                  Cart Items
                </h3>
                <span className="text-xs font-bold text-slate-900 bg-slate-100 px-2 py-0.5 rounded">
                  {cartItems.length} items
                </span>
              </div>
              <div className="flex items-center gap-2">
                <div className="relative flex-1" ref={productRef}>
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
                  <Input
                    placeholder="Search products or scan barcode..."
                    className="pl-10 h-12 border-slate-200 focus:border-slate-900 text-base"
                    value={productSearch}
                    onChange={(e) => {
                      setProductSearch(e.target.value);
                      setIsProductDropdownOpen(true);
                    }}
                    onFocus={() => setIsProductDropdownOpen(true)}
                    onKeyDown={handleProductSearchKeyDown}
                  />
                  {isProductDropdownOpen && productSearch.length > 0 && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-slate-200 rounded-lg shadow-lg z-50 max-h-72 overflow-y-auto">
                      {(() => {
                        return availableProducts.length > 0 ? (
                          <ul className="py-1">
                            {availableProducts.map((p: any) => {
                            const imgUrl = getImageUrl(p);
                            const sAvail = searchAvailabilityMap.get(p.id);
                            const sMaxAvail = (sAvail as any)?.availableWithPriority ?? sAvail?.available ?? 0;
                            const isAvail = sAvail ? sMaxAvail > 0 : p.available_quantity > 0;
                            
                            return (
                              <li
                                key={p.id}
                                className={`px-3 py-2.5 flex items-center gap-3 border-b border-slate-50 last:border-0 ${isAvail ? 'hover:bg-slate-50 cursor-pointer' : 'opacity-60 cursor-not-allowed'}`}
                                onClick={() => isAvail ? addToCart(p) : null}
                              >
                                <div className="w-10 h-10 rounded-md bg-slate-100 border border-slate-200 flex-shrink-0 overflow-hidden">
                                  {imgUrl ? (
                                    <img src={imgUrl} alt={p.name} className="w-full h-full object-cover" />
                                  ) : (
                                    <div className="w-full h-full flex items-center justify-center text-slate-300">
                                      <Package className="w-4 h-4" />
                                    </div>
                                  )}
                                </div>
                                <div className="flex-1 min-w-0">
                                  <div className="font-medium text-slate-900 text-sm truncate">{p.name}</div>
                                  <div className="text-xs text-slate-500 flex gap-2 mt-0.5">
                                    <span>{formatCurrency(p.price_per_day)}</span>
                                    <span className={isAvail ? (sAvail && sAvail.available === 0 ? "text-amber-600" : "text-emerald-600") : "text-red-500 font-bold"}>
                                      {isCheckingSearch 
                                        ? "Checking dates..." 
                                        : sAvail 
                                          ? (sAvail.available > 0 ? `${sAvail.available} free for dates` : `0 free (${sMaxAvail} with priority cleaning)`)
                                          : `${p.available_quantity} in stock`}
                                    </span>
                                  </div>
                                </div>
                                <Plus className="w-4 h-4 text-slate-300 flex-shrink-0" />
                              </li>
                            );
                          })}
                          </ul>
                        ) : (
                          <div className="p-4 text-center text-sm text-slate-500">
                            {products.length > 0 ? "All matching products are already in the cart." : "No products found."}
                          </div>
                        );
                      })()}
                    </div>
                  )}
                </div>
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setIsScannerOpen(prev => !prev)}
                  className={`h-12 w-12 p-0 flex-shrink-0 ${isScannerOpen ? 'bg-slate-900 text-white border-slate-900 hover:bg-slate-800 hover:text-white' : 'border-slate-200 text-slate-500 hover:text-slate-900 hover:border-slate-400'}`}
                  title={isScannerOpen ? "Close scanner" : "Scan barcode"}
                >
                  <ScanBarcode className="w-5 h-5" />
                </Button>
              </div>
            </div>

            {/* Inline Barcode Scanner */}
            {isScannerOpen && (
              <div className="p-3 border-b border-slate-200">
                <BarcodeScanner
                  onScan={handleBarcodeScan}
                  onClose={() => setIsScannerOpen(false)}
                />
              </div>
            )}

            {/* Cart items */}
            <div className="p-4 min-h-[200px] max-h-[450px] overflow-y-auto">
              {cartItems.length === 0 ? (
                <div className="h-[200px] flex flex-col items-center justify-center text-slate-400 space-y-2">
                  <Package className="w-10 h-10 text-slate-200" />
                  <p className="text-sm">Search and add products</p>
                </div>
              ) : (
                <ul className="space-y-2">
                  {cartItems.map((item) => {
                    const imgUrl = getImageUrl(item.product);
                    const avail = availabilityMap.get(item.product.id);
                    const isItemUnavailable = avail && !avail.isAvailable;
                    return (
                      <li key={item.product.id} className={`p-3 rounded-lg border bg-white ${isItemUnavailable ? 'border-red-200 bg-red-50/30' : 'border-slate-100'}`}>
                        <div className="flex items-center gap-3">
                          <div className="w-11 h-11 rounded-lg bg-slate-100 flex-shrink-0 overflow-hidden border border-slate-200">
                            {imgUrl ? (
                              <img src={imgUrl} alt={item.product.name} className="w-full h-full object-cover" />
                            ) : (
                              <div className="w-full h-full flex items-center justify-center text-slate-300">
                                <Package className="w-4 h-4" />
                              </div>
                            )}
                          </div>
                          <div className="flex-1 min-w-0">
                            <h5 className="font-medium text-slate-900 text-sm truncate">{item.product.name}</h5>
                            <p className="text-xs text-slate-500 mt-0.5">{formatCurrency(item.price_per_day)}/day</p>
                          </div>
                          <button
                            type="button"
                            onClick={() => removeCartItem(item.product.id)}
                            className="p-1.5 text-slate-300 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors flex-shrink-0"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                        </div>

                        {/* Live Availability Badge */}
                        {avail && (
                          <div className={`mt-2 px-2 py-1.5 rounded-md text-xs flex items-center gap-1.5 ${isItemUnavailable ? 'bg-red-50 text-red-700 border border-red-200' : 'bg-emerald-50 text-emerald-700 border border-emerald-200'}`}>
                            {isCheckingAvailability ? (
                              <><Loader2 className="w-3 h-3 animate-spin" /> Checking...</>
                            ) : isItemUnavailable ? (
                              <><AlertTriangle className="w-3 h-3 flex-shrink-0" /> <span>Unavailable — only <strong>{avail.available}</strong> free for these dates (need {item.quantity})</span></>
                            ) : (
                              <><CheckCircle2 className="w-3 h-3 flex-shrink-0" /> <span>{avail.available} of {avail.available + avail.peakReserved} free for this period{(avail as any).priorityCleaningNeeded ? <span className="text-amber-600 ml-1">({(avail as any).availableWithPriority} with priority cleaning)</span> : null}</span></>
                            )}
                          </div>
                        )}
                        {avail && (() => {
                          const actualConflicts = avail.overlappingOrders.filter((o: any) => !o.bufferOnly);
                          const nearbyBookings = avail.overlappingOrders.filter((o: any) => o.bufferOnly);
                          const fmtShort = (d: string) => new Date(d).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
                          return (
                            <>
                                {((actualConflicts.length > 0 || nearbyBookings.length > 0)) && (() => {
                                  const allBookings = [...actualConflicts, ...nearbyBookings];
                                  const firstBooking = allBookings[0];
                                  const remainingCount = allBookings.length - 1;
                                  const expandKey = `${item.product.id}`;
                                  const isExpanded = expandedBookings.has(expandKey);

                                  return (
                                    <div className="mt-1 px-2 py-1.5 rounded bg-slate-50 border border-slate-100">
                                      <div className="flex items-center justify-between">
                                        <p className="text-[10px] font-semibold text-slate-500 uppercase tracking-wider">
                                          Existing Bookings
                                        </p>
                                        {remainingCount > 0 && (
                                          <button
                                            type="button"
                                            onClick={() => setExpandedBookings(prev => {
                                              const next = new Set(prev);
                                              next.has(expandKey) ? next.delete(expandKey) : next.add(expandKey);
                                              return next;
                                            })}
                                            className="text-[9px] text-slate-400 hover:text-slate-600 flex items-center gap-0.5 transition-colors"
                                          >
                                            {isExpanded ? 'Collapse' : `+${remainingCount} more`}
                                            <ChevronDown className={`w-3 h-3 transition-transform duration-200 ${isExpanded ? 'rotate-180' : ''}`} />
                                          </button>
                                        )}
                                      </div>
                                      {/* Always show first booking */}
                                      <div className="text-[10px] text-slate-500 flex flex-col gap-0.5 mt-1 p-1.5 rounded bg-white/50 border border-slate-200/50">
                                        <div className="flex items-center justify-between">
                                          <span className="font-bold text-slate-800">{firstBooking.customerName} — {firstBooking.quantity} {firstBooking.quantity > 1 ? 'units' : 'unit'}</span>
                                          <div className="flex items-center gap-2">
                                            <span className="text-slate-600">{fmtShort(firstBooking.startDate)} – {fmtShort(firstBooking.endDate)}</span>
                                            <span className={`${firstBooking.bufferSkipped ? 'text-slate-400 line-through decoration-amber-500/50' : 'text-amber-600 font-medium'} border-l border-slate-200 pl-2`}>
                                              {firstBooking.bufferStartDate && firstBooking.bufferEndDate 
                                                ? `Gap: ${fmtShort(firstBooking.bufferStartDate)} & ${fmtShort(firstBooking.bufferEndDate)}`
                                                : 'No Buffer'}
                                              {firstBooking.bufferSkipped && <span className="text-[8px] ml-1 text-amber-600 font-bold">(Prior Cleaning ON)</span>}
                                            </span>
                                          </div>
                                        </div>
                                      </div>
                                      {/* Remaining bookings — collapsible */}
                                      {isExpanded && allBookings.slice(1).map((o: any, idx: number) => (
                                        <div key={idx} className="text-[10px] text-slate-500 flex flex-col gap-0.5 mt-1 p-1.5 rounded bg-white/50 border border-slate-200/50 animate-in fade-in slide-in-from-top-1 duration-150">
                                          <div className="flex items-center justify-between">
                                            <span className="font-bold text-slate-800">{o.customerName} — {o.quantity} {o.quantity > 1 ? 'units' : 'unit'}</span>
                                            <div className="flex items-center gap-2">
                                              <span className="text-slate-600">{fmtShort(o.startDate)} – {fmtShort(o.endDate)}</span>
                                              <span className={`${o.bufferSkipped ? 'text-slate-400 line-through decoration-amber-500/50' : 'text-amber-600 font-medium'} border-l border-slate-200 pl-2`}>
                                                {o.bufferStartDate && o.bufferEndDate 
                                                  ? `Gap: ${fmtShort(o.bufferStartDate)} & ${fmtShort(o.bufferEndDate)}`
                                                  : 'No Buffer'}
                                                {o.bufferSkipped && <span className="text-[8px] ml-1 text-amber-600 font-bold">(Prior Cleaning ON)</span>}
                                              </span>
                                            </div>
                                          </div>
                                        </div>
                                      ))}
                                    </div>
                                  );
                                })()}

                                {/* Buffer-only nearby bookings — show warning only if quantity exceeds truly available stock */}
                                {nearbyBookings.length > 0 && item.quantity > avail.available && (
                                  <div className="mt-1 px-2 py-1.5 rounded-md bg-amber-50/70 border border-amber-200/60">
                                    <p className="text-[10px] font-semibold text-amber-700 uppercase tracking-wider mb-0.5 flex items-center gap-1">
                                      <Info className="w-3 h-3" /> Nearby bookings <span className="normal-case font-normal text-amber-500">(within gap period — auto-allowed)</span>
                                    </p>
                                    <p className="text-[9px] text-amber-500 mt-1">Product will be returned before this rental starts. Ensure it&apos;s prepared in time.</p>
                                  </div>
                                )}
                            </>
                          );
                        })()}

                        {/* Auto Priority Cleaning Warning Banner — only when qty exceeds free stock */}
                        {avail && (avail as any).priorityCleaningNeeded && item.quantity > avail.available && (() => {
                          const neededExtra = item.quantity - avail.available;
                          const allInfo = (avail as any).priorityCleaningInfo || [];
                          // Accumulate from sorted list until we have enough
                          let accumulated = 0;
                          const relevantInfo: any[] = [];
                          for (const info of allInfo) {
                            if (accumulated >= neededExtra) break;
                            const useFromThis = Math.min(info.returningQuantity, neededExtra - accumulated);
                            relevantInfo.push({ ...info, usedQuantity: useFromThis });
                            accumulated += useFromThis;
                          }
                          return (
                            <div className="mt-2 px-2.5 py-2 rounded-lg bg-amber-50 border border-amber-200">
                              <div className="flex items-center gap-1.5 text-[11px] text-amber-800 font-medium">
                                <Zap className="w-3.5 h-3.5 flex-shrink-0" />
                                <span>
                                  <strong>{avail.available}</strong> freely available, need <strong>{neededExtra}</strong> via priority cleaning
                                </span>
                              </div>
                              {relevantInfo.map((info: any, i: number) => (
                                <div key={i} className="text-[10px] text-amber-700 mt-1 ml-5">
                                  {info.direction === 'returning_before'
                                    ? <span>⚡ {info.usedQuantity === info.returningQuantity ? `${info.returningQuantity}` : `${info.usedQuantity} of ${info.returningQuantity}`} units — rush-clean from <strong>{info.returningOrderCustomer}</strong> (returning {new Date(info.returningOrderEndDate).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })})</span>
                                    : <span>⚡ {info.usedQuantity} {info.usedQuantity === 1 ? 'unit' : 'units'} — skip prep for <strong>{info.returningOrderCustomer}</strong> (pickup {new Date(info.returningOrderStartDate).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })})</span>
                                  }
                                </div>
                              ))}
                            </div>
                          );
                        })()}

                        <div className="flex items-center justify-between mt-2 pt-2 border-t border-slate-50">
                          <div className="flex items-center border border-slate-200 rounded-md bg-white overflow-hidden">
                            <button type="button" onClick={() => updateCartQty(item.product.id, -1)} className="px-2.5 py-1 hover:bg-slate-50 text-slate-500">
                              <Minus className="w-3 h-3" />
                            </button>
                            <input
                              type="text"
                              inputMode="numeric"
                              pattern="[0-9]*"
                              defaultValue={item.quantity}
                              key={`qty-${item.product.id}-${item.quantity}`}
                              onFocus={(e) => e.target.select()}
                              onChange={(e) => {
                                const raw = e.target.value.replace(/[^0-9]/g, '');
                                e.target.value = raw;
                                if (raw === '') return;
                                const val = Math.max(1, parseInt(raw));
                                
                                // Stock check — allow up to availableWithPriority
                                const cartAvail = availabilityMap.get(item.product.id);
                                const maxQty = (cartAvail as any)?.availableWithPriority ?? cartAvail?.available ?? 0;
                                if (cartAvail && val > maxQty) {
                                  showError("Unavailable for Dates", `Maximum ${maxQty} available for these dates (${cartAvail.available} free + ${maxQty - cartAvail.available} with priority cleaning).`);
                                  e.target.value = String(item.quantity);
                                  return;
                                }

                                setCartItems(prev => prev.map(p =>
                                  p.product.id === item.product.id ? { ...p, quantity: val } : p
                                ));
                              }}
                              onBlur={(e) => {
                                const val = parseInt(e.target.value) || 1;
                                const clamped = Math.max(1, val);
                                
                                // Stock check — allow up to availableWithPriority
                                const cartAvail = availabilityMap.get(item.product.id);
                                const maxQty = (cartAvail as any)?.availableWithPriority ?? cartAvail?.available ?? 0;
                                if (cartAvail && clamped > maxQty) {
                                  showError("Unavailable for Dates", `Maximum ${maxQty} available for these dates (${cartAvail.available} free + ${maxQty - cartAvail.available} with priority cleaning).`);
                                  e.target.value = String(item.quantity);
                                  return;
                                }

                                e.target.value = String(clamped);
                                setCartItems(prev => prev.map(p =>
                                  p.product.id === item.product.id ? { ...p, quantity: clamped } : p
                                ));
                              }}
                              className="w-12 text-center text-xs font-bold text-slate-900 bg-slate-50 border-x border-slate-100 outline-none py-1"
                            />
                            <button type="button" onClick={() => updateCartQty(item.product.id, 1)} className="px-2.5 py-1 hover:bg-slate-50 text-slate-500">
                              <Plus className="w-3 h-3" />
                            </button>
                          </div>
                          <div className="text-right">
                            {(() => {
                              const lineTotal = item.price_per_day * item.quantity * pricingMultiplier;
                              const discAmt = item.discount_type === 'percent'
                                ? lineTotal * ((item.discount || 0) / 100)
                                : (item.discount || 0) * item.quantity;
                              const effectiveDisc = Math.min(discAmt, lineTotal);
                              return (
                                <>
                                  {effectiveDisc > 0 && (
                                    <span className="text-[10px] text-red-500 line-through mr-1">{formatCurrency(lineTotal)}</span>
                                  )}
                                  <span className="text-sm font-bold text-slate-900">{formatCurrency(lineTotal - effectiveDisc)}</span>
                                </>
                              );
                            })()}
                          </div>
                        </div>

                        {/* Price calculation breakdown */}
                        <div className="mt-1.5 px-2 py-1.5 bg-slate-50/80 rounded border border-slate-100">
                          <div className="flex items-center justify-between text-[10px] text-slate-500">
                            <span className="font-medium">
                              {formatCurrency(item.price_per_day)} × {item.quantity} {item.quantity === 1 ? 'unit' : 'units'} × {pricingMultiplier === 1 ? `base (${rentalDays} days)` : `${pricingMultiplier} (${rentalDays} days − 2 free)`}
                            </span>
                            <span className="font-semibold text-slate-600">
                              = {formatCurrency(item.price_per_day * item.quantity * pricingMultiplier)}
                            </span>
                          </div>
                          <div className="text-[9px] text-slate-400 mt-0.5 flex items-center gap-1">
                            <CalendarDays className="w-2.5 h-2.5" />
                            {format(startDate, 'MMM d')} – {format(endDate, 'MMM d, yyyy')}
                          </div>
                        </div>

                        {/* Per-item GST split (if GST enabled and category has rate) */}
                        {isGstEnabled && (() => {
                          const gstInfo = cartTotals.itemGstBreakdown.find(g => g.productId === item.product.id);
                          if (!gstInfo || gstInfo.gstRate === 0) return null;
                          return (
                            <div className="flex items-center justify-between mt-1.5 px-1 py-1 bg-blue-50/50 rounded text-[10px]">
                              <span className="text-blue-600 font-medium flex items-center gap-1">
                                <Info className="w-2.5 h-2.5" />
                                GST {gstInfo.gstRate}% (incl.)
                              </span>
                              <span className="text-blue-600 font-semibold">
                                ₹{gstInfo.baseAmount.toFixed(2)} + ₹{gstInfo.gstAmount.toFixed(2)}
                              </span>
                            </div>
                          );
                        })()}

                        {/* Per-Item Discount — available to all staff */}
                        <div className="mt-2 pt-2 border-t border-dashed border-slate-100">
                            <div className="flex items-center gap-2">
                              <Tag className="w-3 h-3 text-orange-400 flex-shrink-0" />
                              <span className="text-[10px] text-slate-400 font-semibold uppercase tracking-wider">Discount</span>
                              <div className="flex items-center gap-1 ml-auto">
                                <input
                                  type="number"
                                  value={item.discount || ""}
                                  placeholder="0"
                                  onChange={(e) => {
                                    const val = parseFloat(e.target.value) || 0;
                                    setCartItems(prev => prev.map(p =>
                                      p.product.id === item.product.id ? { ...p, discount: val } : p
                                    ));
                                  }}
                                  onWheel={(e) => (e.target as HTMLInputElement).blur()}
                                  className="w-16 h-6 text-xs text-right font-semibold border border-slate-200 rounded px-1.5 outline-none focus:border-orange-400 bg-white"
                                />
                                <div className="flex h-6 rounded-md border border-slate-200 overflow-hidden">
                                  <button
                                    type="button"
                                    onClick={() => setCartItems(prev => prev.map(p =>
                                      p.product.id === item.product.id ? { ...p, discount_type: 'flat' } : p
                                    ))}
                                    className={`w-6 flex items-center justify-center text-[10px] font-bold transition-colors ${item.discount_type === 'flat' ? 'bg-orange-500 text-white' : 'bg-white text-slate-400 hover:bg-slate-50'}`}
                                  >
                                    ₹
                                  </button>
                                  <button
                                    type="button"
                                    onClick={() => setCartItems(prev => prev.map(p =>
                                      p.product.id === item.product.id ? { ...p, discount_type: 'percent' } : p
                                    ))}
                                    className={`w-6 flex items-center justify-center text-[10px] font-bold transition-colors ${item.discount_type === 'percent' ? 'bg-orange-500 text-white' : 'bg-white text-slate-400 hover:bg-slate-50'}`}
                                  >
                                    %
                                  </button>
                                </div>
                              </div>
                            </div>
                          </div>
                      </li>
                    );
                  })}
                </ul>
              )}
            </div>

            {/* Totals */}
            <div className="bg-slate-50 border-t border-slate-200 p-5 space-y-3">
              <div>
                <div className="flex justify-between text-sm text-slate-600">
                  <span>Subtotal</span>
                  <span className="font-medium">{formatCurrency(cartTotals.subtotal)}</span>
                </div>
                <div className="text-[10px] text-slate-400 mt-0.5 flex items-center gap-1">
                  <CalendarDays className="w-3 h-3" />
                  {cartItems.length} {cartItems.length === 1 ? 'item' : 'items'} · {rentalDays} days ({format(startDate, 'MMM d')} – {format(endDate, 'MMM d, yyyy')}) · Rate: ×{pricingMultiplier}
                </div>
              </div>
              {cartTotals.itemDiscountTotal > 0 && (
                <div className="flex justify-between text-sm text-orange-600">
                  <span className="flex items-center gap-1"><Tag className="w-3 h-3" /> Item Discounts</span>
                  <span className="font-medium">−{formatCurrency(cartTotals.itemDiscountTotal)}</span>
                </div>
              )}
              {cartTotals.effectiveOrderDiscount > 0 && (
                <div className="flex justify-between text-sm text-purple-600">
                  <span className="flex items-center gap-1"><Percent className="w-3 h-3" /> Order Discount</span>
                  <span className="font-medium">−{formatCurrency(cartTotals.effectiveOrderDiscount)}</span>
                </div>
              )}

              {/* GST-inclusive breakdown */}
              {isGstEnabled && cartTotals.gstAmount > 0 && (
                <div className="pt-2 border-t border-slate-200 space-y-1.5">
                  <div className="flex justify-between text-xs text-slate-500">
                    <span>Base Amount (excl. GST)</span>
                    <span className="font-medium">{formatCurrency(cartTotals.baseAmount)}</span>
                  </div>
                  <div className="flex justify-between text-xs text-blue-600">
                    <span className="flex items-center gap-1">
                      <Info className="w-3 h-3" /> GST (included)
                    </span>
                    <span className="font-semibold">{formatCurrency(cartTotals.gstAmount)}</span>
                  </div>
                </div>
              )}

              <div className="flex justify-between items-end pt-3 border-t border-slate-200">
                <div>
                  <div className="text-base font-semibold text-slate-900">Grand Total</div>
                  <div className="text-[10px] text-slate-400 mt-0.5 flex items-center gap-1">
                    <CalendarDays className="w-3 h-3" />
                    {rentalDays} days · {format(startDate, 'MMM d')} – {format(endDate, 'MMM d, yyyy')} · Rate: ×{pricingMultiplier}
                    {isGstEnabled && cartTotals.gstAmount > 0 && <span> · Incl. GST</span>}
                  </div>
                </div>
                <div className="text-3xl font-bold text-slate-900 tracking-tight">
                  {formatCurrency(cartTotals.grandTotal)}
                </div>
              </div>
            </div>

            {/* Order-Level Discount + Advance — below totals */}
            {cartItems.length > 0 && (
              <div className="border-t border-slate-200 p-5 space-y-4">
                {/* Order-Level Discount — available to all staff */}
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-sm font-semibold text-slate-900 flex items-center gap-1.5">
                        <Percent className="w-3.5 h-3.5 text-purple-400" />
                        Order Discount
                      </span>
                      <div className="flex h-7 rounded-lg border border-slate-200 overflow-hidden">
                        <button
                          type="button"
                          onClick={() => setOrderDiscountType('flat')}
                          className={`px-3 flex items-center gap-1 text-xs font-bold transition-colors ${orderDiscountType === 'flat' ? 'bg-purple-500 text-white' : 'bg-white text-slate-500 hover:bg-slate-50'}`}
                        >
                          ₹ Flat
                        </button>
                        <button
                          type="button"
                          onClick={() => setOrderDiscountType('percent')}
                          className={`px-3 flex items-center gap-1 text-xs font-bold transition-colors ${orderDiscountType === 'percent' ? 'bg-purple-500 text-white' : 'bg-white text-slate-500 hover:bg-slate-50'}`}
                        >
                          % Percent
                        </button>
                      </div>
                    </div>
                    <div className="relative">
                      <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-500 font-semibold text-sm">{orderDiscountType === 'percent' ? '%' : '₹'}</span>
                      <Input
                        type="number"
                        value={orderDiscount || ""}
                        onChange={(e) => setOrderDiscount(parseFloat(e.target.value) || 0)}
                        onWheel={(e) => (e.target as HTMLInputElement).blur()}
                        placeholder="0"
                        className="h-10 pl-7 font-bold text-base border-slate-200 focus:border-purple-500"
                      />
                    </div>
                    {cartTotals.effectiveOrderDiscount > 0 && (
                      <p className="text-xs text-purple-600 font-medium">
                        Saving {formatCurrency(cartTotals.effectiveOrderDiscount)} on this order
                      </p>
                    )}
                  </div>

                {/* Divider — only if both discount and advance are visible */}
                <div className="border-t border-slate-100"></div>

                {/* Advance Payment */}
                <div className="space-y-3">
                  <span className="text-sm font-semibold text-slate-900 flex items-center gap-1.5">
                    <Banknote className="w-3.5 h-3.5 text-slate-400" />
                    Advance Payment
                    <span className="text-xs font-normal text-slate-400">(Optional)</span>
                  </span>
                  <div className="space-y-2">
                    <div className="flex gap-2">
                      <div className="relative flex-1">
                        <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-500 font-semibold text-sm">₹</span>
                        <Input
                          type="number"
                          value={advanceAmount || ""}
                          onChange={(e) => setAdvanceAmount(parseFloat(e.target.value) || 0)}
                          onWheel={(e) => (e.target as HTMLInputElement).blur()}
                          placeholder="0"
                          className={`h-10 pl-7 font-bold text-base ${advanceExceedsTotal ? 'border-red-400 focus:border-red-500' : 'border-slate-200 focus:border-slate-900'}`}
                        />
                      </div>
                      <Select value={advancePaymentMethod} onValueChange={setAdvancePaymentMethod}>
                        <SelectTrigger className="h-10 w-[110px] border-slate-200 text-xs">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value={PaymentMethod.CASH}>Cash</SelectItem>
                          <SelectItem value={PaymentMethod.UPI}>UPI</SelectItem>
                          <SelectItem value={PaymentMethod.GPAY}>GPay</SelectItem>
                          <SelectItem value={PaymentMethod.BANK_TRANSFER}>Bank</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    {advanceExceedsTotal && (
                      <p className="text-xs text-red-600 font-medium flex items-center gap-1">
                        <AlertTriangle className="w-3 h-3" /> Advance cannot exceed grand total ({formatCurrency(cartTotals.grandTotal)})
                      </p>
                    )}
                    {isFullAdvancePayment && (
                      <div className="px-3 py-2 bg-green-50 border border-green-200 rounded-lg text-xs text-green-700 font-medium flex items-center gap-1.5">
                        <CheckCircle2 className="w-3.5 h-3.5" /> Full payment collected — no balance due at return
                      </div>
                    )}
                    {!advanceExceedsTotal && !isFullAdvancePayment && advanceAmount > 0 && (
                      <div className="px-3 py-2 bg-blue-50 border border-blue-200 rounded-lg text-xs text-blue-700 flex items-center gap-1.5">
                        <Info className="w-3.5 h-3.5 flex-shrink-0" />
                        Balance due at return: {formatCurrency(cartTotals.grandTotal - advanceAmount)}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* Final Summary & Confirm */}
            <div className="border-t border-slate-200 p-5 space-y-3">
              {advanceAmount > 0 && !advanceExceedsTotal && (
                <>
                  <div className="flex justify-between text-sm text-blue-700 bg-blue-50 px-3 py-2 rounded-lg border border-blue-200">
                    <span className="font-medium">Less: Advance Paid</span>
                    <span className="font-bold">−{formatCurrency(advanceAmount)}</span>
                  </div>
                  <div className="flex justify-between text-sm font-bold text-slate-900">
                    <span>Balance Due</span>
                    <span>{formatCurrency(Math.max(0, cartTotals.grandTotal - advanceAmount))}</span>
                  </div>
                </>
              )}

              {hasUnavailableItems && (
                <div className="flex items-center gap-2 p-2.5 bg-red-50 border border-red-200 rounded-lg text-xs text-red-700">
                  <AlertTriangle className="w-4 h-4 flex-shrink-0" />
                  <span>Some items are <strong>not available</strong> for the selected dates. Adjust quantities or change dates.</span>
                </div>
              )}
              {isPaymentInvalid && (
                <div className="flex items-center gap-2 p-2.5 bg-red-50 border border-red-200 rounded-lg text-xs text-red-700">
                  <AlertTriangle className="w-4 h-4 flex-shrink-0" />
                  <span>Amount exceeds grand total. Please adjust before confirming.</span>
                </div>
              )}
              <Button
                onClick={handleCheckout}
                disabled={isCreating || isUpdating || hasUnavailableItems || isDateInvalid || isPaymentInvalid}
                className={`w-full h-14 font-bold text-lg mt-2 shadow-lg ${hasUnavailableItems || isDateInvalid || isPaymentInvalid ? 'bg-slate-400 cursor-not-allowed shadow-none' : 'bg-slate-900 text-white hover:bg-slate-800 shadow-slate-900/20'}`}
              >
                {isCreating || isUpdating ? "Processing..." : isPaymentInvalid ? "Amount Exceeds Total" : isDateInvalid ? "Invalid Dates" : hasUnavailableItems ? "Items Unavailable" : isEditing ? "Save Changes" : "Confirm Order"}
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Create Customer Dialog */}
      {isQuickAddMode && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm animate-in fade-in-0"
          onClick={(e) => { if (e.target === e.currentTarget && !isCreatingCustomer) setIsQuickAddMode(false); }}
        >
          <div className="w-full max-w-md mx-4 bg-white rounded-2xl shadow-2xl animate-in zoom-in-95 slide-in-from-bottom-2">
            {/* Header */}
            <div className="flex items-center justify-between px-6 pt-6 pb-4 border-b border-slate-100">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center">
                  <UserPlus className="w-5 h-5 text-slate-700" />
                </div>
                <div>
                  <h3 className="text-base font-semibold text-slate-900">New Customer</h3>
                  <p className="text-xs text-slate-500">Add a new customer to this order</p>
                </div>
              </div>
              <button
                onClick={() => setIsQuickAddMode(false)}
                disabled={isCreatingCustomer}
                className="w-8 h-8 rounded-full hover:bg-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-600 transition-colors"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleQuickAddSubmit} className="p-6 space-y-4">
              <div className="space-y-1.5">
                <label className="text-xs font-medium text-slate-500 uppercase tracking-wider">Full Name <span className="text-red-400">*</span></label>
                <Input
                  value={quickAddName}
                  onChange={e => setQuickAddName(e.target.value)}
                  placeholder="Customer name"
                  className={`h-11 border-slate-200 focus:border-slate-900 ${quickAddName.length > 0 && quickAddName.trim().length < 2 ? 'border-red-300 focus:border-red-500' : ''}`}
                  autoFocus
                />
                {quickAddName.length > 0 && quickAddName.trim().length < 2 && (
                  <p className="text-xs text-red-500">Name must be at least 2 characters</p>
                )}
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-medium text-slate-500 uppercase tracking-wider">Phone Number <span className="text-red-400">*</span></label>
                <Input
                  value={quickAddPhone}
                  onChange={e => {
                    const val = e.target.value.replace(/\D/g, '');
                    if (val.length <= 10) setQuickAddPhone(val);
                  }}
                  placeholder="9876543210"
                  className={`h-11 border-slate-200 focus:border-slate-900 ${quickAddPhone.length > 0 && quickAddPhone.length !== 10 ? 'border-red-300 focus:border-red-500' : ''}`}
                  inputMode="numeric"
                  maxLength={10}
                />
                {quickAddPhone.length > 0 && quickAddPhone.length !== 10 && (
                  <p className="text-xs text-red-500">Phone number must be 10 digits ({quickAddPhone.length}/10)</p>
                )}
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-medium text-slate-500 uppercase tracking-wider">Alternate Phone <span className="text-slate-400 normal-case font-normal">(Optional)</span></label>
                <Input
                  value={quickAddAltPhone}
                  onChange={e => {
                    const val = e.target.value.replace(/\D/g, '');
                    if (val.length <= 10) setQuickAddAltPhone(val);
                  }}
                  placeholder="2nd number"
                  className={`h-11 border-slate-200 focus:border-slate-900 ${quickAddAltPhone.length > 0 && quickAddAltPhone.length !== 10 ? 'border-red-300 focus:border-red-500' : ''}`}
                  inputMode="numeric"
                  maxLength={10}
                />
                {quickAddAltPhone.length > 0 && quickAddAltPhone.length !== 10 && (
                  <p className="text-xs text-red-500">Phone number must be 10 digits ({quickAddAltPhone.length}/10)</p>
                )}
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-medium text-slate-500 uppercase tracking-wider">Address <span className="text-slate-400 normal-case font-normal">(Optional)</span></label>
                <textarea
                  value={quickAddAddress}
                  onChange={e => setQuickAddAddress(e.target.value)}
                  placeholder="Customer address"
                  className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 text-sm focus:outline-none focus:border-slate-900 focus:ring-1 focus:ring-slate-900 resize-none"
                  rows={3}
                />
              </div>

              {/* Actions */}
              <div className="flex gap-3 pt-2">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setIsQuickAddMode(false)}
                  disabled={isCreatingCustomer}
                  className="flex-1 h-11 border-slate-300 text-slate-600"
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  disabled={isCreatingCustomer || !quickAddName.trim() || quickAddPhone.length !== 10 || (quickAddAltPhone.length > 0 && quickAddAltPhone.length !== 10)}
                  className="flex-1 h-11 bg-slate-900 text-white hover:bg-slate-800 font-semibold"
                >
                  {isCreatingCustomer ? (
                    <>
                      <Loader2 className="w-4 h-4 animate-spin mr-1.5" />
                      Saving…
                    </>
                  ) : (
                    <>
                      <Plus className="w-4 h-4 mr-1.5" />
                      Save & Select
                    </>
                  )}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>

      {/* Priority Cleaning Confirmation Dialog */}
      {showPriorityConfirmDialog && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-2xl max-w-md mx-4 p-6 animate-in fade-in zoom-in-95 duration-200">
            <div className="flex items-center gap-2 mb-3">
              <div className="w-9 h-9 rounded-full bg-amber-100 flex items-center justify-center">
                <Zap className="w-5 h-5 text-amber-600" />
              </div>
              <h3 className="text-lg font-bold text-slate-900">Priority Cleaning Required</h3>
            </div>
            <p className="text-sm text-slate-600 mb-4">
              The following products need priority cleaning to fulfill this order. Staff will be notified in the Cleaning Queue.
            </p>
            <div className="space-y-2 mb-5 max-h-48 overflow-y-auto">
              {priorityCleaningItems.map((info: any, i: number) => (
                <div key={i} className="flex items-start gap-2 px-3 py-2.5 rounded-lg bg-amber-50 border border-amber-200">
                  <AlertTriangle className="w-4 h-4 text-amber-600 flex-shrink-0 mt-0.5" />
                  <div className="text-[12px] text-amber-800">
                    <p className="font-medium">{info.productName}</p>
                    <p className="text-amber-600 mt-0.5">
                      {info.direction === 'returning_before'
                        ? <>{info.usedQuantity === info.returningQuantity ? info.returningQuantity : `${info.usedQuantity} of ${info.returningQuantity}`} units — rush-clean from <strong>{info.returningOrderCustomer}</strong> (returning {new Date(info.returningOrderEndDate).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })})</>
                        : <>{info.usedQuantity} {info.usedQuantity === 1 ? 'unit' : 'units'} — skip prep for <strong>{info.returningOrderCustomer}</strong> (pickup {new Date(info.returningOrderStartDate).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })})</>
                      }
                    </p>
                  </div>
                </div>
              ))}
            </div>
            <div className="flex gap-3">
              <Button
                variant="outline"
                className="flex-1"
                onClick={() => {
                  setShowPriorityConfirmDialog(false);
                  setPendingOrderPayload(null);
                }}
              >
                Cancel
              </Button>
              <Button
                className="flex-1 bg-amber-600 hover:bg-amber-700 text-white"
                onClick={handleConfirmPriorityCleaning}
              >
                <Zap className="w-4 h-4 mr-1.5" />
                Confirm &amp; Create Order
              </Button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
