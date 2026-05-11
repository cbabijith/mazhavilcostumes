/**
 * Product Damage History API
 *
 * GET /api/products/[id]/damage-history — Fetch all damage assessments for a product
 *
 * @module app/api/products/[id]/damage-history/route
 */

import { NextResponse } from 'next/server';
import { damageAssessmentRepository } from '@/repository';

export async function GET(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;

  if (!id) {
    return NextResponse.json(
      { error: 'Product ID is required' },
      { status: 400 }
    );
  }

  const result = await damageAssessmentRepository.findByProductId(id);

  if (!result.success) {
    return NextResponse.json(
      { error: result.error?.message || 'Failed to fetch damage history' },
      { status: 500 }
    );
  }

  return NextResponse.json({
    success: true,
    assessments: result.data || [],
  });
}
