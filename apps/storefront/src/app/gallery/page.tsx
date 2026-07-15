import { Suspense } from "react";
import Header from "@/components/home/Header";
import Footer from "@/components/home/Footer";
import { getParisBridalsStore } from "@/lib/actions/store";
import { getCachedCategories, getCachedGalleryItems } from "@/lib/supabase/cached-queries";
import GalleryClient from "./GalleryClient";

export default async function GalleryPage() {
  const store = await getParisBridalsStore();
  if (!store) return null;

  // Fetch data in parallel
  const [categories, galleryItems] = await Promise.all([
    getCachedCategories(store.id),
    getCachedGalleryItems(),
  ]);

  return (
    <main className="min-h-screen bg-white selection:bg-rosegold/20 pb-20 lg:pb-0">
      <Header store={store} categories={categories} />
      
      <Suspense fallback={<div className="container mx-auto py-24 text-center">Loading gallery...</div>}>
        <GalleryClient initialItems={galleryItems} />
      </Suspense>

      <Footer store={store} />
    </main>
  );
}
