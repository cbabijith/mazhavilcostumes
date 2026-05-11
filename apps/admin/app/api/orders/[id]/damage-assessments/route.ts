/**
 * Damage Assessments API Route
 *
 * GET  /api/orders/[id]/damage-assessments — Fetch all assessments for an order
 * POST /api/orders/[id]/damage-assessments — Create damage assessments batch
 *
 * @module app/api/orders/[id]/damage-assessments/route
 */

import { NextRequest, NextResponse } from 'next/server';
import { damageAssessmentService } from '@/services/damageAssessmentService';

export async function GET(
  _request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: orderId } = await params;
    const result = await damageAssessmentService.getAssessmentsForOrder(orderId);

    if (!result.success) {
      return NextResponse.json(
        { error: result.error?.message || 'Failed to fetch assessments' },
        { status: 500 }
      );
    }

    const status = await damageAssessmentService.checkAllAssessed(orderId);

    return NextResponse.json({
      assessments: result.data || [],
      summary: status,
    });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: orderId } = await params;
    const body = await request.json();

    if (!body.items || !Array.isArray(body.items) || body.items.length === 0) {
      return NextResponse.json(
        { error: 'items array is required' },
        { status: 400 }
      );
    }

    const result = await damageAssessmentService.createAssessments({
      order_id: orderId,
      items: body.items,
    });

    if (!result.success) {
      return NextResponse.json(
        { error: result.error?.message || 'Failed to create assessments' },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      assessments: result.data || [],
    }, { status: 201 });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
