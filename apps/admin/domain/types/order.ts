/**
 * Order Domain Types
 *
 * Type definitions for the order domain.
 *
 * @module domain/types/order
 */

// Order Status Enum
export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  SCHEDULED = 'scheduled',
  DELIVERED = 'delivered',
  IN_USE = 'in_use',
  ONGOING = 'ongoing',
  PARTIAL = 'partial',
  RETURNED = 'returned',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  FLAGGED = 'flagged',
  LATE_RETURN = 'late_return',
}

// Payment Status Enum
export enum PaymentStatus {
  PENDING = 'pending',
  PARTIAL = 'partial',
  PAID = 'paid',
}

// Payment Method Enum
export enum PaymentMethod {
  CASH = 'cash',
  UPI = 'upi',
  BANK_TRANSFER = 'bank_transfer',
  CARD = 'card',
  OTHER = 'other',
}

// Condition Rating Enum
export enum ConditionRating {
  EXCELLENT = 'excellent',
  GOOD = 'good',
  FAIR = 'fair',
  DAMAGED = 'damaged',
}

// Delivery Method Enum
export enum DeliveryMethod {
  PICKUP = 'pickup',
  DELIVERY = 'delivery',
}

// Order Item Entity
export interface OrderItem {
  readonly id: string;
  readonly order_id: string;
  readonly product_id: string;
  quantity: number;
  price_per_day: number;
  total_price: number;
  subtotal: number;
  discount: number;
  discount_type: 'flat' | 'percent';
  gst_percentage: number;
  base_amount: number;
  gst_amount: number;
  condition_rating?: ConditionRating;
  damage_description?: string;
  damage_charges?: number;
  is_returned?: boolean;
  returned_at?: string;
  returned_quantity?: number;
  readonly created_at: string;
  // Relation
  product?: {
    id: string;
    name: string;
    images?: Array<{
      url: string;
      alt_text?: string;
      is_primary: boolean;
      sort_order: number;
    }>;
  };
}

// Order Entity
export interface Order {
  readonly id: string;
  readonly store_id: string;
  readonly customer_id: string;
  readonly branch_id: string;
  status: OrderStatus;
  start_date: string;
  end_date: string;
  event_date: string;
  total_amount: number;
  subtotal: number;
  gst_amount: number;
  advance_amount: number;
  advance_collected?: boolean;
  advance_payment_method?: PaymentMethod;
  advance_collected_at?: string;
  amount_paid: number;
  payment_status: PaymentStatus;
  has_priority_cleaning?: boolean;
  notes: string | null;
  delivery_method?: DeliveryMethod;
  delivery_address?: string;
  pickup_address?: string;
  late_fee: number;
  discount: number;
  discount_type: 'flat' | 'percent';
  damage_charges_total: number;
  cancellation_reason?: string;
  cancelled_by?: string;
  cancelled_at?: string;

  readonly created_at: string;
  readonly updated_at?: string;
}


// Order with Relations
export interface OrderWithRelations extends Order {
  customer: {
    id: string;
    name: string;
    phone: string;
    alt_phone?: string | null;
    email: string | null;
  };
  items: OrderItem[];
  branch?: {
    id: string;
    name: string;
  };
  store?: {
    id: string;
    name: string;
    address: string | null;
    phone: string | null;
    email: string | null;
    gstin: string | null;
  };
}

// Order Status History Entity
export interface OrderStatusHistory {
  readonly id: string;
  readonly order_id: string;
  status: OrderStatus;
  changed_by: string | null;
  changed_at_branch_id: string | null;
  notes: string | null;
  readonly created_at: string;
}

// Order Create DTO
export interface CreateOrderDTO {
  customer_id: string;
  branch_id: string;
  items: {
    product_id: string;
    quantity: number;
    price_per_day: number;
  }[];
  rental_start_date: string;
  rental_end_date: string;
  event_date?: string;
  delivery_method?: DeliveryMethod;
  delivery_address?: string;
  pickup_address?: string;
  notes?: string;
  advance_amount?: number;
  advance_collected?: boolean;
  advance_payment_method?: string;
  priority_cleaning_confirmed?: boolean;
}

// Order Update DTO
export interface UpdateOrderDTO {
  status?: OrderStatus;
  start_date?: string;
  end_date?: string;
  notes?: string;
  delivery_method?: DeliveryMethod;
  delivery_address?: string;
  pickup_address?: string;
  event_date?: string;
  amount_paid?: number;
  payment_status?: PaymentStatus | string;
  advance_amount?: number;
  advance_collected?: boolean;
  advance_payment_method?: string;
  late_fee?: number;
  discount?: number;
  discount_type?: 'flat' | 'percent';
  damage_charges_total?: number;
  subtotal?: number;
  gst_amount?: number;
  total_amount?: number;
  cancellation_reason?: string;
  cancelled_by?: string;
  cancelled_at?: string;

  items?: {
    product_id: string;
    quantity: number;
    price_per_day: number;
    discount?: number;
    discount_type?: 'flat' | 'percent';
    gst_percentage?: number;
    base_amount?: number;
    gst_amount?: number;
  }[];
}

// Return Order DTO
export interface ReturnOrderDTO {
  order_id: string;
  items: {
    item_id: string;
    returned_quantity: number;
    condition_rating: ConditionRating;
    damage_description?: string;
    damage_charges?: number;
  }[];
  notes?: string;
  late_fee?: number;
  discount?: number;
}

// Order Search Parameters
export interface OrderSearchParams {
  customer_id?: string;
  branch_id?: string;
  status?: OrderStatus | OrderStatus[];
  product_id?: string;
  query?: string;
  date_filter?: 'today' | 'yesterday' | 'this_week' | 'this_month' | 'custom';
  date_field?: 'created_at' | 'start_date' | 'end_date';
  date_from?: string;
  date_to?: string;
  limit?: number;
  offset?: number;
}

// Order Validation Result
export interface OrderValidationResult {
  is_valid: boolean;
  errors: string[];
  warnings: string[];
}

// ─── Interval-Based Availability Types ──────────────────────────────────────

/** Status of a single calendar day */
export type DayAvailabilityStatus = 'available' | 'partial' | 'unavailable' | 'buffer';

/** A booking that occupies a product on a given day */
export interface DayBookingInfo {
  orderId: string;
  customerName: string;
  quantity: number;
  startDate: string;
  endDate: string;
  status: string;
  isBuffer?: boolean;
}

/** Per-day availability data for calendar rendering */
export interface DayAvailability {
  date: string;
  total: number;
  reserved: number;
  bufferReserved: number;
  available: number;
  status: DayAvailabilityStatus;
  bookings: DayBookingInfo[];
}

/** Full availability calendar response */
export interface AvailabilityCalendarResponse {
  productId: string;
  productName: string;
  totalQuantity: number;
  days: DayAvailability[];
}

/** Info about an order whose cleaning must be prioritized */
export interface PriorityCleaningInfo {
  returningOrderId: string;
  returningOrderCustomer: string;
  returningOrderEndDate: string;
  returningQuantity: number;
  productId: string;
  productName: string;
}

/** Availability check result for a single item (used in order form) */
export interface ItemAvailabilityResult {
  product_id: string;
  product_name: string;
  requested: number;
  available: number;
  availableWithPriority: number;
  isAvailable: boolean;
  peakReserved: number;
  overlappingOrders: DayBookingInfo[];
  priorityCleaningNeeded: boolean;
  priorityCleaningInfo?: PriorityCleaningInfo[];
}

/** Batch availability check response */
export interface BatchAvailabilityResponse {
  allAvailable: boolean;
  items: ItemAvailabilityResult[];
}
