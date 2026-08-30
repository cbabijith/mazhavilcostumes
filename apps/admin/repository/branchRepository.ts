/**
 * Branch Repository
 *
 * Data access layer for the branches table.
 *
 * @module repository/branchRepository
 */

import { BaseRepository, RepositoryResult } from './supabaseClient';
import {
  Branch,
  BranchWithStaffCount,
  CreateBranchDTO,
  UpdateBranchDTO,
} from '@/domain/types/branch';

export class BranchRepository extends BaseRepository {
  private readonly tableName = 'branches';

  // Branch rows are tiny and rarely change, but they're read on nearly every
  // product/order request for the branch-permission check. A short in-memory
  // cache removes that round trip from hot paths (invalidated on update/delete).
  private static branchCache = new Map<string, { value: Branch | null; expiresAt: number }>();
  private static readonly BRANCH_TTL_MS = 5 * 60_000;

  async findAll(storeId: string): Promise<RepositoryResult<Branch[]>> {
    const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!storeId || !uuidPattern.test(storeId)) {
      return { data: [], error: null, success: true };
    }

    const { data, error } = await this.client
      .from(this.tableName)
      .select('*')
      .eq('store_id', storeId)
      .order('is_main', { ascending: false })
      .order('name');

    return this.handleResponse<Branch[]>({ data, error });
  }

  async findAllWithStaffCount(storeId: string): Promise<RepositoryResult<BranchWithStaffCount[]>> {
    const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!storeId || !uuidPattern.test(storeId)) {
      return { data: [], error: null, success: true };
    }

    // Use count query instead of embed to avoid ambiguous relationship error
    const { data: branches, error } = await this.client
      .from(this.tableName)
      .select('*')
      .eq('store_id', storeId)
      .order('is_main', { ascending: false })
      .order('name');

    if (error) return this.handleResponse<BranchWithStaffCount[]>({ data: null, error });

    // Get staff count for each branch
    const branchIds = (branches || []).map((b: any) => b.id);
    const { data: staffCounts, error: countError } = await this.client
      .from('staff')
      .select('branch_id')
      .in('branch_id', branchIds);

    if (countError) {
      // If count fails, return branches with 0 count
      const mapped = (branches || []).map((b: any) => ({
        ...b,
        staff_count: 0,
      }));
      return { data: mapped, error: null, success: true };
    }

    // Count staff per branch
    const countMap = (staffCounts || []).reduce((acc: Record<string, number>, s: any) => {
      acc[s.branch_id] = (acc[s.branch_id] || 0) + 1;
      return acc;
    }, {});

    const mapped = (branches || []).map((b: any) => ({
      ...b,
      staff_count: countMap[b.id] || 0,
    }));

    return { data: mapped, error: null, success: true };
  }

  async findById(id: string): Promise<RepositoryResult<Branch>> {
    const cached = BranchRepository.branchCache.get(id);
    if (cached) {
      if (Date.now() <= cached.expiresAt && cached.value) {
        return { data: cached.value, error: null, success: true };
      }
      BranchRepository.branchCache.delete(id);
    }

    const { data, error } = await this.client
      .from(this.tableName)
      .select('*')
      .eq('id', id)
      .single();

    const result = this.handleResponse<Branch>({ data, error });
    if (result.success && result.data) {
      BranchRepository.branchCache.set(id, {
        value: result.data,
        expiresAt: Date.now() + BranchRepository.BRANCH_TTL_MS,
      });
    }
    return result;
  }

  async create(data: CreateBranchDTO): Promise<RepositoryResult<Branch>> {
    const { data: branch, error } = await this.client
      .from(this.tableName)
      .insert({ ...data, ...this.getCreateAuditFields() })
      .select()
      .single();

    return this.handleResponse<Branch>({ data: branch, error });
  }

  async update(id: string, data: UpdateBranchDTO): Promise<RepositoryResult<Branch>> {
    const { data: branch, error } = await this.client
      .from(this.tableName)
      .update({ ...data, updated_at: new Date().toISOString(), ...this.getUpdateAuditFields() })
      .eq('id', id)
      .select()
      .single();

    const result = this.handleResponse<Branch>({ data: branch, error });
    if (result.success) BranchRepository.branchCache.delete(id);
    return result;
  }

  async delete(id: string): Promise<RepositoryResult<boolean>> {
    const { error } = await this.client.from(this.tableName).delete().eq('id', id);

    if (error) return { data: null, error, success: false };
    BranchRepository.branchCache.delete(id);
    return { data: true, error: null, success: true };
  }

  async canDelete(id: string): Promise<RepositoryResult<{ canDelete: boolean; reason?: string }>> {
    const { count, error } = await this.client
      .from('staff')
      .select('*', { count: 'exact', head: true })
      .eq('branch_id', id);

    if (error) return { data: null, error, success: false };

    if ((count ?? 0) > 0) {
      return {
        data: {
          canDelete: false,
          reason: `Branch has ${count} staff member(s). Remove or reassign them first.`,
        },
        error: null,
        success: true,
      };
    }

    return { data: { canDelete: true }, error: null, success: true };
  }
}

export const branchRepository = new BranchRepository();
