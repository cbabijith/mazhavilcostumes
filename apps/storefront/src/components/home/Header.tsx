"use client";

import { useState, useEffect, useRef } from "react";
import Link from "next/link";
import Image from "next/image";
import { ShoppingBag, Heart, ChevronLeft, ChevronRight } from "lucide-react";
import { Store, Category } from "@/lib/supabase/queries";
import { cn } from "@/lib/utils";
import { useRouter } from "next/navigation";
import ActionSearchBar from "@/components/ui/action-search-bar";

interface HeaderProps {
  store: Store | null;
  categories?: Category[];
}

export default function Header({ store, categories }: HeaderProps) {
  const [isScrolled, setIsScrolled] = useState(false);
  const [cartCount, setCartCount] = useState(0);
  const [wishlistCount, setWishlistCount] = useState(0);
  const router = useRouter();

  const scrollRef = useRef<HTMLDivElement>(null);
  const [showLeftArrow, setShowLeftArrow] = useState(false);
  const [showRightArrow, setShowRightArrow] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      const scrolled = window.scrollY > 40;
      if (scrolled !== isScrolled) setIsScrolled(scrolled);
    };

    const loadCounts = () => {
      const cart = JSON.parse(localStorage.getItem("paris_cart") || "[]");
      const wish = JSON.parse(localStorage.getItem("paris_wishlist") || "[]");
      setCartCount(cart.length);
      setWishlistCount(wish.length);
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    loadCounts();

    const handleCartUpdate = (e: any) => setCartCount(e.detail);
    const handleWishUpdate = (e: any) => setWishlistCount(e.detail);

    window.addEventListener("paris_cart_updated", handleCartUpdate);
    window.addEventListener("paris_wishlist_updated", handleWishUpdate);

    return () => {
      window.removeEventListener("scroll", handleScroll);
      window.removeEventListener("paris_cart_updated", handleCartUpdate);
      window.removeEventListener("paris_wishlist_updated", handleWishUpdate);
    };
  }, [isScrolled]);

  const compactCategories = false;

  const storeName = store?.name || "Mazhavil Dance Costumes";
  const logoUrl = store?.logo_url || "/logo_mazhavil.jpeg";

  const displayCategories = categories || [];

  const checkScroll = () => {
    if (scrollRef.current) {
      const { scrollLeft, scrollWidth, clientWidth } = scrollRef.current;
      setShowLeftArrow(scrollLeft > 10);
      setShowRightArrow(scrollLeft < scrollWidth - clientWidth - 10);
    }
  };

  useEffect(() => {
    const el = scrollRef.current;
    if (el) {
      el.addEventListener("scroll", checkScroll);
      // Wait a moment for layout to compute and set initial visibility
      const timer = setTimeout(checkScroll, 100);
      window.addEventListener("resize", checkScroll);
      return () => {
        el.removeEventListener("scroll", checkScroll);
        window.removeEventListener("resize", checkScroll);
        clearTimeout(timer);
      };
    }
  }, [displayCategories]);

  const scroll = (direction: "left" | "right") => {
    if (scrollRef.current) {
      const { clientWidth } = scrollRef.current;
      const scrollAmount = clientWidth * 0.75;
      scrollRef.current.scrollBy({
        left: direction === "left" ? -scrollAmount : scrollAmount,
        behavior: "smooth",
      });
    }
  };

  const navLinks = [
    { label: "Collections", href: "/collections" },
    { label: "Gallery", href: "/gallery" },
    { label: "About Us", href: "/about" },
  ];


  return (
    <>
      <nav
        className={cn(
          "sticky top-0 z-50 transition-all duration-300 border-b bg-white py-4",
          isScrolled ? "border-[var(--border-silk)] shadow-sm" : "border-transparent"
        )}
      >
        <div className="max-w-[1600px] mx-auto px-6 sm:px-8 lg:px-12">
          <div className="flex items-center justify-between gap-4 sm:gap-10">
            {/* Logo */}
            <Link href="/" className="flex items-center gap-2 group shrink-0 transition-all duration-500">
              <div className="relative overflow-hidden rounded-full">
                <Image
                  src={logoUrl}
                  alt="Mazhavil Dance Costumes"
                  width={180}
                  height={60}
                  className="w-auto object-contain transition-all duration-500 h-12 sm:h-14 md:h-16"
                />
              </div>
              <div className="hidden sm:flex flex-col text-left justify-center">
                <span className="text-sm sm:text-base md:text-xl font-serif font-bold tracking-[0.05em] uppercase text-rosegold transition-colors leading-tight whitespace-nowrap">
                  Mazhavil Dance Costumes
                </span>
                <span 
                  className="w-full text-center text-[10px] sm:text-[11px] md:text-[12px] tracking-[0.6em] text-body uppercase opacity-80 leading-none mt-1.5 font-medium font-sans block italic"
                  style={{ marginRight: "-0.6em" }}
                >
                  Karamana | Trivandrum
                </span>
              </div>
            </Link>

            {/* Desktop Nav */}
            <div className="hidden lg:flex items-center gap-8">
              {navLinks.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  className="text-[11px] uppercase tracking-[0.15em] font-bold text-rosegold transition-colors relative after:absolute after:bottom-0 after:left-0 after:w-0 after:h-[1px] after:bg-rosegold after:transition-all hover:after:w-full"
                >
                  {link.label}
                </Link>
              ))}
            </div>

            {/* Actions & Search */}
            <div className="flex items-center flex-1 justify-end gap-2 sm:gap-4 shrink-0">
              {/* Search Bar — uses ActionSearchBar on all sizes */}
              <div className="flex-1 max-w-[400px]">
                <ActionSearchBar storeId={store?.id} />
              </div>

              <div className="flex items-center gap-1 hidden sm:flex">
                <Link
                  href="/wishlist"
                  className="hidden sm:flex p-2.5 text-body hover:text-rosegold transition-all hover:bg-rosegold/5 rounded-full relative"
                  aria-label="Wishlist"
                >
                  <Heart size={20} strokeWidth={1.5} />
                  {wishlistCount > 0 && (
                    <span className="absolute top-1.5 right-1.5 bg-rosegold text-white text-[9px] font-bold min-w-[14px] h-[14px] flex items-center justify-center rounded-full border border-white animate-in zoom-in duration-200">
                      {wishlistCount}
                    </span>
                  )}
                </Link>
                <Link
                  href="/cart"
                  className="hidden sm:flex p-2.5 text-body hover:text-rosegold transition-all hover:bg-rosegold/5 rounded-full relative"
                  aria-label="Enquiry Cart"
                >
                  <ShoppingBag size={20} strokeWidth={1.5} />
                  {cartCount > 0 && (
                    <span className="absolute top-1.5 right-1.5 bg-heading text-white text-[9px] font-bold min-w-[14px] h-[14px] flex items-center justify-center rounded-full border border-white animate-in zoom-in duration-200">
                      {cartCount}
                    </span>
                  )}
                </Link>
              </div>
            </div>
          </div>
        </div>

        {/* Category Bar */}
        {displayCategories.length > 0 && (
          <div className="border-t border-[var(--border-silk)] mt-2">
            <div className="w-full lg:max-w-[1600px] lg:mx-auto relative group/nav">
              {/* Left Arrow */}
              {showLeftArrow && (
                <button
                  onClick={() => scroll("left")}
                  className="absolute left-4 top-[43px] -translate-y-1/2 z-10 size-9 rounded-full bg-white/80 backdrop-blur-md border border-[var(--border-silk)] shadow-sm hover:shadow-md hover:shadow-rosegold/10 flex items-center justify-center text-rosegold hover:bg-rosegold hover:text-white hover:border-rosegold transition-all duration-300 active:scale-90 cursor-pointer animate-in fade-in duration-300"
                  aria-label="Scroll left"
                >
                  <ChevronLeft size={18} strokeWidth={2} />
                </button>
              )}

              {/* Right Arrow */}
              {showRightArrow && (
                <button
                  onClick={() => scroll("right")}
                  className="absolute right-4 top-[43px] -translate-y-1/2 z-10 size-9 rounded-full bg-white/80 backdrop-blur-md border border-[var(--border-silk)] shadow-sm hover:shadow-md hover:shadow-rosegold/10 flex items-center justify-center text-rosegold hover:bg-rosegold hover:text-white hover:border-rosegold transition-all duration-300 active:scale-90 cursor-pointer animate-in fade-in duration-300"
                  aria-label="Scroll right"
                >
                  <ChevronRight size={18} strokeWidth={2} />
                </button>
              )}

              <div
                ref={scrollRef}
                className="flex items-center overflow-x-auto gap-4 sm:gap-6 py-3 hide-scrollbar px-6 sm:px-8 lg:px-12 scroll-smooth"
              >
                {/* "For You" Circle */}
                <Link
                  href="/collections"
                  className="flex items-center gap-2 shrink-0 transition-all duration-300 luxury-link flex-col h-20 justify-center"
                >
                  <div className="relative size-12 sm:size-14 rounded-full flex items-center justify-center bg-rosegold text-white shadow-lg shadow-rosegold/30 border-2 border-white transition-all duration-300 group-hover:-translate-y-1 group-hover:shadow-rosegold/50 group-active:scale-95">
                    <span className="text-[8px] uppercase font-bold tracking-widest text-center leading-tight">For<br/>You</span>
                  </div>
                  <span className="text-[9px] font-extrabold uppercase tracking-widest text-rosegold leading-none transition-all">Discovery</span>
                </Link>

                {displayCategories.map((category, index) => (
                  <Link
                    key={category.id || index}
                    href={`/collections?category_id=${category.id}`}
                    className="flex items-center snap-start group shrink-0 transition-all duration-300 luxury-link flex-col gap-2 h-20 justify-center"
                  >
                    <div className="relative size-12 sm:size-14 rounded-full overflow-hidden bg-white border border-[var(--border-silk)] shadow-sm group-hover:border-rosegold transition-all duration-300 group-hover:-translate-y-1 group-hover:shadow-md group-hover:shadow-rosegold/15 group-active:scale-95">
                      {category.image_url && category.image_url.trim() !== "" ? (
                        <Image
                          src={category.image_url}
                          alt={category.name}
                          fill
                          sizes="(max-width: 640px) 48px, 56px"
                          className="w-full h-full object-cover transition-all duration-500 group-hover:scale-110"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center bg-silk text-rosegold/30 text-lg">👗</div>
                      )}
                    </div>
                    <span className="text-[9px] font-extrabold uppercase tracking-[0.1em] text-heading group-hover:text-rosegold transition-all leading-none truncate max-w-[70px]">
                      {category.name.split(' ')[0]}
                    </span>
                  </Link>
                ))}
              </div>
            </div>
          </div>
        )}
      </nav>
    </>
  );
}
