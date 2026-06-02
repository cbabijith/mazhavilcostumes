/**
 * Damage Assessment Service
 *
 * Business logic for damage assessment operations.
 * Handles assessment creation after returns, decision processing,
 * and stock adjustments for write-offs.
 *
 * @module services/damageAssessmentService
 */

import { damageAssessmentRepository, orderRepository, cleaningRepository } from '@/repository';
import type { RepositoryResult } from '@/repository/supabaseClient';
import type { DamageAssessment, DamageAssessmentWithProduct, CreateDamageAssessmentsDTO } from '@/domain';
import { DamageDecision } from '@/domain';

export class DamageAssessmentService {
  /**
   * Create damage assessments for all damaged items in a return.
   * Called after the return process when items have damage.
   * Batch inserts all assessment rows in a single query.
   */
  async createAssessments(dto: CreateDamageAssessmentsDTO): Promise<RepositoryResult<DamageAssessment[]>> {
    const rows: any[] = [];

    for (const item of dto.items) {
      if (item.damaged_quantity <= 0) continue;

      for (let i = 0; i < item.damaged_quantity; i++) {
        rows.push({
          order_id: dto.order_id,
          order_item_id: item.order_item_id,
          product_id: item.product_id,
          branch_id: item.branch_id,
          unit_index: i + 1,
          decision: 'pending',
        });
      }
    }

    if (rows.length === 0) {
      return { data: [], error: null, success: true };
    }

    return damageAssessmentRepository.createAll(rows);
  }

  /**
   * Fetch all damage assessments for an order.
   */
  async getAssessmentsForOrder(orderId: string): Promise<RepositoryResult<DamageAssessmentWithProduct[]>> {
    return damageAssessmentRepository.findByOrderId(orderId);
  }

  /**
   * Assess a single damaged unit — mark as reuse or not_reuse.
   * If not_reuse, decrements global product stock by 1.
   */
  async assessUnit(
    assessmentId: string,
    decision: DamageDecision,
    notes?: string,
    assessedBy?: string
  ): Promise<RepositoryResult<DamageAssessment>> {
    if (decision === DamageDecision.PENDING) {
      return {
        data: null,
        error: { message: 'Cannot set decision back to pending', code: 'VALIDATION_ERROR' } as any,
        success: false,
      };
    }

    // Update the assessment
    const result = await damageAssessmentRepository.updateDecision(
      assessmentId,
      decision,
      notes,
      assessedBy
    );

    if (!result.success || !result.data) return result;

    // If not_reuse, decrement stock
    if (decision === DamageDecision.NOT_REUSE) {
      const stockResult = await damageAssessmentRepository.decrementProductStock(
        result.data.product_id,
        1
      );

      if (!stockResult.success) {
        console.error('[DamageAssessmentService] Failed to decrement stock:', stockResult.error);
        // Return the assessment result but log the stock error
      } else {
        const orderId = result.data.order_id;
        const productId = result.data.product_id;

        // Perform stock-conflict syncing and cleaning adjustments in parallel to improve performance
        await Promise.all([
          // 1. PROACTIVE CONFLICT DETECTION
          // Since stock was reduced, re-evaluate all future orders for this product
          orderRepository.syncProductConflicts(productId),

          // 2. Decrement/delete cleaning record for write-off since it shouldn't be cleaned
          (async () => {
            try {
              const activeCleaningRes = await cleaningRepository.findActiveByOrderAndProduct(
                orderId,
                productId
              );

              if (activeCleaningRes.success && activeCleaningRes.data) {
                const cleaningRecord = activeCleaningRes.data;
                if (cleaningRecord.quantity > 1) {
                  await cleaningRepository.update(cleaningRecord.id, {
                    quantity: cleaningRecord.quantity - 1,
                    notes: cleaningRecord.notes
                      ? `${cleaningRecord.notes} — 1 unit written off`
                      : '1 unit written off',
                  });
                } else {
                  // Delete cleaning record if quantity goes to 0
                  await cleaningRepository.delete(cleaningRecord.id);
                }

                // Sync order priority flag since the cleaning records changed
                await orderRepository.syncOrderPriorityFlag(orderId);
              }
            } catch (err) {
              console.error('[DamageAssessmentService] Failed to adjust cleaning record for write-off:', err);
            }
          })()
        ]);
      }
    }

    return result;
  }

  /**
   * Check if all assessments for an order are complete.
   */
  async checkAllAssessed(orderId: string) {
    return damageAssessmentRepository.checkAllAssessed(orderId);
  }
}

export const damageAssessmentService = new DamageAssessmentService();
