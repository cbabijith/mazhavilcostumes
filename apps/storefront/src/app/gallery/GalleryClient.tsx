"use client";

import { useState } from "react";
import Image from "next/image";
import { X, ChevronLeft, ChevronRight, ZoomIn } from "lucide-react";
import { type GalleryItem } from "@/lib/supabase/queries";

interface GalleryClientProps {
  initialItems: GalleryItem[];
}

export default function GalleryClient({ initialItems }: GalleryClientProps) {
  const [items] = useState<GalleryItem[]>(initialItems || []);
  const [selectedIdx, setSelectedIdx] = useState<number | null>(null);

  const openLightbox = (index: number) => {
    setSelectedIdx(index);
  };

  const closeLightbox = () => {
    setSelectedIdx(null);
  };

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
    <div className="max-w-[1600px] mx-auto px-6 sm:px-8 lg:px-12 py-12 md:py-16">
      {/* Eyebrow and Page Title */}
      <div className="text-center max-w-2xl mx-auto mb-16 animate-fadeInUp">
        <span className="section-eyebrow justify-center">Client Diaries</span>
        <h1 className="text-metallic-rosegold text-4xl sm:text-5xl md:text-6xl font-serif tracking-tight mt-2 mb-4 leading-tight">
          Our <em>Gallery</em>
        </h1>
        <p className="text-body font-light text-sm sm:text-base leading-relaxed">
          Step into a world of shared celebrations. Beautiful moments captured by our clients, showcasing the elegance of our rental dance costumes in action.
        </p>
      </div>

      {/* Gallery Grid */}
      {items.length === 0 ? (
        <div className="text-center py-24 border border-dashed border-border-silk rounded-3xl bg-white/50 backdrop-blur-sm max-w-lg mx-auto">
          <p className="text-caption font-light text-sm">Our gallery is being curated. Check back soon for client diaries.</p>
        </div>
      ) : (
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4 sm:gap-6 stagger-children">
          {items.map((item, index) => (
            <div
              key={item.id || index}
              onClick={() => openLightbox(index)}
              className="group relative aspect-[3/4] rounded-2xl overflow-hidden border border-border-silk bg-white cursor-pointer shadow-silk hover:shadow-[0_30px_60px_-15px_rgba(183,110,121,0.2)] transition-all duration-700 hover:-translate-y-2 animate-fadeInUp"
              style={{ animationDelay: `${(index % 5) * 0.1}s` }}
            >
              {/* Costume Image */}
              <Image
                src={item.image_url}
                alt="Client shared costume photo"
                fill
                sizes="(max-width: 640px) 50vw, (max-width: 768px) 33vw, (max-width: 1024px) 25vw, 20vw"
                className="object-cover transition-transform duration-1000 group-hover:scale-105"
                loading="lazy"
              />

              {/* Shimmer Overlay on hover */}
              <div className="absolute inset-0 bg-gradient-to-t from-black/40 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 flex items-center justify-center">
                <div className="p-3 bg-white/20 backdrop-blur-md rounded-full text-white scale-75 group-hover:scale-100 transition-all duration-500 border border-white/30">
                  <ZoomIn size={18} strokeWidth={1.5} />
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Lightbox Modal */}
      {selectedIdx !== null && items[selectedIdx] && (
        <div
          onClick={closeLightbox}
          className="fixed inset-0 bg-black/90 backdrop-blur-md z-[100] flex items-center justify-center p-4 animate-in fade-in duration-300"
        >
          {/* Close Button */}
          <button
            onClick={closeLightbox}
            className="absolute top-6 right-6 p-2 text-white/75 hover:text-white bg-white/10 hover:bg-white/20 rounded-full transition-all border border-white/10 z-50 cursor-pointer"
            aria-label="Close Lightbox"
          >
            <X size={24} strokeWidth={1.5} />
          </button>

          {/* Left Arrow */}
          <button
            onClick={prevImage}
            className="absolute left-6 p-3 text-white/75 hover:text-white bg-white/10 hover:bg-white/20 rounded-full transition-all border border-white/10 z-50 cursor-pointer"
            aria-label="Previous image"
          >
            <ChevronLeft size={24} strokeWidth={1.5} />
          </button>

          {/* Image Container */}
          <div
            onClick={(e) => e.stopPropagation()}
            className="relative max-w-5xl w-full max-h-[85vh] h-full rounded-2xl overflow-hidden shadow-2xl border border-white/10"
          >
            <Image
              src={items[selectedIdx].image_url}
              alt="Client Costume Detail View"
              fill
              className="object-contain"
              priority
            />
          </div>

          {/* Right Arrow */}
          <button
            onClick={nextImage}
            className="absolute right-6 p-3 text-white/75 hover:text-white bg-white/10 hover:bg-white/20 rounded-full transition-all border border-white/10 z-50 cursor-pointer"
            aria-label="Next image"
          >
            <ChevronRight size={24} strokeWidth={1.5} />
          </button>

          {/* Image Counter */}
          <div className="absolute bottom-6 left-1/2 -translate-x-1/2 bg-black/60 backdrop-blur-sm border border-white/15 px-4 py-1.5 rounded-full text-xs text-white/80 font-medium tracking-widest">
            {selectedIdx + 1} / {items.length}
          </div>
        </div>
      )}
    </div>
  );
}
