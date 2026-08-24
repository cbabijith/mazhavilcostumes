/**
 * Cleaning API Route
 *
 * GET /api/cleaning?branch_id=...&status=...
 *
 * @module app/api/cleaning/route
 */

import { NextResponse } from 'next/server';
import { cleaningService } from '@/services/cleaningService';
import { CleaningStatus } from '@/domain';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const branchId = searchParams.get('branch_id');
  const status = searchParams.get('status') as CleaningStatus | null;
  const sortBy = searchParams.get('sort_by') as any;
  const sortOrder = searchParams.get('sort_order') as any;

  if (!branchId) {
    return NextResponse.json({ error: 'branch_id is required' }, { status: 400 });
  }

  const result = await cleaningService.getQueue({ 
    branch_id: branchId, 
    status: status || undefined,
    sort_by: sortBy || undefined,
    sort_order: sortOrder || undefined,
  });
  
  if (!result.success) {
    return NextResponse.json({ error: result.error }, { status: 500 });
  }

  return NextResponse.json({ data: result.data });
}
