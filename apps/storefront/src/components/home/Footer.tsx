"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { Instagram, Facebook, Twitter, Mail, Phone, MapPin } from "lucide-react";
import { Store, Category } from "@/lib/supabase/queries";
import { Separator } from "@/components/ui/separator";
import { DISPLAY_PHONE } from "@/lib/whatsapp";

const WhatsAppIcon = ({ className, size = 14 }: { className?: string; size?: number }) => (
  <svg
    viewBox="0 0 24 24"
    width={size}
    height={size}
    className={className}
    fill="currentColor"
  >
    <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L0 24l6.335-1.662c1.746.953 3.71 1.458 5.704 1.459h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" />
  </svg>
);

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
  const storePhone = DISPLAY_PHONE;

  return (
    <footer className="bg-white border-t border-border-silk pt-8 sm:pt-12 md:pt-16 pb-28 lg:pb-8">
      <div className="max-w-[1600px] mx-auto px-6 sm:px-8 lg:px-12">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 sm:gap-12 mb-8 sm:mb-10">
          <div className="lg:col-span-1">
            <Link href="/" className="block mb-4 sm:mb-6 group">
              <div className="flex flex-col text-left justify-center">
                <span className="text-sm sm:text-base md:text-lg font-serif font-bold tracking-[0.05em] uppercase text-rosegold transition-colors leading-tight">
                  Mazhavil Dance Costumes
                </span>
                <span 
                  className="w-full text-left text-[10px] sm:text-[11px] md:text-[12px] tracking-[0.4em] text-body uppercase opacity-80 leading-none mt-2 font-medium font-sans block italic"
                  style={{ marginRight: "-0.4em" }}
                >
                  Karamana | Trivandrum
                </span>
              </div>
            </Link>
            <p className="text-sm text-body font-light leading-relaxed mb-4 sm:mb-6 max-w-xs">
              Premium classical and traditional dance costumes for rent. Crafted with heritage, designed for the stage.
            </p>
            <div className="flex gap-3 sm:gap-4 md:gap-5">
              {[Instagram, Facebook, Twitter].map((Icon, idx) => (
                <a 
                  key={idx} 
                  href="#" 
                  className="w-8 h-8 sm:w-9 sm:h-9 md:w-10 md:h-10 rounded-full border border-border-silk flex items-center justify-center text-heading hover:bg-rosegold hover:text-white hover:border-rosegold transition-all duration-500 shadow-sm"
                >
                  <Icon size={14} strokeWidth={1.5} />
                </a>
              ))}
            </div>
          </div>

          <div>
            <h4 className="text-xs sm:text-sm uppercase tracking-[0.2em] font-bold text-rosegold mb-4 sm:mb-6">Policies</h4>
            <ul className="space-y-2 sm:space-y-3">
              <li>
                <Link href="/legal/terms" className="text-sm text-body font-light hover:text-rosegold transition-colors">
                  Terms of Service
                </Link>
              </li>
              <li>
                <Link href="/legal/privacy" className="text-sm text-body font-light hover:text-rosegold transition-colors">
                  Privacy Policy
                </Link>
              </li>
            </ul>
          </div>

          <div>
            <h4 className="text-xs sm:text-sm uppercase tracking-[0.2em] font-bold text-rosegold mb-4 sm:mb-6">Concierge</h4>
            <ul className="space-y-2 sm:space-y-3">
              {[
                { label: "About Us", href: "/about" },
                { label: "Gallery", href: "/gallery" },
                { label: "Costume Care", href: "/care" },
                { label: "FAQs", href: "/faqs" },
              ].map((link) => (
                <li key={link.label}>
                  <Link href={link.href} className="text-sm text-body font-light hover:text-rosegold transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-xs sm:text-sm uppercase tracking-[0.2em] font-bold text-rosegold mb-4 sm:mb-6">Get in Touch</h4>
            <ul className="space-y-3 sm:space-y-4">
              <li className="flex gap-3 sm:gap-4 items-start group">
                <div className="w-8 h-8 rounded-full bg-rosegold/5 flex items-center justify-center group-hover:bg-rosegold transition-colors duration-500 shrink-0">
                  <Mail size={14} className="text-rosegold group-hover:text-white transition-colors" />
                </div>
                <div>
                  <p className="text-[9px] uppercase tracking-widest text-caption mb-1">Email</p>
                  <a href={`mailto:${storeEmail}`} className="text-sm text-heading font-medium hover:text-rosegold transition-colors">
                    {storeEmail}
                  </a>
                </div>
              </li>
              <li className="flex gap-3 sm:gap-4 items-start group">
                <div className="w-8 h-8 rounded-full bg-rosegold/5 flex items-center justify-center group-hover:bg-rosegold transition-colors duration-500 shrink-0">
                  <MapPin size={14} className="text-rosegold group-hover:text-white transition-colors" />
                </div>
                <div>
                  <p className="text-[9px] uppercase tracking-widest text-caption mb-1">Address</p>
                  <a 
                    href="https://maps.google.com/?q=Mazhavil+Dance+Costumes+Karamana+Thiruvananthapuram+Kerala+695002"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-sm text-heading font-medium hover:text-rosegold transition-colors leading-relaxed block max-w-[240px]"
                  >
                    Karamana Main Road, near QRS, Prem Nagar, Karamana, Thiruvananthapuram, Kerala 695002
                  </a>
                </div>
              </li>
              <li className="flex gap-3 sm:gap-4 items-start">
                <div className="flex flex-col gap-4 w-full">
                  {/* Number 1 Row */}
                  <div className="flex items-center gap-3">
                    <div className="flex gap-1.5 shrink-0">
                      <a 
                        href="tel:9446961765" 
                        title="Call +91 94469 61765"
                        className="w-8 h-8 rounded-full bg-rosegold/5 flex items-center justify-center text-rosegold hover:bg-rosegold hover:text-white transition-all duration-300 border border-border-silk"
                      >
                        <Phone size={13} strokeWidth={1.8} />
                      </a>
                      <a 
                        href="https://wa.me/919446961765" 
                        target="_blank" 
                        rel="noopener noreferrer" 
                        title="WhatsApp +91 94469 61765"
                        className="w-8 h-8 rounded-full bg-emerald-500/5 flex items-center justify-center text-emerald-600 hover:bg-emerald-500 hover:text-white transition-all duration-300 border border-emerald-500/10"
                      >
                        <WhatsAppIcon size={13} />
                      </a>
                    </div>
                    <div>
                      <p className="text-[9px] uppercase tracking-widest text-caption leading-none mb-1">Mob / Whatsapp</p>
                      <span className="text-sm text-heading font-medium leading-none block">
                        +91 94469 61765
                      </span>
                    </div>
                  </div>

                  {/* Number 2 Row */}
                  <div className="flex items-center gap-3">
                    <div className="flex gap-1.5 shrink-0">
                      <a 
                        href="tel:9447961765" 
                        title="Call +91 94479 61765"
                        className="w-8 h-8 rounded-full bg-rosegold/5 flex items-center justify-center text-rosegold hover:bg-rosegold hover:text-white transition-all duration-300 border border-border-silk"
                      >
                        <Phone size={13} strokeWidth={1.8} />
                      </a>
                      <a 
                        href="https://wa.me/919447961765" 
                        target="_blank" 
                        rel="noopener noreferrer" 
                        title="WhatsApp +91 94479 61765"
                        className="w-8 h-8 rounded-full bg-emerald-500/5 flex items-center justify-center text-emerald-600 hover:bg-emerald-500 hover:text-white transition-all duration-300 border border-emerald-500/10"
                      >
                        <WhatsAppIcon size={13} />
                      </a>
                    </div>
                    <div>
                      <p className="text-[9px] uppercase tracking-widest text-caption leading-none mb-1">Mob / Whatsapp</p>
                      <span className="text-sm text-heading font-medium leading-none block">
                        +91 94479 61765
                      </span>
                    </div>
                  </div>
                </div>
              </li>
            </ul>
          </div>
        </div>

        <Separator className="bg-border-silk mb-8 sm:mb-12" />

        <div className="flex justify-center items-center">
          <p className="text-[9px] uppercase tracking-[0.3em] text-caption text-center">
            © 2026 {storeName}. Handcrafted with Love.
          </p>
        </div>
      </div>
    </footer>
  );
}
