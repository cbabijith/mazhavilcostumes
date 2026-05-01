'use server';

import { getStoreByEmail, getStoreBySlug } from '@/lib/supabase/queries';

const MAZHAVIL_COSTUMES_EMAIL = 'mazhavilcostumes1@gmail.com';
const MAZHAVIL_COSTUMES_SLUG = 'mazhavil-costumes';

/**
 * Get Mazhavil Costumes store data
 * First tries by email, then by slug as fallback
 */
export async function getParisBridalsStore() {
  // Try to get by email first
  let store = await getStoreByEmail(MAZHAVIL_COSTUMES_EMAIL);
  
  // Fallback to slug
  if (!store) {
    store = await getStoreBySlug(MAZHAVIL_COSTUMES_SLUG);
  }
  
  return store;
}
