/**
 * Staff Password Reset API Route
 * POST /api/staff/[id]/reset-password — Reset a staff member's password (super_admin only)
 */

import { NextRequest, NextResponse } from 'next/server';
import { staffService } from '@/services/staffService';
import { apiGuard } from '@/lib/apiGuard';
import { apiSuccess, apiRepositoryError, apiInternalError } from '@/lib/apiResponse';

export const dynamic = 'force-dynamic';

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    // Check authentication and permissions (staff permission is required)
    const guard = await apiGuard(request, 'staff');
    if (guard.error) return guard.error;

    // Set user context
    staffService.setUserContext(
      guard.user.staff_id,
      guard.user.branch_id,
      guard.user.store_id
    );

    // RESTRICTED TO SUPER ADMIN ONLY
    if (guard.user.role !== 'super_admin') {
      return NextResponse.json(
        { success: false, error: { message: 'Only Super Admins can reset staff passwords.', code: 'FORBIDDEN' } },
        { status: 403 }
      );
    }

    const { id } = await params;
    const body = await request.json();
    const { password } = body;

    if (!password || password.length < 6) {
      return NextResponse.json(
        { success: false, error: { message: 'Password must be at least 6 characters long.', code: 'VALIDATION_ERROR' } },
        { status: 400 }
      );
    }

    const result = await staffService.resetStaffPassword(id, password);
    if (!result.success) {
      return apiRepositoryError(result.error, 'Failed to reset password');
    }

    return apiSuccess(null, { message: 'Password reset successfully' });
  } catch (error: any) {
    console.error('[API] POST /api/staff/[id]/reset-password error:', error);
    return apiInternalError(error.message);
  }
}
