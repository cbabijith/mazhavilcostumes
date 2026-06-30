import { Suspense } from 'react';
import Header from "@/components/home/Header";
import HeroCarousel from "@/components/home/HeroCarousel";
import NewArrivals from "@/components/home/NewArrivals";
import HowItWorks from "@/components/home/HowItWorks";
import CustomerReviews from "@/components/home/CustomerReviews";
import FinalCTA from "@/components/home/FinalCTA";
import Footer from "@/components/home/Footer";
import TrustBadges from "@/components/home/TrustBadges";
import { getParisBridalsStore } from "@/lib/actions/store";
import { getCachedCategories, getCachedNewArrivals } from "@/lib/supabase/cached-queries";
import { getHeroBanners } from "@/lib/supabase/queries";

async function getStoreData() {
  const store = await getParisBridalsStore();
  return store;
}

export default async function Home() {
  const store = await getStoreData();

  if (!store) {
    return (
      <div className="max-w-[1600px] mx-auto px-6 sm:px-8 lg:px-12 flex items-center justify-center bg-silk min-h-screen">
        <div className="text-center animate-fadeInUp">
          <h1 className="text-4xl font-serif text-heading mb-4">Mazhavil Dance Costumes</h1>
          <p className="text-body font-light">Elegance is taking a moment. Please check back soon.</p>
        </div>
      </div>
    );
  }

  const storeId = store.id;

  // Fetch data in parallel — each banner type has its own optimized query
  const [heroBanners, categories, newArrivals] = await Promise.all([
    getHeroBanners(storeId),
    getCachedCategories(storeId),
    getCachedNewArrivals(storeId, 20),
  ]);

  return (
    <main className="min-h-screen selection:bg-rosegold/20 selection:text-rosegold-dark">
      {/* 1. Header with Categories */}
      <Header store={store} categories={categories} />

      {/* 2. Hero Carousel — only if hero banners exist */}
      {heroBanners.length > 0 && <HeroCarousel banners={heroBanners} />}

      {/* 4. Trust Badges */}
      <TrustBadges />
      
      {/* 5. Latest Treasures (New Arrivals) */}
      <Suspense fallback={<div className="h-[600px] animate-pulse bg-silk-dark/30" />}>
        <NewArrivals products={newArrivals} />
      </Suspense>

      {/* 7. The Experience (How It Works) */}
      <HowItWorks />

      {/* 9. Bridal Stories (Reviews) */}
      <CustomerReviews />
      
      {/* 10. Final Invitation (CTA) */}
      <FinalCTA />
      
      {/* 11. Footer */}
      <Footer store={store} />
    </main>
  );
}
