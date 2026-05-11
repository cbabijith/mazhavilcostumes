/**
 * Damage Assessment Decision API Route
 *
 * PATCH /api/orders/[id]/damage-assessments/[assessmentId] — Update decision
 *
 * @module app/api/orders/[id]/damage-assessments/[assessmentId]/route
 */

import { NextRequest, NextResponse } from 'next/server';
import { damageAssessmentService } from '@/services/damageAssessmentService';
import { DamageDecision } from '@/domain';

export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string; assessmentId: string }> }
) {
  try {
    const { assessmentId } = await params;
    const body = await request.json();

    const { decision, notes } = body;

    if (!decision || !Object.values(DamageDecision).includes(decision)) {
      return NextResponse.json(
        { error: `Invalid decision. Must be one of: ${Object.values(DamageDecision).join(', ')}` },
        { status: 400 }
      );
    }

    const result = await damageAssessmentService.assessUnit(
      assessmentId,
      decision as DamageDecision,
      notes
    );

    if (!result.success) {
      return NextResponse.json(
        { error: result.error?.message || 'Failed to update assessment' },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      assessment: result.data,
    });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
