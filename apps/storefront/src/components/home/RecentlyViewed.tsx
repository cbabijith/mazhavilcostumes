"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { getProductImageUrls } from "@/lib/supabase/queries";

interface RecentlyViewedItem {
  id: string;
  name: string;
  images: any[];
}

export default function RecentlyViewed() {
  const [items, setItems] = useState<RecentlyViewedItem[]>([]);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    try {
      const history = localStorage.getItem("recently_viewed");
      if (history) {
        setItems(JSON.parse(history));
      }
    } catch (e) {
      console.error("Failed to read recently viewed items from localStorage", e);
    }
    setMounted(true);
  }, []);

  if (!mounted || items.length === 0) return null;

  return (
    <section className="py-8 sm:py-12 md:py-16 px-4 sm:px-6 md:px-12 bg-silk/30 border-b border-[var(--border-silk)] animate-fadeInUp">
      <div className="max-w-[1600px] mx-auto">
        <div className="flex flex-col md:flex-row md:items-end justify-between mb-6 sm:mb-8 gap-4">
          <div>
            <span className="section-eyebrow">Pick up where you left off</span>
            <h2 className="section-title">
              Recently <em>Viewed</em>
            </h2>
          </div>
          <button
            onClick={() => {
              localStorage.removeItem("recently_viewed");
              setItems([]);
            }}
            className="text-xs uppercase tracking-widest text-caption hover:text-rosegold transition-colors font-semibold font-sans ml-auto md:ml-0 cursor-pointer"
          >
            Clear History
          </button>
        </div>

        {/* Horizontal scroll container */}
        <div className="flex gap-4 overflow-x-auto pb-4 hide-scrollbar snap-x snap-mandatory">
          {items.map((item) => {
            const imageUrls = getProductImageUrls(item.images);
            const imageUrl = imageUrls.length > 0 ? imageUrls[0] : null;

            return (
              <Link
                key={item.id}
                href={`/product/${item.id}`}
                className="group snap-start shrink-0 block w-[40vw] sm:w-[28vw] md:w-[20vw] lg:w-[15vw] max-w-[200px]"
              >
                <div className="relative aspect-[3/4] overflow-hidden rounded-xl sm:rounded-2xl bg-silk-dark border border-[var(--border-silk)] shadow-sm group-hover:shadow-md transition-all duration-500">
                  {imageUrl ? (
                    <Image
                      src={imageUrl}
                      alt={item.name}
                      fill
                      sizes="(max-width: 640px) 40vw, (max-width: 1024px) 25vw, 200px"
                      className="absolute inset-0 w-full h-full object-cover transition-transform duration-700 ease-out group-hover:scale-[1.06]"
                    />
                  ) : (
                    <div className="absolute inset-0 flex items-center justify-center bg-rosegold/5 text-3xl opacity-20">👗</div>
                  )}
                </div>
                <div className="mt-2 text-center sm:text-left px-0.5">
                  <h4 className="text-[12px] sm:text-sm font-sans font-medium text-heading line-clamp-1 group-hover:text-rosegold transition-colors leading-snug">
                    {item.name}
                  </h4>
                </div>
              </Link>
            );
          })}
        </div>
      </div>
    </section>
  );
}
