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
      revalidate: 60, // 1 minute — category order changes should propagate quickly
      tags: ['categories', `categories_${storeId}`],
    }
  );
  return cachedFn(storeId);
};

/**
 * Get cached hero banners for a store
 */
export const getCachedHeroBanners = (storeId: string) => {
  const cachedFn = unstable_cache(
    async (sid: string) => rawQueries.getHeroBanners(sid),
    [`hero_banners_${storeId}`],
    {
      revalidate: 60, // 1 minute — banner changes from admin should reflect quickly
      tags: ['banners', 'hero_banners', `hero_banners_${storeId}`],
    }
  );
  return cachedFn(storeId);
};

/**
 * Get cached editorial banners for a store
 */
export const getCachedEditorialBanners = (storeId: string) => {
  const cachedFn = unstable_cache(
    async (sid: string) => rawQueries.getEditorialBanners(sid),
    [`editorial_banners_${storeId}`],
    {
      revalidate: 60, // 1 minute — banner changes from admin should reflect quickly
      tags: ['banners', 'editorial_banners', `editorial_banners_${storeId}`],
    }
  );
  return cachedFn(storeId);
};

/**
 * Get cached split banners for a store
 */
export const getCachedSplitBanners = (storeId: string) => {
  const cachedFn = unstable_cache(
    async (sid: string) => rawQueries.getSplitBanners(sid),
    [`split_banners_${storeId}`],
    {
      revalidate: 60, // 1 minute — banner changes from admin should reflect quickly
      tags: ['banners', 'split_banners', `split_banners_${storeId}`],
    }
  );
  return cachedFn(storeId);
};

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

/**
 * Get cached new arrivals for a store
 */
export const getCachedNewArrivals = (storeId: string, limit = 10) => {
  const cachedFn = unstable_cache(
    async (id: string, lim: number) => rawQueries.getNewArrivals(id, lim),
    [`new_arrivals_${storeId}_${limit}`],
    {
      revalidate: 300, // 5 minutes
      tags: ['products', `new_arrivals_${storeId}`],
    }
  );
  return cachedFn(storeId, limit);
};

/**
 * Get cached featured products for a store
 */
export const getCachedFeaturedProducts = (storeId: string, limit = 8) => {
  const cachedFn = unstable_cache(
    async (id: string, lim: number) => rawQueries.getFeaturedProducts(id, lim),
    [`featured_products_${storeId}_${limit}`],
    {
      revalidate: 300, // 5 minutes
      tags: ['products', `featured_products_${storeId}`],
    }
  );
  return cachedFn(storeId, limit);
};

/**
 * Get cached related products
 */
export const getCachedRelatedProducts = (
  storeId: string,
  categoryId: string,
  excludeId: string,
  limit = 8
) => {
  const cachedFn = unstable_cache(
    async (sid: string, cid: string, eid: string, lim: number) =>
      rawQueries.getRelatedProducts(sid, cid, eid, lim),
    [`related_products_${storeId}_${categoryId}_${excludeId}_${limit}`],
    {
      revalidate: 300, // 5 minutes
      tags: ['products', `related_products_${storeId}`],
    }
  );
  return cachedFn(storeId, categoryId, excludeId, limit);
};

/**
 * Get cached products with pagination and filters
 */
export const getCachedProducts = (
  storeId: string,
  options: {
    categoryId?: string;
    limit?: number;
    offset?: number;
    featured?: boolean;
    search?: string;
    sort?: string;
  } = {}
) => {
  const optsKey = JSON.stringify(options);
  const cachedFn = unstable_cache(
    async (sid: string, opts: string) => {
      const parsed = JSON.parse(opts) as typeof options;
      return rawQueries.getProducts(sid, parsed);
    },
    [`products_${storeId}_${optsKey}`],
    {
      revalidate: 60, // 1 minute — product lists change with pagination/filters
      tags: ['products', `products_${storeId}`],
    }
  );
  return cachedFn(storeId, optsKey);
};

