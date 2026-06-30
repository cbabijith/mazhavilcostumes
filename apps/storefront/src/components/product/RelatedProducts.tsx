import { Product } from "@/lib/supabase/queries";
import ProductCard from "@/components/product/ProductCard";

interface RelatedProductsProps {
  products: Product[];
  heading?: string;
  eyebrow?: string;
}

export default function RelatedProducts({
  products,
  heading = "You May Also Love",
  eyebrow = "More from the collection",
}: RelatedProductsProps) {
  if (!products || products.length === 0) return null;

  return (
    <section className="py-10 sm:py-12 md:py-14 border-t border-[#EAEAEA]">
      <div className="max-w-[1100px] mx-auto px-4 sm:px-6 md:px-12">
        <div className="mb-6 sm:mb-8">
          <span className="text-[10px] uppercase tracking-[0.2em] font-bold text-rosegold block mb-1">
            {eyebrow}
          </span>
          <h2 className="text-xl sm:text-2xl md:text-3xl font-bold text-heading">
            {heading}
          </h2>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-4 md:gap-5">
          {products.slice(0, 4).map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      </div>
    </section>
  );
}
