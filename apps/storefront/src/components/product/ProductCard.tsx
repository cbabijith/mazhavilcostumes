"use client";

import { useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { ShoppingBag, Check } from 'lucide-react';
import { Product, getProductImageUrls } from '@/lib/supabase/queries';
import { Badge } from '@/components/ui/badge';

interface ProductCardProps {
  product: Product;
  badge?: {
    text: string;
    variant?: 'default' | 'secondary';
  };
}

export default function ProductCard({ product, badge }: ProductCardProps) {
  const imageUrls = getProductImageUrls(product.images);
  const imageUrl = imageUrls.length > 0 ? imageUrls[0] : null;
  const [added, setAdded] = useState(false);

  const handleAddToCart = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();

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
    }
    setAdded(true);
    setTimeout(() => setAdded(false), 2000);
  };

  return (
    <Link
      href={`/product/${product.id}`}
      className="group block"
    >
      {/* Image Container — square aspect ratio matching reference */}
      <div className="relative aspect-square overflow-hidden rounded-xl sm:rounded-2xl bg-gray-50">
        {imageUrl ? (
          <Image
            src={imageUrl}
            alt={product.name}
            fill
            sizes="(max-width: 640px) 50vw, (max-width: 1024px) 33vw, 25vw"
            className="absolute inset-0 w-full h-full object-cover transition-transform duration-700 ease-out group-hover:scale-[1.03]"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center bg-rosegold/5">
            <span className="text-4xl opacity-20">👗</span>
          </div>
        )}

        {/* Badge — solid pink */}
        {badge && (
          <div className="absolute top-2 sm:top-3 left-2 sm:left-3 z-10">
            <Badge
              variant={badge.variant || 'secondary'}
              className="bg-rosegold text-white text-[8px] sm:text-[9px] uppercase tracking-widest border-none px-1.5 sm:px-2 py-0.5 shadow-sm font-semibold"
            >
              {badge.text}
            </Badge>
          </div>
        )}
      </div>

      {/* Product Info — left-aligned with price and add-to-cart */}
      <div className="mt-2 sm:mt-2.5 px-0.5">
        <h3 className="text-[13px] sm:text-sm md:text-base font-sans text-heading mb-0.5 sm:mb-1 line-clamp-1 group-hover:text-rosegold transition-colors leading-snug">
          {product.name}
        </h3>
        <div className="flex items-center justify-between">
          <span className="text-[13px] sm:text-sm md:text-base font-semibold text-heading">
            ₹{product.price_per_day.toLocaleString("en-IN")}
          </span>
          <button
            onClick={handleAddToCart}
            aria-label="Add to cart"
            className="flex items-center justify-center w-8 h-8 sm:w-9 sm:h-9 rounded-lg bg-rosegold text-white hover:bg-rosegold-dark transition-colors duration-300 active:scale-95"
          >
            {added ? (
              <Check size={16} strokeWidth={2.5} />
            ) : (
              <ShoppingBag size={16} strokeWidth={2} />
            )}
          </button>
        </div>
      </div>
    </Link>
  );
}
