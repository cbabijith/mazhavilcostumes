/**
 * Report Domain Types
 *
 * Type definitions for the reports module.
 *
 * @module domain/types/report
 */

export type ReportType =
  | 'day-wise-booking'    // R1
  | 'due-overdue'         // R2
  | 'revenue'             // R3
  | 'top-costumes'        // R4
  | 'top-customers'       // R5
  | 'rental-frequency'    // R6
  | 'roi'                 // R7
  | 'dead-stock'          // R8
  | 'sales-by-staff'      // R9
  | 'inventory-revenue'   // R10
  | 'enquiry-log'         // R11
  | 'gst-filing'          // R12
  | 'todays-revenue';     // R13 — staff/manager only

export type StaffRole = 'super_admin' | 'admin' | 'manager' | 'staff';

export interface ReportMeta {
  id: ReportType;
  name: string;
  description: string;
  category: 'booking' | 'due' | 'sale' | 'inventory' | 'reminder';
  icon: string;
  /** Roles that can access this report. If omitted, all roles can access. */
  roles?: StaffRole[];
}

export const REPORT_LIST: ReportMeta[] = [
  { id: 'day-wise-booking', name: 'Day-wise Booking', description: 'Daily pickups and deliveries schedule', category: 'booking', icon: 'CalendarDays' },
  { id: 'due-overdue', name: 'Due / Overdue Report', description: 'Overdue returns as of today', category: 'due', icon: 'AlertTriangle' },
  { id: 'todays-revenue', name: "Today's Revenue", description: "Today's revenue snapshot", category: 'sale', icon: 'TrendingUp', roles: ['manager', 'staff'] },
  { id: 'top-costumes', name: 'Top Costumes', description: 'Most rented or highest earning', category: 'sale', icon: 'Trophy' },
  { id: 'dead-stock', name: 'Dead Stock / No-Sale', description: 'Products with zero rentals', category: 'sale', icon: 'PackageX' },
  { id: 'enquiry-log', name: 'Customer Enquiry Log', description: 'Manual enquiry entries', category: 'reminder', icon: 'MessageSquare' },
  { id: 'revenue', name: 'Revenue Report', description: 'Revenue by status and period', category: 'sale', icon: 'TrendingUp', roles: ['super_admin', 'admin'] },
  { id: 'top-customers', name: 'Top Customers', description: 'Customers ranked by spend', category: 'sale', icon: 'Users', roles: ['super_admin', 'admin'] },
  { id: 'rental-frequency', name: 'Rental Frequency', description: 'Products by rental count', category: 'sale', icon: 'BarChart3', roles: ['super_admin', 'admin'] },
  { id: 'roi', name: 'ROI / Profit per Costume', description: 'Return on investment per product', category: 'sale', icon: 'PiggyBank', roles: ['super_admin', 'admin'] },
  { id: 'sales-by-staff', name: 'Sales by Staff', description: 'Staff ranked by order revenue', category: 'sale', icon: 'UserCheck', roles: ['super_admin', 'admin'] },
  { id: 'inventory-revenue', name: 'Inventory + Revenue', description: 'Stock levels and lifetime revenue', category: 'inventory', icon: 'Boxes', roles: ['super_admin', 'admin'] },
  { id: 'gst-filing', name: 'GST Filing Report', description: 'GSTR-1 friendly tax breakdown', category: 'sale', icon: 'FileText', roles: ['super_admin', 'admin'] },
];

/** R1: Day-wise booking row */
export interface DayWiseBookingRow {
  order_id: string;
  customer_name: string;
  customer_phone: string;
  product_names: string;
  start_date: string;
  end_date: string;
  total_amount: number;
  status: string;
}

/** R2: Due/Overdue row */
export interface DueOverdueRow {
  order_id: string;
  customer_name: string;
  customer_phone: string;
  product_names: string;
  end_date: string;
  days_overdue: number;
  total_amount: number;
  amount_paid: number;
  balance: number;
  status: string;
}

/** R3: Revenue row (Summary) */
export interface RevenueRow {
  period: string;
  booking_sales: number;      // Total value of orders booked (Sales)
  cash_collection: number;    // Actual cash collected (Cash Flow)
  amount_collection: number;  // Unified collection (renamed label)
  net_revenue: number;        // Revenue excluding GST
  gst_collected: number;      // GST portion
  completed_revenue: number;
  ongoing_revenue: number;
  scheduled_revenue: number;
  cancelled_revenue: number;
  refund_amount: number;
  cash_revenue: number;
  upi_revenue: number;
  gpay_revenue: number;
  bank_transfer_revenue: number;
  other_revenue: number;
  total_revenue: number;      // Gross collected
  order_count: number;
}

/** R3: Revenue detail row (Order-wise) */
export interface RevenueDetailRow {
  date: string;
  order_id: string;
  customer_name: string;
  payment_mode: string;
  payment_type: string;
  amount: number;
  status: string;
}

/** R3: Revenue report data structure */
export interface RevenueReportData {
  summary: RevenueRow[];
  details: RevenueDetailRow[];
  total_details_count: number;
  total_booking_sales: number;
  total_received: number;
  total_cash_collection: number;
  total_amount_collection: number;
  total_net_revenue: number;
  total_gst_collected: number;
  total_cash: number;
  total_upi: number;
  total_gpay: number;
  total_bank_transfer: number;
  total_collected: number;
  total_refunded: number;
  cancelled_total: number;
  refund_due: number;
  total_damage_charges: number;
  total_late_fees: number;
}

/** R4: Top costumes row */
export interface TopCostumeRow {
  product_id: string;
  product_name: string;
  category_name: string;
  rental_count: number;
  revenue: number;
  avg_rental_days: number;
}

/** R5: Top customers row */
export interface TopCustomerRow {
  customer_id: string;
  customer_name: string;
  customer_phone: string;
  order_count: number;
  total_spent: number;
  last_order_date: string;
}

/** R6: Rental frequency row */
export interface RentalFrequencyRow {
  product_id: string;
  product_name: string;
  category_name: string;
  rental_count: number;
  last_rented: string;
}

/** R7: ROI row */
export interface ROIRow {
  product_id: string;
  product_name: string;
  purchase_price: number;
  total_revenue: number;
  profit: number;
  roi_percentage: number;
  rental_count: number;
}

/** R8: Dead stock row */
export interface DeadStockRow {
  product_id: string;
  product_name: string;
  category_name: string;
  price_per_day: number;
  quantity: number;
  days_since_last_rental: number | null;
  created_at: string;
}

/** R9: Sales by staff row */
export interface SalesByStaffRow {
  staff_id: string;
  staff_name: string;
  staff_email: string;
  order_count: number;
  cancelled_order_count: number;
  total_revenue: number;
  avg_order_value: number;
  total_item_discount: number;
  total_order_discount: number;
  total_discount: number;
  discount_percentage: number;
}

/** R10: Inventory + Revenue row */
export interface InventoryRevenueRow {
  product_id: string;
  product_name: string;
  category_name: string;
  quantity: number;
  available_quantity: number;
  price_per_day: number;
  lifetime_revenue: number;
  rental_count: number;
}

/** R11: Enquiry log */
export interface CustomerEnquiry {
  id: string;
  product_query: string;
  customer_name: string | null;
  customer_phone: string | null;
  notes: string | null;
  logged_by: string | null;
  branch_id: string | null;
  store_id: string | null;
  created_at: string;
  staff?: { name: string; email: string };
}

/** R12: GST Filing report */
export interface GSTFilingRow {
  slab: number;
  taxable_value: number;
  cgst: number;
  sgst: number;
  total_gst: number;
}

export interface GSTFilingReport {
  summary: GSTFilingRow[];
  total_taxable: number;
  total_cgst: number;
  total_sgst: number;
  total_gst: number;
  period: string;
}

export interface CreateEnquiryDTO {
  product_query: string;
  customer_name?: string;
  customer_phone?: string;
  notes?: string;
}

/** Report filter params */
export interface ReportFilters {
  date?: string;
  from_date?: string;
  to_date?: string;
  period?: 'day' | 'week' | 'month' | 'year' | 'custom';
  status?: string[];
  rank_by?: 'count' | 'revenue';
  limit?: number;
  page?: number;
  payment_mode?: string;
}
