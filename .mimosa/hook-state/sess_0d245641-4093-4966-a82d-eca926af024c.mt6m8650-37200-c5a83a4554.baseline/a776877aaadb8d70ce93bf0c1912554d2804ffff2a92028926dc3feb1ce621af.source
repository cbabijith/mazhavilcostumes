"use client";

import { useState } from "react";
import Image from "next/image";
import { X, ChevronLeft, ChevronRight } from "lucide-react";
import { type GalleryItem } from "@/lib/supabase/queries";

interface GalleryClientProps {
  initialItems: GalleryItem[];
}

export default function GalleryClient({ initialItems }: GalleryClientProps) {
  const [items] = useState<GalleryItem[]>(initialItems || []);
  const [selectedIdx, setSelectedIdx] = useState<number | null>(null);

  const openLightbox = (index: number) => setSelectedIdx(index);
  const closeLightbox = () => setSelectedIdx(null);

  const nextImage = (e?: React.MouseEvent) => {
    e?.stopPropagation();
    if (selectedIdx === null || items.length === 0) return;
    setSelectedIdx((selectedIdx + 1) % items.length);
  };

  const prevImage = (e?: React.MouseEvent) => {
    e?.stopPropagation();
    if (selectedIdx === null || items.length === 0) return;
    setSelectedIdx((selectedIdx - 1 + items.length) % items.length);
  };

  return (
    <div className="max-w-[1200px] mx-auto px-4 sm:px-6 md:px-12 py-10 sm:py-12 md:py-16">
      {/* Header */}
      <div className="text-center mb-8 sm:mb-10 md:mb-14">
        <span className="text-[10px] sm:text-xs uppercase tracking-[0.2em] font-bold text-rosegold">
          Client Diaries
        </span>
        <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold text-heading mt-3">
          Our Gallery
        </h1>
        <p className="text-sm text-body mt-3 max-w-lg mx-auto leading-relaxed">
          Step into a world of shared celebrations. Beautiful moments captured by our clients, showcasing the elegance of our rental dance costumes in action.
        </p>
      </div>

      {/* Gallery Grid */}
      {items.length === 0 ? (
        <div className="text-center py-20 border border-dashed border-[#EAEAEA] rounded-2xl bg-white max-w-lg mx-auto">
          <p className="text-sm text-body">Our gallery is being curated. Check back soon for client diaries.</p>
        </div>
      ) : (
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3 sm:gap-4">
          {items.map((item, index) => (
            <div
              key={item.id || index}
              onClick={() => openLightbox(index)}
              className="group relative rounded-xl overflow-hidden bg-gray-50 cursor-pointer aspect-square"
            >
              <Image
                src={item.image_url}
                alt="Client shared costume photo"
                fill
                sizes="(max-width: 640px) 50vw, (max-width: 768px) 33vw, 25vw"
                className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-[1.03]"
              />
              <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-colors duration-300" />
            </div>
          ))}
        </div>
      )}

      {/* Lightbox */}
      {selectedIdx !== null && items[selectedIdx] && (
        <div
          onClick={closeLightbox}
          className="fixed inset-0 bg-black/95 z-[100] flex items-center justify-center p-4 animate-in fade-in duration-200"
        >
          <button
            onClick={closeLightbox}
            className="absolute top-5 right-5 p-2 text-white/70 hover:text-white transition-colors z-50 cursor-pointer"
            aria-label="Close"
          >
            <X size={24} strokeWidth={1.5} />
          </button>

          <button
            onClick={prevImage}
            className="absolute left-4 sm:left-6 p-2 text-white/70 hover:text-white transition-colors z-50 cursor-pointer"
            aria-label="Previous"
          >
            <ChevronLeft size={28} strokeWidth={1.5} />
          </button>

          <div
            onClick={(e) => e.stopPropagation()}
            className="relative max-w-4xl w-full max-h-[88vh] h-full"
          >
            <Image
              src={items[selectedIdx].image_url}
              alt="Client costume photo"
              fill
              className="object-contain"
              priority
            />
          </div>

          <button
            onClick={nextImage}
            className="absolute right-4 sm:right-6 p-2 text-white/70 hover:text-white transition-colors z-50 cursor-pointer"
            aria-label="Next"
          >
            <ChevronRight size={28} strokeWidth={1.5} />
          </button>

          <div className="absolute bottom-5 left-1/2 -translate-x-1/2 text-xs text-white/50 font-medium">
            {selectedIdx + 1} / {items.length}
          </div>
        </div>
      )}
    </div>
  );
}
