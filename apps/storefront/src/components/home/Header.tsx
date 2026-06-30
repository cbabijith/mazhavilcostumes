"use client";

import { useState, useEffect, useRef } from "react";
import Link from "next/link";
import Image from "next/image";
import { ShoppingBag, Heart, ChevronLeft, ChevronRight, Search } from "lucide-react";
import { Store, Category } from "@/lib/supabase/queries";
import { cn } from "@/lib/utils";
import { useRouter, usePathname } from "next/navigation";
import ActionSearchBar from "@/components/ui/action-search-bar";

interface HeaderProps {
  store: Store | null;
  categories?: Category[];
}

export default function Header({ store, categories }: HeaderProps) {
  const [isScrolled, setIsScrolled] = useState(false);
  const [cartCount, setCartCount] = useState(0);
  const [wishlistCount, setWishlistCount] = useState(0);
  const [showCategoryBar, setShowCategoryBar] = useState(true);
  const router = useRouter();
  const pathname = usePathname();
  const isHomePage = pathname === "/";

  const lastScrollY = useRef(0);
  const toggleLock = useRef(false);
  const showCategoryBarRef = useRef(true);

  const scrollRef = useRef<HTMLDivElement>(null);
  const [showLeftArrow, setShowLeftArrow] = useState(false);
  const [showRightArrow, setShowRightArrow] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      const currentScrollY = window.scrollY;
      const scrolled = currentScrollY > 40;
      if (scrolled !== isScrolled) setIsScrolled(scrolled);

      // Hide category bar on scroll down, show on scroll up (homepage only)
      if (isHomePage) {
        if (toggleLock.current) return;

        const scrollDelta = currentScrollY - lastScrollY.current;
        if (Math.abs(scrollDelta) > 15) {
          const shouldShow = scrollDelta < 0 || currentScrollY < 120;
          const shouldHide = scrollDelta > 0 && currentScrollY > 120;

          if (shouldShow && !showCategoryBarRef.current) {
            setShowCategoryBar(true);
            showCategoryBarRef.current = true;
            toggleLock.current = true;
            setTimeout(() => {
              toggleLock.current = false;
              lastScrollY.current = window.scrollY;
            }, 400);
          } else if (shouldHide && showCategoryBarRef.current) {
            setShowCategoryBar(false);
            showCategoryBarRef.current = false;
            toggleLock.current = true;
            setTimeout(() => {
              toggleLock.current = false;
              lastScrollY.current = window.scrollY;
            }, 400);
          }

          if (!toggleLock.current) {
            lastScrollY.current = currentScrollY;
          }
        }
      } else {
        lastScrollY.current = currentScrollY;
      }
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
  }, [isHomePage]);

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
          "sticky top-0 z-50 transition-all duration-300 border-b py-4",
          isScrolled ? "border-[var(--border-silk)] bg-silk" : "border-transparent bg-transparent"
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
              <div className="flex flex-col text-left justify-center">
                <span className="text-[10px] min-[380px]:text-xs sm:text-base md:text-lg lg:text-xl font-bold tracking-[0.05em] uppercase text-rosegold transition-colors leading-tight whitespace-nowrap">
                  Mazhavil Dance Costumes
                </span>
                <span 
                  className="text-[6px] min-[380px]:text-[8px] sm:text-[10px] md:text-[11px] tracking-[0.05em] min-[380px]:tracking-[0.1em] sm:tracking-[0.15em] text-rosegold-dark uppercase leading-none mt-1.5 font-bold block whitespace-nowrap"
                >
                  Karamana | Trivandrum
                </span>
              </div>
            </Link>

            {/* Desktop Nav — minimal clean links */}
            <div className="hidden lg:flex items-center gap-10">
              {navLinks.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  className="text-sm font-medium text-heading hover:text-rosegold transition-colors duration-300"
                >
                  {link.label}
                </Link>
              ))}
            </div>

            {/* Actions & Search */}
            <div className="flex items-center flex-1 justify-end gap-2 sm:gap-4 shrink-0">
              {/* Search Icon alone for Mobile View */}
              <Link
                href="/search"
                className="flex sm:hidden p-2.5 text-body hover:text-rosegold transition-all hover:bg-rosegold/5 rounded-full relative cursor-pointer"
                aria-label="Search"
              >
                <Search size={20} strokeWidth={1.5} />
              </Link>

              {/* Full Search Bar for Desktop View */}
              <div className="hidden sm:block flex-1 max-w-[300px] lg:max-w-[320px]">
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

        {/* Category Bar — homepage only, hides on scroll down */}
        {isHomePage && displayCategories.length > 0 && showCategoryBar && (
          <div 
            className="border-t border-[var(--border-silk)] mt-2"
          >
            <div className="w-full lg:max-w-[1600px] lg:mx-auto relative group/nav">
              {/* Left Arrow & Gradient Overlay */}
              {showLeftArrow && (
                <>
                  <div className="hidden sm:block absolute left-0 top-0 bottom-0 w-16 sm:w-20 bg-gradient-to-r from-silk via-silk/90 to-transparent pointer-events-none z-10" />
                  <button
                    onClick={() => scroll("left")}
                    className="hidden sm:flex absolute left-4 top-[40px] -translate-y-1/2 z-20 size-8 sm:size-9 rounded-full bg-silk/95 border border-[var(--border-silk)] hover:border-rosegold flex items-center justify-center text-rosegold hover:bg-rosegold hover:text-white hover:border-rosegold transition-all duration-300 active:scale-95 cursor-pointer animate-in fade-in duration-300"
                    aria-label="Scroll left"
                  >
                    <ChevronLeft size={16} strokeWidth={2.5} />
                  </button>
                </>
              )}

              {/* Right Arrow & Gradient Overlay */}
              {showRightArrow && (
                <>
                  <div className="hidden sm:block absolute right-0 top-0 bottom-0 w-16 sm:w-20 bg-gradient-to-l from-silk via-silk/90 to-transparent pointer-events-none z-10" />
                  <button
                    onClick={() => scroll("right")}
                    className="hidden sm:flex absolute right-4 top-[40px] -translate-y-1/2 z-20 size-8 sm:size-9 rounded-full bg-silk/95 border border-[var(--border-silk)] hover:border-rosegold flex items-center justify-center text-rosegold hover:bg-rosegold hover:text-white hover:border-rosegold transition-all duration-300 active:scale-95 cursor-pointer animate-in fade-in duration-300"
                    aria-label="Scroll right"
                  >
                    <ChevronRight size={16} strokeWidth={2.5} />
                  </button>
                </>
              )}

              <div
                ref={scrollRef}
                className="flex items-center overflow-x-auto gap-4 sm:gap-6 py-3 hide-scrollbar px-6 sm:px-8 lg:px-12 scroll-smooth"
              >
                {/* "Home" Circle */}
                <Link
                  href="/"
                  className="flex items-center gap-2 shrink-0 transition-all duration-300 luxury-link flex-col h-20 justify-center"
                >
                  <div className="relative size-12 sm:size-14 rounded-full flex items-center justify-center bg-rosegold text-white border-2 border-white transition-all duration-300 group-hover:-translate-y-0.5 group-active:scale-95">
                    <span className="text-[8px] uppercase font-bold tracking-widest text-center leading-tight font-sans">Home</span>
                  </div>
                </Link>

                {displayCategories.map((category, index) => (
                  <Link
                    key={category.id || index}
                    href={`/collections?category_id=${category.id}`}
                    className="flex items-center snap-start group shrink-0 transition-all duration-300 luxury-link flex-col gap-2 h-20 justify-center"
                  >
                    <div className="relative size-12 sm:size-14 rounded-full overflow-hidden bg-white border border-[var(--border-silk)] group-hover:border-rosegold transition-all duration-300 group-hover:-translate-y-0.5 group-active:scale-95">
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
