/**
 * Cleaning Repository
 *
 * Data access layer for cleaning records using Supabase.
 *
 * @module repository/cleaningRepository
 */

import { BaseRepository, RepositoryResult } from './supabaseClient';
import { 
  CleaningRecord, 
  CreateCleaningRecordDTO, 
  UpdateCleaningRecordDTO,
  CleaningSearchParams,
  CleaningStatus
} from '@/domain';

export class CleaningRepository extends BaseRepository {
  private readonly TABLE = 'cleaning_records';

  /**
   * Find all cleaning records with optional filters
   */
  async findMany(params: CleaningSearchParams = {}): Promise<RepositoryResult<CleaningRecord[]>> {
    return this.executeOperation(async () => {
      let query = this.client
        .from(this.TABLE)
        .select('*, product:products(name, images)')
        .order('priority', { ascending: false })
        .order('created_at', { ascending: true });

      if (params.branch_id) query = query.eq('branch_id', params.branch_id);
      if (params.status) query = query.eq('status', params.status);
      if (params.priority) query = query.eq('priority', params.priority);
      if (params.product_id) query = query.eq('product_id', params.product_id);
      if (params.order_id) query = query.eq('order_id', params.order_id);

      return query;
    });
  }

  /**
   * Find a single cleaning record by ID
   */
  async findById(id: string): Promise<RepositoryResult<CleaningRecord>> {
    return this.executeOperation(async () => {
      return this.client
        .from(this.TABLE)
        .select('*, product:products(name, images)')
        .eq('id', id)
        .single();
    });
  }

  /**
   * Create a new cleaning record
   */
  async create(data: CreateCleaningRecordDTO): Promise<RepositoryResult<CleaningRecord>> {
    return this.executeOperation(async () => {
      return this.client
        .from(this.TABLE)
        .insert({
          ...data,
          ...this.getCreateAuditFields(),
        })
        .select()
        .single();
    });
  }

  /**
   * Update a cleaning record
   */
  async update(id: string, data: UpdateCleaningRecordDTO): Promise<RepositoryResult<CleaningRecord>> {
    return this.executeOperation(async () => {
      return this.client
        .from(this.TABLE)
        .update({
          ...data,
          ...this.getUpdateAuditFields(),
          updated_at: new Date().toISOString(),
        })
        .eq('id', id)
        .select()
        .single();
    });
  }

  /**
   * Delete a cleaning record
   */
  async delete(id: string): Promise<RepositoryResult<void>> {
    return this.executeOperation(async () => {
      return this.client
        .from(this.TABLE)
        .delete()
        .eq('id', id);
    });
  }

  /**
   * Get active cleaning count for a branch
   */
  async getActiveCount(branchId: string): Promise<number> {
    const { count } = await this.client
      .from(this.TABLE)
      .select('*', { count: 'exact', head: true })
      .eq('branch_id', branchId)
      .in('status', [CleaningStatus.PENDING, CleaningStatus.IN_PROGRESS]);
    
    return count || 0;
  }
}

export const cleaningRepository = new CleaningRepository();
