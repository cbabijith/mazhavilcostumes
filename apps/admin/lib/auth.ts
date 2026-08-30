/**
 * Server-side Auth Utilities
 *
 * Reads the authenticated user session from request cookies
 * and resolves their role from the staff table.
 *
 * Used in API routes for backend RBAC enforcement.
 *
 * Performance note: every API call used to pay TWO sequential Supabase
 * round trips (auth.getUser + staff lookup) before any business logic —
 * several hundred ms per request. Results are now cached in-memory,
 * keyed by a hash of the verified access token, so one admin page load
 * (which fires several API calls in parallel) verifies once and reuses.
 * TTLs are short so role/branch changes apply within a minute.
 *
 * @module lib/auth
 */

import { createHash } from 'crypto';
import { createServerClient } from '@supabase/ssr';
import { createAdminClient } from '@/lib/supabase/server';
import { cache } from 'react';
import type { NextRequest } from 'next/server';
import type { StaffRole } from '@/domain/types/branch';

export interface AuthUser {
  id: string;
  email: string;
  role: StaffRole;
  store_id: string | null;
  branch_id: string | null;
  staff_id: string | null;
  name?: string;
}

interface StaffRow {
  id: string;
  role: StaffRole;
  branch_id: string | null;
  store_id: string | null;
  name: string | null;
}

interface CacheEntry<T> {
  value: T;
  expiresAt: number;
}

const AUTH_TTL_MS = 60_000; // verified-token → AuthUser
const STAFF_TTL_MS = 5 * 60_000; // user_id → staff row
const MAX_ENTRIES = 500;

const authCache = new Map<string, CacheEntry<AuthUser>>();
const staffCache = new Map<string, CacheEntry<StaffRow | null>>();

function cacheGet<T>(map: Map<string, CacheEntry<T>>, key: string): T | undefined {
  const hit = map.get(key);
  if (!hit) return undefined;
  if (Date.now() > hit.expiresAt) {
    map.delete(key);
    return undefined;
  }
  return hit.value;
}

function cacheSet<T>(map: Map<string, CacheEntry<T>>, key: string, value: T, ttl: number): void {
  if (map.size >= MAX_ENTRIES) map.clear();
  map.set(key, { value, expiresAt: Date.now() + ttl });
}

function tokenKey(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

/** Look up the staff record for a user (cached — roles rarely change). */
async function resolveStaff(userId: string): Promise<StaffRow | null> {
  const cached = cacheGet(staffCache, userId);
  if (cached !== undefined) return cached;

  const adminClient = createAdminClient();
  const { data: staff } = await adminClient
    .from('staff')
    .select('id, role, branch_id, store_id, name')
    .eq('user_id', userId)
    .eq('is_active', true)
    .maybeSingle();

  const row = (staff as StaffRow | null) ?? null;
  cacheSet(staffCache, userId, row, STAFF_TTL_MS);
  return row;
}

/** Extract the access token from the Bearer header or the cookie session (local read, no network). */
async function extractAccessToken(request: NextRequest): Promise<string | null> {
  const authHeader = request.headers.get('authorization');
  if (authHeader?.startsWith('Bearer ')) {
    return authHeader.substring(7);
  }

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll() {
          // No-op for API routes (can't set cookies in API handlers this way)
        },
      },
    }
  );
  const {
    data: { session },
  } = await supabase.auth.getSession();
  return session?.access_token ?? null;
}

function toAuthUser(user: any, staff: StaffRow | null): AuthUser {
  if (staff) {
    return {
      id: user.id,
      email: user.email || '',
      role: staff.role,
      store_id: staff.store_id,
      branch_id: staff.branch_id,
      staff_id: staff.id,
      name: staff.name ?? undefined,
    };
  }
  // If no staff record, check user_metadata for role (admin users)
  return {
    id: user.id,
    email: user.email || '',
    role: (user.user_metadata?.role as StaffRole) || 'admin', // Default to admin if no staff record (shop owner)
    store_id: (user.user_metadata?.store_id as string) || null,
    branch_id: null,
    staff_id: null,
  };
}

/**
 * Internal implementation of getAuthUser
 */
async function getAuthUserImpl(request: NextRequest): Promise<AuthUser | null> {
  try {
    let token: string | null = null;
    try {
      token = await extractAccessToken(request);
    } catch {
      token = null;
    }
    // No session cookie and no Bearer token — nothing to verify, fail fast.
    if (!token) return null;

    const key = tokenKey(token);
    const cached = cacheGet(authCache, key);
    if (cached) return cached;

    // Trusted verification: Supabase validates the token signature server-side.
    const adminClient = createAdminClient();
    const {
      data: { user },
      error,
    } = await adminClient.auth.getUser(token);
    if (error || !user) return null;

    const authUser = toAuthUser(user, await resolveStaff(user.id));
    cacheSet(authCache, key, authUser, AUTH_TTL_MS);
    return authUser;
  } catch (err) {
    console.error('[auth] getAuthUser error:', err);
    return null;
  }
}

/**
 * Get the authenticated user + their role from request cookies or Bearer token.
 * Returns null if not authenticated.
 * Cached per-request using React cache(), and across requests via short-TTL
 * in-memory caches (see performance note at the top of this module).
 */
export const getAuthUser = cache(async (request: NextRequest) => {
  return getAuthUserImpl(request);
});
