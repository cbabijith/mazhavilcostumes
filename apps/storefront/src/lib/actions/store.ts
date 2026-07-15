'use server';

import { unstable_cache } from 'next/cache';
import { getStoreByEmail, getStoreBySlug } from '@/lib/supabase/queries';

const MAZHAVIL_COSTUMES_EMAIL = 'mazhavildancecostumes01@gmail.com';
const MAZHAVIL_COSTUMES_SLUG = 'mazhavil-costumes';

const fetchStoreConfig = unstable_cache(
  async () => {
    let store = await getStoreByEmail(MAZHAVIL_COSTUMES_EMAIL);
    if (!store) {
      store = await getStoreBySlug(MAZHAVIL_COSTUMES_SLUG);
    }
    return store;
  },
  ['mazhavil_store_config'],
  {
    revalidate: 3600, // cache for 1 hour
    tags: ['store_config'],
  }
);

/**
 * Get Mazhavil Dance Costumes store data
 * First tries by email, then by slug as fallback
 */
export async function getParisBridalsStore() {
  return fetchStoreConfig();
}
