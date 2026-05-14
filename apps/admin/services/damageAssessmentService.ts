/**
 * Damage Assessment Service
 *
 * Business logic for damage assessment operations.
 * Handles assessment creation after returns, decision processing,
 * and stock adjustments for write-offs.
 *
 * @module services/damageAssessmentService
 */

import { damageAssessmentRepository, orderRepository } from '@/repository';
import type { RepositoryResult } from '@/repository/supabaseClient';
import type { DamageAssessment, DamageAssessmentWithProduct, CreateDamageAssessmentsDTO } from '@/domain';
import { DamageDecision } from '@/domain';

export class DamageAssessmentService {
  /**
   * Create damage assessments for all damaged items in a return.
   * Called after the return process when items have damage.
   */
  async createAssessments(dto: CreateDamageAssessmentsDTO): Promise<RepositoryResult<DamageAssessment[]>> {
    const allAssessments: DamageAssessment[] = [];

    for (const item of dto.items) {
      if (item.damaged_quantity <= 0) continue;

      const result = await damageAssessmentRepository.createBatch({
        order_id: dto.order_id,
        order_item_id: item.order_item_id,
        product_id: item.product_id,
        branch_id: item.branch_id,
        damaged_quantity: item.damaged_quantity,
      });

      if (result.success && result.data) {
        allAssessments.push(...result.data);
      } else if (!result.success) {
        return result;
      }
    }

    return { data: allAssessments, error: null, success: true };
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
        // PROACTIVE CONFLICT DETECTION
        // Since stock was reduced, re-evaluate all future orders for this product
        await orderRepository.syncProductConflicts(result.data.product_id);
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
