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
  ReturnOrderDTO,
  ConditionRating
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
      if ((params.status as string) === 'action_needed') {
        // Virtual status: scheduled orders whose pickup date has passed
        const todayStr = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Kolkata' }).format(new Date());
        query = query.eq('status', 'scheduled').lte('start_date', todayStr);
      } else if ((params.status as string) === 'priority_cleaning') {
        // Virtual status: active orders that need priority cleaning
        query = query.eq('has_priority_cleaning', true)
          .not('status', 'in', '(completed,cancelled)');
      } else if ((params.status as string) === 'revenue_due') {
        // Virtual status: returned/partial/flagged but not fully paid
        query = query.in('status', ['returned', 'partial', 'flagged', 'late_return'])
          .neq('payment_status', 'paid');
      } else if ((params.status as string) === 'pending') {
        // Virtual status: draft/enquiry OR scheduled orders whose pickup date has passed/today
        const todayStr = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Kolkata' }).format(new Date());
        query = query.or(`status.eq.pending,and(status.eq.scheduled,start_date.lte.${todayStr})`);
      } else if ((params.status as string) === 'partial') {
        // Virtual status: orders with outstanding balance
        // We look for orders explicitly marked as partial OR where paid < total
        // Using .or() for a more robust "partial" check
        query = query.or('payment_status.eq.partial,and(payment_status.eq.pending,amount_paid.gt.0)');
      } else if (Array.isArray(params.status)) {
        query = query.in('status', params.status);
      } else {
        query = query.eq('status', params.status);
      }
    }

    if (params?.exclude_status) {
      if (Array.isArray(params.exclude_status)) {
        query = query.not('status', 'in', `(${params.exclude_status.join(',')})`);
      } else {
        query = query.neq('status', params.exclude_status);
      }
    }

    if (params?.payment_status) {
      if (Array.isArray(params.payment_status)) {
        query = query.in('payment_status', params.payment_status);
      } else {
        query = query.eq('payment_status', params.payment_status);
      }
    }

    if (params?.has_damage_charges) {
      query = query.gt('damage_charges_total', 0);
    }

    if (params?.has_stock_conflict !== undefined) {
      query = query.eq('has_stock_conflict', params.has_stock_conflict);
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
      const dateCol = params?.date_field || 'created_at';
      const isDateOnly = dateCol === 'start_date' || dateCol === 'end_date';
      if (params?.date_filter === 'custom' || (!params?.date_filter && (params?.date_from || params?.date_to))) {
        if (params?.date_from) query = query.gte(dateCol, params.date_from);
        if (params?.date_to) query = query.lte(dateCol, params.date_to);
      } else if (params?.date_filter) {
        const getISTISO = (date: Date) => {
          return new Intl.DateTimeFormat('en-CA', {
            timeZone: 'Asia/Kolkata',
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
          }).format(date);
        };

        switch (params.date_filter) {
          case 'today': {
            const todayStr = getISTISO(new Date());
            if (isDateOnly) {
              query = query.gte(dateCol, todayStr).lte(dateCol, todayStr);
            } else {
              query = query.gte(dateCol, `${todayStr}T00:00:00+05:30`).lte(dateCol, `${todayStr}T23:59:59+05:30`);
            }
            break;
          }
          case 'yesterday': {
            const yesterday = new Date(new Date().getTime() - 24 * 60 * 60 * 1000);
            const yStr = getISTISO(yesterday).split('T')[0];
            if (isDateOnly) {
              query = query.gte(dateCol, yStr).lte(dateCol, yStr);
            } else {
              query = query.gte(dateCol, `${yStr}T00:00:00+05:30`).lte(dateCol, `${yStr}T23:59:59+05:30`);
            }
            break;
          }
          case 'this_week': {
            const now = new Date();
            const day = now.getDay();
            const diff = now.getDate() - day + (day === 0 ? -6 : 1); // Monday start
            const monday = new Date(now.setDate(diff));
            const monStr = getISTISO(monday).split('T')[0];
            if (isDateOnly) {
              query = query.gte(dateCol, monStr);
            } else {
              query = query.gte(dateCol, `${monStr}T00:00:00+05:30`);
            }
            break;
          }
          case 'this_month': {
            const now = new Date();
            const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
            const fomStr = getISTISO(monthStart).split('T')[0];
            if (isDateOnly) {
              query = query.gte(dateCol, fomStr);
            } else {
              query = query.gte(dateCol, `${fomStr}T00:00:00+05:30`);
            }
            break;
          }
        }
      }
    }

    if (params?.has_damage_charges) {
      query = query.gt('damage_charges_total', 0);
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
      .in('status', ['pending', 'confirmed', 'scheduled', 'ongoing', 'in_use', 'late_return', 'partial', 'flagged', 'returned'])
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
  /**
   * Get product total quantity and category buffer setting.
   * Used for internal calculations.
   */
  async getProductBufferInfo(productId: string): Promise<RepositoryResult<{ quantity: number; has_buffer: boolean }>> {
    const response = await this.client
      .from('products')
      .select('quantity, category:category_id(has_buffer)')
      .eq('id', productId)
      .single();
      
    if (response.error) return this.handleResponse(response as any);
    
    const data = response.data as any;
    const categoryData = data.category;
    const category = Array.isArray(categoryData) ? categoryData[0] : categoryData;
    
    return {
      success: true,
      error: null,
      data: {
        quantity: data.quantity || 0,
        has_buffer: category?.has_buffer ?? true
      }
    };
  }

  async checkAvailability(
    productId: string,
    startDate: string,
    endDate: string,
    branchId?: string,
    excludeOrderId?: string,
  ): Promise<RepositoryResult<{ available: number; availableWithPriority: number; total: number; peakReserved: number; overlappingOrders: any[]; priorityCleaningNeeded: boolean; priorityCleaningInfo: any[] }>> {
    // Get product total quantity, name, and category buffer setting
    const productResponse = await this.client
      .from('products')
      .select('quantity, name, category:category_id(has_buffer)')
      .eq('id', productId)
      .single();

    if (productResponse.error) {
      return this.handleResponse<any>(productResponse);
    }

    const totalQuantity = productResponse.data?.quantity || 0;
    const productName = productResponse.data?.name || 'Unknown';
    
    // Handle Supabase join ambiguity (could be object or array)
    const categoryData = productResponse.data?.category;
    const category = Array.isArray(categoryData) ? categoryData[0] : categoryData;
    const categoryHasBuffer = category?.has_buffer ?? true;
    
    // The cleaning buffer is 1 day (BUFFER_MS) unless disabled at category level
    const effectiveBuffer = categoryHasBuffer ? BUFFER_MS : 0;

    // Fetch all active order items for this product with their order date ranges
    const ordersResponse = await this.client
      .from('order_items')
      .select('quantity, returned_quantity, order_id, orders!inner(id, start_date, end_date, status, customer_id, customer:customer_id(name))')
      .eq('product_id', productId)
      .in('orders.status', ['pending', 'confirmed', 'scheduled', 'ongoing', 'in_use', 'late_return', 'partial', 'flagged', 'returned']);

    if (ordersResponse.error) {
      return this.handleResponse<any>(ordersResponse);
    }

    const DAY_MS = 86400000;
    const reqStart = Math.floor(new Date(startDate).getTime() / DAY_MS) * DAY_MS;
    const reqEnd = Math.floor(new Date(endDate).getTime() / DAY_MS) * DAY_MS;

    // Collect bookings into categories
    type BookingInfo = { start: number; end: number; quantity: number; orderId: string; customerName: string; startDate: string; endDate: string; status: string };
    const actualOverlaps: BookingInfo[] = [];
    const bufferOnlyOverlaps: BookingInfo[] = [];

    for (const item of (ordersResponse.data || []) as any[]) {
      const order = Array.isArray(item.orders) ? item.orders[0] : item.orders;
      if (!order) continue;
      if (excludeOrderId && order.id === excludeOrderId) continue;

      const ordStart = Math.floor(new Date(order.start_date).getTime() / DAY_MS) * DAY_MS;
      const ordEnd = Math.floor(new Date(order.end_date).getTime() / DAY_MS) * DAY_MS;
      const unreturned = item.quantity - (item.returned_quantity || 0);
      if (unreturned <= 0) continue;

      const customer = Array.isArray(order.customer) ? order.customer[0] : order.customer;
      const bookingInfo: BookingInfo = {
        start: ordStart,
        end: ordEnd,
        quantity: unreturned,
        orderId: order.id,
        customerName: customer?.name || 'Unknown',
        startDate: order.start_date,
        endDate: order.end_date,
        status: order.status,
      };

      // Check ACTUAL rental date overlap (no buffer)
      const hasActualOverlap = ordStart <= reqEnd && ordEnd >= reqStart;

      // Check buffer-extended overlap
      const bookingBuffer = !categoryHasBuffer ? 0 : effectiveBuffer;
      const effectiveStart = ordStart - bookingBuffer;
      const effectiveEnd = ordEnd + bookingBuffer;
      const hasBufferOverlap = effectiveStart <= (reqEnd + effectiveBuffer) && effectiveEnd >= (reqStart - effectiveBuffer);

      if (hasActualOverlap) {
        actualOverlaps.push(bookingInfo);
      } else if (hasBufferOverlap) {
        bufferOnlyOverlaps.push(bookingInfo);
      }
    }

    // ─── Availability Calculation (union-of-blocked-sets) ──────────────────
    // For a multi-day rental, the same physical unit stays with the customer
    // for the entire period. Blocked units on DIFFERENT days are disjoint
    // physical units. We compute the UNION of all unique booking quantities
    // that block any day in the requested range.
    //
    // Example: 5 units in cleaning on May 12 + 1 unit in prep on May 14
    //          = 6 total blocked (disjoint sets) → available = total - 6
    const allRelevant = [...actualOverlaps, ...bufferOnlyOverlaps];
    const blockedBookingIds = new Set<string>();
    const blockedBufferOrderIds = new Set<string>(); // Track buffer-only bookings that ACTUALLY blocked a day
    let unionBlocked = 0;

    for (let dayMs = reqStart; dayMs <= reqEnd; dayMs += DAY_MS) {
      for (const booking of allRelevant) {
        // Skip if we already counted this booking
        if (blockedBookingIds.has(booking.orderId)) continue;

        const isActualDay = booking.start <= dayMs && booking.end >= dayMs;
        const bookingBuffer = !categoryHasBuffer ? 0 : effectiveBuffer;
        const bufferStart = booking.start - bookingBuffer;
        const bufferEnd = booking.end + bookingBuffer;
        const isBufferDay = !isActualDay && bufferStart <= dayMs && bufferEnd >= dayMs;

        if (isActualDay || isBufferDay) {
          blockedBookingIds.add(booking.orderId);
          unionBlocked += booking.quantity;
          // Track if this was a buffer-only booking (not an actual overlap)
          if (bufferOnlyOverlaps.some(b => b.orderId === booking.orderId)) {
            blockedBufferOrderIds.add(booking.orderId);
          }
        }
      }
    }

    const availableQuantity = Math.max(0, totalQuantity - unionBlocked);

    // ─── Priority Cleaning Detection ──────────────────────────────────────
    // Calculate availability ignoring buffer-only overlaps (i.e. priority cleaning).
    // Uses the same union approach — only actual rental overlaps count.
    const actualBlockedIds = new Set<string>();
    let unionBlockedActualOnly = 0;

    for (let dayMs = reqStart; dayMs <= reqEnd; dayMs += DAY_MS) {
      for (const booking of actualOverlaps) {
        if (actualBlockedIds.has(booking.orderId)) continue;
        if (booking.start <= dayMs && booking.end >= dayMs) {
          actualBlockedIds.add(booking.orderId);
          unionBlockedActualOnly += booking.quantity;
        }
      }
    }

    const availableWithPriority = Math.max(0, totalQuantity - unionBlockedActualOnly);

    // Priority cleaning is available when buffer-only overlaps exist and
    // removing them would free up additional units
    const priorityCleaningNeeded = blockedBufferOrderIds.size > 0 && availableWithPriority > availableQuantity;

    // ─── Build Priority Cleaning Info ─────────────────────────────────────
    // Only include buffer-only bookings that ACTUALLY blocked a day in the
    // requested range (fixes phantom bookings from double-buffer overlap check).
    // Add direction: 'returning_before' (rush-clean returned items) or
    // 'starting_after' (skip prep for future booking).
    const priorityCleaningInfo: any[] = [];
    if (priorityCleaningNeeded) {
      for (const bufferBooking of bufferOnlyOverlaps) {
        // Skip phantom bookings — only include those that actually blocked availability
        if (!blockedBufferOrderIds.has(bufferBooking.orderId)) continue;

        const direction = bufferBooking.end < reqStart ? 'returning_before' : 'starting_after';
        priorityCleaningInfo.push({
          returningOrderId: bufferBooking.orderId,
          returningOrderCustomer: bufferBooking.customerName,
          returningOrderEndDate: bufferBooking.endDate,
          returningOrderStartDate: bufferBooking.startDate,
          returningQuantity: bufferBooking.quantity,
          productId: productId,
          productName: productName,
          direction,
        });
      }

      // Sort: returning_before first (by end date asc), then starting_after (by start date asc)
      priorityCleaningInfo.sort((a: any, b: any) => {
        if (a.direction !== b.direction) return a.direction === 'returning_before' ? -1 : 1;
        const dateA = a.direction === 'returning_before' ? a.returningOrderEndDate : a.returningOrderStartDate;
        const dateB = b.direction === 'returning_before' ? b.returningOrderEndDate : b.returningOrderStartDate;
        return new Date(dateA).getTime() - new Date(dateB).getTime();
      });
    }

    // Build the overlapping orders response — combine actual + buffer-only with flags
    // Sort by start date for chronological display
    const allOverlapping = [
      ...actualOverlaps.map(b => ({ ...b, bufferOnly: false })),
      ...bufferOnlyOverlaps.map(b => ({ ...b, bufferOnly: true })),
    ].sort((a, b) => a.start - b.start);

    return {
      data: {
        available: availableQuantity,
        availableWithPriority,
        total: totalQuantity,
        peakReserved: unionBlocked,
        overlappingOrders: allOverlapping.map(b => {
          const potentialBufferStart = categoryHasBuffer ? new Date(b.start - DAY_MS).toISOString().split('T')[0] : null;
          const potentialBufferEnd = categoryHasBuffer ? new Date(b.end + DAY_MS).toISOString().split('T')[0] : null;
          
          return {
            orderId: b.orderId,
            customerName: b.customerName,
            quantity: b.quantity,
            startDate: b.startDate,
            endDate: b.endDate,
            status: b.status,
            bufferStartDate: potentialBufferStart,
            bufferEndDate: potentialBufferEnd,
            bufferOnly: b.bufferOnly,
          };
        }),
        priorityCleaningNeeded,
        priorityCleaningInfo,
      },
      error: null,
      success: true,
    };
  }

  /**
   * Recalculate and sync stock conflict flags for a specific order.
   * Checks ALL items in the order for availability conflicts.
   *
   * @param orderId - The order to validate
   */
  async validateOrderStockConflicts(orderId: string): Promise<RepositoryResult<boolean>> {
    // 1. Fetch the order with its items
    const orderRes = await this.findById(orderId);
    if (!orderRes.success || !orderRes.data) return { data: false, error: orderRes.error, success: false };
    const order = orderRes.data;

    // Only active orders can have conflicts
    const activeStatuses = ['pending', 'confirmed', 'scheduled', 'ongoing', 'in_use', 'late_return', 'partial', 'flagged', 'returned'];
    if (!activeStatuses.includes(order.status)) {
      if (order.has_stock_conflict) {
        await this.client.from(this.tableName).update({ has_stock_conflict: false, conflict_details: [] }).eq('id', orderId);
      }
      return { data: false, error: null, success: true };
    }

    const conflicts: any[] = [];
    let hasConflict = false;

    // 2. Check each item in the order
    for (const item of order.items || []) {
      if (!item.product_id) continue;
      
      const availRes = await this.checkAvailability(
        item.product_id, 
        order.start_date, 
        order.end_date, 
        order.branch_id, 
        orderId // Exclude self from the count
      );

      if (availRes.success && availRes.data) {
        const available = availRes.data.availableWithPriority; // Be generous: if priority cleaning helps, it's not a hard conflict yet
        if (available < item.quantity) {
          hasConflict = true;
          conflicts.push({
            productId: item.product_id,
            productName: (item as any).product?.name || 'Unknown Product',
            requested: item.quantity,
            available: available,
            shortfall: item.quantity - available
          });
        }
      }
    }

    // 3. Update order flag and details
    const { error: updateError } = await this.client
      .from(this.tableName)
      .update({ 
        has_stock_conflict: hasConflict,
        conflict_details: conflicts
      })
      .eq('id', orderId);

    if (updateError) {
      return { data: hasConflict, error: updateError, success: false };
    }

    return { data: hasConflict, error: null, success: true };
  }

  /**
   * Proactively sync conflicts for ALL orders containing a specific product.
   * Typically called when product quantity is reduced (damage write-off).
   *
   * @param productId - The product whose changes might cause conflicts
   */
  async syncProductConflicts(productId: string): Promise<void> {
    const todayStr = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Kolkata' }).format(new Date());
    
    // Find all future active orders containing this product
    const { data: orderItems, error } = await this.client
      .from(this.orderItemsTable)
      .select('order_id, orders!inner(id, status, end_date)')
      .eq('product_id', productId)
      .in('orders.status', ['pending', 'confirmed', 'scheduled', 'ongoing', 'in_use', 'late_return', 'partial', 'flagged', 'returned'])
      .gte('orders.end_date', todayStr);

    if (error || !orderItems) return;

    // Deduplicate order IDs
    const orderIds = Array.from(new Set(orderItems.map(item => item.order_id)));

    // Run validation for each order
    for (const id of orderIds) {
      await this.validateOrderStockConflicts(id);
    }
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
    
    // Handle Supabase join ambiguity (could be object or array)
    const categoryData = productResponse.data?.category;
    const category = Array.isArray(categoryData) ? categoryData[0] : categoryData;
    const categoryHasBuffer = category?.has_buffer ?? true;
    
    const effectiveBuffer = categoryHasBuffer ? BUFFER_MS : 0;

    // Fetch all active bookings that overlap with the view range
    const ordersResponse = await this.client
      .from('order_items')
      .select('quantity, returned_quantity, order_id, orders!inner(id, start_date, end_date, status, customer_id, customer:customer_id(name))')
      .eq('product_id', productId)
      .in('orders.status', ['pending', 'confirmed', 'scheduled', 'ongoing', 'in_use', 'late_return', 'partial', 'flagged', 'returned']);

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
      const bufferedStart = new Date(bookingStart.getTime() - effectiveBuffer);
      const bufferedEnd = new Date(bookingEnd.getTime() + effectiveBuffer);
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
   * Find all active orders containing a specific product.
   *
   * Returns orders sorted by end_date ascending (chronological return order).
   * Uses the same active status list as checkAvailability() for consistency.
   *
   * @param productId - The product to search for
   * @param branchId  - Optional branch filter
   */

  /**
   * Get a product's total stock quantity.
   * Used by the priority cleaning recalculation to determine if buffer conflicts
   * actually exceed available stock.
   */
  async getProductTotalQuantity(productId: string): Promise<number> {
    const response = await this.client
      .from('products')
      .select('quantity')
      .eq('id', productId)
      .single();
    return response.data?.quantity || 0;
  }

  async findActiveOrdersForProduct(
    productId: string,
    branchId?: string,
  ): Promise<RepositoryResult<{ 
    orderId: string; 
    startDate: string; 
    endDate: string; 
    quantity: number;
    branchId: string;
    storeId: string;
    status: string;
  }[]>> {
    let query = this.client
      .from('order_items')
      .select('quantity, returned_quantity, order_id, orders!inner(id, start_date, end_date, status, branch_id, store_id)')
      .eq('product_id', productId)
      .in('orders.status', ['pending', 'confirmed', 'scheduled', 'ongoing', 'in_use', 'late_return', 'partial', 'flagged', 'returned']);

    const response = await query;

    if (response.error) {
      return this.handleResponse<any>(response);
    }

    let results = (response.data || []).map((item: any) => {
      const order = Array.isArray(item.orders) ? item.orders[0] : item.orders;
      const unreturned = item.quantity - (item.returned_quantity || 0);
      return {
        orderId: order.id,
        startDate: order.start_date,
        endDate: order.end_date,
        quantity: unreturned,
        branchId: order.branch_id,
        storeId: order.store_id,
        status: order.status
      };
    }).filter((r: any) => {
      // Include if either:
      // 1. Item is still with the customer (quantity > 0)
      // 2. Order is in a status where items might be in the cleaning room
      return r.quantity > 0 || ['returned', 'flagged', 'partial', 'late_return'].includes(r.status);
    });

    // Filter by branch if specified
    if (branchId) {
      results = results.filter((r: any) => r.branchId === branchId);
    }

    // Sort by end_date ascending
    results.sort((a: any, b: any) => new Date(a.endDate).getTime() - new Date(b.endDate).getTime());

    return {
      data: results,
      error: null,
      success: true,
    };
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
      if ((params.status as string) === 'action_needed') {
        // Virtual status: scheduled orders whose pickup date has passed
        const todayStr = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Kolkata' }).format(new Date());
        query = query.eq('status', 'scheduled').lte('start_date', todayStr);
      } else if ((params.status as string) === 'priority_cleaning') {
        // Virtual status: active orders that need priority cleaning
        query = query.eq('has_priority_cleaning', true)
          .not('status', 'in', '(completed,cancelled)');
      } else if ((params.status as string) === 'revenue_due') {
        // Virtual status: returned/partial/flagged but not fully paid
        query = query.in('status', ['returned', 'partial', 'flagged', 'late_return'])
          .neq('payment_status', 'paid');
      } else if ((params.status as string) === 'pending') {
        // Virtual status: draft/enquiry OR scheduled orders whose pickup date has passed/today
        const todayStr = new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Kolkata' }).format(new Date());
        query = query.or(`status.eq.pending,and(status.eq.scheduled,start_date.lte.${todayStr})`);
      } else if ((params.status as string) === 'partial') {
        // Virtual status: orders with outstanding balance
        query = query.or('payment_status.eq.partial,and(payment_status.eq.pending,amount_paid.gt.0)');
      } else if (Array.isArray(params.status)) {
        query = query.in('status', params.status);
      } else {
        query = query.eq('status', params.status);
      }
    }

    if (params?.exclude_status) {
      if (Array.isArray(params.exclude_status)) {
        query = query.not('status', 'in', `(${params.exclude_status.join(',')})`);
      } else {
        query = query.neq('status', params.exclude_status);
      }
    }

    if (params?.has_damage_charges) {
      query = query.gt('damage_charges_total', 0);
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
      const dateCol = params?.date_field || 'created_at';
      const isDateOnly = dateCol === 'start_date' || dateCol === 'end_date';
      if (params?.date_filter === 'custom' || (!params?.date_filter && (params?.date_from || params?.date_to))) {
        if (params?.date_from) query = query.gte(dateCol, params.date_from);
        if (params?.date_to) query = query.lte(dateCol, params.date_to);
      } else if (params?.date_filter) {
        const getISTISO = (date: Date) => {
          return new Intl.DateTimeFormat('en-CA', {
            timeZone: 'Asia/Kolkata',
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
          }).format(date);
        };

        switch (params.date_filter) {
          case 'today': {
            const todayStr = getISTISO(new Date());
            if (isDateOnly) {
              query = query.gte(dateCol, todayStr).lte(dateCol, todayStr);
            } else {
              query = query.gte(dateCol, `${todayStr}T00:00:00+05:30`).lte(dateCol, `${todayStr}T23:59:59+05:30`);
            }
            break;
          }
          case 'yesterday': {
            const yesterday = new Date(new Date().getTime() - 24 * 60 * 60 * 1000);
            const yStr = getISTISO(yesterday);
            if (isDateOnly) {
              query = query.gte(dateCol, yStr).lte(dateCol, yStr);
            } else {
              query = query.gte(dateCol, `${yStr}T00:00:00+05:30`).lte(dateCol, `${yStr}T23:59:59+05:30`);
            }
            break;
          }
          case 'this_week': {
            const now = new Date();
            const day = now.getDay();
            const diff = now.getDate() - day + (day === 0 ? -6 : 1); // Monday start
            const monday = new Date(now.setDate(diff));
            const monStr = getISTISO(monday);
            if (isDateOnly) {
              query = query.gte(dateCol, monStr);
            } else {
              query = query.gte(dateCol, `${monStr}T00:00:00+05:30`);
            }
            break;
          }
          case 'this_month': {
            const now = new Date();
            const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
            const fomStr = getISTISO(monthStart);
            if (isDateOnly) {
              query = query.gte(dateCol, fomStr);
            } else {
              query = query.gte(dateCol, `${fomStr}T00:00:00+05:30`);
            }
            break;
          }
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

    // Fetch existing order items to check for partial returns
    const { data: existingItems } = await this.client
      .from(this.orderItemsTable)
      .select('id, quantity, returned_quantity')
      .eq('order_id', orderId);

    // 1. First, update all order items with their condition and damage info
    // This must happen before recalculating order totals
    for (const item of returnData.items) {
      // Get existing order item to prevent double-counting inventory on partial returns
      const { data: orderItem } = await this.client
        .from(this.orderItemsTable)
        .select('returned_quantity, product_id, orders(branch_id)')
        .eq('id', item.item_id)
        .single();
        
      const oldReturnedQuantity = orderItem?.returned_quantity || 0;
      const quantityToIncrement = Math.max(0, (item.returned_quantity || 0) - oldReturnedQuantity);

      await this.client
        .from(this.orderItemsTable)
        .update({
          is_returned: true,
          returned_at: new Date().toISOString(),
          returned_quantity: item.returned_quantity,
          condition_rating: item.condition_rating,
          damage_description: item.damage_description || null,
          damage_charges: item.damage_charges || 0,
          damaged_quantity: item.damaged_quantity || 0,
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

    // 2. Now recalculate totals from source of truth
    const { data: allItems } = await this.client
      .from(this.orderItemsTable)
      .select('damage_charges, condition_rating, quantity, returned_quantity')
      .eq('order_id', orderId);

    const totalDamageCharges = allItems?.reduce((sum, i) => sum + (i.damage_charges || 0), 0) || 0;
    const hasDamage = allItems?.some(i => i.condition_rating === 'damaged') || false;
    const hasMissing = allItems?.some(i => (i.returned_quantity || 0) < i.quantity) || false;

    if (hasDamage) {
      newStatus = 'flagged';
    } else if (hasMissing) {
      newStatus = 'partial';
    }

    // 3. Fetch current order to get the clean base (subtotal + gst)
    const { data: currentOrder } = await this.client
      .from(this.tableName)
      .select('subtotal, gst_amount, amount_paid')
      .eq('id', orderId)
      .single();

    const lateFee = Number(returnData.late_fee || 0);
    const discount = Number(returnData.discount || 0);
    
    // Total amount = Subtotal + GST + Total Item Damage + Late Fee - Discount
    const newTotalAmount = Math.max(0, 
      Number(currentOrder?.subtotal || 0) + 
      Number(currentOrder?.gst_amount || 0) + 
      lateFee + 
      totalDamageCharges - 
      discount
    );
    
    // Update payment status if the new total changed and is not fully paid anymore
    let paymentStatus = undefined;
    const amountPaid = Number(currentOrder?.amount_paid || 0);
    if (newTotalAmount > amountPaid) {
       paymentStatus = amountPaid > 0 ? 'partial' : 'pending';
    } else {
       paymentStatus = 'paid';
    }

    // 4. Update order status and totals
    const orderResponse = await this.client
      .from(this.tableName)
      .update({
        status: newStatus,
        total_amount: newTotalAmount,
        late_fee: lateFee,
        discount: discount,
        damage_charges_total: totalDamageCharges,
        payment_status: paymentStatus
      })
      .eq('id', orderId)
      .select()
      .single();

    if (orderResponse.error) {
      return this.handleResponse<OrderWithRelations>(orderResponse);
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
   * Update damage details for a specific order item incrementally.
   */
  async updateOrderItemDamage(itemId: string, data: {
    condition_rating: ConditionRating;
    damage_description: string | null;
    damage_charges: number;
    damaged_quantity: number;
  }): Promise<RepositoryResult<OrderItem>> {
    // 1. Update the order item
    const itemResponse = await this.client
      .from(this.orderItemsTable)
      .update({
        condition_rating: data.condition_rating,
        damage_description: data.damage_description,
        damage_charges: data.damage_charges,
        damaged_quantity: data.damaged_quantity,
      })
      .eq('id', itemId)
      .select('*, order_id')
      .single();

    if (itemResponse.error) {
      return this.handleResponse<OrderItem>(itemResponse);
    }

    const orderId = itemResponse.data.order_id;

    // 2. Recalculate order total damage
    const { data: allItems } = await this.client
      .from(this.orderItemsTable)
      .select('damage_charges')
      .eq('order_id', orderId);

    const totalDamageCharges = allItems?.reduce((sum, item) => sum + (item.damage_charges || 0), 0) || 0;

    // 3. Fetch current order to recalculate total_amount
    const { data: order } = await this.client
      .from(this.tableName)
      .select('subtotal, gst_amount, discount, late_fee, amount_paid')
      .eq('id', orderId)
      .single();

    if (order) {
      const newTotalAmount = Math.max(0, 
        Number(order.subtotal || 0) + 
        Number(order.gst_amount || 0) + 
        Number(order.late_fee || 0) + 
        totalDamageCharges - 
        Number(order.discount || 0)
      );

      const amountPaid = Number(order.amount_paid || 0);
      const paymentStatus = amountPaid >= newTotalAmount ? 'paid' : amountPaid > 0 ? 'partial' : 'pending';

      // 4. Update the order with new totals
      await this.client
        .from(this.tableName)
        .update({ 
          damage_charges_total: totalDamageCharges,
          total_amount: newTotalAmount,
          payment_status: paymentStatus
        })
        .eq('id', orderId);
    }

    return this.handleResponse<OrderItem>(itemResponse);
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

  /**
   * Count orders that need action: status = 'scheduled' AND start_date <= today.
   * This is a lightweight query used for the filter badge count.
   * It only respects branch_id filter, ignoring all other search params.
   */
  async countActionNeeded(branchId?: string): Promise<RepositoryResult<number>> {
    const todayStr = new Date().toISOString().split('T')[0];

    let query = this.client
      .from(this.tableName)
      .select('*', { count: 'exact', head: true })
      .or(`status.eq.pending,and(status.eq.scheduled,start_date.lte.${todayStr})`);

    if (branchId) {
      query = query.eq('branch_id', branchId);
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
   * Count orders with stock conflicts.
   * This is a lightweight query used for the filter badge count.
   */
  async countConflict(branchId?: string): Promise<RepositoryResult<number>> {
    let query = this.client
      .from(this.tableName)
      .select('*', { count: 'exact', head: true })
      .eq('has_stock_conflict', true)
      .not('status', 'in', '(completed,cancelled)');

    if (branchId) {
      query = query.eq('branch_id', branchId);
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
   * Sync an order's has_priority_cleaning flag based on its cleaning records.
   * An order is marked as "Priority Cleaning" if ANY of its cleaning records
   * are marked as URGENT and are not yet completed.
   */
  async syncOrderPriorityFlag(orderId: string): Promise<void> {
    // 1. Get current order status
    const { data: order } = await this.client
      .from(this.tableName)
      .select('status')
      .eq('id', orderId)
      .single();

    // 2. If order is terminal (Completed/Cancelled), always clear the flag
    if (order?.status === 'completed' || order?.status === 'cancelled') {
      await this.client
        .from(this.tableName)
        .update({ has_priority_cleaning: false })
        .eq('id', orderId);
      return;
    }

    // 3. Otherwise, check cleaning records as before
    const { data: cleaningRecords } = await this.client
      .from('cleaning_records')
      .select('priority, status')
      .eq('order_id', orderId);

    if (!cleaningRecords) return;

    const hasUrgentCleaning = cleaningRecords.some(
      record => record.priority === 'urgent' && record.status !== 'completed'
    );

    await this.client
      .from(this.tableName)
      .update({ has_priority_cleaning: hasUrgentCleaning })
      .eq('id', orderId);
  }
}

// Singleton instance
export const orderRepository = new OrderRepository();
