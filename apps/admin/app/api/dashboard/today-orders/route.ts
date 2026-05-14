import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/lib/supabase/server';

export interface TodayOrder {
  id: string;
  customer_name: string;
  customer_phone: string;
  product_name: string;
  product_image_url?: string;
  start_date: string;
  end_date: string;
  status: string;
  total_amount: number;
  type: 'pickup' | 'return';
}

export async function GET(request: NextRequest) {
  try {
    const supabase = createAdminClient();
    const now = new Date();
    const todayStr = now.toISOString().split('T')[0];

    // Fetch today's pickups
    const { data: pickupOrders } = await supabase
      .from('orders')
      .select(`
        id,
        start_date,
        end_date,
        status,
        total_amount,
        customer:customer_id (
          name,
          phone
        ),
        order_items (
          product:product_id (
            name,
            image_url
          )
        )
      `)
      .eq('start_date', todayStr)
      .neq('status', 'cancelled')
      .order('start_date', { ascending: true });

    // Fetch today's returns
    const { data: returnOrders } = await supabase
      .from('orders')
      .select(`
        id,
        start_date,
        end_date,
        status,
        total_amount,
        customer:customer_id (
          name,
          phone
        ),
        order_items (
          product:product_id (
            name,
            image_url
          )
        )
      `)
      .eq('end_date', todayStr)
      .in('status', ['ongoing', 'in_use', 'late_return'])
      .order('end_date', { ascending: true });

    const formatOrder = (order: any, type: 'pickup' | 'return'): TodayOrder => {
      const customer = order.customer;
      const items = order.order_items || [];
      const firstItem = items[0]?.product || {};
      
      return {
        id: order.id,
        customer_name: customer?.name || 'Unknown',
        customer_phone: customer?.phone || '',
        product_name: firstItem.name || 'Unknown Product',
        product_image_url: firstItem.image_url,
        start_date: order.start_date,
        end_date: order.end_date,
        status: order.status,
        total_amount: order.total_amount || 0,
        type,
      };
    };

    const todayOrders: TodayOrder[] = [
      ...(pickupOrders?.map((o) => formatOrder(o, 'pickup')) || []),
      ...(returnOrders?.map((o) => formatOrder(o, 'return')) || []),
    ];

    return NextResponse.json({
      success: true,
      data: todayOrders,
    });
  } catch (error) {
    console.error('Error fetching today orders:', error);
    return NextResponse.json(
      {
        success: false,
        error: 'Failed to fetch today orders',
      },
      { status: 500 }
    );
  }
}
