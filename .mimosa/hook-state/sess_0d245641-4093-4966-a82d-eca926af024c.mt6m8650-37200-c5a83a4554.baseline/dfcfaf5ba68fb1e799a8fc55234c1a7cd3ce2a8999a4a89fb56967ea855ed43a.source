"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Home, LayoutGrid, Images, ShoppingBag, Headphones } from "lucide-react";
import { cn } from "@/lib/utils";

const NAV_ITEMS = [
  { href: "/", label: "Home", icon: Home },
  { href: "/collections", label: "Shop", icon: LayoutGrid },
  { href: "/gallery", label: "Gallery", icon: Images },
  { href: "/cart", label: "Cart", icon: ShoppingBag },
  { href: "/contact", label: "Support", icon: Headphones },
] as const;

export default function MobileBottomNav() {
  const pathname = usePathname();
  const [mounted, setMounted] = useState(false);
  const [cartCount, setCartCount] = useState(0);

  useEffect(() => {
    setMounted(true);

    const loadCartCount = () => {
      const cart = JSON.parse(localStorage.getItem("paris_cart") || "[]");
      setCartCount(cart.length);
    };

    loadCartCount();

    const handleCartUpdate = (e: any) => setCartCount(e.detail);
    window.addEventListener("paris_cart_updated", handleCartUpdate);

    return () => {
      window.removeEventListener("paris_cart_updated", handleCartUpdate);
    };
  }, []);

  if (!mounted) return null;

  const isProductPage = pathname.startsWith("/product/");

  return (
    <nav
      className={cn(
        "lg:hidden fixed bottom-0 inset-x-0 z-50 bg-white border-t border-[#EAEAEA] transition-transform duration-300",
        isProductPage && "translate-y-full"
      )}
    >
      <div className="flex items-stretch h-14 max-w-md mx-auto">
        {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
          const active = pathname === href || (href !== "/" && pathname.startsWith(href));

          return (
            <Link
              key={href}
              href={href}
              className="flex flex-col items-center justify-center gap-0.5 flex-1 relative"
            >
              <div className="relative">
                <Icon
                  size={20}
                  strokeWidth={active ? 2.2 : 1.6}
                  className={cn(
                    "transition-colors",
                    active ? "text-rosegold" : "text-body/60"
                  )}
                />
                {label === "Cart" && cartCount > 0 && (
                  <span className="absolute -top-1.5 -right-1.5 bg-rosegold text-white text-[9px] font-bold min-w-[15px] h-[15px] flex items-center justify-center rounded-full px-1">
                    {cartCount}
                  </span>
                )}
              </div>
              <span className={cn(
                "text-[9px] font-medium transition-colors",
                active ? "text-rosegold" : "text-body/50"
              )}>
                {label}
              </span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
