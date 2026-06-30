"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { Instagram, Facebook, Twitter, Phone } from "lucide-react";
import { Store, Category } from "@/lib/supabase/queries";

interface FooterProps {
  store: Store | null;
  categories?: Category[];
}

export default function Footer({ store, categories: initialCategories }: FooterProps) {
  const [categories, setCategories] = useState<Category[]>(initialCategories || []);

  useEffect(() => {
    if (initialCategories) {
      setCategories(initialCategories);
      return;
    }
    if (!store?.id) return;
    const storeId = store.id;

    async function loadCategories() {
      const { createClient } = await import("@/lib/supabase/client");
      const supabase = createClient();
      const { data } = await supabase
        .from("categories")
        .select("*")
        .eq("store_id", storeId)
        .eq("is_active", true)
        .is("parent_id", null)
        .is("deleted_at", null)
        .order("sort_order", { ascending: true })
        .order("name", { ascending: true });
      if (data) {
        setCategories(data);
      }
    }
    loadCategories();
  }, [store?.id, initialCategories]);

  const storeName = store?.name || "Mazhavil Dance Costumes";
  const storeEmail = "mazhavildancecostumes@gmail.com";

  return (
    <footer className="bg-[#1a1a1a] text-white pb-28 lg:pb-0">
      <div className="max-w-[1400px] mx-auto px-6 sm:px-8 lg:px-12 pt-12 sm:pt-16 md:pt-20">
        {/* Top section */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 sm:gap-10 lg:gap-12 pb-10 sm:pb-12">
          {/* Brand */}
          <div className="lg:col-span-1">
            <Link href="/" className="block mb-4">
              <span className="text-lg sm:text-xl font-bold tracking-wide uppercase text-rosegold block">
                Mazhavil Dance Costumes
              </span>
              <span className="text-[10px] sm:text-[11px] tracking-[0.3em] text-white/40 uppercase block mt-1.5">
                Karamana | Trivandrum
              </span>
            </Link>
            <p className="text-sm text-white/50 leading-relaxed mb-6 max-w-xs">
              Premium classical and traditional dance costumes for rent. Crafted with heritage, designed for the stage.
            </p>
            <div className="flex gap-3">
              {[Instagram, Facebook, Twitter].map((Icon, idx) => (
                <a
                  key={idx}
                  href="#"
                  className="w-9 h-9 rounded-full bg-white/5 flex items-center justify-center text-white/60 hover:bg-rosegold hover:text-white hover:border-rosegold transition-all duration-300"
                >
                  <Icon size={16} strokeWidth={1.5} />
                </a>
              ))}
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="text-xs uppercase tracking-[0.2em] font-semibold text-white/80 mb-5">Quick Links</h4>
            <ul className="space-y-3">
              {[
                { label: "About Us", href: "/about" },
                { label: "Gallery", href: "/gallery" },
                { label: "Costume Care", href: "/care" },
                { label: "FAQs", href: "/faqs" },
              ].map((link) => (
                <li key={link.label}>
                  <Link href={link.href} className="text-sm text-white/50 hover:text-rosegold transition-colors duration-300">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Policies */}
          <div>
            <h4 className="text-xs uppercase tracking-[0.2em] font-semibold text-white/80 mb-5">Policies</h4>
            <ul className="space-y-3">
              <li>
                <Link href="/legal/terms" className="text-sm text-white/50 hover:text-rosegold transition-colors duration-300">
                  Terms of Service
                </Link>
              </li>
              <li>
                <Link href="/legal/privacy" className="text-sm text-white/50 hover:text-rosegold transition-colors duration-300">
                  Privacy Policy
                </Link>
              </li>
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h4 className="text-xs uppercase tracking-[0.2em] font-semibold text-white/80 mb-5">Get in Touch</h4>
            <ul className="space-y-4">
              <li>
                <a href={`mailto:${storeEmail}`} className="text-sm text-white/50 hover:text-rosegold transition-colors duration-300 block">
                  {storeEmail}
                </a>
              </li>
              <li>
                <a
                  href="https://www.google.com/maps/search/?api=1&query=8.481222,76.965056"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm text-white/50 hover:text-rosegold transition-colors duration-300 leading-relaxed block max-w-[240px]"
                >
                  Karamana Main Road, near QRS, Prem Nagar, Karamana, Thiruvananthapuram, Kerala 695002
                </a>
              </li>
              <li>
                <div className="flex flex-col gap-2.5">
                  <a href="tel:9446961765" className="text-sm text-white/50 hover:text-rosegold transition-colors duration-300 flex items-center gap-2">
                    <Phone size={13} strokeWidth={1.8} className="text-rosegold" />
                    +91 94469 61765
                  </a>
                  <a href="tel:9447961765" className="text-sm text-white/50 hover:text-rosegold transition-colors duration-300 flex items-center gap-2">
                    <Phone size={13} strokeWidth={1.8} className="text-rosegold" />
                    +91 94479 61765
                  </a>
                </div>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="border-t border-white/10 py-6 sm:py-8 flex flex-col sm:flex-row items-center justify-between gap-3">
          <p className="text-xs text-white/40 text-center sm:text-left">
            © 2026 {storeName}. All rights reserved.
          </p>
          <p className="text-xs text-white/40">
            Handcrafted with Love in Kerala
          </p>
        </div>
      </div>
    </footer>
  );
}
