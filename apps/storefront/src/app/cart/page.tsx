"use client";

import { useState, useEffect } from "react";
import Header from "@/components/home/Header";
import Footer from "@/components/home/Footer";
import Image from "next/image";
import { getParisBridalsStore } from "@/lib/actions/store";
import { getProductImageUrls } from "@/lib/supabase/queries";
import { Trash2, ShoppingBag, Calendar, Minus, Plus } from "lucide-react";
import { buildWishlistMessage, buildWhatsAppUrl, calculateRentalPrice } from "@/lib/whatsapp";
import Link from "next/link";

interface CartItem {
  id: string;
  name: string;
  price_per_day: number;
  images: any[];
  quantity?: number;
}

export default function CartPage() {
  const [store, setStore] = useState<any>(null);
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [mounted, setMounted] = useState(false);
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    async function loadStore() {
      const storeData = await getParisBridalsStore();
      setStore(storeData);
    }
    loadStore();

    const saved = localStorage.getItem("paris_cart");
    if (saved) {
      try {
        const items = JSON.parse(saved);
        setCartItems(items.map((item: CartItem) => ({ ...item, quantity: item.quantity || 1 })));
      } catch (e) {
        setCartItems([]);
      }
    }
    setMounted(true);
  }, []);

  const saveCart = (items: CartItem[]) => {
    setCartItems(items);
    localStorage.setItem("paris_cart", JSON.stringify(items));
    window.dispatchEvent(new CustomEvent("paris_cart_updated", { detail: items.length }));
  };

  const updateQuantity = (id: string, delta: number) => {
    const updated = cartItems.map((item) =>
      item.id === id
        ? { ...item, quantity: Math.max(1, (item.quantity || 1) + delta) }
        : item
    );
    saveCart(updated);
  };

  const removeFromCart = (id: string) => {
    const updated = cartItems.filter((item) => item.id !== id);
    saveCart(updated);
  };

  const bookViaWhatsApp = () => {
    if (!startDate || !endDate) {
      setError("Please select rental start and end dates");
      return;
    }
    setError("");

    const items = cartItems.map((item) => {
      const { rentalDays, totalRent } = calculateRentalPrice(
        item.price_per_day,
        item.quantity || 1,
        startDate,
        endDate
      );
      return {
        name: item.name,
        price: item.price_per_day,
        quantity: item.quantity || 1,
        startDate,
        endDate,
        rentalDays,
        totalRent,
      };
    });
    const message = buildWishlistMessage(items);
    window.open(buildWhatsAppUrl(message), "_blank");
  };

  if (!mounted) return null;

  return (
    <main className="min-h-screen bg-white pb-28 lg:pb-0">
      <Header store={store} />

      <section className="py-8 sm:py-12 md:py-16 px-4 sm:px-6 md:px-12">
        <div className="max-w-[1100px] mx-auto">
          {/* Header */}
          <div className="text-center mb-8 sm:mb-10">
            <span className="text-[10px] sm:text-xs uppercase tracking-[0.2em] font-bold text-rosegold">
              Selection Cart
            </span>
            <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold text-heading mt-2">
              Enquiry Cart
            </h1>
            <p className="text-sm text-body mt-2">
              {cartItems.length} {cartItems.length === 1 ? "item" : "items"} selected for your event
            </p>
          </div>

          {cartItems.length === 0 ? (
            <div className="text-center py-16 sm:py-24">
              <div className="w-16 h-16 sm:w-20 sm:h-20 bg-rosegold/5 rounded-full flex items-center justify-center mx-auto mb-5">
                <ShoppingBag size={28} className="text-rosegold" strokeWidth={1.5} />
              </div>
              <h2 className="text-lg sm:text-xl font-semibold text-heading mb-3">
                Your cart is empty
              </h2>
              <p className="text-sm text-body mb-6 max-w-sm mx-auto">
                Browse our collection and add costumes to your enquiry cart.
              </p>
              <Link
                href="/collections"
                className="inline-flex items-center justify-center px-6 py-3 rounded-full bg-rosegold text-white text-sm font-semibold hover:bg-rosegold-dark transition-colors"
              >
                Explore Collections
              </Link>
            </div>
          ) : (
            <>
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 lg:gap-8 items-start">
                {/* Cart Items */}
                <div className="lg:col-span-2 space-y-3 sm:space-y-4">
                  {cartItems.map((item) => {
                    const imageUrls = getProductImageUrls(item.images);
                    const imageUrl = imageUrls.length > 0 ? imageUrls[0] : null;
                    const qty = item.quantity || 1;

                    return (
                      <div
                        key={item.id}
                        className="flex gap-3 sm:gap-4 p-3 sm:p-4 rounded-2xl border border-[#EAEAEA] bg-white"
                      >
                        {/* Image */}
                        <div className="relative w-20 h-20 sm:w-24 sm:h-24 rounded-xl overflow-hidden shrink-0 bg-gray-50">
                          {imageUrl ? (
                            <Image
                              src={imageUrl}
                              alt={item.name}
                              fill
                              sizes="(max-width: 640px) 80px, 96px"
                              className="object-cover"
                            />
                          ) : (
                            <div className="absolute inset-0 flex items-center justify-center bg-rosegold/5">
                              <span className="text-2xl opacity-20">👗</span>
                            </div>
                          )}
                        </div>

                        {/* Details */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-start justify-between gap-2">
                            <Link
                              href={`/product/${item.id}`}
                              className="text-sm sm:text-base font-semibold text-heading hover:text-rosegold transition-colors line-clamp-2 leading-snug"
                            >
                              {item.name}
                            </Link>
                            <button
                              onClick={() => removeFromCart(item.id)}
                              className="shrink-0 p-1.5 text-body hover:text-red-500 transition-colors"
                              aria-label="Remove item"
                            >
                              <Trash2 size={16} strokeWidth={1.5} />
                            </button>
                          </div>

                          <div className="mt-2 flex items-center justify-between">
                            <span className="text-sm font-medium text-rosegold">
                              ₹{item.price_per_day.toLocaleString("en-IN")} <span className="text-xs text-body">/day</span>
                            </span>

                            {/* Quantity Controls */}
                            <div className="flex items-center gap-2">
                              <button
                                onClick={() => updateQuantity(item.id, -1)}
                                className="w-7 h-7 rounded-lg border border-[#EAEAEA] flex items-center justify-center text-body hover:border-rosegold hover:text-rosegold transition-colors active:scale-95"
                                aria-label="Decrease quantity"
                              >
                                <Minus size={14} strokeWidth={2} />
                              </button>
                              <span className="text-sm font-semibold text-heading w-6 text-center">
                                {qty}
                              </span>
                              <button
                                onClick={() => updateQuantity(item.id, 1)}
                                className="w-7 h-7 rounded-lg border border-[#EAEAEA] flex items-center justify-center text-body hover:border-rosegold hover:text-rosegold transition-colors active:scale-95"
                                aria-label="Increase quantity"
                              >
                                <Plus size={14} strokeWidth={2} />
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>

                {/* Sidebar */}
                <div className="lg:col-span-1 lg:sticky lg:top-28">
                  <div className="rounded-2xl border border-[#EAEAEA] bg-white p-5 sm:p-6 space-y-5">
                    <div className="flex items-center gap-2 text-rosegold">
                      <Calendar size={18} strokeWidth={1.8} />
                      <span className="text-xs uppercase font-bold tracking-[0.15em]">Rental Dates</span>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="text-[10px] uppercase tracking-wider text-body font-medium block mb-1.5">
                          Start
                        </label>
                        <input
                          type="date"
                          min={new Date().toISOString().split("T")[0]}
                          value={startDate}
                          onChange={(e) => setStartDate(e.target.value)}
                          className="w-full px-3 py-2.5 bg-gray-50 border border-[#EAEAEA] rounded-xl text-sm focus:outline-none focus:border-rosegold transition-colors"
                        />
                      </div>
                      <div>
                        <label className="text-[10px] uppercase tracking-wider text-body font-medium block mb-1.5">
                          End
                        </label>
                        <input
                          type="date"
                          min={startDate || new Date().toISOString().split("T")[0]}
                          value={endDate}
                          onChange={(e) => setEndDate(e.target.value)}
                          className="w-full px-3 py-2.5 bg-gray-50 border border-[#EAEAEA] rounded-xl text-sm focus:outline-none focus:border-rosegold transition-colors"
                        />
                      </div>
                    </div>

                    {error && (
                      <p className="text-xs text-red-500 text-center bg-red-50 rounded-lg py-2 px-3">
                        {error}
                      </p>
                    )}

                    {/* Summary */}
                    <div className="border-t border-[#EAEAEA] pt-4 space-y-2">
                      <div className="flex justify-between text-sm">
                        <span className="text-body">Items</span>
                        <span className="font-semibold text-heading">{cartItems.length}</span>
                      </div>
                      <div className="flex justify-between text-sm">
                        <span className="text-body">Total Quantity</span>
                        <span className="font-semibold text-heading">
                          {cartItems.reduce((sum, item) => sum + (item.quantity || 1), 0)}
                        </span>
                      </div>
                      {(() => {
                        const { rentalDays } = calculateRentalPrice(0, 1, startDate, endDate);
                        if (rentalDays > 0) {
                          return (
                            <div className="flex justify-between text-sm">
                              <span className="text-body">Duration</span>
                              <span className="font-semibold text-heading">
                                {rentalDays} {rentalDays === 1 ? "day" : "days"}
                              </span>
                            </div>
                          );
                        }
                        return null;
                      })()}
                    </div>

                    {/* Desktop CTA */}
                    <button
                      onClick={bookViaWhatsApp}
                      className="hidden lg:flex w-full py-3.5 rounded-full bg-rosegold text-white text-sm font-semibold hover:bg-rosegold-dark transition-colors items-center justify-center gap-2"
                    >
                      <ShoppingBag size={16} strokeWidth={1.8} />
                      Enquire via WhatsApp
                    </button>
                  </div>
                </div>
              </div>

              {/* Mobile Sticky CTA */}
              <div className="fixed bottom-20 left-4 right-4 lg:hidden z-40">
                <button
                  onClick={bookViaWhatsApp}
                  className="w-full py-3.5 rounded-full bg-rosegold text-white text-sm font-semibold hover:bg-rosegold-dark transition-colors flex items-center justify-center gap-2 shadow-lg"
                >
                  <ShoppingBag size={18} strokeWidth={1.8} />
                  Enquire via WhatsApp ({cartItems.length})
                </button>
              </div>
            </>
          )}
        </div>
      </section>

      <Footer store={store} />
    </main>
  );
}
