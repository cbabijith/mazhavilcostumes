import { NextRequest, NextResponse } from 'next/server';
import { staffService } from '@/services/staffService';

/**
 * GET /api/staff/[id]/stats
 * 
 * Fetches performance statistics for a specific staff member.
 */
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    if (!id) {
      return NextResponse.json(
        { success: false, error: 'Staff ID is required' },
        { status: 400 }
      );
    }

    const result = await staffService.getStaffOrderStats(id);

    if (!result.success) {
      return NextResponse.json(
        { success: false, error: result.error?.message || 'Failed to fetch staff stats' },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      data: result.data
    });
  } catch (error: any) {
    console.error('[API] Error fetching staff stats:', error);
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    );
  }
}
