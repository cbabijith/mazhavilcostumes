"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import { X, Minus, Plus } from "lucide-react";
import { cn } from "@/lib/utils";
import { buildOrderMessage, buildWhatsAppUrl, calculateRentalPrice } from "@/lib/whatsapp";

interface ProductSummary {
  name: string;
  price_per_day: number;
  categoryName?: string | null;
  image?: string | null;
}

interface WhatsAppOrderModalProps {
  open: boolean;
  onClose: () => void;
  product: ProductSummary;
}

export default function WhatsAppOrderModal({
  open,
  onClose,
  product,
}: WhatsAppOrderModalProps) {
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [address, setAddress] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [quantity, setQuantity] = useState(1);
  const [errors, setErrors] = useState<{ name?: string; phone?: string; address?: string; startDate?: string; endDate?: string }>({});

  useEffect(() => {
    document.body.style.overflow = open ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  // Reset form when closed
  useEffect(() => {
    if (!open) {
      setErrors({});
    }
  }, [open]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const newErrors: typeof errors = {};
    if (!name.trim() || name.trim().length < 2) {
      newErrors.name = "Please enter your full name";
    }
    const cleanPhone = phone.replace(/\s|-/g, "");
    if (!/^[6-9]\d{9}$/.test(cleanPhone)) {
      newErrors.phone = "Enter a valid 10-digit Indian mobile number";
    }
    if (!address.trim() || address.trim().length < 5) {
      newErrors.address = "Please enter your delivery address";
    }
    if (!startDate) {
      newErrors.startDate = "Select a start date";
    }
    if (!endDate) {
      newErrors.endDate = "Select an end date";
    }
    setErrors(newErrors);
    if (Object.keys(newErrors).length > 0) return;

    const { rentalDays, totalRent } = calculateRentalPrice(
      product.price_per_day,
      quantity,
      startDate,
      endDate
    );

    const message = buildOrderMessage({
      productName: product.name,
      price: product.price_per_day,
      categoryName: product.categoryName,
      quantity,
      customerName: name.trim(),
      customerPhone: cleanPhone,
      customerAddress: address.trim(),
      startDate,
      endDate,
      rentalDays,
      totalRent,
    });

    window.open(buildWhatsAppUrl(message), "_blank");
    onClose();
  };

  return (
    <div
      className={cn(
        "fixed inset-0 z-[80] flex items-end sm:items-center justify-center transition-opacity duration-300",
        open ? "opacity-100 pointer-events-auto" : "opacity-0 pointer-events-none"
      )}
      aria-hidden={!open}
    >
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/50"
        onClick={onClose}
      />

      {/* Modal */}
      <div
        className={cn(
          "relative w-full sm:max-w-md mx-auto bg-white rounded-t-2xl sm:rounded-2xl overflow-hidden transition-transform duration-300 flex flex-col max-h-[85vh] sm:max-h-[90vh]",
          open ? "translate-y-0 sm:scale-100" : "translate-y-full sm:translate-y-0 sm:scale-95"
        )}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#EAEAEA] shrink-0">
          <h3 className="text-lg font-bold text-heading">Order on WhatsApp</h3>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-lg hover:bg-gray-100 flex items-center justify-center text-body transition-colors"
            aria-label="Close"
          >
            <X size={18} />
          </button>
        </div>

        {/* Scrollable content */}
        <div className="flex-1 overflow-y-auto">
          {/* Product summary */}
          <div className="px-5 py-3 bg-gray-50 border-b border-[#EAEAEA] flex items-center gap-3">
            {product.image && (
              <div className="relative w-12 h-12 rounded-lg overflow-hidden bg-white border border-[#EAEAEA] shrink-0">
                <Image
                  src={product.image}
                  alt={product.name}
                  fill
                  sizes="48px"
                  className="w-full h-full object-cover"
                />
              </div>
            )}
            <div className="min-w-0">
              <p className="text-[10px] text-body mb-0.5">You're ordering</p>
              <p className="text-sm font-semibold text-heading line-clamp-1">{product.name}</p>
            </div>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="px-5 py-5 space-y-4">
            <div>
              <label className="text-xs font-medium text-body block mb-1.5">Your Name *</label>
              <input
                type="text"
                value={name}
                onChange={(e) => {
                  setName(e.target.value);
                  if (errors.name) setErrors((p) => ({ ...p, name: undefined }));
                }}
                className={cn(
                  "w-full px-3 py-2.5 bg-white border rounded-lg text-sm focus:outline-none transition-colors placeholder:text-body/50",
                  errors.name ? "border-red-400 focus:border-red-500" : "border-[#EAEAEA] focus:border-rosegold"
                )}
                placeholder="Enter your full name"
              />
              {errors.name && <p className="text-xs text-red-500 mt-1">{errors.name}</p>}
            </div>

            <div>
              <label className="text-xs font-medium text-body block mb-1.5">Phone Number *</label>
              <div className="flex gap-2">
                <div className="flex items-center justify-center px-3 bg-gray-50 border border-[#EAEAEA] rounded-lg text-sm text-heading font-medium shrink-0">
                  +91
                </div>
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => {
                    setPhone(e.target.value.replace(/\D/g, "").slice(0, 10));
                    if (errors.phone) setErrors((p) => ({ ...p, phone: undefined }));
                  }}
                  className={cn(
                    "flex-1 px-3 py-2.5 bg-white border rounded-lg text-sm focus:outline-none transition-colors placeholder:text-body/50",
                    errors.phone ? "border-red-400 focus:border-red-500" : "border-[#EAEAEA] focus:border-rosegold"
                  )}
                  placeholder="10-digit mobile number"
                  inputMode="numeric"
                  maxLength={10}
                />
              </div>
              {errors.phone && <p className="text-xs text-red-500 mt-1">{errors.phone}</p>}
            </div>

            <div>
              <label className="text-xs font-medium text-body block mb-1.5">Delivery Address *</label>
              <textarea
                value={address}
                onChange={(e) => {
                  setAddress(e.target.value);
                  if (errors.address) setErrors((p) => ({ ...p, address: undefined }));
                }}
                rows={2}
                className={cn(
                  "w-full px-3 py-2.5 bg-white border rounded-lg text-sm focus:outline-none transition-colors placeholder:text-body/50 resize-none",
                  errors.address ? "border-red-400 focus:border-red-500" : "border-[#EAEAEA] focus:border-rosegold"
                )}
                placeholder="Full address with pincode"
              />
              {errors.address && <p className="text-xs text-red-500 mt-1">{errors.address}</p>}
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="text-xs font-medium text-body block mb-1.5">Start Date *</label>
                <input
                  type="date"
                  min={new Date().toISOString().split('T')[0]}
                  value={startDate}
                  onChange={(e) => {
                    setStartDate(e.target.value);
                    if (errors.startDate) setErrors((p) => ({ ...p, startDate: undefined }));
                  }}
                  className={cn(
                    "w-full px-3 py-2.5 bg-white border rounded-lg text-sm focus:outline-none transition-colors",
                    errors.startDate ? "border-red-400 focus:border-red-500" : "border-[#EAEAEA] focus:border-rosegold"
                  )}
                />
                {errors.startDate && <p className="text-xs text-red-500 mt-1">{errors.startDate}</p>}
              </div>
              <div>
                <label className="text-xs font-medium text-body block mb-1.5">End Date *</label>
                <input
                  type="date"
                  min={startDate || new Date().toISOString().split('T')[0]}
                  value={endDate}
                  onChange={(e) => {
                    setEndDate(e.target.value);
                    if (errors.endDate) setErrors((p) => ({ ...p, endDate: undefined }));
                  }}
                  className={cn(
                    "w-full px-3 py-2.5 bg-white border rounded-lg text-sm focus:outline-none transition-colors",
                    errors.endDate ? "border-red-400 focus:border-red-500" : "border-[#EAEAEA] focus:border-rosegold"
                  )}
                />
                {errors.endDate && <p className="text-xs text-red-500 mt-1">{errors.endDate}</p>}
              </div>
            </div>

            {/* Duration */}
            {(() => {
              const { rentalDays } = calculateRentalPrice(0, quantity, startDate, endDate);
              if (rentalDays <= 0) return null;
              return (
                <div className="px-3 py-2.5 bg-gray-50 rounded-lg flex items-center justify-between text-sm">
                  <span className="text-body">Duration</span>
                  <span className="font-semibold text-heading">
                    {rentalDays} {rentalDays === 1 ? "Day" : "Days"}
                  </span>
                </div>
              );
            })()}

            <div>
              <label className="text-xs font-medium text-body block mb-1.5">Quantity</label>
              <div className="flex items-center gap-2 bg-white border border-[#EAEAEA] rounded-lg p-1 w-fit">
                <button
                  type="button"
                  onClick={() => setQuantity((q) => Math.max(1, q - 1))}
                  disabled={quantity <= 1}
                  className="w-8 h-8 rounded-md hover:bg-gray-100 text-heading flex items-center justify-center transition-colors disabled:opacity-30"
                  aria-label="Decrease quantity"
                >
                  <Minus size={14} />
                </button>
                <span className="text-sm font-semibold text-heading w-8 text-center">{quantity}</span>
                <button
                  type="button"
                  onClick={() => setQuantity((q) => q + 1)}
                  className="w-8 h-8 rounded-md hover:bg-gray-100 text-heading flex items-center justify-center transition-colors"
                  aria-label="Increase quantity"
                >
                  <Plus size={14} />
                </button>
              </div>
            </div>

            <button
              type="submit"
              className="w-full py-3.5 rounded-full bg-rosegold text-white text-sm font-semibold hover:bg-rosegold-dark transition-colors mt-2"
            >
              Send Order on WhatsApp
            </button>

            <p className="text-xs text-center text-body">
              We'll confirm availability on WhatsApp shortly
            </p>
          </form>
        </div>
      </div>
    </div>
  );
}
