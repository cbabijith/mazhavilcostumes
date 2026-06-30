"use client";

import { useTransition, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { ChevronLeft, ChevronRight, Loader2, Search, SlidersHorizontal } from "lucide-react";
import { Product, Category } from "@/lib/supabase/queries";
import { cn } from "@/lib/utils";
import ProductCard from "@/components/product/ProductCard";

interface CollectionsClientProps {
  initialProducts: Product[];
  categories: Category[];
  initialCategoryId?: string;
  initialSearchQuery?: string;
  initialSort?: string;
  total: number;
  currentPage: number;
  itemsPerPage: number;
}

const SORT_OPTIONS = [
  { value: "newest", label: "Newest First" },
  { value: "price_low", label: "Price: Low to High" },
  { value: "price_high", label: "Price: High to Low" },
  { value: "name_asc", label: "Name: A to Z" },
  { value: "name_desc", label: "Name: Z to A" },
];

export default function CollectionsClient({
  initialProducts,
  categories,
  initialCategoryId,
  initialSearchQuery,
  initialSort,
  total,
  currentPage,
  itemsPerPage,
}: CollectionsClientProps) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  const totalPages = Math.ceil(total / itemsPerPage);
  const startItem = (currentPage - 1) * itemsPerPage + 1;
  const endItem = Math.min(currentPage * itemsPerPage, total);
  const currentSort = initialSort || "newest";

  const updateParams = (updates: Record<string, string | undefined>) => {
    startTransition(() => {
      const params = new URLSearchParams(window.location.search);
      Object.entries(updates).forEach(([key, value]) => {
        if (value === undefined || value === "") {
          params.delete(key);
        } else {
          params.set(key, value);
        }
      });
      // Reset to page 1 when filters/sort change
      if (!updates.page) params.set("page", "1");
      router.push(`/collections?${params.toString()}`);
    });
  };

  const handleSortChange = (value: string) => {
    updateParams({ sort: value === "newest" ? undefined : value });
  };

  const handleCategoryChange = (categoryId: string | undefined) => {
    updateParams({ category_id: categoryId, page: "1" });
  };

  const getPageLink = (page: number) => {
    if (typeof window === "undefined") return `/collections?page=${page}`;
    const params = new URLSearchParams(window.location.search);
    params.set("page", page.toString());
    return `/collections?${params.toString()}`;
  };

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

  const getPageNumbers = () => {
    const pages: number[] = [];
    const start = Math.max(1, currentPage - 2);
    const end = Math.min(totalPages, start + 4);
    for (let i = start; i <= end; i++) pages.push(i);
    return pages;
  };

  return (
    <div className="max-w-[1200px] mx-auto px-4 sm:px-6 md:px-12 py-8 sm:py-10 md:py-12">
      {/* Header */}
      <div className="text-center mb-6 sm:mb-8">
        <span className="text-[10px] sm:text-xs uppercase tracking-[0.2em] font-bold text-rosegold">
          Our Treasures
        </span>
        <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold text-heading mt-2">
          {initialSearchQuery ? `Results for "${initialSearchQuery}"` : "Explore our Masterpieces"}
        </h1>
        <p className="text-sm text-body mt-2 max-w-lg mx-auto">
          Browse Kerala's most exquisite bridal costumes collection. Hand-selected pieces for your most precious moments.
        </p>
      </div>

      {/* Category Filter Pills */}
      {categories.length > 0 && (
        <div className="flex items-center gap-2 overflow-x-auto hide-scrollbar pb-2 mb-4">
          <button
            onClick={() => handleCategoryChange(undefined)}
            className={cn(
              "shrink-0 px-4 py-2 rounded-full text-xs font-medium transition-colors border",
              !initialCategoryId
                ? "bg-rosegold border-rosegold text-white"
                : "bg-white border-[#EAEAEA] text-body hover:border-rosegold hover:text-rosegold"
            )}
          >
            All
          </button>
          {categories.map((cat) => (
            <button
              key={cat.id}
              onClick={() => handleCategoryChange(cat.id)}
              className={cn(
                "shrink-0 px-4 py-2 rounded-full text-xs font-medium transition-colors border",
                initialCategoryId === cat.id
                  ? "bg-rosegold border-rosegold text-white"
                  : "bg-white border-[#EAEAEA] text-body hover:border-rosegold hover:text-rosegold"
              )}
            >
              {cat.name}
            </button>
          ))}
        </div>
      )}

      {/* Stats + Sort */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-5 sm:mb-6 pb-3 border-b border-[#EAEAEA]">
        <p className="text-xs sm:text-sm text-body">
          {total > 0 ? (
            <>
              Showing <span className="font-semibold text-heading">{startItem}–{endItem}</span> of{" "}
              <span className="font-semibold text-heading">{total.toLocaleString("en-IN")}</span> items
            </>
          ) : (
            "No items available"
          )}
        </p>

        {/* Sort Dropdown */}
        <div className="flex items-center gap-2">
          <SlidersHorizontal size={14} className="text-body" />
          <select
            value={currentSort}
            onChange={(e) => handleSortChange(e.target.value)}
            className="text-xs sm:text-sm font-medium text-heading bg-transparent border border-[#EAEAEA] rounded-lg px-3 py-2 focus:outline-none focus:border-rosegold transition-colors cursor-pointer"
          >
            {SORT_OPTIONS.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Product Grid */}
      <div className="relative min-h-[300px]">
        {isPending && (
          <div className="absolute inset-0 bg-white/60 z-20 flex items-start justify-center pt-32">
            <Loader2 className="w-6 h-6 animate-spin text-rosegold" />
          </div>
        )}

        <div className={cn(
          "grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-4 md:gap-5 transition-opacity duration-300",
          isPending ? "opacity-40" : "opacity-100"
        )}>
          {initialProducts.length > 0 ? (
            initialProducts.map((product) => (
              <ProductCard
                key={product.id}
                product={product}
                badge={product.is_featured ? { text: "Featured" } : undefined}
              />
            ))
          ) : (
            <div className="col-span-full py-20 text-center">
              <Search size={32} className="text-body/30 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-heading mb-2">No items found</h3>
              <p className="text-sm text-body mb-6 max-w-sm mx-auto">
                We couldn't find any pieces matching your request.
              </p>
              <Link
                href="/collections"
                className="inline-flex items-center justify-center px-6 py-3 rounded-full bg-rosegold text-white text-sm font-semibold hover:bg-rosegold-dark transition-colors"
              >
                View All Collections
              </Link>
            </div>
          )}
        </div>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="mt-8 sm:mt-10 flex items-center justify-center gap-2">
          <button
            onClick={() => handlePageChange(currentPage - 1)}
            disabled={currentPage === 1 || isPending}
            className="w-9 h-9 flex items-center justify-center rounded-lg border border-[#EAEAEA] text-body hover:border-rosegold hover:text-rosegold disabled:opacity-30 disabled:pointer-events-none transition-colors"
            aria-label="Previous page"
          >
            <ChevronLeft size={16} />
          </button>

          {getPageNumbers().map((pageNum) => (
            <button
              key={`page-${pageNum}`}
              onClick={() => handlePageChange(pageNum)}
              disabled={isPending}
              className={cn(
                "w-9 h-9 flex items-center justify-center rounded-lg text-sm font-medium transition-colors border",
                currentPage === pageNum
                  ? "bg-rosegold border-rosegold text-white"
                  : "bg-white border-[#EAEAEA] text-body hover:border-rosegold hover:text-rosegold"
              )}
            >
              {pageNum}
            </button>
          ))}

          <button
            onClick={() => handlePageChange(currentPage + 1)}
            disabled={currentPage === totalPages || isPending}
            className="w-9 h-9 flex items-center justify-center rounded-lg border border-[#EAEAEA] text-body hover:border-rosegold hover:text-rosegold disabled:opacity-30 disabled:pointer-events-none transition-colors"
            aria-label="Next page"
          >
            <ChevronRight size={16} />
          </button>
        </div>
      )}
    </div>
  );
}
