'use server';

import { unstable_cache } from 'next/cache';
import { getStoreByEmail, getStoreBySlug } from '@/lib/supabase/queries';

const Rentocostume_COSTUMES_EMAIL = 'rentocostume1@gmail.com';
const Rentocostume_COSTUMES_SLUG = 'Rentocostume-costumes';

const fetchStoreConfig = unstable_cache(
  async () => {
    let store = await getStoreByEmail(Rentocostume_COSTUMES_EMAIL);
    if (!store) {
      store = await getStoreBySlug(Rentocostume_COSTUMES_SLUG);
    }
    return store;
  },
  ['Rentocostume_store_config'],
  {
    revalidate: 3600, // cache for 1 hour
    tags: ['store_config'],
  }
);

/**
 * Get Rentocostume store data
 * First tries by email, then by slug as fallback
 */
export async function getParisBridalsStore() {
  return fetchStoreConfig();
}
