import { NextRequest } from 'next/server';
import { z } from 'zod';
import { apiGuard } from '@/lib/apiGuard';
import { getAuthUser } from '@/lib/auth';
import { 
  apiSuccess, 
  apiForbidden, 
  apiBadRequest, 
  apiInternalError 
} from '@/lib/apiResponse';
import { createAdminClient } from '@/lib/supabase/server';
import { randomUUID } from 'crypto';

function baseSlug(str: string): string {
  return str.toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim();
}

function generateSlug(name: string, sku: string): string {
  let namePart = baseSlug(name);
  let skuPart = baseSlug(sku);
  return `${namePart}-${skuPart}`;
}

export async function POST(request: NextRequest) {
  try {
    // 1. Guard check and authenticate user role
    const guard = await apiGuard(request, 'products');
    if (guard.error) return guard.error;

    const authUser = await getAuthUser(request);
    if (!authUser || !['super_admin', 'admin'].includes(authUser.role || '')) {
      return apiForbidden('Only super admins and admins can perform catalog imports.');
    }

    const storeId = authUser.store_id;
    const branchId = authUser.branch_id;
    const staffId = authUser.staff_id;

    if (!storeId || !branchId || !staffId) {
      return apiBadRequest('Missing user context (store, branch, or staff context is missing).');
    }

    const body = await request.json();
    const { cleanSlate, items } = body;

    if (!Array.isArray(items)) {
      return apiBadRequest('Invalid input format. Expected an array of items.');
    }

    const adminClient = createAdminClient();

    // 2. Clear Database if cleanSlate is requested
    if (cleanSlate) {
      console.log('Admin UI Import - Starting Clean Slate Purge...');
      
      const tablesToDelete = [
        'order_status_history',
        'payments',
        'damage_assessments',
        'cleaning_records',
        'order_reservations',
        'order_items',
        'orders',
        'customers',
        'product_inventory',
        'products',
        'categories'
      ];

      for (const table of tablesToDelete) {
        const { error } = await adminClient
          .from(table)
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');
        
        if (error) {
          console.error(`Wipe failed on table ${table}:`, error);
          return apiInternalError(`Clean slate failed on table ${table}: ${error.message}`);
        }
      }
    }

    // Filter valid items containing code & name
    const validItems = items.filter(item => {
      const code = item.code || item.Code;
      const name = item.name || item.Name;
      return code && String(code).trim() && name && String(name).trim();
    });

    if (validItems.length === 0) {
      return apiBadRequest('No valid products found in the uploaded data.');
    }

    // 3. Create Categories
    const uniqueCategories: any[] = [];
    const categorySlugMap = new Map<string, string>(); // catName -> catId

    for (const item of validItems) {
      const catName = (item.category || item.Category || '').trim();
      const gst = item.gst !== undefined ? Number(item.gst) : (item.GST !== undefined ? Number(item.GST) : 5.00);

      if (!catName) continue;

      const key = catName.toLowerCase();
      if (!categorySlugMap.has(key)) {
        const catId = randomUUID();
        const slug = baseSlug(catName);
        categorySlugMap.set(key, catId);

        uniqueCategories.push({
          id: catId,
          name: catName,
          slug: slug,
          gst_percentage: gst,
          store_id: storeId,
          is_global: true,
          is_active: true,
          created_by: staffId,
          created_at_branch_id: branchId
        });
      }
    }

    if (uniqueCategories.length > 0) {
      const { error: catInsertErr } = await adminClient
        .from('categories')
        .insert(uniqueCategories);

      if (catInsertErr) {
        console.error('Failed to insert categories:', catInsertErr);
        return apiInternalError(`Failed to insert categories: ${catInsertErr.message}`);
      }
    }

    // 4. Prepare Products and Branch Inventories
    const productsToInsert: any[] = [];
    const inventoryToInsert: any[] = [];

    for (const item of validItems) {
      const code = String(item.code || item.Code || '').trim();
      const name = String(item.name || item.Name || '').trim();
      const catName = (item.category || item.Category || '').trim().toLowerCase();
      const rent = item.rent !== undefined ? Number(item.rent) : (item.Rent !== undefined ? Number(item.Rent) : 0);
      const purchasePrice = item.purchasePrice !== undefined ? Number(item.purchasePrice) : (item['Purchase Price'] !== undefined ? Number(item['Purchase Price']) : 0);
      const qty = item.qty !== undefined ? Number(item.qty) : (item.Qty !== undefined ? Number(item.Qty) : 0);

      const productId = randomUUID();
      const catId = categorySlugMap.get(catName) || null;
      const slug = baseSlug(code);

      productsToInsert.push({
        id: productId,
        store_id: storeId,
        category_id: catId,
        branch_id: branchId,
        name: code, // Code/Name
        slug: slug,
        description: name, // Description/SKU
        sku: name, // Description/SKU
        barcode: code, // Code/Name
        price_per_day: rent,
        purchase_price: purchasePrice,
        quantity: qty,
        available_quantity: qty,
        is_active: true,
        track_inventory: true,
        created_by: staffId,
        created_at_branch_id: branchId
      });

      inventoryToInsert.push({
        id: randomUUID(),
        product_id: productId,
        branch_id: branchId,
        quantity: qty,
        available_quantity: qty
      });
    }

    // 5. Insert Products and Inventories in Batches of 100
    const BATCH_SIZE = 100;
    for (let i = 0; i < productsToInsert.length; i += BATCH_SIZE) {
      const prodBatch = productsToInsert.slice(i, i + BATCH_SIZE);
      const invBatch = inventoryToInsert.slice(i, i + BATCH_SIZE);

      const { error: prodErr } = await adminClient.from('products').insert(prodBatch);
      if (prodErr) {
        console.error(`Failed to insert product batch starting at index ${i}:`, prodErr);
        return apiInternalError(`Failed to insert product batch: ${prodErr.message}`);
      }

      const { error: invErr } = await adminClient.from('product_inventory').insert(invBatch);
      if (invErr) {
        console.error(`Failed to insert product inventory batch starting at index ${i}:`, invErr);
        return apiInternalError(`Failed to insert inventory batch: ${invErr.message}`);
      }
    }

    return apiSuccess({
      categoriesCount: uniqueCategories.length,
      productsCount: productsToInsert.length
    }, {
      message: 'Catalog imported successfully.'
    });

  } catch (error: any) {
    console.error('Products API - Catalog Import Error:', error);
    return apiInternalError(error.message || 'Catalog import failed due to an internal server error.');
  }
}
