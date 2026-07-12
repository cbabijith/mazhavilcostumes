/**
 * Product Service
 *
 * Business logic layer for product operations.
 * Orchestrates repository calls and implements complex business rules.
 *
 * @module services/productService
 */

import {
  productRepository,
  categoryRepository,
  uploadRepository,
  orderRepository,
  RepositoryResult,
} from '@/repository';
import { orderService } from './orderService';
import {
  Product,
  CreateProductDTO,
  UpdateProductDTO,
  ProductSearchParams,
  ProductSearchResult,
  ProductWithRelations,
  BulkProductOperation,
  BulkOperationResult,
  ProductValidationResult,
  ProductValidationError,
} from '@/domain';
import { CreateProductSchema, UpdateProductSchema } from '@/domain';
import { generateSlug } from '@/lib/shared-utils';

export class ProductService {
  private currentUserId: string | null = null;
  private currentStoreId: string | null = null;
  private currentBranchId: string | null = null;

  /**
   * Set current user context for audit fields and multi-tenancy
   */
  setUserContext(userId: string | null, branchId: string | null, storeId: string | null = null) {
    this.currentUserId = userId;
    this.currentBranchId = branchId;
    this.currentStoreId = storeId;
    productRepository.setUserContext(userId, branchId);
  }

  /**
   * Handle service errors
   */
  private handleError(error: any): any {
    if (error?.code) {
      return {
        message: error.message || 'Service operation failed',
        code: error.code,
        details: error.details,
        hint: error.hint || '',
      };
    }

    return {
      message: error?.message || 'Unknown service error',
      code: 'UNKNOWN_ERROR',
      details: error,
      hint: '',
    };
  }

  /**
   * Get products with search and filtering
   */
  async getProducts(
    params: ProductSearchParams = {}
  ): Promise<RepositoryResult<ProductSearchResult>> {
    const result = await productRepository.findAll(params);
    if (result.success && result.data && params.query) {
      result.data.products = this.sortProductsByRelevance(result.data.products, params.query);
    }
    return result;
  }

  /**
   * Get product by ID with relations
   */
  async getProductById(id: string): Promise<RepositoryResult<ProductWithRelations>> {
    return await productRepository.findById(id);
  }

  /**
   * Create a new product with validation
   */
  async createProduct(
    data: CreateProductDTO,
    userRole: string = 'staff'
  ): Promise<RepositoryResult<ProductWithRelations>> {
    // Validate input data
    const validation = this.validateProductData(data);
    if (!validation.is_valid) {
      return {
        data: null,
        error: {
          message: 'Validation failed',
          details: validation.errors,
          code: 'VALIDATION_ERROR',
        } as any,
        success: false,
      };
    }

    // Generate slug if not provided
    if (!data.slug) {
      data.slug = generateSlug(data.name);
    }

    // Check slug availability
    const slugCheck = await this.checkSlugAvailability(data.slug);
    if (!slugCheck.success || !slugCheck.data) {
      return {
        data: null,
        error: {
          message: 'Product slug already exists',
          code: 'SLUG_EXISTS',
        } as any,
        success: false,
      };
    }

    // Validate category if provided
    if (data.category_id) {
      const categoryResult = await categoryRepository.findById(data.category_id);
      if (!categoryResult.success || !categoryResult.data) {
        return {
          data: null,
          error: {
            message: 'Invalid category ID',
            code: 'INVALID_CATEGORY',
          } as any,
          success: false,
        };
      }
    }

    // Check barcode uniqueness if provided
    if (data.barcode && data.barcode.trim().length > 0) {
      const barcodeCheck = await productRepository.isBarcodeUnique(data.barcode.trim());
      if (!barcodeCheck.unique) {
        return {
          data: null,
          error: {
            message: `Barcode "${data.barcode}" is already assigned to "${barcodeCheck.existingProductName}"`,
            code: 'BARCODE_EXISTS',
          } as any,
          success: false,
        };
      }
    }

    // Handle "all branches" / global product for admin/super admin
    let branchId = data.branch_id;
    const isGlobal =
      (userRole === 'admin' || userRole === 'super_admin') &&
      (data.branch_id === 'all' || !data.branch_id);
    if (isGlobal) {
      // For global products, branch_id in products table is null
      branchId = undefined;
    }

    // Force branch restriction for sub-branch users
    if (this.currentBranchId) {
      const { branchRepository } = await import('@/repository');
      const branchRes = await branchRepository.findById(this.currentBranchId);
      const isUserBranchMain = branchRes.success && branchRes.data ? branchRes.data.is_main : false;
      if (!isUserBranchMain) {
        branchId = this.currentBranchId;
      }
    }

    // Extract branch_inventory from data before passing to repository
    const { branch_inventory, ...restData } = data;

    // Create product with adjusted branch_id
    const createData = { ...restData, branch_id: branchId };
    const createResult = await productRepository.create(createData as CreateProductDTO);

    if (!createResult.success || !createResult.data) {
      return createResult;
    }

    // Initialize inventory records
    const adminClient = (await import('@/lib/supabase/server')).createAdminClient();
    const { branchRepository } = await import('@/repository');
    const branchesResult = await branchRepository.findAllWithStaffCount(this.currentStoreId || '');
    const allBranches = branchesResult.success && branchesResult.data ? branchesResult.data : [];
    if (isGlobal) {
      if (allBranches.length > 0) {
        const inventoryPayload = allBranches.map((branch) => {
          // Use per-branch quantity from branch_inventory if provided,
          // otherwise fall back to data.quantity (for backward compat)
          let qty = data.quantity || 0;
          if (branch_inventory && branch_inventory.length > 0) {
            const match = branch_inventory.find((inv) => inv.branch_id === branch.id);
            qty = match !== undefined ? (match.quantity || 0) : 0;
          }

          return {
            product_id: createResult.data!.id,
            branch_id: branch.id,
            quantity: qty,
            available_quantity: qty,
            low_stock_threshold: data.low_stock_threshold ?? 5,
          };
        });
        await adminClient.from('product_inventory').insert(inventoryPayload);
      }
    } else {
      // Non-global product: ensure ALL branches have a product_inventory record.
      // The owning branch (either branch_inventory or branchId) gets its stock, and other branches get 0.
      if (allBranches.length > 0) {
        const inventoryPayload = allBranches.map((branch) => {
          let qty = 0;
          if (branch_inventory && branch_inventory.length > 0) {
            const match = branch_inventory.find((inv) => inv.branch_id === branch.id);
            qty = match ? match.quantity || 0 : 0;
          } else if (branchId && branch.id === branchId) {
            qty = data.quantity || 0;
          }

          return {
            product_id: createResult.data!.id,
            branch_id: branch.id,
            quantity: qty,
            available_quantity: qty,
            low_stock_threshold: data.low_stock_threshold ?? 5,
          };
        });

        await adminClient.from('product_inventory').insert(inventoryPayload);
      } else if (branchId) {
        await adminClient.from('product_inventory').insert([
          {
            product_id: createResult.data!.id,
            branch_id: branchId,
            quantity: data.quantity || 0,
            available_quantity: data.quantity || 0,
            low_stock_threshold: data.low_stock_threshold ?? 5,
          },
        ]);
      }
    }

    // After creating inventory records, sync the product's total
    // quantity/available_quantity from the actual branch inventory totals.
    if (branch_inventory && branch_inventory.length > 0) {
      const totalFromBranches = branch_inventory.reduce((sum, inv) => sum + (inv.quantity || 0), 0);
      await adminClient.from('products')
        .update({ quantity: totalFromBranches, available_quantity: totalFromBranches })
        .eq('id', createResult.data!.id);
    }

    // Return product with relations
    return await productRepository.findById(createResult.data.id);
  }

  /**
   * Update an existing product with validation
   */
  async updateProduct(
    id: string,
    data: UpdateProductDTO
  ): Promise<RepositoryResult<ProductWithRelations>> {
    // Check if product exists
    const existingProduct = await productRepository.findById(id);
    if (!existingProduct.success || !existingProduct.data) {
      return {
        data: null,
        error: {
          message: 'Product not found',
          code: 'PRODUCT_NOT_FOUND',
        } as any,
        success: false,
      };
    }

    // Check branch ownership lock for sub-branch users
    if (this.currentBranchId) {
      const { branchRepository } = await import('@/repository');
      const branchRes = await branchRepository.findById(this.currentBranchId);
      const isUserBranchMain = branchRes.success && branchRes.data ? branchRes.data.is_main : false;

      if (!isUserBranchMain) {
        // Sub-branch user editing a product from another branch:
        // Allow inventory-only updates for their own branch (cross_branch_stock_only mode)
        if (existingProduct.data.branch_id !== this.currentBranchId) {
          if ((data as any).cross_branch_stock_only && (data as any).branch_inventory) {
            // Only upsert this user's branch inventory — skip all product-level updates
            const adminClient = (await import('@/lib/supabase/server')).createAdminClient();
            const branchInventory = (data as any).branch_inventory as Array<{
              branch_id: string;
              quantity: number;
              id?: string;
            }>;

            // Filter to only allow updating their own branch's inventory
            const ownBranchInv = branchInventory.filter(
              (inv) => inv.branch_id === this.currentBranchId
            );

            if (ownBranchInv.length > 0) {
              const upsertPayload = ownBranchInv.map((inv) => ({
                product_id: id,
                branch_id: inv.branch_id,
                quantity: inv.quantity || 0,
                available_quantity: inv.quantity || 0,
                low_stock_threshold: existingProduct.data!.low_stock_threshold ?? 5,
                ...(inv.id ? { id: inv.id } : {}),
              }));

              await adminClient
                .from('product_inventory')
                .upsert(upsertPayload, { onConflict: 'product_id, branch_id' });
            }

            // Recalculate total product quantity from all branch inventories
            const { data: allInv } = await adminClient
              .from('product_inventory')
              .select('quantity')
              .eq('product_id', id);

            if (allInv) {
              const totalQty = allInv.reduce((sum, row) => sum + (row.quantity || 0), 0);
              await adminClient
                .from('products')
                .update({ quantity: totalQty, available_quantity: totalQty })
                .eq('id', id);
            }

            // Sync conflicts if quantity changed
            await orderService.syncProductConflicts(id);

            return await productRepository.findById(id);
          }

          // Not a stock-only update — block it
          return {
            data: null,
            error: {
              message: 'Unauthorized: You can only edit products belonging to your sub-branch.',
              code: 'UNAUTHORIZED',
            } as any,
            success: false,
          };
        }
      }
    }

    // Validate input data
    const validation = this.validateProductData(data, existingProduct.data);
    if (!validation.is_valid) {
      return {
        data: null,
        error: {
          message: 'Validation failed',
          details: validation.errors,
          code: 'VALIDATION_ERROR',
        } as any,
        success: false,
      };
    }

    // Generate slug if name changed and slug not provided
    if (data.name && !data.slug && data.name !== existingProduct.data.name) {
      data.slug = generateSlug(data.name);
    }

    // Check slug availability if changed
    if (data.slug && data.slug !== existingProduct.data.slug) {
      const slugCheck = await this.checkSlugAvailability(data.slug, id);
      if (!slugCheck.success || !slugCheck.data) {
        return {
          data: null,
          error: {
            message: 'Product slug already exists',
            code: 'SLUG_EXISTS',
          } as any,
          success: false,
        };
      }
    }

    // Validate category if provided
    if (data.category_id !== undefined) {
      if (data.category_id) {
        const categoryResult = await categoryRepository.findById(data.category_id);
        if (!categoryResult.success || !categoryResult.data) {
          return {
            data: null,
            error: {
              message: 'Invalid category ID',
              code: 'INVALID_CATEGORY',
            } as any,
            success: false,
          };
        }
      }
    }

    // Check barcode uniqueness if changed
    if (
      data.barcode &&
      data.barcode.trim().length > 0 &&
      data.barcode !== existingProduct.data.barcode
    ) {
      const barcodeCheck = await productRepository.isBarcodeUnique(data.barcode.trim(), id);
      if (!barcodeCheck.unique) {
        return {
          data: null,
          error: {
            message: `Barcode "${data.barcode}" is already assigned to "${barcodeCheck.existingProductName}"`,
            code: 'BARCODE_EXISTS',
          } as any,
          success: false,
        };
      }
    }

    // Extract branch_inventory and removed_inventory_ids before updating product
    const { branch_inventory, removed_inventory_ids, ...restData } = data;

    // Update product
    const updateResult = await productRepository.update(id, restData as UpdateProductDTO);

    if (!updateResult.success || !updateResult.data) {
      return updateResult;
    }

    const adminClient = (await import('@/lib/supabase/server')).createAdminClient();

    // Process branch inventory deletions if any
    if (removed_inventory_ids && removed_inventory_ids.length > 0) {
      await adminClient.from('product_inventory').delete().in('id', removed_inventory_ids);
    }

    // Process branch inventory bulk upsert
    if (branch_inventory && branch_inventory.length > 0) {
      const upsertPayload = branch_inventory.map((inv) => {
        const payload: any = {
          product_id: id,
          branch_id: inv.branch_id,
          quantity: inv.quantity || 0,
          available_quantity: inv.quantity || 0,
          low_stock_threshold:
            restData.low_stock_threshold ?? existingProduct.data!.low_stock_threshold ?? 5,
        };
        if (inv.id) {
          payload.id = inv.id;
        }
        return payload;
      });

      await adminClient
        .from('product_inventory')
        .upsert(upsertPayload, { onConflict: 'product_id, branch_id' });
    }

    // PROACTIVE CONFLICT DETECTION
    // If quantity was updated, re-evaluate all future orders for this product
    if (data.quantity !== undefined && data.quantity !== existingProduct.data.quantity) {
      await orderService.syncProductConflicts(id);
    }

    // Return updated product with relations
    return await productRepository.findById(id);
  }

  /**
   * Delete a product with safety checks
   */
  async deleteProduct(id: string): Promise<RepositoryResult<void>> {
    // Check if product exists
    const existingProduct = await productRepository.findById(id);
    if (!existingProduct.success || !existingProduct.data) {
      return {
        success: false,
        error: existingProduct.error,
        data: null,
      };
    }

    // Check branch ownership lock for sub-branch users
    if (this.currentBranchId) {
      const { branchRepository } = await import('@/repository');
      const branchRes = await branchRepository.findById(this.currentBranchId);
      const isUserBranchMain = branchRes.success && branchRes.data ? branchRes.data.is_main : false;

      if (!isUserBranchMain) {
        if (existingProduct.data.branch_id !== this.currentBranchId) {
          return {
            data: null,
            error: {
              message: 'Unauthorized: You can only delete products belonging to your sub-branch.',
              code: 'UNAUTHORIZED',
            } as any,
            success: false,
          };
        }
      }
    }

    // Check if product can be deleted
    const canDeleteResult = await productRepository.canDelete(id);

    if (!canDeleteResult.success) {
      return {
        success: false,
        error: canDeleteResult.error,
        data: null,
      };
    }

    if (!canDeleteResult.data || !canDeleteResult.data.canDelete) {
      return {
        data: null,
        error: {
          message: canDeleteResult.data?.reason || 'Cannot delete product',
          code: 'CANNOT_DELETE',
        } as any,
        success: false,
      };
    }

    // Delete product
    return await productRepository.delete(id);
  }

  /**
   * Perform bulk operations on products
   */
  async performBulkOperation(
    operation: BulkProductOperation
  ): Promise<RepositoryResult<BulkOperationResult>> {
    // Validate operation
    if (!operation.product_ids || operation.product_ids.length === 0) {
      return {
        data: null,
        error: {
          message: 'No products selected',
          code: 'NO_PRODUCTS_SELECTED',
        } as any,
        success: false,
      };
    }

    // For delete operations, check each product
    if (operation.operation === 'delete') {
      const canDeletePromises = operation.product_ids.map((id) => productRepository.canDelete(id));

      const canDeleteResults = await Promise.all(canDeletePromises);
      const cannotDelete = operation.product_ids.filter(
        (_, index) => !canDeleteResults[index].success || !canDeleteResults[index].data?.canDelete
      );

      if (cannotDelete.length > 0) {
        return {
          data: null,
          error: {
            message: 'Some products cannot be deleted',
            details: { cannotDelete },
            code: 'CANNOT_DELETE_BULK',
          } as any,
          success: false,
        };
      }
    }

    // Perform bulk operation
    return await productRepository.bulkOperation(operation);
  }

  /**
   * Search products
   */
  async searchProducts(query: string, limit: number = 10): Promise<RepositoryResult<Product[]>> {
    const result = await productRepository.search(query, limit);
    if (result.success && result.data && query) {
      result.data = this.sortProductsByRelevance(result.data, query);
    }
    return result;
  }

  /**
   * Get product by barcode
   * Used for barcode scanner lookup in order forms.
   */
  async getProductByBarcode(barcode: string): Promise<RepositoryResult<ProductWithRelations>> {
    if (!barcode || barcode.trim().length === 0) {
      return {
        data: null,
        error: {
          message: 'Barcode is required',
          code: 'VALIDATION_ERROR',
        } as any,
        success: false,
      };
    }

    return await productRepository.findByBarcode(barcode.trim());
  }

  /**
   * Get featured products
   */
  async getFeaturedProducts(limit: number = 10): Promise<RepositoryResult<Product[]>> {
    return await productRepository.getFeatured(limit);
  }

  /**
   * Get low stock products
   */
  async getLowStockProducts(): Promise<RepositoryResult<Product[]>> {
    return await productRepository.getLowStock();
  }

  /**
   * Update product inventory
   */
  async updateInventory(
    productId: string,
    availableQuantity: number
  ): Promise<RepositoryResult<Product>> {
    // Validate quantity
    if (availableQuantity < 0) {
      return {
        data: null,
        error: {
          message: 'Available quantity cannot be negative',
          code: 'INVALID_QUANTITY',
        } as any,
        success: false,
      };
    }

    // Get current product to validate against total quantity
    const currentProduct = await productRepository.findById(productId);
    if (!currentProduct.success || !currentProduct.data) {
      return {
        data: null,
        error: {
          message: 'Product not found',
          code: 'PRODUCT_NOT_FOUND',
        } as any,
        success: false,
      };
    }

    if (availableQuantity > currentProduct.data.quantity) {
      return {
        data: null,
        error: {
          message: 'Available quantity cannot be greater than total quantity',
          code: 'INVALID_QUANTITY',
        } as any,
        success: false,
      };
    }

    const result = await productRepository.updateInventory(productId, availableQuantity);

    // Sync conflicts if quantity changed
    if (result.success) {
      await orderService.syncProductConflicts(productId);
    }

    return result;
  }

  /**
   * Clone a product
   */
  async cloneProduct(
    id: string,
    newName?: string
  ): Promise<RepositoryResult<ProductWithRelations>> {
    // Get original product
    const originalProduct = await productRepository.findById(id);
    if (!originalProduct.success || !originalProduct.data) {
      return {
        data: null,
        error: {
          message: 'Product not found',
          code: 'PRODUCT_NOT_FOUND',
        } as any,
        success: false,
      };
    }

    // Create clone data
    const cloneData: CreateProductDTO = {
      name: newName || `${originalProduct.data.name} (Copy)`,
      slug: '', // Will be generated
      sku: originalProduct.data.sku ? `${originalProduct.data.sku}-copy` : undefined,
      category_id: originalProduct.data.category_id || undefined,
      store_id: originalProduct.data.store_id,
      description: originalProduct.data.description || undefined,
      price_per_day: originalProduct.data.price_per_day,
      purchase_price: (originalProduct.data as any).purchase_price || 0,
      quantity: originalProduct.data.quantity,
      available_quantity: originalProduct.data.available_quantity,
      images: originalProduct.data.images,
      sizes: originalProduct.data.sizes,
      colors: originalProduct.data.colors,
      is_active: false, // Start as inactive
      is_featured: false,
      track_inventory: originalProduct.data.track_inventory,
      low_stock_threshold: originalProduct.data.low_stock_threshold,
    };

    // Create cloned product
    return await this.createProduct(cloneData);
  }

  /**
   * Validate product data
   */
  private validateProductData(
    data: CreateProductDTO | UpdateProductDTO,
    existingProduct?: Product
  ): ProductValidationResult {
    const errors: ProductValidationError[] = [];
    const warnings: ProductValidationError[] = [];

    // Use Zod schema validation
    const schema = existingProduct ? UpdateProductSchema : CreateProductSchema;
    const result = schema.safeParse(data);

    if (!result.success) {
      result.error.issues.forEach((issue) => {
        errors.push({
          field: issue.path.join('.'),
          message: issue.message,
          code: issue.code || 'VALIDATION_ERROR',
        });
      });
    }

    // Custom business validations
    if ('price_per_day' in data && (data.price_per_day || 0) <= 0) {
      errors.push({
        field: 'price_per_day',
        message: 'Price per day must be greater than 0',
        code: 'INVALID_PRICE',
      });
    }

    if ('quantity' in data && 'available_quantity' in data) {
      if (data.available_quantity! > data.quantity!) {
        errors.push({
          field: 'available_quantity',
          message: 'Available quantity cannot be greater than total quantity',
          code: 'INVALID_QUANTITY',
        });
      }
    }

    if ('description' in data && !data.description) {
      warnings.push({
        field: 'description',
        message: 'No description provided - consider adding one for better SEO',
        code: 'NO_DESCRIPTION',
      });
    }

    return {
      is_valid: errors.length === 0,
      errors,
      warnings,
    };
  }

  /**
   * Check if slug is available (returns true if available)
   */
  private async checkSlugAvailability(
    slug: string,
    excludeId?: string
  ): Promise<RepositoryResult<boolean>> {
    try {
      // Use exact slug match instead of search query
      const adminClient = (await import('@/lib/supabase/server')).createAdminClient();

      let query = adminClient.from('products').select('id').eq('slug', slug).is('deleted_at', null);

      // Exclude current product when editing
      if (excludeId) {
        query = query.neq('id', excludeId);
      }

      const { data, error } = await query.maybeSingle();

      if (error) {
        return { success: false, data: null, error: this.handleError(error) };
      }

      // If no product found with this slug, it's available
      return { success: true, data: data === null, error: null };
    } catch (error) {
      return { success: false, data: null, error: this.handleError(error) };
    }
  }

  /**
   * Sort products by relevance to a query (exact matches first, then prefix matches, then other matches)
   */
  private sortProductsByRelevance<
    T extends {
      name: string;
      barcode?: string | null;
      slug: string;
      sku?: string | null;
      description?: string | null;
    },
  >(products: T[], query: string): T[] {
    if (!query) return products;

    const q = query.trim().toLowerCase();
    const normalizedQ = q.replace(/\s+/g, '-');

    return products.sort((a, b) => {
      const aName = a.name.toLowerCase();
      const bName = b.name.toLowerCase();
      const aBarcode = (a.barcode || '').toLowerCase();
      const bBarcode = (b.barcode || '').toLowerCase();
      const aSlug = (a.slug || '').toLowerCase();
      const bSlug = (b.slug || '').toLowerCase();

      // 1. Exact matches (name or barcode or slug)
      const aExact =
        aName === q ||
        aName === normalizedQ ||
        aBarcode === q ||
        aBarcode === normalizedQ ||
        aSlug === q ||
        aSlug === normalizedQ;
      const bExact =
        bName === q ||
        bName === normalizedQ ||
        bBarcode === q ||
        bBarcode === normalizedQ ||
        bSlug === q ||
        bSlug === normalizedQ;
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;

      // 2. Prefix matches (starts with query)
      const aPrefix =
        aName.startsWith(q) ||
        aName.startsWith(normalizedQ) ||
        aBarcode.startsWith(q) ||
        aBarcode.startsWith(normalizedQ) ||
        aSlug.startsWith(q) ||
        aSlug.startsWith(normalizedQ);
      const bPrefix =
        bName.startsWith(q) ||
        bName.startsWith(normalizedQ) ||
        bBarcode.startsWith(q) ||
        bBarcode.startsWith(normalizedQ) ||
        bSlug.startsWith(q) ||
        bSlug.startsWith(normalizedQ);
      if (aPrefix && !bPrefix) return -1;
      if (!aPrefix && bPrefix) return 1;

      // 3. Substring matches in barcode/slug/SKU
      const aSub = aBarcode.includes(q) || aBarcode.includes(normalizedQ);
      const bSub = bBarcode.includes(q) || bBarcode.includes(normalizedQ);
      if (aSub && !bSub) return -1;
      if (!aSub && bSub) return 1;

      // 4. Default: Alphabetical/lexicographical order by name with natural number sort
      const matchA = a.name.match(/^(.+?)-(\d+)$/);
      const matchB = b.name.match(/^(.+?)-(\d+)$/);
      if (matchA && matchB && matchA[1].toLowerCase() === matchB[1].toLowerCase()) {
        return parseInt(matchA[2], 10) - parseInt(matchB[2], 10);
      }

      return aName.localeCompare(bName, undefined, { numeric: true, sensitivity: 'base' });
    });
  }
}

// Export singleton instance
export const productService = new ProductService();
