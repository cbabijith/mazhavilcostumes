/**
 * Damage Assessment Repository
 *
 * Data access layer for damage_assessments table.
 * Handles CRUD operations for post-return damage assessment records.
 *
 * @module repository/damageAssessmentRepository
 */

import { BaseRepository, type RepositoryResult } from './supabaseClient';
import type { DamageAssessment, DamageAssessmentWithProduct } from '@/domain';

export class DamageAssessmentRepository extends BaseRepository {
  protected tableName = 'damage_assessments';

  /**
   * Create a batch of pending damage assessments for an order item.
   * One row per damaged unit.
   */
  async createBatch(params: {
    order_id: string;
    order_item_id: string;
    product_id: string;
    branch_id: string;
    damaged_quantity: number;
  }): Promise<RepositoryResult<DamageAssessment[]>> {
    const rows = Array.from({ length: params.damaged_quantity }, (_, i) => ({
      order_id: params.order_id,
      order_item_id: params.order_item_id,
      product_id: params.product_id,
      branch_id: params.branch_id,
      unit_index: i + 1,
      decision: 'pending',
    }));

    return this.executeOperation(async () =>
      this.client.from(this.tableName).insert(rows).select('*')
    );
  }

  /**
   * Fetch all damage assessments for an order, with product info.
   */
  async findByOrderId(orderId: string): Promise<RepositoryResult<DamageAssessmentWithProduct[]>> {
    return this.executeOperation(async () =>
      this.client
        .from(this.tableName)
        .select(`
          *,
          product:product_id(id, name, images),
          order_item:order_item_id(id, quantity, damage_description, damage_charges, condition_rating)
        `)
        .eq('order_id', orderId)
        .order('product_id', { ascending: true })
        .order('unit_index', { ascending: true })
    );
  }

  /**
   * Fetch all damage assessments for a specific product (across all orders).
   * Used by the product details page to show damage history.
   */
  async findByProductId(productId: string): Promise<RepositoryResult<DamageAssessmentWithProduct[]>> {
    return this.executeOperation(async () =>
      this.client
        .from(this.tableName)
        .select(`
          *,
          product:product_id(id, name, images),
          order_item:order_item_id(id, quantity, damage_description, damage_charges, condition_rating),
          order:order_id(id, status, customer:customer_id(name))
        `)
        .eq('product_id', productId)
        .order('created_at', { ascending: false })
        .limit(20)
    );
  }

  /**
   * Update a single assessment decision.
   */
  async updateDecision(
    id: string,
    decision: string,
    notes?: string,
    assessedBy?: string
  ): Promise<RepositoryResult<DamageAssessment>> {
    const updateData: any = {
      decision,
      notes: notes || null,
      assessed_at: new Date().toISOString(),
    };
    if (assessedBy) updateData.assessed_by = assessedBy;

    return this.executeOperation(async () =>
      this.client
        .from(this.tableName)
        .update(updateData)
        .eq('id', id)
        .select('*')
        .single()
    );
  }

  /**
   * Check if all assessments for an order are decided (not pending).
   */
  async checkAllAssessed(orderId: string): Promise<{ allDone: boolean; pending: number; total: number }> {
    const { data, error } = await this.client
      .from(this.tableName)
      .select('decision')
      .eq('order_id', orderId);

    if (error || !data) return { allDone: false, pending: 0, total: 0 };

    const total = data.length;
    const pending = data.filter(d => d.decision === 'pending').length;
    return { allDone: pending === 0, pending, total };
  }

  /**
   * Decrement product stock (global) when a unit is marked as not_reuse.
   * Decrements both products.quantity and products.available_quantity.
   */
  async decrementProductStock(productId: string, quantity: number = 1): Promise<RepositoryResult<any>> {
    // Fetch current stock
    const { data: product, error: fetchErr } = await this.client
      .from('products')
      .select('quantity, available_quantity')
      .eq('id', productId)
      .single();

    if (fetchErr || !product) {
      return { data: null, error: fetchErr, success: false };
    }

    const newQty = Math.max(0, (product.quantity || 0) - quantity);
    const newAvail = Math.max(0, (product.available_quantity || 0) - quantity);

    return this.executeOperation(async () =>
      this.client
        .from('products')
        .update({ quantity: newQty, available_quantity: newAvail })
        .eq('id', productId)
        .select('id, quantity, available_quantity')
        .single()
    );
  }
}

export const damageAssessmentRepository = new DamageAssessmentRepository();
