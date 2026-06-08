# Mazhavil Dance Costumes - Database Schema

## Tables and Columns

### audit_logs
| Column | Description |
|--------|-------------|
| id | Primary key |
| user_id | User who performed the action |
| entity_type | Type of entity affected (e.g., 'order', 'product') |
| entity_id | ID of the affected entity |
| action | Action performed (e.g., 'create', 'update', 'delete') |
| old_values | JSON of previous state |
| new_values | JSON of new state |
| ip_address | IP address of the user |
| user_agent | Browser/user agent string |
| created_at | Timestamp of the audit log entry |

### banners
| Column | Description |
|--------|-------------|
| id | Primary key |
| store_id | Store this banner belongs to |
| title | Banner title |
| subtitle | Banner subtitle |
| description | Banner description |
| call_to_action | CTA button text |
| web_image_url | Image URL for web display |
| mobile_image_url | Image URL for mobile display |
| redirect_type | Type of redirect ('product', 'category', 'url') |
| redirect_target_id | Target entity ID for redirect |
| redirect_url | External URL for redirect |
| banner_type | Type of banner ('hero', 'promo', 'announcement') |
| position | Display position/order |
| is_active | Whether banner is currently active |
| priority | Display priority (higher = more important) |
| start_date | Campaign start date |
| end_date | Campaign end date |
| alt_text | Alt text for accessibility |
| created_by | User who created the banner |
| created_at_branch_id | Branch where banner was created |
| updated_by | User who last updated the banner |
| updated_at_branch_id | Branch where banner was last updated |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |

### branches
| Column | Description |
|--------|-------------|
| id | Primary key |
| store_id | Store this branch belongs to |
| name | Branch name |
| address | Branch physical address |
| phone | Branch contact phone |
| is_main | Whether this is the main branch |
| is_active | Whether branch is currently active |
| created_by | User who created the branch |
| created_at_branch_id | Branch where this branch was created |
| updated_by | User who last updated the branch |
| updated_at_branch_id | Branch where branch was last updated |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |

### categories
| Column | Description |
|--------|-------------|
| id | Primary key |
| name | Category name |
| slug | URL-friendly slug |
| description | Category description |
| image_url | Category image URL |
| parent_id | Parent category ID (for hierarchy) |
| store_id | Store this category belongs to |
| is_global | Whether category is available across all branches |
| is_active | Whether category is currently active |
| sort_order | Display order |
| created_by | User who created the category |
| created_at_branch_id | Branch where category was created |
| updated_by | User who last updated the category |
| updated_at_branch_id | Branch where category was last updated |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |
| deleted_at | Soft delete timestamp |
| gst_percentage | GST rate for products in this category |
| has_buffer | If TRUE, products require 1-day cleaning buffer between rentals. If FALSE, can be rented back-to-back. |

### cleaning_records
| Column | Description |
|--------|-------------|
| id | Primary key |
| product_id | Product being cleaned |
| order_id | Order the product was returned from |
| branch_id | Branch where cleaning is done |
| quantity | Quantity being cleaned |
| status | Cleaning status ('scheduled', 'pending', 'in_progress', 'completed') |
| priority | Cleaning priority ('normal', 'urgent') |
| priority_order_id | The upcoming order that needs this product urgently after cleaning |
| started_at | When cleaning started |
| completed_at | When cleaning completed |
| notes | Cleaning notes |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |
| expected_return_date | Date when the returning order ends — cleaning can begin after this date |
| store_id | Store this cleaning record belongs to — mirrors the order's store_id for consistency |

### customer_enquiries
| Column | Description |
|--------|-------------|
| id | Primary key |
| product_query | Product the customer is asking about |
| customer_name | Customer name |
| customer_phone | Customer phone number |
| notes | Enquiry notes |
| logged_by | Staff member who logged the enquiry |
| branch_id | Branch where enquiry was made |
| store_id | Store where enquiry was made |
| created_at | Creation timestamp |

### customers
| Column | Description |
|--------|-------------|
| id | Primary key |
| name | Customer name |
| email | Customer email |
| phone | Primary phone number |
| alt_phone | Alternate phone number |
| address | Customer address |
| gstin | GST identification number |
| photo_url | Customer photo URL |
| id_type | ID proof type (e.g., 'aadhaar', 'passport') |
| id_number | ID proof number |
| id_documents | JSON array of ID document URLs |
| created_by | User who created the customer record |
| created_at_branch_id | Branch where customer was created |
| updated_by | User who last updated the customer |
| updated_at_branch_id | Branch where customer was last updated |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |

### damage_assessments
| Column | Description |
|--------|-------------|
| id | Primary key |
| order_id | Order the damage occurred in |
| order_item_id | Specific order item that was damaged |
| product_id | Product that was damaged |
| branch_id | Branch where damage was assessed |
| unit_index | Index of the damaged unit (for quantity > 1) |
| decision | Assessment decision ('no_damage', 'minor', 'major', 'replace') |
| notes | Assessment notes |
| assessed_by | Staff member who did the assessment |
| assessed_at | When assessment was done |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |

### order_items
| Column | Description |
|--------|-------------|
| id | Primary key |
| order_id | Parent order ID |
| product_id | Product ID |
| quantity | Quantity rented |
| price_per_day | Daily rental rate |
| subtotal | Subtotal before GST |
| condition_rating | Condition on return ('excellent', 'good', 'fair', 'damaged') |
| damage_description | Description of any damage |
| damage_charges | Charges for damage |
| is_returned | Whether item has been returned |
| returned_at | Return timestamp |
| returned_quantity | Quantity actually returned |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |
| discount | Discount amount |
| discount_type | Discount type ('flat', 'percent') |
| gst_percentage | GST rate for this item |
| base_amount | Amount before GST |
| gst_amount | GST amount |
| damaged_quantity | Quantity that was damaged |

### order_reservations
| Column | Description |
|--------|-------------|
| id | Primary key |
| order_id | Parent order ID |
| product_id | Product being reserved |
| branch_id | Branch where reservation is made |
| quantity | Quantity reserved |
| reserved_from | Reservation start date |
| reserved_to | Reservation end date |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |

### order_status_history
| Column | Description |
|--------|-------------|
| id | Primary key |
| order_id | Order ID |
| status | Status value |
| notes | Status change notes |
| changed_by | User who changed the status |
| created_at | Timestamp of status change |

### orders
| Column | Description |
|--------|-------------|
| id | Primary key |
| store_id | Store this order belongs to |
| branch_id | Branch this order is associated with |
| customer_id | Customer ID |
| pickup_branch_id | Branch where items are picked up from |
| status | Order status ('pending', 'confirmed', 'scheduled', 'delivered', 'in_use', 'ongoing', 'partial', 'returned', 'completed', 'cancelled', 'flagged') |
| start_date | Rental start date |
| end_date | Rental end date |
| event_date | Event date |
| pickup_time | Time when customer picks up the items |
| return_time | Time when customer returns the items |
| subtotal | Subtotal before GST |
| gst_amount | GST amount |
| gst_percentage | GST rate applied |
| total_amount | Total amount including GST |
| amount_paid | Amount paid so far |
| payment_status | Payment status ('pending', 'partial', 'paid') |
| advance_amount | Advance/deposit amount |
| advance_collected | Whether advance has been collected |
| advance_payment_method | Method used for advance payment |
| advance_collected_at | When advance was collected |
| late_fee | Late fee charges |
| discount | Discount amount |
| damage_charges_total | Total damage charges |
| delivery_method | Delivery method ('pickup', 'delivery') |
| delivery_address | Delivery address |
| pickup_address | Pickup address |
| notes | Order notes |
| created_by | User who created the order |
| created_at_branch_id | Branch where order was created |
| updated_by | User who last updated the order |
| updated_at_branch_id | Branch where order was last updated |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |
| discount_type | Discount type ('flat', 'percent') |
| cancellation_reason | Reason for cancellation |
| cancelled_by | User who cancelled the order |
| cancelled_at | Cancellation timestamp |
| has_priority_cleaning | True when another order triggered priority cleaning for this order's returned products |
| has_stock_conflict | True when total product inventory (minus other reservations) is insufficient for this order |
| conflict_details | JSON array of conflicting products: [{productId, productName, requested, available}] |
| is_late | Flag indicating if the order is late (end_date < current_date and status is ongoing/in_use/delivered) |

### payments
| Column | Description |
|--------|-------------|
| id | Primary key |
| order_id | Order this payment is for |
| payment_type | Payment type ('advance', 'partial', 'full', 'late_fee', 'damage') |
| amount | Payment amount |
| payment_mode | Payment mode ('cash', 'upi', 'card', 'bank_transfer') |
| transaction_id | Transaction ID |
| payment_date | Payment date |
| notes | Payment notes |
| created_by | User who recorded the payment |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |

### product_inventory
| Column | Description |
|--------|-------------|
| id | Primary key |
| product_id | Product ID |
| branch_id | Branch ID |
| quantity | Total quantity at branch |
| available_quantity | Quantity available for rent |
| low_stock_threshold | Threshold for low stock alert |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |

### products
| Column | Description |
|--------|-------------|
| id | Primary key |
| store_id | Store this product belongs to |
| category_id | Main category ID |
| subcategory_id | Subcategory ID |
| subvariant_id | Subvariant ID |
| branch_id | Branch where product is located |
| name | Product name |
| slug | URL-friendly slug |
| description | Product description |
| sku | Stock keeping unit |
| barcode | Product barcode |
| price_per_day | Daily rental rate |
| quantity | Total quantity |
| available_quantity | Available for rent |
| images | JSON array of image URLs |
| sizes | JSON array of available sizes |
| colors | JSON array of available colors |
| material | Material description |
| weight | Weight in grams |
| gemstones | Gemstone information |
| metal_purity | Metal purity (e.g., '18K', '22K') |
| is_active | Whether product is currently active |
| is_featured | Whether product is featured |
| track_inventory | Whether to track inventory for this product |
| low_stock_threshold | Threshold for low stock alert |
| total_rentals | Total number of rentals |
| total_revenue | Total revenue generated |
| avg_rating | Average customer rating |
| reviews_count | Number of reviews |
| last_rented_at | Last rental date |
| created_by | User who created the product |
| created_at_branch_id | Branch where product was created |
| updated_by | User who last updated the product |
| updated_at_branch_id | Branch where product was last updated |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |
| purchase_price | Purchase cost |
| deleted_at | Soft delete timestamp |

### settings
| Column | Description |
|--------|-------------|
| id | Primary key |
| store_id | Store this setting belongs to |
| key | Setting key |
| value | Setting value |
| updated_by | User who last updated the setting |
| updated_at | Last update timestamp |

### staff
| Column | Description |
|--------|-------------|
| id | Primary key |
| store_id | Store this staff member belongs to |
| branch_id | Branch this staff member is assigned to |
| user_id | Auth user ID |
| name | Staff member name |
| email | Staff email |
| phone | Staff phone |
| role | Staff role ('super_admin', 'admin', 'manager', 'staff') |
| is_active | Whether staff member is active |
| created_by | User who created this staff record |
| created_at_branch_id | Branch where staff was created |
| updated_by | User who last updated the staff |
| updated_at_branch_id | Branch where staff was last updated |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |

### stores
| Column | Description |
|--------|-------------|
| id | Primary key |
| name | Store name |
| slug | URL-friendly slug |
| email | Store email |
| phone | Store phone |
| address | Store address |
| logo_url | Store logo URL |
| subscription_status | Subscription status ('active', 'trial', 'expired') |
| is_active | Whether store is active |
| gstin | Store GST identification number |
| created_at | Creation timestamp |
| updated_at | Last update timestamp |

## Database Functions (RPCs)

### calculate_late_flag
Trigger function that automatically sets `is_late` flag based on:
- `end_date` is in the past
- Status is one of: ongoing, in_use, delivered

### get_dead_stock
Returns products that haven't been rented in 90+ days.

### get_operational_dashboard_metrics
Returns operational metrics for dashboard:
- Today's bookings
- Today's delivery total/done
- Today's return total/done
- Prepare deliveries (next 5 days)
- Pending deliveries
- Pending returns
- Revenue due
- Priority cleaning records

### get_user_branch_id
Returns the branch ID of the authenticated staff member.

### get_user_role
Returns the role of the authenticated staff member.

### is_admin
Returns TRUE if authenticated user is super_admin or admin.

### is_manager_or_admin
Returns TRUE if authenticated user is super_admin, admin, or manager.

### is_super_admin
Returns TRUE if authenticated user is super_admin.

## Triggers

### update_branch_inventory_updated_at
Automatically updates `updated_at` timestamp on branch_inventory changes.

### update_updated_at_column
Automatically updates `updated_at` timestamp on table changes.

### trigger_update_late_flag
Automatically calculates and sets `is_late` flag on orders table when `end_date` or `status` changes.
