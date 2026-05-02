/**
 * Server-Side Page Auth Helper
 *
 * Resolves the authenticated user's role from cookies
 * for use in Next.js server components (pages/layouts).
 *
 * Unlike `getAuthUser()` which requires a NextRequest,
 * this helper reads cookies directly via `next/headers`.
 *
 * @module lib/pageAuth
 */

import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { createAdminClient } from '@/lib/supabase/server';
import type { AuthUser } from '@/lib/auth';

/**
 * Get the authenticated user for server components.
 * Returns null if not authenticated.
 */
export async function getPageAuthUser(): Promise<AuthUser | null> {
  try {
    const cookieStore = await cookies();

    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          getAll() {
            return cookieStore.getAll();
          },
          setAll() {
            // No-op — server components can't set cookies
          },
        },
      }
    );

    const { data: { user }, error } = await supabase.auth.getUser();
    if (error || !user) return null;

    // Look up staff record for role
    const adminClient = createAdminClient();
    const { data: staff } = await adminClient
      .from('staff')
      .select('id, role, branch_id, store_id, can_give_product_discount, can_give_order_discount')
      .eq('user_id', user.id)
      .eq('is_active', true)
      .maybeSingle();

    if (staff) {
      return {
        id: user.id,
        email: user.email || '',
        role: staff.role as any,
        store_id: staff.store_id,
        branch_id: staff.branch_id,
        staff_id: staff.id,
        can_give_product_discount: staff.can_give_product_discount ?? false,
        can_give_order_discount: staff.can_give_order_discount ?? false,
      };
    }

    // Fallback to metadata
    return {
      id: user.id,
      email: user.email || '',
      role: (user.user_metadata?.role as any) || 'admin',
      store_id: user.user_metadata?.store_id || null,
      branch_id: null,
      staff_id: null,
    };
  } catch (err) {
    console.error('[pageAuth] Error:', err);
    return null;
  }
}
