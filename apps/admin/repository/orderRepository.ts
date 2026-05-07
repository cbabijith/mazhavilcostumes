/**
 * Order Repository
 *
 * Data access layer for order entities using Supabase.
 *
 * @module repository/orderRepository
 */

import { BaseRepository, RepositoryResult } from './supabaseClient';
import { 
  Order, 
  OrderWithRelations,
  OrderItem,
  OrderStatusHistory,
  CreateOrderDTO,
  UpdateOrderDTO,
  OrderSearchParams,
  ReturnOrderDTO
} from '@/domain/types/order';

/** Buffer days for cleaning/prep before and after each rental (in milliseconds) */
const BUFFER_DAYS = 1;
const BUFFER_MS = BUFFER_DAYS * 86400000;

export class OrderRepository extends BaseRepository {
  private readonly tableName = 'orders';
  private readonly orderItemsTable = 'order_items';
  private readonly orderStatusHistoryTable = 'order_status_history';

  /**
   * Find all orders
   */
  async findAll(params?: OrderSearchParams): Promise<RepositoryResult<OrderWithRelations[]>> {
    let customerIds: string[] = [];
    const searchTerm = params?.query?.trim();

    // Two-step search: if query provided, first find matching customers
    if (searchTerm) {
      const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
      const isUuid = uuidPattern.test(searchTerm);
      
      let customerOr = `name.ilike.%${searchTerm}%,phone.ilike.%${searchTerm}%,email.ilike.%${searchTerm}%`;
      if (isUuid) {
        customerOr += `,id.eq.${searchTerm}`;
      }

      const { data: matchingCustomers, error: customerError } = await this.client
        .from('customers')
        .select('id')
        .or(customerOr);

      if (customerError) {
        console.error('Customer Search Query Error:', customerError);
      }

      customerIds = matchingCustomers?.map(c => c.id) || [];
    }

    let query = this.client
      .from(this.tableName)
      .select(`
        *,
        customer:customer_id(id, name, phone, alt_phone, email),
        items:order_items(*, product:product_id(id, name, images, category:category_id(has_buffer))),
        branch:branch_id(id, name)
      `)
      .order('created_at', { ascending: false });

    if (params?.customer_id) {
      query = query.eq('customer_id', params.customer_id);
    }

    if (params?.branch_id) {
      query = query.eq('branch_id', params.branch_id);
    }

    if (params?.status) {
      if (Array.isArray(params.status)) {
        query = query.in('status', params.status);
      } else {
        query = query.eq('status', params.status);
      }
    }

    if (params?.buffer_override !== undefined) {
      query = query.eq('buffer_override', params.buffer_override);
    }

    if (searchTerm) {
      const filters: string[] = [];
      
      // 1. Add customer ID matches
      if (customerIds.length > 0) {
        filters.push(`customer_id.in.(${customerIds.join(',')})`);
      }

      // 2. Add Order ID matches (Full UUID or first 8 chars)
      const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
      const isHexIsh = /^[0-9a-fA-F-]+$/.test(searchTerm);

      if (uuidPattern.test(searchTerm)) {
        filters.push(`id.eq.${searchTerm}`);
      } else if (isHexIsh && searchTerm.length >= 4) {
        // Support searching by the first 8 characters (short ID used in invoices)
        // ONLY if it looks like a hex string to avoid performance issues on UUID column
        filters.push(`id.ilike.${searchTerm}%`);
      }


      if (filters.length > 0) {
        query = query.or(filters.join(','));
      } else {
        // If searchTerm provided but no matching customers or ID pattern, force empty result
        query = query.eq('id', '00000000-0000-0000-0000-000000000000');
      }
    }

    if (params?.date_filter || params?.date_from || params?.date_to) {
      if (params?.date_filter === 'custom' || (!params?.date_filter && (params?.date_from || params?.date_to))) {
        if (params?.date_from) query = query.gte('created_at', params.date_from);
        if (params?.date_to) query = query.lte('created_at', params.date_to);
      } else if (params?.date_filter) {
        const now = new Date();
        let startDate, endDate;
        switch (params.date_filter) {
          case 'today':
            startDate = new Date(new Date().setHours(0, 0, 0, 0)).toISOString();
            endDate = new Date(new Date().setHours(23, 59, 59, 999)).toISOString();
            query = query.gte('created_at', startDate).lte('created_at', endDate);
            break;
          case 'yesterday':
            const yesterday = new Date(now);
            yesterday.setDate(yesterday.getDate() - 1);
            startDate = new Date(yesterday.setHours(0, 0, 0, 0)).toISOString();
            endDate = new Date(yesterday.setHours(23, 59, 59, 999)).toISOString();
            query = query.gte('created_at', startDate).lte('created_at', endDate);
            break;
          case 'this_week':
            const firstDay = new Date(now.setDate(now.getDate() - now.getDay()));
            startDate = new Date(firstDay.setHours(0, 0, 0, 0)).toISOString();
            query = query.gte('created_at', startDate);
            break;
          case 'this_month':
            startDate = new Date(now.getFullYear(), now.getMonth(), 1).toISOString();
            query = query.gte('created_at', startDate);
            break;
        }
      }
    }

    if (params?.limit) {
      query = query.limit(params.limit);
    }

    if (params?.offset) {
      query = query.range(params.offset, params.offset + (params.limit || 10) - 1);
    }

    const response = await query;
    return this.handleResponse<OrderWithRelations[]>(response);
  }

  /**
   * Fetch active orders overlapping a specific date range for the calendar view.
   */
  async getCalendarOrders(branchId: string, startDate: string, endDate: string): Promise<RepositoryResult<OrderWithRelations[]>> {
    const response = await this.client
      .from(this.tableName)
      .select(`
        *,
        customer:customer_id(id, name, phone, alt_phone, email),
        items:order_items(*, product:product_id(id, name, images, category:category_id(has_buffer))),
        branch:branch_id(id, name)
      `)
      .eq('branch_id', branchId)
      .in('status', ['pending', 'confirmed', 'scheduled', 'ongoing', 'in_use', 'late_return', 'partial', 'flagged'])
      .lte('start_date', endDate)
      .gte('end_date', startDate)
      .order('start_date', { ascending: true });

    return this.handleResponse<OrderWithRelations[]>(response);
  }

  /**
   * Check product availability for given date range using Sweep Line algorithm.
   *
   * Instead of simply summing all overlapping reservations (which over-counts
   * when bookings don't all overlap each other simultaneously), this uses the
   * Sweep Line technique to find the PEAK concurrent usage within the
   * requested date range.
   *
   * Time complexity: O(N log N) where N = number of overlapping bookings.
   *
   * @param excludeOrderId - Exclude this order from the count (for edit scenarios)
   */
  async checkAvailability(
    productId: string,
    startDate: string,
    endDate: string,
    branchId?: string,
    excludeOrderId?: string,
    bufferOverride: boolean = false
  ): Promise<RepositoryResult<{ available: number; total: number; peakReserved: number; overlappingOrders: any[]; adjacentOrders: any[] }>> {
    // Get product total quantity and category buffer setting
    const productResponse = await this.client
      .from('products')
      .select('quantity, name, category:category_id(has_buffer)')
      .eq('id', productId)
      .single();

    if (productResponse.error) {
      return this.handleResponse<{ available: number; total: number; peakReserved: number; overlappingOrders: any[]; adjacentOrders: any[] }>(productResponse);
    }

    const totalQuantity = productResponse.data?.quantity || 0;
    const categoryHasBuffer = (productResponse.data as any)?.category?.has_buffer ?? true;
    
    // The cleaning buffer is 1 day (BUFFER_MS) unless disabled at category level
    const effectiveBuffer = categoryHasBuffer ? BUFFER_MS : 0;

    // Fetch all active order items for this product with their order date ranges
    const ordersResponse = await this.client
      .from('order_items')
      .select('quantity, returned_quantity, order_id, orders!inner(id, start_date, end_date, status, customer_id, buffer_override, customer:customer_id(name))')
      .eq('product_id', productId)
      .in('orders.status', ['pending', 'confirmed', 'scheduled', 'ongoing', 'in_use', 'late_return', 'partial']);

    if (ordersResponse.error) {
      return this.handleResponse<{ available: number; total: number; peakReserved: number; overlappingOrders: any[]; adjacentOrders: any[] }>(ordersResponse);
    }

    const reqStart = new Date(startDate).getTime();
    const reqEnd = new Date(endDate).getTime();

    // Buffer for the REQUESTING order
    const reqBuffer = (bufferOverride || !categoryHasBuffer) ? 0 : effectiveBuffer;

    // Collect bookings into categories
    const actualOverlaps: { start: number; end: number; quantity: number; orderId: string; customerName: string; startDate: string; endDate: string; status: string; bufferOverride: boolean }[] = [];
    const bufferOnlyOverlaps: typeof actualOverlaps = [];
    const allBookings: typeof actualOverlaps = [];

    for (const item of (ordersResponse.data || []) as any[]) {
      const order = Array.isArray(item.orders) ? item.orders[0] : item.orders;
      if (!order) continue;
      if (excludeOrderId && order.id === excludeOrderId) continue;

      const ordStart = new Date(order.start_date).getTime();
      const ordEnd = new Date(order.end_date).getTime();
      const unreturned = item.quantity - (item.returned_quantity || 0);
      if (unreturned <= 0) continue;

      const customer = Array.isArray(order.customer) ? order.customer[0] : order.customer;
      const bookingInfo = {
        start: ordStart,
        end: ordEnd,
        quantity: unreturned,
        orderId: order.id,
        customerName: customer?.name || 'Unknown',
        startDate: order.start_date,
        endDate: order.end_date,
        status: order.status,
        bufferOverride: order.buffer_override || false,
      };

      allBookings.push(bookingInfo);

      // Check ACTUAL rental date overlap (no buffer)
      const hasActualOverlap = ordStart <= reqEnd && ordEnd >= reqStart;

      // Check buffer-extended overlap using EACH booking's own buffer + the effective buffer
      // We use effectiveBuffer here which is 0 if category has no buffer
      const bookingBuffer = (bookingInfo.bufferOverride || !categoryHasBuffer) ? 0 : effectiveBuffer;
      const effectiveStart = ordStart - bookingBuffer;
      const effectiveEnd = ordEnd + bookingBuffer;
      const hasBufferOverlap = effectiveStart <= (reqEnd + effectiveBuffer) && effectiveEnd >= (reqStart - effectiveBuffer);

      if (hasActualOverlap) {
        actualOverlaps.push(bookingInfo);
      } else if (hasBufferOverlap) {
        // Buffer-only: informational, does NOT block availability
        bufferOnlyOverlaps.push(bookingInfo);
      }
    }

    // ─── Availability Calculation ────────────────────────────────────────
    // Two modes depending on whether the requesting order has Skip Gap ON/OFF.
    //
    // When bufferOverride = true (Skip Gap ON):
    //   Only count ACTUAL rental date overlaps. Buffers are ignored.
    //   → Available = total - peakActualUsage
    //
    // When bufferOverride = false (Skip Gap OFF, default):
    //   Use per-day formula: blocked = actual_normal + max(buffer_only, actual_skipgap)
    //   This avoids double-counting because Skip Gap orders take units FROM the buffer pool.
    //   Example: 9 in buffer + 2 Skip Gap = max(9,2) = 9 blocked (not 11)

    let peakUsage = 0;

    if (bufferOverride) {
      // ─── Skip Gap ON: simple sweep line on actual overlaps only ──────
      const events: { time: number; delta: number }[] = [];
      for (const booking of actualOverlaps) {
        events.push({ time: booking.start, delta: +booking.quantity });
        // Release on the same day (same-day turnover allowed in Skip Gap mode)
        events.push({ time: booking.end, delta: -booking.quantity });
      }
      // Sort by time. If same time, process PICKUPS (+delta) before RETURNS (-delta)
      // This ensures that same-day turnover (Return 7, Pickup 7) counts as an overlap
      events.sort((a, b) => a.time - b.time || b.delta - a.delta);

      let currentUsage = 0;
      for (const event of events) {
        if (event.time > reqEnd) break;
        currentUsage += event.delta;
        if (event.time >= reqStart && event.time <= reqEnd) {
          peakUsage = Math.max(peakUsage, currentUsage);
        }
      }
      // Baseline check: count orders that are active at the very start of reqStart
      // If an order ends ON reqStart, we still count it for the start of the day
      let baselineAtStart = 0;
      for (const booking of actualOverlaps) {
        if (booking.start <= reqStart && booking.end >= reqStart) {
          baselineAtStart += booking.quantity;
        }
      }
      peakUsage = Math.max(peakUsage, baselineAtStart);
    } else {
      // ─── Skip Gap OFF: per-day calculation with buffer awareness ─────
      // For each day in the requested range, categorize bookings:
      //   actual_normal:  actual overlap, order did NOT use buffer_override
      //   actual_skipgap: actual overlap, order DID use buffer_override
      //   buffer_only:    day is in buffer zone (not actual rental), order did NOT use buffer_override
      // Formula: blocked = actual_normal + max(buffer_only, actual_skipgap)

      const DAY_MS = 86400000;
      const allRelevant = [...actualOverlaps, ...bufferOnlyOverlaps];

      // Iterate each day in the requested range
      for (let dayMs = reqStart; dayMs <= reqEnd; dayMs += DAY_MS) {
        let actualNormal = 0;
        let actualSkipgap = 0;
        let bufferOnly = 0;

        for (const booking of allRelevant) {
          const isActualDay = booking.start <= dayMs && booking.end >= dayMs;
          // Buffer zone: 1 day before start + 1 day after end (if booking didn't use buffer_override)
          const bookingBuffer = (booking.bufferOverride || !categoryHasBuffer) ? 0 : effectiveBuffer;
          const bufferStart = booking.start - bookingBuffer;
          const bufferEnd = booking.end + bookingBuffer;
          const isBufferDay = !isActualDay && bufferStart <= dayMs && bufferEnd >= dayMs;

          if (isActualDay) {
            if (booking.bufferOverride) {
              actualSkipgap += booking.quantity;
            } else {
              actualNormal += booking.quantity;
            }
          } else if (isBufferDay) {
            bufferOnly += booking.quantity;
          }
        }

        const dayBlocked = actualNormal + Math.max(bufferOnly, actualSkipgap);
        peakUsage = Math.max(peakUsage, dayBlocked);
      }
    }

    const availableQuantity = Math.max(0, totalQuantity - peakUsage);

    // ─── Adjacent Orders (for buffer override warnings) ─────────────
    // Find bookings within ±2 days of the requested range that are NOT overlapping
    const adjacentOrders: any[] = [];
    if (bufferOverride) {
      const ADJACENT_WINDOW = 2 * 86400000; // ±2 days
      for (const booking of allBookings) {
        // Skip if already overlapping with the rental period
        if (booking.start <= reqEnd && booking.end >= reqStart) continue;

        // Check if booking is within ±2 days
        const gapBefore = reqStart - booking.end;
        const gapAfter = booking.start - reqEnd;

        if ((gapBefore > 0 && gapBefore <= ADJACENT_WINDOW) || (gapAfter > 0 && gapAfter <= ADJACENT_WINDOW)) {
          adjacentOrders.push({
            orderId: booking.orderId,
            customerName: booking.customerName,
            quantity: booking.quantity,
            startDate: booking.startDate,
            endDate: booking.endDate,
            status: booking.status,
            position: gapAfter > 0 ? 'after' : 'before',
          });
        }
      }
    }

    // Build the overlapping orders response — combine actual + buffer-only with flags
    const allOverlapping = [
      ...actualOverlaps.map(b => ({ ...b, bufferOnly: false })),
      ...bufferOnlyOverlaps.map(b => ({ ...b, bufferOnly: true })),
    ];

    return {
      data: {
        available: availableQuantity,
        total: totalQuantity,
        peakReserved: peakUsage,
        overlappingOrders: allOverlapping.map(b => {
          // Compute buffer date range: 1 day before start, 1 day after end
          // If the overlapping order itself has buffer_override, it has no buffer zone
          const hasBuffer = !b.bufferOverride;
          const bufferStart = hasBuffer ? new Date(b.start - BUFFER_MS).toISOString().split('T')[0] : null;
          const bufferEnd = hasBuffer ? new Date(b.end + BUFFER_MS).toISOString().split('T')[0] : null;
          return {
            orderId: b.orderId,
            customerName: b.customerName,
            quantity: b.quantity,
            startDate: b.startDate,
            endDate: b.endDate,
            status: b.status,
            bufferStartDate: bufferStart,
            bufferEndDate: bufferEnd,
            bufferOnly: b.bufferOnly,
          };
        }),
        adjacentOrders,
      },
      error: null,
      success: true,
    };
  }

  /**
   * Get per-day availability calendar for a product over a date range.
   *
   * Used to render the availability calendar on the product detail page.
   * For each day in the range, computes how many units are reserved vs available.
   *
   * Uses per-day iteration (O(D × N)) which is appropriate for calendar
   * rendering where we need every single day's data.
   */
  async getAvailabilityCalendar(
    productId: string,
    rangeStart: string,
    rangeEnd: string,
  ): Promise<RepositoryResult<{ productId: string; productName: string; totalQuantity: number; days: any[] }>> {
    // Get product info and category buffer setting
    const productResponse = await this.client
      .from('products')
      .select('quantity, name, category:category_id(has_buffer)')
      .eq('id', productId)
      .single();

    if (productResponse.error) {
      return this.handleResponse<any>(productResponse);
    }

    const totalQuantity = productResponse.data?.quantity || 0;
    const productName = productResponse.data?.name || '';
    const categoryHasBuffer = (productResponse.data as any)?.category?.has_buffer ?? true;
    const effectiveBuffer = categoryHasBuffer ? BUFFER_MS : 0;

    // Fetch all active bookings that overlap with the view range
    const ordersResponse = await this.client
      .from('order_items')
      .select('quantity, returned_quantity, order_id, orders!inner(id, start_date, end_date, status, customer_id, customer:customer_id(name))')
      .eq('product_id', productId)
      .in('orders.status', ['pending', 'confirmed', 'scheduled', 'ongoing', 'in_use', 'late_return', 'partial']);

    if (ordersResponse.error) {
      return this.handleResponse<any>(ordersResponse);
    }

    const viewStart = new Date(rangeStart);
    const viewEnd = new Date(rangeEnd);

    // Parse all bookings
    const bookings: { start: Date; end: Date; quantity: number; orderId: string; customerName: string; startDate: string; endDate: string; status: string }[] = [];
    for (const item of (ordersResponse.data || []) as any[]) {
      const order = Array.isArray(item.orders) ? item.orders[0] : item.orders;
      if (!order) continue;

      const unreturned = item.quantity - (item.returned_quantity || 0);
      if (unreturned <= 0) continue;

      const bookingStart = new Date(order.start_date);
      const bookingEnd = new Date(order.end_date);

      // Include if the booking's buffered range overlaps with our view range
      const bufferedStart = new Date(bookingStart.getTime() - BUFFER_MS);
      const bufferedEnd = new Date(bookingEnd.getTime() + BUFFER_MS);
      if (bufferedStart <= viewEnd && bufferedEnd >= viewStart) {
        const customer = Array.isArray(order.customer) ? order.customer[0] : order.customer;
        bookings.push({
          start: bookingStart,
          end: bookingEnd,
          quantity: unreturned,
          orderId: order.id,
          customerName: customer?.name || 'Unknown',
          startDate: order.start_date,
          endDate: order.end_date,
          status: order.status,
        });
      }
    }

    // Build per-day availability map (with buffer day detection)
    const days: any[] = [];
    const current = new Date(viewStart);
    while (current <= viewEnd) {
      const dateStr = current.toISOString().split('T')[0];
      const currentTime = current.getTime();
      let reserved = 0;
      let bufferReserved = 0;
      const dayBookings: any[] = [];

      for (const booking of bookings) {
        const bookingStartTime = booking.start.getTime();
        const bookingEndTime = booking.end.getTime();
        const bufferedStartTime = bookingStartTime - effectiveBuffer;
        const bufferedEndTime = bookingEndTime + effectiveBuffer;

        // Check if this booking (including buffer) covers the current day
        if (bufferedStartTime <= currentTime && bufferedEndTime >= currentTime) {
          reserved += booking.quantity;

          // Determine if this day is a buffer day or an actual rental day
          const isActualRentalDay = bookingStartTime <= currentTime && bookingEndTime >= currentTime;
          const isBuffer = !isActualRentalDay;

          if (isBuffer) {
            bufferReserved += booking.quantity;
          }

          dayBookings.push({
            orderId: booking.orderId,
            customerName: booking.customerName,
            quantity: booking.quantity,
            startDate: booking.startDate,
            endDate: booking.endDate,
            status: booking.status,
            isBuffer,
          });
        }
      }

      const available = Math.max(0, totalQuantity - reserved);
      let status: 'available' | 'partial' | 'unavailable' | 'buffer' = 'available';
      if (available === 0 && bufferReserved === reserved) status = 'buffer';
      else if (available === 0) status = 'unavailable';
      else if (reserved > 0 && bufferReserved === reserved) status = 'buffer';
      else if (reserved > 0) status = 'partial';

      days.push({ date: dateStr, total: totalQuantity, reserved, bufferReserved, available, status, bookings: dayBookings });
      current.setDate(current.getDate() + 1);
    }

    return {
      data: { productId, productName, totalQuantity, days },
      error: null,
      success: true,
    };
  }

  /**
   * Find order by ID
   */
  async findById(id: string): Promise<RepositoryResult<OrderWithRelations>> {
    const response = await this.client
      .from(this.tableName)
      .select(`
        *,
        customer:customer_id(id, name, phone, alt_phone, email),
        items:order_items(*, product:product_id(id, name, images, category:category_id(has_buffer))),
        branch:branch_id(id, name)
      `)
      .eq('id', id)
      .single();

    return this.handleResponse<OrderWithRelations>(response);
  }

  /**
   * Create a new order with items
   */
  async create(data: CreateOrderDTO, isGstEnabled: boolean = false, perItemGstRates: Map<string, number> = new Map()): Promise<RepositoryResult<OrderWithRelations>> {
    // Parse rental dates — used for scheduling AND pricing
    const startDate = new Date(data.rental_start_date);
    const endDate = new Date(data.rental_end_date);

    // Calculate rental days — inclusive counting (pickup day + return day)
    const diffTime = Math.abs(endDate.getTime() - startDate.getTime());
    const rentalDays = Math.max(1, Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1);

    // Pricing multiplier: base price covers first 3 days, each extra day adds 1×
    const pricingMultiplier = Math.max(1, rentalDays - 2);

    // Calculate subtotal — rent price × quantity × pricingMultiplier, with per-item discounts
    let rawSubtotal = 0;
    let itemDiscountTotal = 0;
    data.items.forEach((item: any) => {
      const lineTotal = item.price_per_day * item.quantity * pricingMultiplier;
      const itemDisc = item.discount_type === 'percent'
        ? lineTotal * ((item.discount || 0) / 100)
        : (item.discount || 0) * item.quantity;
      rawSubtotal += lineTotal;
      itemDiscountTotal += Math.min(itemDisc, lineTotal);
    });
    const afterItemDiscount = rawSubtotal - itemDiscountTotal;

    // Order-level discount
    const orderDiscountVal = (data as any).discount || 0;
    const orderDiscountType = (data as any).discount_type || 'flat';
    const orderDiscAmt = orderDiscountType === 'percent'
      ? afterItemDiscount * (orderDiscountVal / 100)
      : orderDiscountVal;
    const effectiveOrderDiscount = Math.min(orderDiscAmt, afterItemDiscount);
    const subtotal = afterItemDiscount - effectiveOrderDiscount;

    // GST-INCLUSIVE calculation: the rent amount ALREADY includes GST
    // Formula: base = amount / (1 + rate/100), gst = amount - base
    let totalGstAmount = 0;
    const itemGstDetails = new Map<string, { rate: number; base: number; gst: number }>();
    
    if (isGstEnabled) {
      data.items.forEach((item: any) => {
        const lineTotal = item.price_per_day * item.quantity * pricingMultiplier;
        const itemDisc = item.discount_type === 'percent'
          ? lineTotal * ((item.discount || 0) / 100)
          : (item.discount || 0) * item.quantity;
        const lineAfterDiscount = lineTotal - Math.min(itemDisc, lineTotal);
        const gstRate = perItemGstRates.get(item.product_id) ?? 0;
        
        let itemGst = 0;
        let itemBase = lineAfterDiscount;
        
        if (gstRate > 0) {
          itemGst = lineAfterDiscount - (lineAfterDiscount / (1 + gstRate / 100));
          itemBase = lineAfterDiscount - itemGst;
          totalGstAmount += itemGst;
        }
        
        itemGstDetails.set(item.product_id, { rate: gstRate, base: itemBase, gst: itemGst });
      });

      // Proportionally adjust GST if order-level discount was applied
      if (effectiveOrderDiscount > 0 && afterItemDiscount > 0) {
        const ratio = subtotal / afterItemDiscount;
        totalGstAmount = totalGstAmount * ratio;
        
        // Also adjust individual item details for accurate reporting
        for (const [productId, details] of itemGstDetails.entries()) {
          const adjustedGst = details.gst * ratio;
          const adjustedBase = (details.base + details.gst) * ratio - adjustedGst;
          itemGstDetails.set(productId, { ...details, base: adjustedBase, gst: adjustedGst });
        }
      }
      totalGstAmount = Math.round(totalGstAmount * 100) / 100;
    } else {
      // If GST not enabled, still need base amounts (which is just the line total)
      data.items.forEach((item: any) => {
        const lineTotal = item.price_per_day * item.quantity * pricingMultiplier;
        const itemDisc = item.discount_type === 'percent'
          ? lineTotal * ((item.discount || 0) / 100)
          : (item.discount || 0) * item.quantity;
        const lineAfterDiscount = lineTotal - Math.min(itemDisc, lineTotal);
        itemGstDetails.set(item.product_id, { rate: 0, base: lineAfterDiscount, gst: 0 });
      });
    }
    
    // Grand total = subtotal (GST is WITHIN, not added on top)
    const totalAmount = subtotal;

    // Fetch store_id from branch
    const branchResponse = await this.client
      .from('branches')
      .select('store_id')
      .eq('id', data.branch_id)
      .single();
      
    if (branchResponse.error) {
      return {
        data: null,
        error: branchResponse.error,
        success: false
      };
    }
    
    const storeId = branchResponse.data.store_id;

    const todayStr = new Date().toISOString().split('T')[0];
    const startDateStr = startDate.toISOString().split('T')[0];
    const initialStatus = 'scheduled';

    // Start a transaction by creating the order first
    // DB columns: start_date, end_date, event_date (all DATE type)
    const orderResponse = await this.client
      .from(this.tableName)
      .insert({
        customer_id: data.customer_id,
        branch_id: data.branch_id,
        store_id: storeId,
        status: initialStatus,
        start_date: startDateStr,
        end_date: endDate.toISOString().split('T')[0],
        event_date: data.event_date ? new Date(data.event_date).toISOString().split('T')[0] : startDate.toISOString().split('T')[0],
        delivery_method: data.delivery_method || 'pickup',
        delivery_address: data.delivery_address || null,
        pickup_address: data.pickup_address || null,
        subtotal: rawSubtotal,
        gst_amount: totalGstAmount,
        discount: effectiveOrderDiscount,
        discount_type: orderDiscountType,
        advance_amount: data.advance_amount || 0,
        advance_collected: data.advance_collected || false,
        advance_payment_method: data.advance_payment_method || null,
        advance_collected_at: data.advance_collected ? new Date().toISOString() : null,
        total_amount: totalAmount,
        amount_paid: data.advance_collected && data.advance_amount ? data.advance_amount : 0,
        payment_status: data.advance_collected && data.advance_amount
          ? (data.advance_amount >= totalAmount ? 'paid' : 'partial')
          : 'pending',
        notes: data.notes || null,
        buffer_override: (data as any).buffer_override || false,
        ...this.getCreateAuditFields(),
      })
      .select()
      .single();

    if (orderResponse.error) {
      return this.handleResponse<OrderWithRelations>(orderResponse);
    }

    const order = orderResponse.data;

    // Create order items — flat rent price, with per-item discounts
    const itemsResponse = await this.client
      .from(this.orderItemsTable)
      .insert(
        data.items.map((item: any) => {
          const gst = itemGstDetails.get(item.product_id) || { rate: 0, base: 0, gst: 0 };
          return {
            order_id: order.id,
            product_id: item.product_id,
            quantity: item.quantity,
            price_per_day: item.price_per_day,
            discount: item.discount || 0,
            discount_type: item.discount_type || 'flat',
            subtotal: item.price_per_day * item.quantity * pricingMultiplier,
            gst_percentage: gst.rate,
            base_amount: Math.round(gst.base * 100) / 100,
            gst_amount: Math.round(gst.gst * 100) / 100,
          };
        })
      )
      .select();

    if (itemsResponse.error) {
      // Rollback: delete the order if items failed
      await this.client.from(this.tableName).delete().eq('id', order.id);
      return this.handleResponse<OrderWithRelations>(itemsResponse);
    }

    // NOTE: Inventory is NOT deducted at creation time.
    // Stock deduction happens only when the user manually starts the rental
    // (transitions to ongoing/in_use) via the order details page.

    // Create advance payment record if advance was collected
    if (data.advance_collected && data.advance_amount && data.advance_amount > 0) {
      await this.client
        .from('payments')
        .insert({
          order_id: order.id,
          payment_type: 'advance',
          amount: data.advance_amount,
          payment_mode: data.advance_payment_method || 'cash',
          notes: 'Advance payment collected at order creation',
          payment_date: new Date().toISOString(),
          ...this.getCreateAuditFields(),
        });
    }


    // Create initial status history
    await this.client
      .from(this.orderStatusHistoryTable)
      .insert({
        order_id: order.id,
        status: initialStatus,
        changed_by: null,
      });

    // Fetch the complete order with relations
    return this.findById(order.id);
  }

  /**
   * Update an existing order
   */
  async update(id: string, data: UpdateOrderDTO): Promise<RepositoryResult<OrderWithRelations>> {
    // Fetch existing order to check status transitions
    const oldOrderResponse = await this.client
      .from(this.tableName)
      .select('status, branch_id, start_date, end_date')
      .eq('id', id)
      .single();
      
    const oldStatus = oldOrderResponse.data?.status;
    const branchId = oldOrderResponse.data?.branch_id;

    // Normalize date fields to 'YYYY-MM-DD' for DATE columns
    const normalizedData: Record<string, any> = { ...data };
    if (normalizedData.start_date) {
      normalizedData.start_date = new Date(normalizedData.start_date).toISOString().split('T')[0];
    }
    if (normalizedData.end_date) {
      normalizedData.end_date = new Date(normalizedData.end_date).toISOString().split('T')[0];
    }
    if (normalizedData.event_date) {
      normalizedData.event_date = new Date(normalizedData.event_date).toISOString().split('T')[0];
    }

    // Extract items to handle them separately
    const { items, ...orderData } = normalizedData;

    const response = await this.client
      .from(this.tableName)
      .update({ ...orderData })
      .eq('id', id)
      .select()
      .single();

    // If items are provided, sync them
    if (items && Array.isArray(items)) {
      // 1. Delete existing items
      // NOTE: In a production app with complex stock tracking, we might want to do a differential update
      // But for this rental system, replacing them is simpler as long as we're not in an active rental state.
      await this.client.from(this.orderItemsTable).delete().eq('order_id', id);

      // 2. Insert new items with GST calculation
      // Fetch current GST rates for updated items
      const productIds = items.map((item: any) => item.product_id);
      const { data: products } = await this.client
        .from('products')
        .select('id, categories:category_id(gst_percentage)')
        .in('id', productIds);
      
      const perItemGstRates = new Map<string, number>();
      if (products) {
        for (const p of products) {
          const cat = Array.isArray(p.categories) ? p.categories[0] : p.categories;
          perItemGstRates.set(p.id, (cat as any)?.gst_percentage ?? 0);
        }
      }

      // Fetch global GST setting
      const { data: settings } = await this.client.from('settings').select('value').eq('key', 'is_gst_enabled').single();
      const isGstEnabled = settings?.value === 'true';

      const finalStartDate = new Date(normalizedData.start_date || oldOrderResponse.data?.start_date);
      const finalEndDate = new Date(normalizedData.end_date || oldOrderResponse.data?.end_date);
      const diffTime = Math.abs(finalEndDate.getTime() - finalStartDate.getTime());
      const rentalDays = Math.max(1, Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1);
      const pricingMultiplier = Math.max(1, rentalDays - 2);

      // We don't adjust per-item GST for order-level discount during update yet
      // because the update data might not include all order financial fields.
      // Ideally we should recalculate the whole order totals here.
      // For now, save the raw per-item GST breakdown.
      
      await this.client.from(this.orderItemsTable).insert(
        items.map((item: any) => {
          const lineTotal = item.price_per_day * item.quantity * pricingMultiplier;
          const itemDisc = item.discount_type === 'percent'
            ? lineTotal * ((item.discount || 0) / 100)
            : (item.discount || 0) * item.quantity;
          const lineAfterDiscount = lineTotal - Math.min(itemDisc, lineTotal);
          const gstRate = perItemGstRates.get(item.product_id) ?? 0;
          
          let itemGst = 0;
          let itemBase = lineAfterDiscount;
          
          if (isGstEnabled && gstRate > 0) {
            itemGst = lineAfterDiscount - (lineAfterDiscount / (1 + gstRate / 100));
            itemBase = lineAfterDiscount - itemGst;
          }

          return {
            order_id: id,
            product_id: item.product_id,
            quantity: item.quantity,
            price_per_day: item.price_per_day,
            discount: item.discount || 0,
            discount_type: item.discount_type || 'flat',
            subtotal: lineTotal,
            gst_percentage: gstRate,
            base_amount: Math.round(itemBase * 100) / 100,
            gst_amount: Math.round(itemGst * 100) / 100,
          };
        })
      );
    }

    // If status changed to ongoing/in_use, decrement stock
    if (data.status && oldStatus && branchId) {
      const isStarting = ['ongoing', 'in_use'].includes(data.status) && 
                         !['ongoing', 'in_use', 'returned', 'late_return', 'completed'].includes(oldStatus);
      const isCancelling = data.status === 'cancelled' && 
                           ['ongoing', 'in_use'].includes(oldStatus);
                           
      if (isStarting || isCancelling) {
        const itemsRes = await this.client.from(this.orderItemsTable).select('product_id, quantity').eq('order_id', id);
        if (itemsRes.data) {
          for (const item of itemsRes.data) {
            const qtyChange = isStarting ? item.quantity : -item.quantity; // positive means we subtract from available
            
            const { data: inv } = await this.client.from('product_inventory').select('available_quantity').eq('product_id', item.product_id).eq('branch_id', branchId).single();
            if (inv) {
              await this.client.from('product_inventory').update({ available_quantity: Math.max(0, inv.available_quantity - qtyChange) }).eq('product_id', item.product_id).eq('branch_id', branchId);
            }
            
            const { data: prod } = await this.client.from('products').select('available_quantity').eq('id', item.product_id).single();
            if (prod) {
              await this.client.from('products').update({ available_quantity: Math.max(0, prod.available_quantity - qtyChange) }).eq('id', item.product_id);
            }
          }
        }
      }
    }

    // If status changed, add to history
    if (data.status) {
      await this.client
        .from(this.orderStatusHistoryTable)
        .insert({
          order_id: id,
          status: data.status,
          changed_by: null,
        });
    }

    const result = this.handleResponse<Order>(response);
    
    if (!result.success || !result.data) {
      return result as RepositoryResult<OrderWithRelations>;
    }

    return this.findById(id);
  }

  /**
   * Delete an order
   */
  async delete(id: string): Promise<RepositoryResult<void>> {
    // Fetch the order to check if we need to restore stock
    const orderResponse = await this.client
      .from(this.tableName)
      .select('status, branch_id')
      .eq('id', id)
      .single();

    if (orderResponse.data) {
      const status = orderResponse.data.status;
      const branchId = orderResponse.data.branch_id;
      
      // These statuses mean the items have decremented the available_quantity
      if (['ongoing', 'in_use', 'late_return', 'partial', 'flagged'].includes(status)) {
        const itemsRes = await this.client
          .from(this.orderItemsTable)
          .select('product_id, quantity, returned_quantity')
          .eq('order_id', id);

        if (itemsRes.data) {
          for (const item of itemsRes.data) {
            const unreturnedQuantity = item.quantity - (item.returned_quantity || 0);
            if (unreturnedQuantity > 0) {
              // Restore inventory
              const { data: inv } = await this.client
                .from('product_inventory')
                .select('available_quantity')
                .eq('product_id', item.product_id)
                .eq('branch_id', branchId)
                .single();
                
              if (inv) {
                await this.client
                  .from('product_inventory')
                  .update({ available_quantity: inv.available_quantity + unreturnedQuantity })
                  .eq('product_id', item.product_id)
                  .eq('branch_id', branchId);
              }
              
              const { data: prod } = await this.client
                .from('products')
                .select('available_quantity')
                .eq('id', item.product_id)
                .single();
                
              if (prod) {
                await this.client
                  .from('products')
                  .update({ available_quantity: prod.available_quantity + unreturnedQuantity })
                  .eq('id', item.product_id);
              }
            }
          }
        }
      }
    }

    const response = await this.client
      .from(this.tableName)
      .delete()
      .eq('id', id);

    return this.handleResponse<void>(response);
  }

  /**
   * Get order status history
   */
  async getStatusHistory(orderId: string): Promise<RepositoryResult<OrderStatusHistory[]>> {
    const response = await this.client
      .from(this.orderStatusHistoryTable)
      .select('*')
      .eq('order_id', orderId)
      .order('created_at', { ascending: false });

    return this.handleResponse<OrderStatusHistory[]>(response);
  }

  /**
   * Count orders
   */
  async count(params?: OrderSearchParams): Promise<RepositoryResult<number>> {
    let customerIds: string[] = [];
    const searchTerm = params?.query?.trim();

    // Two-step search: if query provided, first find matching customers
    if (searchTerm) {
      const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
      const isUuid = uuidPattern.test(searchTerm);
      
      let customerOr = `name.ilike.%${searchTerm}%,phone.ilike.%${searchTerm}%,email.ilike.%${searchTerm}%`;
      if (isUuid) {
        customerOr += `,id.eq.${searchTerm}`;
      }

      const { data: matchingCustomers, error: customerError } = await this.client
        .from('customers')
        .select('id')
        .or(customerOr);

      if (customerError) {
        console.error('Customer Search Query Error:', customerError);
      }

      customerIds = matchingCustomers?.map(c => c.id) || [];
    }

    let query = this.client
      .from(this.tableName)
      .select('*', { count: 'exact', head: true });

    if (params?.customer_id) {
      query = query.eq('customer_id', params.customer_id);
    }

    if (params?.branch_id) {
      query = query.eq('branch_id', params.branch_id);
    }

    if (params?.status) {
      if (Array.isArray(params.status)) {
        query = query.in('status', params.status);
      } else {
        query = query.eq('status', params.status);
      }
    }

    if (params?.buffer_override !== undefined) {
      query = query.eq('buffer_override', params.buffer_override);
    }

    if (searchTerm) {
      const filters: string[] = [];
      
      // 1. Add customer ID matches
      if (customerIds.length > 0) {
        filters.push(`customer_id.in.(${customerIds.join(',')})`);
      }

      // 2. Add Order ID matches (Full UUID or first 8 chars)
      const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
      const isHexIsh = /^[0-9a-fA-F-]+$/.test(searchTerm);

      if (uuidPattern.test(searchTerm)) {
        filters.push(`id.eq.${searchTerm}`);
      } else if (isHexIsh && searchTerm.length >= 4) {
        // Support searching by the first 8 characters (short ID used in invoices)
        // ONLY if it looks like a hex string to avoid performance issues on UUID column
        filters.push(`id.ilike.${searchTerm}%`);
      }


      if (filters.length > 0) {
        query = query.or(filters.join(','));
      } else {
        // If searchTerm provided but no matching customers or ID pattern, force empty result
        query = query.eq('id', '00000000-0000-0000-0000-000000000000');
      }
    }

    if (params?.date_filter || params?.date_from || params?.date_to) {
      if (params?.date_filter === 'custom' || (!params?.date_filter && (params?.date_from || params?.date_to))) {
        if (params?.date_from) query = query.gte('created_at', params.date_from);
        if (params?.date_to) query = query.lte('created_at', params.date_to);
      } else if (params?.date_filter) {
        const now = new Date();
        let startDate, endDate;
        switch (params.date_filter) {
          case 'today':
            startDate = new Date(new Date().setHours(0, 0, 0, 0)).toISOString();
            endDate = new Date(new Date().setHours(23, 59, 59, 999)).toISOString();
            query = query.gte('created_at', startDate).lte('created_at', endDate);
            break;
          case 'yesterday':
            const yesterday = new Date(now);
            yesterday.setDate(yesterday.getDate() - 1);
            startDate = new Date(yesterday.setHours(0, 0, 0, 0)).toISOString();
            endDate = new Date(yesterday.setHours(23, 59, 59, 999)).toISOString();
            query = query.gte('created_at', startDate).lte('created_at', endDate);
            break;
          case 'this_week':
            const firstDay = new Date(now.setDate(now.getDate() - now.getDay()));
            startDate = new Date(firstDay.setHours(0, 0, 0, 0)).toISOString();
            query = query.gte('created_at', startDate);
            break;
          case 'this_month':
            startDate = new Date(now.getFullYear(), now.getMonth(), 1).toISOString();
            query = query.gte('created_at', startDate);
            break;
        }
      }
    }

    const response = await query;
    
    if (response.error) {
      return {
        success: false,
        data: null,
        error: response.error,
      };
    }
    
    return {
      success: true,
      data: response.count || 0,
      error: null,
    };
  }

  /**
   * Process order return with condition assessment
   */
  async processReturn(orderId: string, returnData: ReturnOrderDTO): Promise<RepositoryResult<OrderWithRelations>> {
    // Determine final status based on return condition
    let newStatus = 'returned';
    let hasMissing = false;
    let hasDamage = false;
    let totalDamageCharges = 0;

    // Fetch existing order items to check for partial returns
    const { data: existingItems } = await this.client
      .from(this.orderItemsTable)
      .select('id, quantity, returned_quantity')
      .eq('order_id', orderId);

    for (const item of returnData.items) {
      if (item.damage_charges && item.damage_charges > 0) {
        hasDamage = true;
        totalDamageCharges += item.damage_charges;
      }
      if (item.condition_rating === 'damaged') hasDamage = true;
      
      const existingItem = existingItems?.find(i => i.id === item.item_id);
      if (existingItem) {
         const oldReturned = existingItem.returned_quantity || 0;
         // If what we are returning now + what was previously returned is less than the total quantity ordered
         if ((item.returned_quantity) < existingItem.quantity) {
           hasMissing = true;
         }
      } else if (item.returned_quantity === 0) {
         hasMissing = true;
      }
    }

    if (hasDamage) {
      newStatus = 'flagged';
    } else if (hasMissing) {
      newStatus = 'partial';
    }

    // Get current order to calculate new total
    const { data: currentOrder } = await this.client
      .from(this.tableName)
      .select('total_amount, amount_paid')
      .eq('id', orderId)
      .single();

    let newTotalAmount = Number(currentOrder?.total_amount || 0);
    
    // Add late fee and damage charges, subtract discounts
    const lateFee = Number(returnData.late_fee || 0);
    const discount = Number(returnData.discount || 0);
    const totalDeductions = lateFee + totalDamageCharges - discount;

    newTotalAmount = Math.max(0, newTotalAmount + totalDeductions);
    
    // Update payment status if the new total changed and is not fully paid anymore
    let paymentStatus = undefined;
    const amountPaid = Number(currentOrder?.amount_paid || 0);
    console.log(`processReturn: newTotalAmount=${newTotalAmount}, amountPaid=${amountPaid}, totalDeductions=${totalDeductions}`);
    if (currentOrder && newTotalAmount > amountPaid) {
       paymentStatus = amountPaid > 0 ? 'partial' : 'pending';
    }

    // Update order status and totals
    const orderResponse = await this.client
      .from(this.tableName)
      .update({
        status: newStatus,
        total_amount: newTotalAmount,
        late_fee: lateFee,
        discount: discount,
        damage_charges_total: totalDamageCharges,
        ...(paymentStatus ? { payment_status: paymentStatus } : {})
      })
      .eq('id', orderId)
      .select()
      .single();

    if (orderResponse.error) {
      return this.handleResponse<OrderWithRelations>(orderResponse);
    }

    // Update order items with condition and damage info
    for (const item of returnData.items) {
      // Get existing order item to prevent double-counting inventory on partial returns
      const { data: orderItem } = await this.client
        .from(this.orderItemsTable)
        .select('returned_quantity, product_id, orders(branch_id)')
        .eq('id', item.item_id)
        .single();
        
      const oldReturnedQuantity = orderItem?.returned_quantity || 0;
      const quantityToIncrement = item.returned_quantity - oldReturnedQuantity;

      await this.client
        .from(this.orderItemsTable)
        .update({
          is_returned: true,
          returned_at: new Date().toISOString(),
          returned_quantity: item.returned_quantity,
          condition_rating: item.condition_rating,
          damage_description: item.damage_description || null,
          damage_charges: item.damage_charges || 0,
        })
        .eq('id', item.item_id);

      // Increment inventory only by the difference
      if (quantityToIncrement > 0 && orderItem && orderItem.product_id) {
        const branchId = (orderItem as any).orders?.branch_id || (orderItem as any).orders?.[0]?.branch_id;
        
        const { data: inv } = await this.client
          .from('product_inventory')
          .select('available_quantity')
          .eq('product_id', orderItem.product_id)
          .eq('branch_id', branchId)
          .single();
          
        if (inv) {
          await this.client
            .from('product_inventory')
            .update({ available_quantity: inv.available_quantity + quantityToIncrement })
            .eq('product_id', orderItem.product_id)
            .eq('branch_id', branchId);
        }
        
        const { data: prod } = await this.client
          .from('products')
          .select('available_quantity')
          .eq('id', orderItem.product_id)
          .single();
          
        if (prod) {
          await this.client
            .from('products')
            .update({ available_quantity: prod.available_quantity + quantityToIncrement })
            .eq('id', orderItem.product_id);
        }
      }
    }

    // Add to status history
    await this.client
      .from(this.orderStatusHistoryTable)
      .insert({
        order_id: orderId,
        status: newStatus,
        notes: returnData.notes || null,
        changed_by: null,
      });

    return this.findById(orderId);
  }

  /**
   * Mark deposit as returned
   */
  async markDepositReturned(orderId: string): Promise<RepositoryResult<OrderWithRelations>> {
    const response = await this.client
      .from(this.tableName)
      .update({
        deposit_returned: true,
        deposit_returned_at: new Date().toISOString(),
      })
      .eq('id', orderId)
      .select()
      .single();

    const result = this.handleResponse<Order>(response);
    
    if (!result.success || !result.data) {
      return result as RepositoryResult<OrderWithRelations>;
    }

    return this.findById(orderId);
  }

  /**
   * Add a status history entry for an order
   */
  async addStatusHistory(orderId: string, status: string, notes?: string): Promise<void> {
    await this.client
      .from(this.orderStatusHistoryTable)
      .insert({
        order_id: orderId,
        status,
        notes: notes || null,
        changed_by: null,
      });
  }

  /**
   * Transition all overdue orders (ongoing/in_use past end_date) to late_return.
   *
   * This is a bulk operation intended to be called by:
   *   1. A daily Vercel Cron Job
   *   2. On-read when the orders list is fetched (lazy fallback)
   *
   * @returns Number of orders transitioned
   */
  async transitionOverdueToLateReturn(): Promise<number> {
    const todayStr = new Date().toISOString().split('T')[0];

    // Find all orders that are in ongoing/in_use AND past their end_date
    const { data: overdueOrders, error } = await this.client
      .from(this.tableName)
      .select('id')
      .in('status', ['ongoing', 'in_use'])
      .lt('end_date', todayStr);

    if (error || !overdueOrders || overdueOrders.length === 0) {
      return 0;
    }

    const overdueIds = overdueOrders.map(o => o.id);

    // Bulk update status to late_return
    const { error: updateError } = await this.client
      .from(this.tableName)
      .update({ status: 'late_return' })
      .in('id', overdueIds);

    if (updateError) {
      console.error('Failed to bulk-transition overdue orders:', updateError);
      return 0;
    }

    // Insert status history entries for each transitioned order
    const historyEntries = overdueIds.map(id => ({
      order_id: id,
      status: 'late_return',
      notes: 'Auto-transitioned: rental period ended without return',
      changed_by: null,
    }));

    await this.client
      .from(this.orderStatusHistoryTable)
      .insert(historyEntries);

    return overdueIds.length;
  }
}

// Singleton instance
export const orderRepository = new OrderRepository();
