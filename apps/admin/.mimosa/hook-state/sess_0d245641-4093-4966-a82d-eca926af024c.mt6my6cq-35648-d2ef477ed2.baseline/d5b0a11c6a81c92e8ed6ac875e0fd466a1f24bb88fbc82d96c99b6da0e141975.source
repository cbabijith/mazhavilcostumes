/**
 * Settings REST API — GST Configuration (DEPRECATED)
 *
 * GST percentage is now set per-category, not as a global setting.
 * This route is kept as a stub to prevent 404s from legacy clients.
 * Only the GST enabled/disabled toggle remains in the settings table.
 *
 * @module app/api/settings/gst/route
 */

import { NextRequest, NextResponse } from "next/server";

/** GET /api/settings/gst — deprecated, returns message */
export async function GET(request: NextRequest) {
  return NextResponse.json(
    { success: false, error: { message: 'GST percentage is now set per-category. Use the category API to manage GST rates.', code: 'DEPRECATED' } },
    { status: 410 }
  );
}

/** PATCH /api/settings/gst — deprecated */
export async function PATCH(request: NextRequest) {
  return NextResponse.json(
    { success: false, error: { message: 'GST percentage is now set per-category. Use the category API to manage GST rates.', code: 'DEPRECATED' } },
    { status: 410 }
  );
}
