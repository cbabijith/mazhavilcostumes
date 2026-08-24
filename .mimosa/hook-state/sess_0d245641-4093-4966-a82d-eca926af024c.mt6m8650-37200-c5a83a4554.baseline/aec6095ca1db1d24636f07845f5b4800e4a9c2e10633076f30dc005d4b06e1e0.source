/**
 * Damage Assessment Types
 *
 * Types and interfaces for the post-return damage assessment workflow.
 * Each damaged unit from a returned order gets an individual assessment
 * so the admin can decide whether to reuse or write off the item.
 *
 * @module domain/types/damageAssessment
 */

/** Decision options for a damaged unit */
export enum DamageDecision {
  PENDING = 'pending',
  REUSE = 'reuse',
  NOT_REUSE = 'not_reuse',
}

/** Core Damage Assessment entity (mirrors DB row) */
export interface DamageAssessment {
  readonly id: string;
  readonly order_id: string;
  readonly order_item_id: string;
  readonly product_id: string;
  readonly branch_id: string;
  readonly unit_index: number;
  decision: DamageDecision;
  notes?: string;
  assessed_by?: string;
  assessed_at?: string;
  readonly created_at: string;
  readonly updated_at: string;
}

/** Damage Assessment with product relation for display */
export interface DamageAssessmentWithProduct extends DamageAssessment {
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
  order_item?: {
    id: string;
    quantity: number;
    damage_description?: string;
    damage_charges?: number;
    condition_rating?: string;
  };
  order?: {
    id: string;
    status: string;
    customer?: { name: string };
  };
}

/** DTO for creating damage assessments batch */
export interface CreateDamageAssessmentsDTO {
  order_id: string;
  items: Array<{
    order_item_id: string;
    product_id: string;
    branch_id: string;
    damaged_quantity: number;
  }>;
}

/** DTO for updating a single assessment decision */
export interface UpdateDamageAssessmentDTO {
  decision: DamageDecision;
  notes?: string;
}
