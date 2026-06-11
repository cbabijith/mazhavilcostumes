# Mazhavil Dance Costumes - API Documentation

**Version**: 1.2.0  
**Base URL**: `https://mazhavilcostumes-admin.vercel.app/api`  
**Local URL**: `http://localhost:3001/api`  
**Authentication**: Bearer Token (required for all endpoints)

---

## Table of Contents

1. [Authentication](#authentication)
2. [Products API](#products-api)
3. [Categories API](#categories-api)
4. [Orders API](#orders-api)
5. [Error Codes](#error-codes)
6. [Rate Limiting](#rate-limiting)

---

## Authentication

All API endpoints require authentication via Bearer token.

### Login

**Endpoint**: `POST /api/auth/login`

**Request Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "user-uuid",
    "email": "user@example.com",
    "role": "super_admin",
    "store_id": "store-uuid",
    "branch_id": "branch-uuid",
    "staff_id": "staff-uuid",
    "access_token": "eyJhbGciOiJFUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJFUzI1NiIs..."
  }
}
```

**Error Response** (401 Unauthorized):
```json
{
  "success": false,
  "error": "Invalid credentials"
}
```

### Using the Token

Include the access token in the Authorization header for all subsequent requests:

```
Authorization: Bearer eyJhbGciOiJFUzI1NiIs...
```

### User Roles

| Role | Permissions |
|------|-------------|
| `super_admin` | Full access to all resources |
| `admin` | Full access to store resources |
| `manager` | Access to products, categories, orders |
| `staff` | Limited access (orders, customers) |

---

## Products API

### List Products

**Endpoint**: `GET /api/products`

**Authentication**: Required

**Query Parameters**:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `query` | string | Search by name, SKU, barcode, slug (case-insensitive, partial match) | - |
| `category_id` | string | Filter by category UUID | - |
| `store_id` | string | Filter by store UUID | - |
| `branch_id` | string | Filter by branch UUID | - |
| `status` | string | `active` or `inactive` | - |
| `is_featured` | boolean | Filter featured products | - |
| `in_stock` | boolean | Filter in-stock products | - |
| `min_price` | number | Minimum price filter | - |
| `max_price` | number | Maximum price filter | - |
| `sort_by` | string | Sort field: `name`, `price`, `created_at`, `stock` | `name` |
| `sort_order` | string | `asc` or `desc` | `asc` |
| `page` | number | Page number | `1` |
| `limit` | number | Items per page (max 100) | `20` |

**Example Request**:
```bash
GET /api/products?limit=100&status=active
```

**Search Examples**:
```bash
# Search by name
GET /api/products?query=bharathanattyam

# Search by SKU
GET /api/products?query=BHN-36

# Search by barcode
GET /api/products?query=BHN-36/46

# Search with pagination
GET /api/products?query=red&limit=20&page=1
```

**Search Behavior**:
- Server-side search using Supabase database queries
- Case-insensitive matching
- Partial string matching (wildcards)
- Searches across: `name`, `slug`, `sku`, `barcode`
- Normalizes spaces to hyphens (e.g., "Black Red" also matches "Black-Red")
- OR logic: matches if ANY field contains the search term

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "product-uuid",
        "name": "BHN-36/46",
        "slug": "bhn-3646",
        "description": "Black/ Red",
        "sku": "Black/ Red",
        "barcode": "BHN-36/46",
        "price_per_day": 750,
        "purchase_price": 3200,
        "quantity": 1,
        "available_quantity": 1,
        "images": [],
        "sizes": [],
        "colors": [],
        "material": null,
        "weight": null,
        "gemstones": [],
        "metal_purity": null,
        "is_active": true,
        "is_featured": false,
        "track_inventory": true,
        "low_stock_threshold": 5,
        "total_rentals": 0,
        "total_revenue": 0,
        "avg_rating": 0,
        "reviews_count": 0,
        "last_rented_at": null,
        "created_by": "user-uuid",
        "created_at_branch_id": "branch-uuid",
        "updated_by": null,
        "updated_at_branch_id": null,
        "created_at": "2026-06-02T07:42:32.249534+00:00",
        "updated_at": "2026-06-04T06:16:15.869345+00:00",
        "deleted_at": null,
        "category": {
          "id": "category-uuid",
          "name": "Bharathanattyam",
          "slug": "bharathanattyam",
          "gst_percentage": 5,
          "has_buffer": true
        },
        "branch": {
          "id": "branch-uuid",
          "name": "Main Branch"
        },
        "product_inventory": [
          {
            "id": "inventory-uuid",
            "product_id": "product-uuid",
            "branch_id": "branch-uuid",
            "quantity": 1,
            "available_quantity": 1,
            "low_stock_threshold": 5,
            "branches": {
              "id": "branch-uuid",
              "name": "Main Branch"
            },
            "created_at": "2026-06-02T07:42:35.324621+00:00",
            "updated_at": "2026-06-04T06:16:15.869345+00:00"
          }
        ]
      }
    ],
    "total": 1749,
    "page": 1,
    "limit": 100,
    "total_pages": 18,
    "has_next": true,
    "has_prev": false,
    "total_stock": 7104
  }
}
```

### Get Product Count

**Endpoint**: `GET /api/products/count`

**Authentication**: Required

**Query Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| `category_id` | string | Filter by category UUID |
| `store_id` | string | Filter by store UUID |
| `branch_id` | string | Filter by branch UUID |
| `status` | string | `active` or `inactive` |
| `is_featured` | boolean | Filter featured products |
| `in_stock` | boolean | Filter in-stock products |

**Example Request**:
```bash
GET /api/products/count?status=active
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "count": 1500
  }
}
```

### Get Single Product

**Endpoint**: `GET /api/products/:id`

**Authentication**: Required

**Example Request**:
```bash
GET /api/products/product-uuid
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "product-uuid",
    "name": "BHN-36/46",
    "slug": "bhn-3646",
    "category": {
      "id": "category-uuid",
      "name": "Bharathanattyam"
    },
    "branch": {
      "id": "branch-uuid",
      "name": "Main Branch"
    }
  }
}
```

### Create Product

**Endpoint**: `POST /api/products`

**Authentication**: Required (super_admin, admin, manager)

**Request Headers**:
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Request Body**:
```json
{
  "name": "New Product",
  "slug": "new-product",
  "description": "Product description",
  "sku": "SKU-001",
  "barcode": "BAR-001",
  "price_per_day": 500,
  "purchase_price": 2000,
  "quantity": 10,
  "category_id": "category-uuid",
  "subcategory_id": null,
  "subvariant_id": null,
  "branch_id": "branch-uuid",
  "images": ["https://example.com/image.jpg"],
  "sizes": ["S", "M", "L"],
  "colors": ["Red", "Blue"],
  "material": "Cotton",
  "weight": 500,
  "is_active": true,
  "is_featured": false,
  "track_inventory": true,
  "low_stock_threshold": 5
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "id": "new-product-uuid",
    "name": "New Product",
    "slug": "new-product",
    "created_at": "2026-06-09T00:00:00Z"
  }
}
```

### Update Product

**Endpoint**: `PATCH /api/products/:id`

**Authentication**: Required (super_admin, admin, manager)

**Request Body** (all fields optional):
```json
{
  "name": "Updated Product Name",
  "price_per_day": 600,
  "is_active": false
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "product-uuid",
    "name": "Updated Product Name",
    "updated_at": "2026-06-09T00:00:00Z"
  }
}
```

### Delete Product

**Endpoint**: `DELETE /api/products/:id`

**Authentication**: Required (super_admin, admin, manager)

**Response** (200 OK):
```json
{
  "success": true,
  "data": null
}
```

### Check if Product Can Be Deleted

**Endpoint**: `GET /api/products/:id/can-delete`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "canDelete": false,
    "reason": "Product has order history",
    "relatedData": {
      "orderCount": 5
    }
  }
}
```

### Lookup Product by Barcode

**Endpoint**: `GET /api/products/by-barcode?code=BARCODE`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "product-uuid",
    "name": "Product Name",
    "barcode": "BAR-001",
    "available_quantity": 5
  }
}
```

---

## Categories API

### List All Categories

**Endpoint**: `GET /api/categories`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "category-uuid",
      "name": "Bharathanattyam",
      "slug": "bharathanattyam",
      "description": null,
      "image_url": null,
      "parent_id": null,
      "store_id": "store-uuid",
      "is_global": true,
      "is_active": true,
      "sort_order": 0,
      "gst_percentage": 5,
      "has_buffer": true,
      "created_at": "2026-06-02T07:42:15.282697+00:00",
      "updated_at": "2026-06-02T07:42:15.282697+00:00",
      "deleted_at": null
    }
  ]
}
```

### Get Single Category

**Endpoint**: `GET /api/categories/:id`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "category-uuid",
    "name": "Bharathanattyam",
    "slug": "bharathanattyam",
    "parent": {
      "id": "parent-uuid",
      "name": "Parent Category",
      "slug": "parent-category"
    },
    "level": "main",
    "path": "Bharathanattyam"
  }
}
```

### Get Category Children

**Endpoint**: `GET /api/categories/:id/children`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "subcategory-uuid",
      "name": "Subcategory Name",
      "slug": "subcategory-name",
      "parent_id": "category-uuid",
      "level": "sub"
    }
  ]
}
```

### Check if Category Can Be Deleted

**Endpoint**: `GET /api/categories/:id/can-delete`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "canDelete": false,
    "reason": "Category has products",
    "relatedData": {
      "productCount": 150,
      "childCount": 5
    }
  }
}
```

### Get Product Counts per Category

**Endpoint**: `GET /api/categories/product-counts`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "category-uuid-1": 150,
    "category-uuid-2": 75,
    "category-uuid-3": 200
  }
}
```

### Create Category

**Endpoint**: `POST /api/categories`

**Authentication**: Required (super_admin, admin, manager)

**Request Body**:
```json
{
  "name": "New Category",
  "slug": "new-category",
  "description": "Category description",
  "image_url": "https://example.com/image.jpg",
  "parent_id": null,
  "is_global": true,
  "is_active": true,
  "sort_order": 0,
  "gst_percentage": 5,
  "has_buffer": true
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "id": "new-category-uuid",
    "name": "New Category",
    "slug": "new-category",
    "created_at": "2026-06-09T00:00:00Z"
  }
}
```

### Update Category

**Endpoint**: `PATCH /api/categories/:id`

**Authentication**: Required (super_admin, admin, manager)

**Request Body** (all fields optional):
```json
{
  "name": "Updated Category Name",
  "description": "Updated description",
  "is_active": false
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "category-uuid",
    "name": "Updated Category Name",
    "updated_at": "2026-06-09T00:00:00Z"
  }
}
```

### Delete Category

**Endpoint**: `DELETE /api/categories/:id`

**Authentication**: Required (super_admin, admin, manager)

**Response** (200 OK):
```json
{
  "success": true,
  "data": null
}
```

### Reorder Categories

**Endpoint**: `POST /api/categories/reorder`

**Authentication**: Required (super_admin, admin, manager)

**Request Body**:
```json
{
  "categoryIds": ["uuid1", "uuid2", "uuid3"]
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid1",
      "sort_order": 0
    },
    {
      "id": "uuid2",
      "sort_order": 1
    },
    {
      "id": "uuid3",
      "sort_order": 2
    }
  ]
}
```

---

## Category Hierarchy

The category system supports 3 levels of hierarchy:

| Level | Description | parent_id |
|-------|-------------|-----------|
| `main` | Top-level category | `null` |
| `sub` | Child of main category | Main category UUID |
| `variant` | Child of sub category | Sub category UUID |

**Maximum depth**: 3 levels (Main → Sub → Variant)

**Example Hierarchy**:
```
Bharathanattyam (main)
  ├── Costumes (sub)
  │   ├── Red Variant (variant)
  │   └── Blue Variant (variant)
  └── Accessories (sub)
```
---

## Orders API

### List Orders

**Endpoint**: `GET /api/orders`

**Authentication**: Required

**Query Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| `query` | string | Search by customer name, phone, email, or order ID |
| `status` | string | Filter by order status: `pending`, `confirmed`, `scheduled`, `ongoing`, `completed`, `cancelled`, `flagged`, `returned`, or virtual status: `action_needed`, `priority_cleaning`, `revenue_due`, `partial`, `damaged` |
| `payment_status` | string | Filter by payment status: `pending`, `partial`, `paid`, `refunded` |
| `branch_id` | string | Filter by branch UUID |
| `customer_id` | string | Filter by customer UUID |
| `date_filter` | string | `today`, `yesterday`, `this_week`, `this_month`, `custom` |
| `date_field` | string | Field to filter by: `created_at`, `start_date`, `end_date` |
| `date_from` | string | ISO Date start filter boundary (YYYY-MM-DD) |
| `date_to` | string | ISO Date end filter boundary (YYYY-MM-DD) |
| `limit` | number | Items per page |
| `offset` | number | Offset starting index |

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "order-uuid",
        "customer_id": "customer-uuid",
        "status": "scheduled",
        "payment_status": "pending",
        "start_date": "2026-06-10",
        "end_date": "2026-06-12",
        "total_amount": 1500,
        "amount_paid": 0,
        "security_deposit": 500,
        "customer": {
          "id": "customer-uuid",
          "name": "John Doe",
          "phone": "9876543210"
        },
        "items": [
          {
            "id": "item-uuid",
            "quantity": 1,
            "price_per_day": 500,
            "product": {
              "id": "product-uuid",
              "name": "Premium Costume"
            }
          }
        ]
      }
    ],
    "total": 1,
    "page": 1,
    "total_pages": 1
  }
}
```

### Create Order

**Endpoint**: `POST /api/orders`

**Authentication**: Required

**Request Body**:
```json
{
  "customer_id": "customer-uuid",
  "branch_id": "branch-uuid",
  "start_date": "2026-06-10",
  "end_date": "2026-06-12",
  "items": [
    {
      "product_id": "product-uuid",
      "quantity": 1,
      "price_per_day": 500
    }
  ],
  "security_deposit": 500,
  "discount": 0,
  "notes": "Order notes"
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "id": "new-order-uuid",
    "status": "pending",
    "total_amount": 1500
  }
}
```

### Get Single Order

**Endpoint**: `GET /api/orders/:id`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "order-uuid",
    "customer_id": "customer-uuid",
    "status": "scheduled",
    "items": []
  }
}
```

### Update Order

**Endpoint**: `PATCH /api/orders/:id`

**Authentication**: Required

**Request Body**:
```json
{
  "status": "ongoing",
  "payment_status": "partial",
  "amount_paid": 1000
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "order-uuid",
    "status": "ongoing",
    "payment_status": "partial"
  }
}
```

### Delete/Cancel Order

**Endpoint**: `DELETE /api/orders/:id`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "success": true,
  "data": null
}
```

### Check Stock Availability

**Endpoint**: `POST /api/orders/check-availability`

**Authentication**: Required

**Request Body**:
```json
{
  "productId": "product-uuid",
  "startDate": "2026-06-10",
  "endDate": "2026-06-12",
  "excludeOrderId": "optional-exclude-order-uuid"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "available": 5,
    "availableWithPriority": 8,
    "total": 10,
    "peakReserved": 5,
    "priorityCleaningNeeded": false
  }
}
```

### Process Rental Return

**Endpoint**: `POST /api/orders/:id/return`

**Authentication**: Required

**Request Body**:
```json
{
  "items": [
    {
      "order_item_id": "item-uuid",
      "returned_quantity": 1,
      "condition": "good"
    }
  ],
  "return_date": "2026-06-12"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "order-uuid",
    "status": "returned"
  }
}
```

### Get Booking Calendar

**Endpoint**: `GET /api/calendar`

**Authentication**: Required

**Query Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| `branch_id` | string | Branch UUID |
| `start_date` | string | ISO start date range (YYYY-MM-DD) |
| `end_date` | string | ISO end date range (YYYY-MM-DD) |

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "order-uuid",
      "title": "John Doe - Premium Costume",
      "start": "2026-06-10",
      "end": "2026-06-12",
      "status": "scheduled"
    }
  ]
}
```

### Process Damage Assessments

**Endpoint**: `POST /api/orders/:id/damage-assessments`

**Authentication**: Required

**Request Body**:
```json
{
  "assessments": [
    {
      "product_id": "product-uuid",
      "unit_index": 1,
      "charge_amount": 300,
      "notes": "Damaged zipper",
      "decision": "reuse"
    }
  ]
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "success": true,
    "damage_charges_total": 300
  }
}
```

### Process Deposit Refund

**Endpoint**: `POST /api/orders/:id/deposit`

**Authentication**: Required

**Request Body**:
```json
{
  "action": "refund",
  "amount": 500,
  "notes": "Full deposit refund"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "order-uuid",
    "security_deposit_refunded": 500
  }
}
```

### Get Order Invoice

**Endpoint**: `GET /api/orders/:id/invoice`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "invoice_number": "INV-2026-0001",
    "subtotal": 1500,
    "gst_amount": 75,
    "grand_total": 1575,
    "invoice_pdf_url": "https://example.com/invoice.pdf"
  }
}
```

### Get Cleaning Queue

**Endpoint**: `GET /api/cleaning`

**Authentication**: Required

**Query Parameters**:

| Parameter | Type | Description |
|-----------|------|-------------|
| `branch_id` | string | Branch UUID |
| `status` | string | `pending`, `completed` |

**Response** (200 OK):
```json
{
  "success": true,
  "data": [
    {
      "id": "cleaning-uuid",
      "product": {
        "id": "product-uuid",
        "name": "Premium Costume"
      },
      "status": "pending",
      "quantity": 1
    }
  ]
}
```

### Update Cleaning Item

**Endpoint**: `PATCH /api/cleaning/:id`

**Authentication**: Required

**Request Body**:
```json
{
  "status": "completed"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "cleaning-uuid",
    "status": "completed"
  }
}
```

---

## Error Codes


| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 200 | - | Success |
| 201 | - | Resource created |
| 400 | VALIDATION_ERROR | Invalid input data |
| 400 | INVALID_SLUG_FORMAT | Slug contains invalid characters |
| 400 | NAME_REQUIRED | Name field is required |
| 401 | - | Authentication required |
| 403 | - | Access denied (insufficient permissions) |
| 404 | CATEGORY_NOT_FOUND | Category does not exist |
| 404 | PRODUCT_NOT_FOUND | Product does not exist |
| 409 | SLUG_EXISTS | Slug already exists |
| 409 | BARCODE_EXISTS | Barcode already assigned to another product |
| 409 | CIRCULAR_REFERENCE | Would create circular reference in hierarchy |
| 409 | CANNOT_DELETE | Resource cannot be deleted (has dependencies) |
| 500 | - | Internal server error |

### Error Response Format

```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "code": "ERROR_CODE",
    "details": []
  }
}
```

---

## Rate Limiting

API requests are rate-limited to prevent abuse:

- **Default limit**: 100 requests per minute per IP
- **Burst limit**: 200 requests per minute per IP

If you exceed the rate limit, you will receive a `429 Too Many Requests` response:

```json
{
  "success": false,
  "error": "Rate limit exceeded. Please try again later."
}
```

---

## PowerShell Examples

### Login and Get Products

```powershell
# Login
$loginResponse = Invoke-WebRequest -Uri "https://mazhavilcostumes-admin.vercel.app/api/auth/login" -Method POST -Headers @{"Content-Type" = "application/json"} -Body '{"email":"your-email@example.com","password":"your-password"}' -UseBasicParsing
$loginData = $loginResponse.Content | ConvertFrom-Json
$token = $loginData.data.access_token

# Get products
$products = Invoke-WebRequest -Uri "https://mazhavilcostumes-admin.vercel.app/api/products?limit=100" -Method GET -Headers @{"Authorization" = "Bearer $token"; "Content-Type" = "application/json"} -UseBasicParsing
$productsData = $products.Content | ConvertFrom-Json
$productsData.data.products
```

### Get Categories

```powershell
$categories = Invoke-WebRequest -Uri "https://mazhavilcostumes-admin.vercel.app/api/categories" -Method GET -Headers @{"Authorization" = "Bearer $token"; "Content-Type" = "application/json"} -UseBasicParsing
$categoriesData = $categories.Content | ConvertFrom-Json
$categoriesData.data
```

### Create Product

```powershell
$newProduct = @{
  name = "New Product"
  slug = "new-product"
  price_per_day = 500
  quantity = 10
  category_id = "category-uuid"
} | ConvertTo-Json

$createResponse = Invoke-WebRequest -Uri "https://mazhavilcostumes-admin.vercel.app/api/products" -Method POST -Headers @{"Authorization" = "Bearer $token"; "Content-Type" = "application/json"} -Body $newProduct -UseBasicParsing
$createResponse.Content | ConvertFrom-Json
```

---

## cURL Examples

### Login

```bash
curl -X POST https://mazhavilcostumes-admin.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"your-email@example.com","password":"your-password"}'
```

### Get Products

```bash
curl https://mazhavilcostumes-admin.vercel.app/api/products?limit=100 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Categories

```bash
curl https://mazhavilcostumes-admin.vercel.app/api/categories \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create Category

```bash
curl -X POST https://mazhavilcostumes-admin.vercel.app/api/categories \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"New Category","slug":"new-category","gst_percentage":5}'
```

---

## Support

For API support or questions, contact:
- Email: mazhavildancecostumes01@gmail.com
- Documentation: See `/docs` directory in repository
