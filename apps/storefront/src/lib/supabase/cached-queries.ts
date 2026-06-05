import { unstable_cache } from 'next/cache';
import * as rawQueries from './queries';

/**
 * Get cached categories for a store
 */
export const getCachedCategories = (storeId: string) => {
  const cachedFn = unstable_cache(
    async (id: string) => rawQueries.getCategories(id),
    [`store_categories_${storeId}`],
    {
      revalidate: 3600, // 1 hour
      tags: ['categories', `categories_${storeId}`],
    }
  );
  return cachedFn(storeId);
};

/**
 * Get cached hero banners
 */
export const getCachedHeroBanners = unstable_cache(
  async () => rawQueries.getHeroBanners(),
  ['hero_banners'],
  {
    revalidate: 3600, // 1 hour
    tags: ['banners', 'hero_banners'],
  }
);

/**
 * Get cached editorial banners
 */
export const getCachedEditorialBanners = unstable_cache(
  async () => rawQueries.getEditorialBanners(),
  ['editorial_banners'],
  {
    revalidate: 3600, // 1 hour
    tags: ['banners', 'editorial_banners'],
  }
);

/**
 * Get cached split banners
 */
export const getCachedSplitBanners = unstable_cache(
  async () => rawQueries.getSplitBanners(),
  ['split_banners'],
  {
    revalidate: 3600, // 1 hour
    tags: ['banners', 'split_banners'],
  }
);

/**
 * Get cached single product by ID
 */
export const getCachedProductById = (id: string) => {
  const cachedFn = unstable_cache(
    async (productId: string) => rawQueries.getProductById(productId),
    [`product_${id}`],
    {
      revalidate: 300, // 5 minutes
      tags: ['products', `product_${id}`],
    }
  );
  return cachedFn(id);
};

/**
 * Get cached gallery items
 */
export const getCachedGalleryItems = unstable_cache(
  async () => rawQueries.getGalleryItems(),
  ['gallery_items'],
  {
    revalidate: 300, // 5 minutes
    tags: ['gallery'],
  }
);

