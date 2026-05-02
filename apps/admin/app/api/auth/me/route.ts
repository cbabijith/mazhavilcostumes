/**
 * Current User API Route
 * GET /api/auth/me — Get current authenticated user info
 */

import { NextRequest } from 'next/server';
import { getAuthUser } from '@/lib/auth';
import { createAdminClient } from '@/lib/supabase/server';
import { apiSuccess, apiUnauthorized, apiInternalError } from '@/lib/apiResponse';

export async function GET(request: NextRequest) {
  try {
    const authUser = await getAuthUser(request);
    
    if (!authUser) {
      return apiUnauthorized('Not authenticated');
    }

    // Resolve staff name for sidebar display
    let name = '';
    if (authUser.staff_id) {
      const supabase = createAdminClient();
      const { data: staff } = await supabase
        .from('staff')
        .select('name')
        .eq('id', authUser.staff_id)
        .maybeSingle();
      name = staff?.name || '';
    }

    return apiSuccess({
      user: {
        ...authUser,
        name: name || authUser.email.split('@')[0] || 'User',
      },
    });
  } catch (error) {
    console.error('[API] GET /api/auth/me error:', error);
    return apiInternalError();
  }
}
