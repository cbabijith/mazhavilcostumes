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

    // Resolve staff name for sidebar display (already fetched in getAuthUser)
    let name = authUser.staff_id ? (authUser as any).name : '';

    const response = apiSuccess({
      user: {
        ...authUser,
        name: name || authUser.email.split('@')[0] || 'User',
      },
    });

    // Add caching headers - cache for 30 seconds, revalidate in background
    response.headers.set('Cache-Control', 'public, s-maxage=30, stale-while-revalidate=60');
    
    return response;
  } catch (error) {
    console.error('[API] GET /api/auth/me error:', error);
    return apiInternalError();
  }
}
