/**
 * Cleaning Detail API Route
 *
 * PATCH /api/cleaning/[id]
 *
 * @module app/api/cleaning/[id]/route
 */

import { NextResponse } from 'next/server';
import { cleaningService } from '@/services/cleaningService';
import { CleaningStatus } from '@/domain';

export async function PATCH(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const body = await request.json();
  const { status } = body;

  let result;
  if (status === CleaningStatus.IN_PROGRESS) {
    result = await cleaningService.startCleaning(id);
  } else if (status === CleaningStatus.COMPLETED) {
    result = await cleaningService.completeCleaning(id);
  } else {
    // Generic update for other fields
    const { cleaningRepository } = await import('@/repository/cleaningRepository');
    result = await cleaningRepository.update(id, body);
  }

  if (!result.success) {
    return NextResponse.json({ error: result.error }, { status: 500 });
  }

  return NextResponse.json({ data: result.data });
}
