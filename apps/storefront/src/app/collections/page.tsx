import { Suspense } from "react";
import Header from "@/components/home/Header";
import Footer from "@/components/home/Footer";
import { getParisBridalsStore } from "@/lib/actions/store";
import { getCachedCategories, getCachedProducts } from "@/lib/supabase/cached-queries";
import CollectionsClient from "./CollectionsClient";

interface CollectionsPageProps {
  searchParams: Promise<{ 
    category_id?: string; 
    q?: string;
    sort?: string;
    featured?: string;
    page?: string;
  }>;
}

export default async function CollectionsPage({ searchParams }: CollectionsPageProps) {
  const store = await getParisBridalsStore();
  if (!store) return null;

  const params = await searchParams;
  const categoryId = params.category_id;
  const searchQuery = params.q;
  const isFeatured = params.featured === "true";
  const currentPage = Math.max(1, parseInt(params.page || "1", 10));
  const limit = 24;
  const offset = (currentPage - 1) * limit;

  // Fetch data in parallel
  const [categories, productsData] = await Promise.all([
    getCachedCategories(store.id),
    getCachedProducts(store.id, {
      categoryId,
      search: searchQuery,
      featured: isFeatured,
      limit,
      offset,
    }),
  ]);

  const { products, total } = productsData;

  return (
    <main className="min-h-screen bg-silk selection:bg-rosegold/20 pb-20 lg:pb-0">
      <Header store={store} categories={categories} />
      
      <Suspense fallback={<div className="container mx-auto py-24 text-center">Loading collections...</div>}>
        <CollectionsClient 
          initialProducts={products}
          categories={categories}
          initialCategoryId={categoryId}
          initialSearchQuery={searchQuery}
          total={total}
          currentPage={currentPage}
          itemsPerPage={limit}
        />
      </Suspense>

      <Footer store={store} />
    </main>
  );
}

