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
  | 'gst-filing';         // R12

export interface ReportMeta {
  id: ReportType;
  name: string;
  description: string;
  category: 'booking' | 'due' | 'sale' | 'inventory' | 'reminder';
  icon: string;
}

export const REPORT_LIST: ReportMeta[] = [
  { id: 'day-wise-booking', name: 'Day-wise Booking', description: 'Daily pickups and deliveries schedule', category: 'booking', icon: 'CalendarDays' },
  { id: 'due-overdue', name: 'Due / Overdue Report', description: 'Overdue returns as of today', category: 'due', icon: 'AlertTriangle' },
  { id: 'revenue', name: 'Revenue Report', description: 'Revenue by status and period', category: 'sale', icon: 'TrendingUp' },
  { id: 'top-costumes', name: 'Top Costumes', description: 'Most rented or highest earning', category: 'sale', icon: 'Trophy' },
  { id: 'top-customers', name: 'Top Customers', description: 'Customers ranked by spend', category: 'sale', icon: 'Users' },
  { id: 'rental-frequency', name: 'Rental Frequency', description: 'Products by rental count', category: 'sale', icon: 'BarChart3' },
  { id: 'roi', name: 'ROI / Profit per Costume', description: 'Return on investment per product', category: 'sale', icon: 'PiggyBank' },
  { id: 'dead-stock', name: 'Dead Stock / No-Sale', description: 'Products with zero rentals', category: 'sale', icon: 'PackageX' },
  { id: 'sales-by-staff', name: 'Sales by Staff', description: 'Staff ranked by order revenue', category: 'sale', icon: 'UserCheck' },
  { id: 'inventory-revenue', name: 'Inventory + Revenue', description: 'Stock levels and lifetime revenue', category: 'inventory', icon: 'Boxes' },
  { id: 'enquiry-log', name: 'Customer Enquiry Log', description: 'Manual enquiry entries', category: 'reminder', icon: 'MessageSquare' },
  { id: 'gst-filing', name: 'GST Filing Report', description: 'GSTR-1 friendly tax breakdown', category: 'sale', icon: 'FileText' },
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

/** R3: Revenue row */
export interface RevenueRow {
  period: string;
  completed_revenue: number;
  ongoing_revenue: number;
  scheduled_revenue: number;
  total_revenue: number;
  order_count: number;
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
}
