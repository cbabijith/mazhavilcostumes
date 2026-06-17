"use client";

import { useState, useEffect } from "react";
import Header from "@/components/home/Header";
import Footer from "@/components/home/Footer";
import Image from "next/image";
import { getParisBridalsStore } from "@/lib/actions/store";
import { Button } from "@/components/ui/button";
import { Trash2, ShoppingBag, Calendar } from "lucide-react";
import { buildWishlistMessage, buildWhatsAppUrl, calculateRentalPrice } from "@/lib/whatsapp";
import Link from "next/link";
import { cn } from "@/lib/utils";

interface CartItem {
  id: string;
  name: string;
  price_per_day: number;
  images: string[];
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

    // Load cart from localStorage
    const saved = localStorage.getItem("paris_cart");
    if (saved) {
      setCartItems(JSON.parse(saved));
    }
    setMounted(true);
  }, []);

  const removeFromCart = (id: string) => {
    const updated = cartItems.filter((item) => item.id !== id);
    setCartItems(updated);
    localStorage.setItem("paris_cart", JSON.stringify(updated));
    window.dispatchEvent(new CustomEvent("paris_cart_updated", { detail: updated.length }));
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
        1,
        startDate,
        endDate
      );
      return {
        name: item.name,
        price: item.price_per_day,
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
    <main className="min-h-screen bg-silk">
      <Header store={store} />

      <section className="py-12 sm:py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-[1600px] mx-auto">
          <div className="text-center mb-12">
            <div className="section-eyebrow justify-center">Selection Cart</div>
            <h1 className="text-4xl sm:text-5xl font-serif text-heading mb-4">Enquiry Cart</h1>
            <p className="text-body font-light">
              {cartItems.length} {cartItems.length === 1 ? "piece" : "pieces"} selected for your event
            </p>
          </div>

          {cartItems.length === 0 ? (
            <div className="text-center py-20">
              <div className="w-20 h-20 bg-rosegold/5 rounded-full flex items-center justify-center mx-auto mb-6">
                <ShoppingBag size={32} className="text-rosegold" strokeWidth={1.5} />
              </div>
              <h2 className="text-2xl font-serif text-heading mb-4">Your enquiry cart is empty</h2>
              <p className="text-body mb-8 max-w-md mx-auto">
                Discover our treasures and add them to your cart for a quick availability enquiry.
              </p>
              <Link href="/collections">
                <Button className="shimmer-btn px-8 py-4 rounded-full text-xs uppercase tracking-widest font-bold">
                  Explore Collections
                </Button>
              </Link>
            </div>
          ) : (
            <>
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-start">
              {/* Left Column: Cart Items List */}
              <div className="lg:col-span-7 xl:col-span-8 space-y-4">
                <div className="flex items-center justify-between border-b border-[var(--border-silk)] pb-3">
                  <h2 className="text-lg font-serif font-bold text-heading">Selected Items</h2>
                  <span className="text-xs text-muted-foreground">{cartItems.length} {cartItems.length === 1 ? 'item' : 'items'}</span>
                </div>

                <div className="space-y-4">
                  {cartItems.map((item) => (
                    <div
                      key={item.id}
                      className="bg-white rounded-[2rem] p-4 border border-[var(--border-silk)] flex gap-4 sm:gap-6 items-center hover:shadow-silk transition-all duration-300 relative"
                    >
                      {/* Item Image */}
                      <div className="relative w-20 h-20 sm:w-24 sm:h-24 rounded-2xl overflow-hidden shrink-0 border border-[var(--border-silk)]">
                        {item.images?.[0] ? (
                          <Image
                            src={item.images[0]}
                            alt={item.name}
                            fill
                            sizes="(max-width: 640px) 80px, 96px"
                            className="object-cover hover:scale-105 transition-transform duration-500"
                          />
                        ) : (
                          <div className="absolute inset-0 bg-rosegold/5" />
                        )}
                      </div>

                      {/* Item Details */}
                      <div className="flex-1 min-w-0 pr-8">
                        <h3 className="font-serif text-heading text-sm sm:text-base font-bold leading-snug line-clamp-2 mb-1.5">
                          {item.name}
                        </h3>
                        <div className="flex flex-wrap items-center gap-3">
                          <span className="text-xs sm:text-sm font-sans font-medium text-rosegold">
                            ₹{item.price_per_day} / Day
                          </span>
                          <span className="text-[10px] text-muted-foreground">•</span>
                          <Link 
                            href={`/product/${item.id}`}
                            className="text-xs font-semibold text-body hover:text-rosegold hover:underline transition-colors"
                          >
                            View Details
                          </Link>
                        </div>
                      </div>

                      {/* Delete Button */}
                      <button
                        onClick={() => removeFromCart(item.id)}
                        className="absolute right-4 top-1/2 -translate-y-1/2 w-8 h-8 sm:w-10 sm:h-10 bg-silk hover:bg-rosegold/10 text-body hover:text-rosegold rounded-full flex items-center justify-center transition-all cursor-pointer"
                        aria-label="Remove item"
                      >
                        <Trash2 size={16} strokeWidth={1.5} />
                      </button>
                    </div>
                  ))}
                </div>
              </div>

              {/* Right Column: Sticky Checkout Sidebar */}
              <div className="lg:col-span-5 xl:col-span-4 lg:sticky lg:top-28 space-y-6">
                <div className="bg-white rounded-[2.5rem] p-6 sm:p-8 border border-[var(--border-silk)] shadow-silk space-y-6">
                  <div>
                    <div className="flex items-center gap-2 mb-1 text-rosegold">
                      <Calendar size={18} />
                      <span className="text-xs uppercase font-bold tracking-widest">Rental Details</span>
                    </div>
                    <h2 className="text-xl font-serif font-bold text-heading">Select Dates</h2>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="text-[10px] uppercase tracking-[0.2em] text-body font-bold block mb-2">
                        Start Date
                      </label>
                      <input
                        type="date"
                        min={new Date().toISOString().split('T')[0]}
                        value={startDate}
                        onChange={(e) => setStartDate(e.target.value)}
                        className="w-full px-4 py-3 bg-silk border border-[var(--border-silk)] rounded-2xl text-xs focus:outline-none focus:border-rosegold focus:ring-2 focus:ring-rosegold/5 transition-all"
                      />
                    </div>
                    <div>
                      <label className="text-[10px] uppercase tracking-[0.2em] text-body font-bold block mb-2">
                        End Date
                      </label>
                      <input
                        type="date"
                        min={startDate || new Date().toISOString().split('T')[0]}
                        value={endDate}
                        onChange={(e) => setEndDate(e.target.value)}
                        className="w-full px-4 py-3 bg-silk border border-[var(--border-silk)] rounded-2xl text-xs focus:outline-none focus:border-rosegold focus:ring-2 focus:ring-rosegold/5 transition-all"
                      />
                    </div>
                  </div>

                  {error && (
                    <p className="text-xs text-red-500 text-center bg-red-50 border border-red-100 rounded-xl py-2 px-3 animate-in fade-in">
                      {error}
                    </p>
                  )}

                  {/* Enquiry Summary inside Checkout Card */}
                  {(() => {
                    const { rentalDays } = calculateRentalPrice(0, 1, startDate, endDate);
                    return (
                      <div className="border-t border-[var(--border-silk)] pt-5 space-y-3">
                        <div className="flex justify-between text-sm">
                          <span className="text-body font-medium">Selected Items:</span>
                          <span className="font-bold text-heading">{cartItems.length}</span>
                        </div>
                        {rentalDays > 0 && (
                          <div className="flex justify-between text-sm animate-in fade-in duration-200">
                            <span className="text-body font-medium">Duration:</span>
                            <span className="font-bold text-heading">{rentalDays} {rentalDays === 1 ? 'day' : 'days'}</span>
                          </div>
                        )}
                      </div>
                    );
                  })()}

                  <Button
                    onClick={bookViaWhatsApp}
                    className="hidden lg:flex w-full shimmer-btn py-4 rounded-full text-xs uppercase tracking-widest font-bold items-center justify-center gap-2 mt-4"
                  >
                    <ShoppingBag size={16} strokeWidth={1.5} />
                    Enquire via WhatsApp
                  </Button>
                </div>
              </div>
            </div>

            {/* Sticky bottom CTA for mobile */}
            <div className="fixed bottom-24 left-4 right-4 lg:hidden z-40 animate-in slide-in-from-bottom duration-300">
              <Button
                onClick={bookViaWhatsApp}
                className="w-full shimmer-btn py-4 rounded-full text-xs sm:text-sm uppercase tracking-widest font-bold flex items-center justify-center gap-3 shadow-xl"
              >
                <ShoppingBag size={18} strokeWidth={1.5} />
                Enquire via WhatsApp ({cartItems.length})
              </Button>
            </div>
            </>
          )}
        </div>
      </section>

      <Footer store={store} />
    </main>
  );
}
