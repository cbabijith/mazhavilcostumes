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
   * cleaning_records table has NO audit columns (created_by, created_at_branch_id, etc.)
   * Override to prevent BaseRepository from injecting non-existent columns.
   */
  protected getCreateAuditFields(): any {
    return {};
  }

  protected getUpdateAuditFields(): any {
    return {};
  }

  /**
   * Find all cleaning records with optional filters
   */
  async findMany(params: CleaningSearchParams = {}): Promise<RepositoryResult<CleaningRecord[]>> {
    return this.executeOperation(async () => {
      let query = this.client
        .from(this.TABLE)
        .select('*, product:products(name, images)')
      if (params.branch_id) query = query.eq('branch_id', params.branch_id);
      if (params.status) query = query.eq('status', params.status);
      if (params.priority) query = query.eq('priority', params.priority);
      if (params.product_id) query = query.eq('product_id', params.product_id);
      if (params.order_id) query = query.eq('order_id', params.order_id);

      // Apply sorting
      if (params.sort_by) {
        const ascending = params.sort_order === 'asc';
        if (params.sort_by === 'product_name') {
          // Join-based sorting for product name
          query = query.order('name', { referencedTable: 'products', ascending });
        } else {
          query = query.order(params.sort_by, { ascending });
        }
      } else {
        // Default sort: Urgent first, then returning soonest first
        query = query
          .order('priority', { ascending: false })
          .order('expected_return_date', { ascending: true })
          .order('created_at', { ascending: false });
      }

      const response = await query;
      return response;
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
   * Get active cleaning count for a branch (includes scheduled)
   */
  async getActiveCount(branchId: string): Promise<number> {
    const { count } = await this.client
      .from(this.TABLE)
      .select('*', { count: 'exact', head: true })
      .eq('branch_id', branchId)
      .in('status', [CleaningStatus.SCHEDULED, CleaningStatus.PENDING, CleaningStatus.IN_PROGRESS]);
    
    return count || 0;
  }

  /**
   * Find scheduled/in-progress cleaning records for a product.
   * Used to check upcoming cleaning needs during availability check.
   */
  async findScheduledForProduct(productId: string): Promise<RepositoryResult<CleaningRecord[]>> {
    return this.executeOperation(async () => {
      return this.client
        .from(this.TABLE)
        .select('*, product:products(name, images)')
        .eq('product_id', productId)
        .in('status', ['scheduled', 'in_progress'])
        .order('expected_return_date', { ascending: true });
    });
  }

  /**
   * Find the first cleaning record for an order + product pair.
   * Used by priority recalculation where we just need any record for the pair.
   * Note: After partial-return splits, multiple records may exist for the same pair.
   */
  async findByOrderAndProduct(orderId: string, productId: string): Promise<RepositoryResult<CleaningRecord | null>> {
    return this.executeOperation(async () => {
      return this.client
        .from(this.TABLE)
        .select('*')
        .eq('order_id', orderId)
        .eq('product_id', productId)
        .order('created_at', { ascending: true })
        .limit(1)
        .maybeSingle();
    });
  }

  /**
   * Find the SCHEDULED cleaning record for an order + product pair.
   * Used during return processing — specifically targets the scheduled record
   * so that partial returns can split it without touching in_progress records.
   */
  async findScheduledByOrderAndProduct(orderId: string, productId: string): Promise<RepositoryResult<CleaningRecord | null>> {
    return this.executeOperation(async () => {
      return this.client
        .from(this.TABLE)
        .select('*')
        .eq('order_id', orderId)
        .eq('product_id', productId)
        .eq('status', CleaningStatus.SCHEDULED)
        .limit(1)
        .maybeSingle();
    });
  }

  /**
   * Find all cleaning records whose buffer period has expired.
   * Buffer = 1 calendar day after started_at.
   * A record is expired when: started_at::date + bufferDays <= today.
   *
   * @param bufferDays Number of full calendar days after started_at before auto-complete
   * @returns Records ready for auto-completion
   */
  async findExpiredInProgress(bufferDays: number = 1): Promise<RepositoryResult<CleaningRecord[]>> {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - bufferDays);
    const cutoffStr = cutoffDate.toISOString().split('T')[0];

    return this.executeOperation(async () => {
      return this.client
        .from(this.TABLE)
        .select('*')
        .eq('status', CleaningStatus.IN_PROGRESS)
        .lte('started_at', cutoffStr + 'T23:59:59Z');
    });
  }

  /**
   * Find all cleaning records that reference a specific order as priority_order_id.
   * Used to downgrade priority when the requesting order is cancelled.
   */
  async findByPriorityOrderId(priorityOrderId: string): Promise<RepositoryResult<CleaningRecord[]>> {
    return this.executeOperation(async () => {
      return this.client
        .from(this.TABLE)
        .select('*')
        .eq('priority_order_id', priorityOrderId);
    });
  }

  /**
   * Find all cleaning records for a specific order (by order_id).
   * Used to delete a cancelled order's own scheduled cleaning records.
   */
  async findByOrderId(orderId: string): Promise<RepositoryResult<CleaningRecord[]>> {
    return this.executeOperation(async () => {
      return this.client
        .from(this.TABLE)
        .select('*')
        .eq('order_id', orderId);
    });
  }
}

export const cleaningRepository = new CleaningRepository();

