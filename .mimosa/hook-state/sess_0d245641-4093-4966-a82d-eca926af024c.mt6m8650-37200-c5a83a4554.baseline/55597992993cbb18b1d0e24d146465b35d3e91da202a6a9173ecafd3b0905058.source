/**
 * Reorder Categories API
 *
 * PATCH /api/categories/reorder
 * Accepts an array of { id, sort_order } and updates each category.
 *
 * @module app/api/categories/reorder/route
 */

import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/lib/supabase/server';

export async function PATCH(request: NextRequest) {
  try {
    const body = await request.json();
    const items: { id: string; sort_order: number }[] = body.items;

    if (!Array.isArray(items) || items.length === 0) {
      return NextResponse.json(
        { error: 'items array is required' },
        { status: 400 }
      );
    }

    const supabase = createAdminClient();

    // Update each category's sort_order and check results
    const results = await Promise.all(
      items.map((item) =>
        supabase
          .from('categories')
          .update({ sort_order: item.sort_order })
          .eq('id', item.id)
      )
    );

    const failures = results.filter((r) => r.error);
    if (failures.length > 0) {
      console.error('Reorder partial failure:', failures);
      return NextResponse.json(
        { error: `Failed to update ${failures.length} of ${items.length} categories`, details: failures[0].error },
        { status: 500 }
      );
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Error reordering categories:', error);
    return NextResponse.json(
      { error: 'Failed to reorder categories' },
      { status: 500 }
    );
  }
}
