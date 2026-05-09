/**
 * Cleaning Domain Types
 *
 * @module domain/types/cleaning
 */

export enum CleaningStatus {
  SCHEDULED = 'scheduled',
  PENDING = 'pending',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
}

export enum CleaningPriority {
  NORMAL = 'normal',
  URGENT = 'urgent',
}

export interface CleaningRecord {
  id: string;
  product_id: string;
  order_id: string;
  branch_id: string;
  store_id?: string;
  quantity: number;
  status: CleaningStatus;
  priority: CleaningPriority;
  priority_order_id?: string | null;
  expected_return_date?: string | null;
  started_at?: string | null;
  completed_at?: string | null;
  notes?: string | null;
  created_at: string;
  updated_at: string;
  product?: {
    name: string;
    image_url?: string;
  };
}

export interface CreateCleaningRecordDTO {
  product_id: string;
  order_id: string;
  branch_id: string;
  store_id?: string;
  quantity: number;
  status?: CleaningStatus;
  priority?: CleaningPriority;
  priority_order_id?: string;
  expected_return_date?: string;
  notes?: string;
}

export interface UpdateCleaningRecordDTO {
  status?: CleaningStatus;
  priority?: CleaningPriority;
  priority_order_id?: string | null;
  expected_return_date?: string | null;
  started_at?: string | null;
  completed_at?: string | null;
  quantity?: number;
  notes?: string;
}

export interface CleaningSearchParams {
  branch_id?: string;
  status?: CleaningStatus;
  priority?: CleaningPriority;
  product_id?: string;
  order_id?: string;
}
