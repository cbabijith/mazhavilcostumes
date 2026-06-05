"use client";

import { useTransition, useEffect } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import Link from "next/link";
import { 
  Search, 
  ChevronLeft, 
  ChevronRight, 
  Loader2 
} from "lucide-react";
import { Product, Category, getProductImageUrls } from "@/lib/supabase/queries";
import { cn } from "@/lib/utils";
import { Badge } from "@/components/ui/badge";

interface CollectionsClientProps {
  initialProducts: Product[];
  categories: Category[];
  initialCategoryId?: string;
  initialSearchQuery?: string;
  total: number;
  currentPage: number;
  itemsPerPage: number;
}

export default function CollectionsClient({
  initialProducts,
  categories,
  initialCategoryId,
  initialSearchQuery,
  total,
  currentPage,
  itemsPerPage,
}: CollectionsClientProps) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  const totalPages = Math.ceil(total / itemsPerPage);
  const startItem = (currentPage - 1) * itemsPerPage + 1;
  const endItem = Math.min(currentPage * itemsPerPage, total);

  // Helper to construct pagination URLs
  const getPageLink = (page: number) => {
    if (typeof window === "undefined") return `/collections?page=${page}`;
    const params = new URLSearchParams(window.location.search);
    params.set("page", page.toString());
    return `/collections?${params.toString()}`;
  };

  // Prefetch adjacent pages to make loading instantaneous on low networks
  useEffect(() => {
    if (currentPage < totalPages) {
      router.prefetch(getPageLink(currentPage + 1));
    }
    if (currentPage > 1) {
      router.prefetch(getPageLink(currentPage - 1));
    }
  }, [currentPage, totalPages, router]);

  const handlePageChange = (page: number) => {
    if (page < 1 || page > totalPages || page === currentPage) return;
    
    startTransition(() => {
      const params = new URLSearchParams(window.location.search);
      params.set("page", page.toString());
      router.push(`/collections?${params.toString()}`);
    });
  };

  // Generate page numbers for pagination bar with ellipses
  const getPageNumbers = () => {
    const pages: (number | string)[] = [];
    const siblingCount = 1; // Number of adjacent pages to show around current page

    if (totalPages <= 5) {
      for (let i = 1; i <= totalPages; i++) pages.push(i);
    } else {
      const leftSiblingIndex = Math.max(currentPage - siblingCount, 1);
      const rightSiblingIndex = Math.min(currentPage + siblingCount, totalPages);

      const shouldShowLeftDots = leftSiblingIndex > 2;
      const shouldShowRightDots = rightSiblingIndex < totalPages - 1;

      if (!shouldShowLeftDots && shouldShowRightDots) {
        const itemCount = 3 + 2 * siblingCount;
        for (let i = 1; i <= itemCount; i++) pages.push(i);
        pages.push("...");
        pages.push(totalPages);
      } else if (shouldShowLeftDots && !shouldShowRightDots) {
        pages.push(1);
        pages.push("...");
        const itemCount = 3 + 2 * siblingCount;
        for (let i = totalPages - itemCount + 1; i <= totalPages; i++) pages.push(i);
      } else if (shouldShowLeftDots && shouldShowRightDots) {
        pages.push(1);
        pages.push("...");
        for (let i = leftSiblingIndex; i <= rightSiblingIndex; i++) pages.push(i);
        pages.push("...");
        pages.push(totalPages);
      }
    }
    return pages;
  };

  const pageNumbers = getPageNumbers();

  return (
    <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
      {/* Page Heading */}
      <div className="mb-6 sm:mb-8 text-center lg:text-left">
        <div className="section-eyebrow justify-center lg:justify-start">Our Treasures</div>
        <h1 className="text-4xl sm:text-5xl lg:text-6xl font-serif text-heading mb-4 leading-tight">
          {initialSearchQuery ? (
            <>Results for <em className="italic text-rosegold">&quot;{initialSearchQuery}&quot;</em></>
          ) : (
            <>Explore our <em className="italic text-rosegold">Masterpieces</em></>
          )}
        </h1>
        <p className="text-body max-w-2xl font-light text-sm sm:text-base">
          Browse Kerala&apos;s most exquisite bridal costumes collection. Hand-selected pieces for your most precious moments.
        </p>
      </div>

      {/* Stats Summary Line */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6 sm:mb-8 pb-4 border-b border-[var(--border-silk)]">
        <div className="text-xs sm:text-sm text-muted-foreground font-sans tracking-wide">
          {total > 0 ? (
            <>
              Showing <span className="font-semibold text-heading">{startItem}–{endItem}</span> of{" "}
              <span className="font-semibold text-heading">{total.toLocaleString("en-IN")}</span> treasures
            </>
          ) : (
            "No treasures available"
          )}
        </div>
      </div>

      {/* Product Grid & Loader overlay */}
      <div className="relative min-h-[400px]">
        {isPending && (
          <div className="absolute inset-0 bg-silk/45 backdrop-blur-[1px] z-20 flex items-start justify-center pt-24 transition-opacity duration-300">
            <div className="bg-white/95 backdrop-blur-md p-4 rounded-full shadow-2xl border border-[var(--border-silk)] flex items-center justify-center">
              <Loader2 className="w-8 h-8 animate-spin text-rosegold" />
            </div>
          </div>
        )}

        <div className={cn(
          "grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-5 lg:gap-6 transition-opacity duration-500",
          isPending ? "opacity-50 pointer-events-none" : "opacity-100"
        )}>
          {initialProducts.length > 0 ? (
            initialProducts.map((product) => (
              <CollectionProductCard key={product.id} product={product} />
            ))
          ) : (
            <div className="col-span-full py-32 text-center bg-white rounded-[3rem] border border-dashed border-[var(--border-silk)]">
              <div className="w-16 h-16 bg-silk rounded-full flex items-center justify-center mx-auto mb-6 text-rosegold/30">
                <Search size={32} />
              </div>
              <h3 className="text-2xl font-serif text-heading mb-2">No Treasures Found</h3>
              <p className="text-muted-foreground text-sm max-w-sm mx-auto">
                We couldn&apos;t find any pieces matching your request. Try adjusting your search keywords.
              </p>
              <Link
                href="/collections"
                className="inline-block mt-8 px-8 py-3 bg-rosegold text-white rounded-full text-xs font-bold uppercase tracking-widest shadow-lg shadow-rosegold/20"
              >
                View All Collections
              </Link>
            </div>
          )}
        </div>
      </div>

      {/* Pagination Bar */}
      {totalPages > 1 && (
        <div className="mt-12 sm:mt-16 flex flex-col items-center justify-center gap-4 border-t border-[var(--border-silk)] pt-8">
          <div className="flex items-center gap-1.5 sm:gap-2">
            {/* Previous Page */}
            <button
              onClick={() => handlePageChange(currentPage - 1)}
              disabled={currentPage === 1 || isPending}
              className="size-9 sm:size-10 flex items-center justify-center rounded-full border border-[var(--border-silk)] bg-white text-body hover:border-rosegold hover:text-rosegold disabled:opacity-30 disabled:pointer-events-none transition-all duration-300"
              aria-label="Previous page"
            >
              <ChevronLeft size={16} />
            </button>

            {/* Page Numbers */}
            {pageNumbers.map((page, index) => {
              if (page === "...") {
                return (
                  <span
                    key={`dots-${index}`}
                    className="size-9 sm:size-10 flex items-center justify-center text-xs text-muted-foreground font-sans"
                  >
                    ...
                  </span>
                );
              }

              const pageNum = page as number;
              return (
                <button
                  key={`page-${pageNum}`}
                  onClick={() => handlePageChange(pageNum)}
                  disabled={isPending}
                  className={cn(
                    "size-9 sm:size-10 flex items-center justify-center rounded-full text-xs font-bold font-sans transition-all duration-300 border",
                    currentPage === pageNum
                      ? "bg-rosegold border-rosegold text-white shadow-md shadow-rosegold/20"
                      : "bg-white border-[var(--border-silk)] text-body hover:border-rosegold hover:text-rosegold"
                  )}
                >
                  {pageNum}
                </button>
              );
            })}

            {/* Next Page */}
            <button
              onClick={() => handlePageChange(currentPage + 1)}
              disabled={currentPage === totalPages || isPending}
              className="size-9 sm:size-10 flex items-center justify-center rounded-full border border-[var(--border-silk)] bg-white text-body hover:border-rosegold hover:text-rosegold disabled:opacity-30 disabled:pointer-events-none transition-all duration-300"
              aria-label="Next page"
            >
              <ChevronRight size={16} />
            </button>
          </div>
          
          <div className="text-[10px] sm:text-xs text-muted-foreground uppercase tracking-widest font-sans font-medium">
            Page {currentPage} of {totalPages}
          </div>
        </div>
      )}
    </div>
  );
}

/**
 * Individual product card for collections grid.
 * Uses Next.js optimized `<Image>` component for maximum performance.
 */
function CollectionProductCard({ product }: { product: Product }) {
  const imageUrls = getProductImageUrls(product.images);
  const imageUrl = imageUrls.length > 0 ? imageUrls[0] : null;

  return (
    <Link
      href={`/product/${product.id}`}
      className="group block"
    >
      {/* Image Container */}
      <div className="relative aspect-[3/4] overflow-hidden rounded-xl sm:rounded-2xl lg:rounded-3xl bg-silk-dark">
        {imageUrl ? (
          <Image
            src={imageUrl}
            alt={product.name}
            fill
            sizes="(max-width: 640px) 50vw, (max-width: 1024px) 33vw, 25vw"
            quality={70}
            className="object-cover transition-transform duration-700 ease-out group-hover:scale-[1.06]"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center text-4xl opacity-10">👗</div>
        )}

        {/* Overlay Tags */}
        <div className="absolute top-2.5 sm:top-3 left-2.5 sm:left-3 flex flex-col gap-1.5 z-10">
          {product.is_featured && (
            <Badge className="bg-white/90 backdrop-blur-sm text-rosegold text-[8px] sm:text-[9px] uppercase tracking-widest px-2 py-0.5 border-none shadow-sm font-semibold">
              Masterpiece
            </Badge>
          )}
        </div>

        {/* Quick View Button (Desktop) */}
        <div className="absolute inset-0 bg-black/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500 hidden sm:flex items-end p-3 lg:p-4 z-10">
          <div className="w-full py-2.5 bg-white/90 backdrop-blur-md text-rosegold text-[10px] font-bold uppercase tracking-widest text-center rounded-xl lg:rounded-2xl shadow-xl transform translate-y-4 group-hover:translate-y-0 transition-transform duration-500">
            View Details
          </div>
        </div>
      </div>

      {/* Product Info */}
      <div className="mt-2.5 sm:mt-4 text-center sm:text-left px-0.5">
        <h3 className="text-[13px] sm:text-sm lg:text-base font-serif text-heading mb-1 sm:mb-1.5 line-clamp-1 group-hover:text-rosegold transition-colors leading-snug">
          {product.name}
        </h3>
        <div className="flex flex-col sm:flex-row sm:items-center gap-0.5 sm:gap-2.5 justify-center sm:justify-start">
          <span className="text-rosegold font-bold font-serif text-sm sm:text-base lg:text-lg">
            ₹{product.price_per_day.toLocaleString("en-IN")}<span className="text-[9px] sm:text-[10px] font-sans text-muted-foreground ml-0.5">/day</span>
          </span>
          <span className="hidden sm:inline-block w-px h-3 bg-[var(--border-silk)]" />
          <span className="text-[8px] sm:text-[9px] uppercase tracking-widest text-muted-foreground font-medium">
            Sanitized
          </span>
        </div>
      </div>
    </Link>
  );
}
