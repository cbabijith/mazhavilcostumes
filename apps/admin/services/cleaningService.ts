/**
 * Cleaning Service
 *
 * Business logic layer for cleaning operations.
 *
 * @module services/cleaningService
 */

import { 
  CleaningRecord, 
  CreateCleaningRecordDTO, 
  UpdateCleaningRecordDTO,
  CleaningSearchParams,
  CleaningStatus,
  CleaningPriority
} from '@/domain';
import { cleaningRepository } from '@/repository/cleaningRepository';
import { RepositoryResult } from '@/repository/supabaseClient';

export class CleaningService {
  /**
   * Get cleaning queue for a branch
   */
  async getQueue(branchId: string, status?: CleaningStatus): Promise<RepositoryResult<CleaningRecord[]>> {
    return cleaningRepository.findMany({ 
      branch_id: branchId, 
      status: status || undefined 
    });
  }

  /**
   * Create a cleaning record (usually triggered by order return)
   */
  async createRecord(data: CreateCleaningRecordDTO): Promise<RepositoryResult<CleaningRecord>> {
    // Basic validation
    if (data.quantity <= 0) {
      return {
        data: null,
        error: { message: 'Quantity must be greater than 0', code: 'VALIDATION_ERROR' } as any,
        success: false
      };
    }

    return cleaningRepository.create(data);
  }

  /**
   * Start cleaning
   */
  async startCleaning(id: string): Promise<RepositoryResult<CleaningRecord>> {
    return cleaningRepository.update(id, {
      status: CleaningStatus.IN_PROGRESS,
      started_at: new Date().toISOString()
    });
  }

  /**
   * Complete cleaning
   */
  async completeCleaning(id: string): Promise<RepositoryResult<CleaningRecord>> {
    return cleaningRepository.update(id, {
      status: CleaningStatus.COMPLETED,
      completed_at: new Date().toISOString()
    });
  }

  /**
   * Update priority
   */
  async updatePriority(id: string, priority: CleaningPriority, priorityOrderId?: string): Promise<RepositoryResult<CleaningRecord>> {
    return cleaningRepository.update(id, {
      priority,
      priority_order_id: priorityOrderId
    });
  }

  /**
   * Get metrics for dashboard
   */
  async getDashboardMetrics(branchId: string) {
    const queueResult = await cleaningRepository.findMany({ 
      branch_id: branchId,
      status: CleaningStatus.IN_PROGRESS 
    });
    
    const urgentCount = queueResult.data?.filter(r => r.priority === CleaningPriority.URGENT).length || 0;
    const totalCount = queueResult.data?.length || 0;

    return {
      urgentCount,
      totalCount,
      queue: queueResult.data || []
    };
  }

  /**
   * Auto-complete cleaning records whose buffer period has expired.
   * Called by the daily cron job.
   *
   * Buffer = 1 calendar day after started_at.
   * Records with started_at::date + 1 <= today are marked completed.
   *
   * @param bufferDays Number of buffer days (default: 1)
   * @returns Number of records auto-completed
   */
  async autoCompleteExpiredCleaning(bufferDays: number = 1): Promise<number> {
    const expired = await cleaningRepository.findExpiredInProgress(bufferDays);
    if (!expired.success || !expired.data || expired.data.length === 0) return 0;

    let count = 0;
    for (const record of expired.data) {
      const result = await cleaningRepository.update(record.id, {
        status: CleaningStatus.COMPLETED,
        completed_at: new Date().toISOString(),
      });
      if (result.success) count++;
    }

    console.log(`[Cleaning Cron] Auto-completed ${count} cleaning records (buffer: ${bufferDays} day(s))`);
    return count;
  }
}

export const cleaningService = new CleaningService();
