"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import Image from "next/image";
import { ChevronRight, ShoppingBag, ShieldCheck, Sparkles, Truck } from "lucide-react";
import WhatsAppOrderModal from "./WhatsAppOrderModal";
import { getProductImageUrls } from "@/lib/supabase/queries";
import { cn } from "@/lib/utils";

interface ProductDetailsProps {
  product: {
    id: string;
    name: string;
    description: string | null;
    price_per_day: number;
    security_deposit: number;
    images: any[];
    category?: { id: string; name: string; slug: string } | null;
    available_quantity: number;
    track_inventory: boolean;
  };
}

export default function ProductDetails({ product }: ProductDetailsProps) {
  const [modalOpen, setModalOpen] = useState(false);
  const [activeImage, setActiveImage] = useState(0);
  const [isInCart, setIsInCart] = useState(false);
  const router = useRouter();

  const images = getProductImageUrls(product.images);
  const mainImage = images[activeImage] || null;

  useEffect(() => {
    const cart = JSON.parse(localStorage.getItem("paris_cart") || "[]");
    setIsInCart(cart.some((item: any) => item.id === product.id));
  }, [product.id]);

  const handleCartAction = () => {
    if (isInCart) {
      router.push("/cart");
      return;
    }
    const cart = JSON.parse(localStorage.getItem("paris_cart") || "[]");
    const exists = cart.some((item: any) => item.id === product.id);
    if (!exists) {
      const newItem = {
        id: product.id,
        name: product.name,
        price_per_day: product.price_per_day,
        images: product.images,
      };
      const newCart = [...cart, newItem];
      localStorage.setItem("paris_cart", JSON.stringify(newCart));
      window.dispatchEvent(new CustomEvent("paris_cart_updated", { detail: newCart.length }));
      setIsInCart(true);
    }
  };

  return (
    <>
      <section className="pt-6 sm:pt-8 md:pt-10 pb-10 sm:pb-14">
        <div className="max-w-[1100px] mx-auto px-4 sm:px-6 md:px-12">
          {/* Breadcrumb */}
          <nav className="flex items-center gap-1.5 text-xs text-body mb-5 sm:mb-6 overflow-x-auto hide-scrollbar">
            <Link href="/" className="hover:text-rosegold transition-colors whitespace-nowrap">Home</Link>
            <ChevronRight size={12} />
            <Link href="/collections" className="hover:text-rosegold transition-colors whitespace-nowrap">Collections</Link>
            {product.category && (
              <>
                <ChevronRight size={12} />
                <Link
                  href={`/collections?category_id=${product.category.id}`}
                  className="hover:text-rosegold transition-colors whitespace-nowrap"
                >
                  {product.category.name}
                </Link>
              </>
            )}
            <ChevronRight size={12} />
            <span className="text-heading font-medium line-clamp-1">{product.name}</span>
          </nav>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 sm:gap-8 lg:gap-12">
            {/* Image Gallery */}
            <div className="flex flex-col gap-3">
              <div className="relative aspect-square rounded-2xl overflow-hidden bg-gray-50 border border-[#EAEAEA]">
                {mainImage ? (
                  <Image
                    src={mainImage}
                    alt={product.name}
                    fill
                    priority
                    sizes="(max-width: 640px) 100vw, 50vw"
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center bg-rosegold/5 text-6xl opacity-20">👗</div>
                )}
              </div>

              {images.length > 1 && (
                <div className="flex gap-2 overflow-x-auto hide-scrollbar pb-1">
                  {images.map((img, idx) => (
                    <button
                      key={idx}
                      onClick={() => setActiveImage(idx)}
                      className={cn(
                        "relative w-16 h-16 sm:w-20 sm:h-20 rounded-xl overflow-hidden shrink-0 border-2 transition-colors",
                        activeImage === idx ? "border-rosegold" : "border-[#EAEAEA] hover:border-rosegold/40"
                      )}
                      aria-label={`View image ${idx + 1}`}
                    >
                      <Image
                        src={img}
                        alt={`${product.name} ${idx + 1}`}
                        fill
                        sizes="80px"
                        className="w-full h-full object-cover"
                      />
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Product Info */}
            <div className="flex flex-col">
              {product.category && (
                <span className="text-[10px] uppercase tracking-[0.2em] font-bold text-rosegold mb-2">
                  {product.category.name}
                </span>
              )}

              <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold text-heading leading-tight mb-3">
                {product.name}
              </h1>

              <div className="flex items-baseline gap-2 mb-4">
                <span className="text-xl sm:text-2xl font-bold text-heading">
                  ₹{product.price_per_day.toLocaleString("en-IN")}
                </span>
                <span className="text-sm text-body">/day</span>
              </div>

              {product.description && (
                <p className="text-sm text-body leading-relaxed mb-6">
                  {product.description}
                </p>
              )}

              {/* Features */}
              <div className="grid grid-cols-3 gap-2 sm:gap-3 mb-6">
                {[
                  { icon: ShieldCheck, label: "Certified" },
                  { icon: Sparkles, label: "Sanitized" },
                  { icon: Truck, label: "Safe Delivery" },
                ].map(({ icon: Icon, label }) => (
                  <div
                    key={label}
                    className="flex flex-col items-center text-center gap-1.5 p-3 rounded-xl bg-gray-50 border border-[#EAEAEA]"
                  >
                    <Icon className="text-rosegold" size={16} strokeWidth={1.8} />
                    <span className="text-[10px] sm:text-[11px] font-medium text-body leading-tight">
                      {label}
                    </span>
                  </div>
                ))}
              </div>

              {/* CTAs */}
              <div className="flex flex-col gap-3">
                <button
                  onClick={() => setModalOpen(true)}
                  className="hidden lg:flex w-full py-3.5 rounded-full bg-rosegold text-white text-sm font-semibold hover:bg-rosegold-dark transition-colors items-center justify-center gap-2"
                >
                  <ShoppingBag size={16} strokeWidth={1.8} />
                  Reserve Now
                </button>

                <button
                  onClick={handleCartAction}
                  className={cn(
                    "w-full py-3.5 rounded-full text-sm font-semibold transition-colors flex items-center justify-center gap-2 border",
                    isInCart
                      ? "bg-heading text-white border-heading"
                      : "bg-white text-heading border-heading hover:bg-heading/5"
                  )}
                >
                  <ShoppingBag size={16} strokeWidth={1.8} />
                  {isInCart ? "Go to Cart" : "Add to Cart"}
                </button>
              </div>

              {/* Trust notes */}
              <div className="mt-6 pt-5 border-t border-[#EAEAEA] space-y-2">
                <p className="text-xs text-body flex items-center gap-2">
                  <span className="text-rosegold">✓</span> Order confirmation on WhatsApp
                </p>
                <p className="text-xs text-body flex items-center gap-2">
                  <span className="text-rosegold">✓</span> Free fittings & styling
                </p>
                <p className="text-xs text-body flex items-center gap-2">
                  <span className="text-rosegold">✓</span> Trusted by 500+ dancers
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Mobile sticky bar */}
      <div className="lg:hidden fixed bottom-0 inset-x-0 z-40 bg-white border-t border-[#EAEAEA]">
        <div className="px-4 py-3">
          <button
            onClick={() => setModalOpen(true)}
            className="w-full py-3.5 rounded-full bg-rosegold text-white text-sm font-semibold hover:bg-rosegold-dark transition-colors"
          >
            Reserve Now
          </button>
        </div>
      </div>

      <WhatsAppOrderModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        product={{
          name: product.name,
          price_per_day: product.price_per_day,
          categoryName: product.category?.name,
          image: mainImage,
        }}
      />
    </>
  );
}
