import Link from 'next/link';
import { Product } from '@/lib/supabase/queries';
import ProductCard from '@/components/product/ProductCard';

interface NewArrivalsProps {
  products: Product[];
}

export default function NewArrivals({ products }: NewArrivalsProps) {
  if (!products || products.length === 0) return null;

  return (
    <section className="py-6 sm:py-8 md:py-12 px-4 sm:px-6 md:px-12 bg-white">
      <div className="max-w-[1600px] mx-auto">
        <div className="flex items-center justify-between mb-4 sm:mb-6 md:mb-8">
          <h2 className="text-xl sm:text-2xl md:text-3xl font-bold text-heading animate-fadeInUp">
            New Arrivals
          </h2>
          <Link 
            href="/collections?sort=new" 
            className="text-sm font-medium text-rosegold hover:text-rosegold-dark transition-all flex items-center gap-2 group animate-fadeInUp"
          >
            Explore All <span className="group-hover:translate-x-1.5 transition-transform">→</span>
          </Link>
        </div>
        
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-4 md:gap-5 stagger-children">
          {products.slice(0, 8).map((product) => (
            <ProductCard
              key={product.id}
              product={product}
              badge={{ text: 'New' }}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
