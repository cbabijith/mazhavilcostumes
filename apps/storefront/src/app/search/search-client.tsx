"use client";

import { useState, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import { Search, X, ChevronLeft } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

interface ProductSuggestion {
  id: string;
  name: string;
  sku?: string | null;
  barcode?: string | null;
  category_name?: string;
}

interface SearchClientProps {
  storeId?: string;
  categories?: any[];
  featured?: any[];
}

export default function SearchClient({ storeId, categories, featured }: SearchClientProps) {
  const [query, setQuery] = useState("");
  const [history, setHistory] = useState<string[]>([]);
  const [suggestions, setSuggestions] = useState<ProductSuggestion[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();
  const supabase = createClient();
  const inputRef = useRef<HTMLInputElement>(null);

  // Load history from localStorage on mount
  useEffect(() => {
    const saved = localStorage.getItem("recent_searches");
    if (saved) {
      try {
        setHistory(JSON.parse(saved));
      } catch (e) {
        setHistory([]);
      }
    }
    // Autofocus on mount
    setTimeout(() => inputRef.current?.focus(), 100);
  }, []);

  // Fetch product suggestions with debounce
  useEffect(() => {
    if (!query.trim()) {
      setSuggestions([]);
      return;
    }

    const timer = setTimeout(async () => {
      setIsLoading(true);
      try {
        let queryBuilder = supabase
          .from("products")
          .select("id, name, sku, barcode, category:category_id(name)")
          .eq("is_active", true)
          .ilike("name", `%${query}%`)
          .order("name", { ascending: true })
          .range(0, 14); // Fetch first 15 suggestions
        
        if (storeId) {
          queryBuilder = queryBuilder.eq("store_id", storeId);
        }

        const { data, error } = await queryBuilder;

        if (!error && data) {
          setSuggestions(data.map((p: any) => ({
            id: p.id,
            name: p.name,
            sku: p.sku,
            barcode: p.barcode,
            category_name: p.category?.name
          })));
        }
      } catch (err) {
        console.error("Search suggestion error:", err);
      } finally {
        setIsLoading(false);
      }
    }, 300);

    return () => clearTimeout(timer);
  }, [query, storeId, supabase]);

  const saveToHistory = (searchQuery: string) => {
    const trimmed = searchQuery.trim();
    if (!trimmed) return;
    
    // Add to beginning, remove duplicates, limit to 8 items
    const updated = [trimmed, ...history.filter(item => item.toLowerCase() !== trimmed.toLowerCase())].slice(0, 8);
    setHistory(updated);
    localStorage.setItem("recent_searches", JSON.stringify(updated));
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    if (query.trim()) {
      saveToHistory(query);
      router.push(`/collections?q=${encodeURIComponent(query.trim())}`);
    }
  };

  const handleHistoryClick = (item: string) => {
    setQuery(item);
    saveToHistory(item);
    router.push(`/collections?q=${encodeURIComponent(item)}`);
  };

  const removeHistoryItem = (itemToRemove: string, e: React.MouseEvent) => {
    e.stopPropagation(); // Prevent triggering search
    const updated = history.filter(item => item !== itemToRemove);
    setHistory(updated);
    localStorage.setItem("recent_searches", JSON.stringify(updated));
  };

  const clearHistory = () => {
    setHistory([]);
    localStorage.removeItem("recent_searches");
  };

  return (
    <div className="min-h-screen flex flex-col bg-silk animate-in fade-in duration-500">
      {/* Sticky Header replacing standard header on mobile search page */}
      <header className="sticky top-0 z-50 bg-white border-b border-[var(--border-silk)] py-3 px-4 flex items-center gap-3 shadow-sm h-16">
        {/* Back Button */}
        <button
          onClick={() => router.back()}
          className="p-1 rounded-full text-body hover:text-rosegold active:scale-95 transition-all cursor-pointer flex items-center justify-center"
          aria-label="Go back"
        >
          <ChevronLeft size={24} strokeWidth={2} />
        </button>

        {/* Search Input Form */}
        <form onSubmit={handleSearch} className="flex-1 relative">
          <input
            ref={inputRef}
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search our treasures..."
            className="w-full h-10 pl-10 pr-10 bg-silk/45 border border-[var(--border-silk)] rounded-full text-sm focus:outline-none focus:border-rosegold focus:ring-4 focus:ring-rosegold/5 transition-all placeholder:text-muted-foreground/50 shadow-inner"
          />
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-muted-foreground size-4" />
          {query && (
            <button
              type="button"
              onClick={() => setQuery("")}
              className="absolute right-3.5 top-1/2 -translate-y-1/2 p-0.5 text-muted-foreground hover:text-rosegold transition-colors cursor-pointer flex items-center justify-center"
            >
              <X size={16} />
            </button>
          )}
        </form>
      </header>

      {/* Content Area */}
      <main className="flex-1 p-5 space-y-6">
        {query.trim() ? (
          /* Live Suggestions */
          <section className="bg-white rounded-[2.5rem] p-6 border border-[var(--border-silk)] shadow-sm animate-in fade-in duration-300">
            <div className="flex items-center justify-between mb-4 border-b border-[var(--border-silk)] pb-3">
              <h3 className="text-xs uppercase tracking-[0.2em] font-bold text-heading">Suggested Products</h3>
              {isLoading && (
                <span className="text-[10px] text-caption animate-pulse">Searching...</span>
              )}
            </div>

            {suggestions.length > 0 ? (
              <div className="divide-y divide-[var(--border-silk)]">
                {suggestions.map((product) => (
                  <button
                    key={product.id}
                    onClick={() => {
                      saveToHistory(product.name);
                      router.push(`/product/${product.id}`);
                    }}
                    className="w-full flex items-center justify-between py-3 hover:text-rosegold transition-colors text-left group cursor-pointer"
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <Search size={14} className="text-muted-foreground group-hover:text-rosegold transition-colors shrink-0" />
                      <span className="text-sm font-medium text-body group-hover:text-rosegold transition-colors truncate">
                        {product.sku && !product.name.toLowerCase().includes(product.sku.toLowerCase()) ? (
                          <span className="inline-flex items-center gap-1.5">
                            <span className="font-semibold text-rosegold">{product.sku}</span>
                            <span className="text-muted-foreground font-normal">-</span>
                            <span className="text-muted-foreground font-normal">{product.name}</span>
                          </span>
                        ) : product.barcode && !product.name.toLowerCase().includes(product.barcode.toLowerCase()) ? (
                          <span className="inline-flex items-center gap-1.5">
                            <span className="font-semibold text-rosegold">{product.barcode}</span>
                            <span className="text-muted-foreground font-normal">-</span>
                            <span className="text-muted-foreground font-normal">{product.name}</span>
                          </span>
                        ) : (
                          product.name
                        )}
                      </span>
                    </div>
                  </button>
                ))}
              </div>
            ) : (
              !isLoading && (
                <div className="py-8 text-center text-sm text-caption italic">
                  No products found for "{query}"
                </div>
              )
            )}
          </section>
        ) : (
          /* Recent Searches */
          <section className="bg-white rounded-[2.5rem] p-6 border border-[var(--border-silk)] shadow-sm animate-in fade-in duration-300">
            <div className="flex items-center justify-between mb-4 border-b border-[var(--border-silk)] pb-3">
              <h3 className="text-xs uppercase tracking-[0.2em] font-bold text-heading">Recent Searches</h3>
              {history.length > 0 && (
                <button
                  onClick={clearHistory}
                  className="text-[10px] uppercase tracking-wider font-bold text-rosegold hover:opacity-80 transition-opacity cursor-pointer"
                >
                  Clear All
                </button>
              )}
            </div>

            {history.length > 0 ? (
              <div className="divide-y divide-[var(--border-silk)]">
                {history.map((item, index) => (
                  <div
                    key={`${item}-${index}`}
                    onClick={() => handleHistoryClick(item)}
                    className="flex items-center justify-between py-3 hover:text-rosegold transition-colors cursor-pointer group"
                  >
                    <div className="flex items-center gap-3">
                      <Search size={14} className="text-muted-foreground group-hover:text-rosegold transition-colors" />
                      <span className="text-sm font-medium text-body group-hover:text-rosegold transition-colors">
                        {item}
                      </span>
                    </div>
                    <button
                      onClick={(e) => removeHistoryItem(item, e)}
                      className="p-1 text-muted-foreground/40 hover:text-rosegold transition-colors cursor-pointer flex items-center justify-center"
                      aria-label={`Remove search term ${item}`}
                    >
                      <X size={14} />
                    </button>
                  </div>
                ))}
              </div>
            ) : (
              <div className="py-8 text-center text-sm text-caption italic">
                No recent searches
              </div>
            )}
          </section>
        )}
      </main>
    </div>
  );
}
