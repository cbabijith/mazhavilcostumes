/**
 * Customer Enquiries API Route
 *
 * POST /api/enquiries — Create a new enquiry
 *
 * @module app/api/enquiries/route
 */

import { NextRequest } from 'next/server';
import { apiGuard } from '@/lib/apiGuard';
import { apiSuccess, apiBadRequest, apiInternalError } from '@/lib/apiResponse';
import { reportService } from '@/services/reportService';

export async function POST(request: NextRequest) {
  try {
    const guard = await apiGuard(request, 'reports');
    if (guard.error) return guard.error;

    const body = await request.json();
    if (!body.product_query || body.product_query.trim().length === 0) {
      return apiBadRequest('Product query is required');
    }

    const enquiry = await reportService.createEnquiry(
      {
        product_query: body.product_query.trim(),
        customer_name: body.customer_name?.trim() || undefined,
        customer_phone: body.customer_phone?.trim() || undefined,
        notes: body.notes?.trim() || undefined,
      },
      guard.user.id,
      guard.user.branch_id || null,
      guard.user.store_id || null
    );

    return apiSuccess(enquiry, { message: 'Enquiry logged successfully' });
  } catch (err) {
    console.error('Enquiry API error:', err);
    return apiInternalError();
  }
}
