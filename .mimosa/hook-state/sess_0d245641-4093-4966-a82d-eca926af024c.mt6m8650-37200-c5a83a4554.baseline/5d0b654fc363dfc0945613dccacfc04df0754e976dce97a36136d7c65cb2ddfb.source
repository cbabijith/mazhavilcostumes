/**
 * Orders REST API — Deposit Return (DEPRECATED)
 *
 * Security deposit has been removed from the system.
 * This endpoint returns 410 Gone.
 *
 * @module app/api/orders/[id]/deposit/route
 */

import { NextRequest, NextResponse } from "next/server";

interface RouteContext {
  params: Promise<{ id: string }>;
}

/** PATCH /api/orders/:id/deposit — DEPRECATED */
export async function PATCH(request: NextRequest, { params }: RouteContext) {
  return NextResponse.json(
    { error: 'Security deposit has been removed from the system.' },
    { status: 410 }
  );
}
