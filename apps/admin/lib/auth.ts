/**
 * Server-side Auth Utilities
 *
 * Reads the authenticated user session from request cookies
 * and resolves their role from the staff table.
 *
 * Used in API routes for backend RBAC enforcement.
 *
 * @module lib/auth
 */

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

/**
 * Read an untrusted lookup hint only. Authentication still requires getUser()
 * and an exact match with its verified user ID before any staff data is used.
 * @param token Bearer JWT supplied by the caller.
 * @returns A UUID subject hint, or null for malformed/unsupported tokens.
 */
function staffLookupHint(token: string): string | null {
  try {
    const payload = token.split('.')[1];
    if (!payload || payload.length > 16384) return null;
    const subject = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')).sub;
    return typeof subject === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(subject)
      ? subject : null;
  } catch {
    return null;
  }
}

/**
 * Internal implementation of getAuthUser
 */
async function getAuthUserImpl(request: NextRequest): Promise<AuthUser | null> {
  try {
    // First, try to get user from Bearer token (for mobile app)
    const authHeader = request.headers.get('authorization');
    if (authHeader?.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const adminClient = createAdminClient();
      const findStaff = (userId: string) => adminClient
        .from('staff')
        .select('id, role, branch_id, store_id, name')
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle();
      const hint = staffLookupHint(token);
      // Overlap two network round trips without caching roles or skipping token
      // verification. No unverified identity or staff result leaves this block.
      const [authResult, prefetchedStaff] = await Promise.all([
        adminClient.auth.getUser(token),
        hint ? findStaff(hint) : Promise.resolve(null),
      ]);
      const { data: { user }, error } = authResult;
      if (!error && user) {
        if (hint && hint !== user.id) return null;
        const { data: staff, error: staffError } = prefetchedStaff ?? await findStaff(user.id);
        if (staffError) return null; // A failed role lookup must not grant fallback privileges.

        const role = staff?.role || user.user_metadata?.role || 'admin';
        const storeId = staff?.store_id || user.user_metadata?.store_id || null;
        const branchId = staff?.branch_id || null;
        const staffId = staff?.id || null;

        return {
          id: user.id,
          email: user.email || '',
          role: role as StaffRole,
          store_id: storeId,
          branch_id: branchId,
          staff_id: staffId,
          name: staff?.name,
        };
      }
    }

    // Fall back to cookie-based auth (for web admin)
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

    const { data: { user }, error } = await supabase.auth.getUser();
    if (error || !user) return null;

    // Look up the staff record to get role + branch + store + name
    const adminClient = createAdminClient();
    const { data: staff } = await adminClient
      .from('staff')
      .select('id, role, branch_id, store_id, name')
      .eq('user_id', user.id)
      .eq('is_active', true)
      .maybeSingle();
 
    // If staff record found, use that role
    if (staff) {
      return {
        id: user.id,
        email: user.email || '',
        role: staff.role as StaffRole,
        store_id: staff.store_id,
        branch_id: staff.branch_id,
        staff_id: staff.id,
        name: staff.name,
      };
    }
 
    // If no staff record, check user_metadata for role (admin users)
    const metaRole = user.user_metadata?.role as StaffRole | undefined;
    const metaStoreId = user.user_metadata?.store_id as string | undefined;
    return {
      id: user.id,
      email: user.email || '',
      role: metaRole || 'admin', // Default to admin if no staff record (shop owner)
      store_id: metaStoreId || null,
      branch_id: null,
      staff_id: null,
    };
  } catch (err) {
    console.error('[auth] getAuthUser error:', err);
    return null;
  }
}

/**
 * Get the authenticated user + their role from request cookies or Bearer token.
 * Returns null if not authenticated.
 * Cached per-request using React cache().
 */
export const getAuthUser = cache(async (request: NextRequest) => {
  return getAuthUserImpl(request);
});
