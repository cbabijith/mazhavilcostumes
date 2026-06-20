/**
 * Supabase Server Clients (Singleton)
 *
 * Cached clients — created once, reused everywhere.
 * - createClient: anon key (subject to RLS)
 * - createAdminClient: service role key (bypasses RLS)
 */

import { createClient as createSupabaseClient, type SupabaseClient } from '@supabase/supabase-js';
import { cookies, headers } from 'next/headers';

let _anonClient: SupabaseClient | null = null;
let _adminClient: SupabaseClient | null = null;

/**
 * Standard anon client (singleton). Subject to RLS.
 */
export function createClient(): SupabaseClient {
  if (_anonClient) return _anonClient;

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!url || !anonKey) {
    throw new Error(
      'Missing Supabase environment variables. Check .env.local for: ' +
      'NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY'
    );
  }

  _anonClient = createSupabaseClient(url, anonKey);
  return _anonClient;
}

/**
 * Admin client (singleton / dynamic fallback). Bypasses RLS via service role key.
 * Falls back to dynamic authenticated client (representing the logged-in user via token or cookies)
 * or standard anon client if service role key is not found.
 */
export function createAdminClient(): SupabaseClient {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!url) {
    throw new Error('Missing NEXT_PUBLIC_SUPABASE_URL in .env.local');
  }

  // 1. If serviceRoleKey is present, return the global admin client (bypasses RLS).
  if (serviceRoleKey) {
    if (_adminClient) return _adminClient;
    console.log('[supabase] Admin client initialized with SERVICE_ROLE_KEY (Bypassing RLS)');
    _adminClient = createSupabaseClient(url, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });
    return _adminClient;
  }

  console.warn(
    '[supabase] SUPABASE_SERVICE_ROLE_KEY not found — falling back to request-based authentication context. RLS will be enforced at database level!'
  );

  // 2. Fall back dynamically using an async fetch interceptor to avoid Next.js 15+ synchronous headers/cookies errors.
  return createSupabaseClient(url, anonKey || '', {
    global: {
      fetch: async (input, init) => {
        const headersObj = new Headers(init?.headers);

        try {
          // Check Bearer token from authorization header (mobile clients)
          const reqHeaders = await headers();
          const authHeader = reqHeaders.get('authorization');
          if (authHeader?.startsWith('Bearer ')) {
            headersObj.set('Authorization', authHeader);
          } else {
            // Check cookies for Supabase session token (web clients)
            const reqCookies = await cookies();
            const projectRef = url.split('.')[0].replace('https://', '');
            const cookieName = `sb-${projectRef}-auth-token`;
            const cookieValue = reqCookies.get(cookieName)?.value;
            
            if (cookieValue) {
              try {
                const session = JSON.parse(cookieValue);
                const token = session?.access_token || (Array.isArray(session) ? session[0] : null);
                if (token) {
                  headersObj.set('Authorization', `Bearer ${token}`);
                }
              } catch (e) {
                // Parsing failed, ignore
              }
            }
          }
        } catch (e) {
          // Not in a request context (e.g. build time, static generation, offline scripts)
        }

        return fetch(input, {
          ...init,
          headers: headersObj,
        });
      }
    },
    auth: { autoRefreshToken: false, persistSession: false },
  });
}
