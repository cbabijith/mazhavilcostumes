'use server';

import { unstable_cache } from 'next/cache';
import { getStoreByEmail, getStoreBySlug } from '@/lib/supabase/queries';
import { BRAND_CONFIG } from 'shared-utils';

const fetchStoreConfig = unstable_cache(
  async () => {
    let store = await getStoreByEmail(BRAND_CONFIG.email);
    if (!store) {
      store = await getStoreBySlug(BRAND_CONFIG.slug);
    }
    return store;
  },
  ['paris_bridals_store_config'],
  {
    revalidate: 3600, // cache for 1 hour
    tags: ['store_config'],
  }
);

/**
 * Get store data
 * First tries by email, then by slug as fallback
 */
export async function getParisBridalsStore() {
  return fetchStoreConfig();
}
