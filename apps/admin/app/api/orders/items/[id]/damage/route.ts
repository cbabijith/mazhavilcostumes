import { NextRequest, NextResponse } from 'next/server';
import { orderService } from '@/services';

/**
 * PATCH /api/orders/items/[id]/damage
 * 
 * Incrementally update damage details for a specific order item.
 */
export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const body = await request.json();
    
    const result = await orderService.updateOrderItemDamage(id, {
      condition_rating: body.condition_rating,
      damage_description: body.damage_description,
      damage_charges: Number(body.damage_charges),
      damaged_quantity: Number(body.damaged_quantity),
    });

    if (result.success) {
      return NextResponse.json(result.data);
    } else {
      return NextResponse.json(
        { error: result.error?.message || 'Failed to update item damage' },
        { status: result.error?.code === 'VALIDATION_ERROR' ? 400 : 500 }
      );
    }
  } catch (error: any) {
    console.error('API Error updating item damage:', error);
    return NextResponse.json(
      { error: 'Internal Server Error' },
      { status: 500 }
    );
  }
}
