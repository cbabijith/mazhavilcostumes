/**
 * Settings Service
 *
 * Business logic layer for settings entities.
 *
 * @module services/settingsService
 */

import { RepositoryResult } from '@/repository';
import {
  Setting,
  SettingKey,
  UpdateSettingDTO
} from '@/domain/types/settings';
import { DEFAULT_GST_SLABS } from '@/domain/types/category';
import { settingsRepository } from '@/repository';

export class SettingsService {
  private currentUserId: string | null = null;
  private currentBranchId: string | null = null;
  private storeId: string = '00000000-0000-0000-0000-000000000001'; // Default store ID - matches branchService pattern

  /**
   * Set user context for audit logging
   */
  setUserContext(userId: string | null, branchId: string | null): void {
    this.currentUserId = userId;
    this.currentBranchId = branchId;
  }

  /**
   * Set store ID
   */
  setStoreId(storeId: string): void {
    this.storeId = storeId;
  }

  /**
   * Check if GST is enabled for the store
   */
  async getIsGSTEnabled(): Promise<RepositoryResult<boolean>> {
    const result = await settingsRepository.findByStoreAndKey(this.storeId, SettingKey.IS_GST_ENABLED);
    
    if (!result.success || !result.data) {
      // Default to false (disabled) if not set
      return {
        data: false,
        error: null,
        success: true,
      };
    }

    return {
      data: result.data.value === 'true',
      error: null,
      success: true,
    };
  }

  /**
   * Enable or disable GST for the store
   */
  async setIsGSTEnabled(isEnabled: boolean): Promise<RepositoryResult<Setting>> {
    return await settingsRepository.upsert(
      this.storeId,
      SettingKey.IS_GST_ENABLED,
      isEnabled ? 'true' : 'false',
      this.currentUserId
    );
  }

  /**
   * Set a generic string value for a setting key
   */
  async setValue(key: SettingKey, value: string): Promise<RepositoryResult<Setting>> {
    return await settingsRepository.upsert(
      this.storeId,
      key,
      value,
      this.currentUserId
    );
  }

  /**
   * Get all settings for the store
   */
  async getAllSettings(): Promise<RepositoryResult<Setting[]>> {
    return await settingsRepository.findAllByStore(this.storeId);
  }

  /**
   * Get a setting by key
   */
  async findByKey(key: string): Promise<RepositoryResult<Setting | null>> {
    const result = await settingsRepository.findByStoreAndKey(this.storeId, key as SettingKey);
    return result;
  }

  /**
   * Get the list of configured GST percentage slabs.
   *
   * Stored as a JSON-stringified array under the `gst_slabs` setting key.
   * Returns the DEFAULT_GST_SLABS fallback when the setting is missing,
   * empty, or fails to parse — the app must never break because of a bad
   * config value.
   */
  async getGstSlabs(): Promise<RepositoryResult<number[]>> {
    const result = await settingsRepository.findByStoreAndKey(this.storeId, SettingKey.GST_SLABS);
    if (!result.success || !result.data) {
      return { data: [...DEFAULT_GST_SLABS], error: null, success: true };
    }
    try {
      const parsed = JSON.parse(result.data.value);
      if (!Array.isArray(parsed) || parsed.length === 0) {
        return { data: [...DEFAULT_GST_SLABS], error: null, success: true };
      }
      // Coerce to numbers, filter invalid, dedupe, sort ascending
      const slabs = Array.from(new Set(parsed.map(Number)))
        .filter((n) => Number.isFinite(n) && n >= 0 && n <= 100)
        .sort((a, b) => a - b);
      return { data: slabs.length > 0 ? slabs : [...DEFAULT_GST_SLABS], error: null, success: true };
    } catch {
      return { data: [...DEFAULT_GST_SLABS], error: null, success: true };
    }
  }

  /**
   * Set the list of configured GST percentage slabs.
   *
   * Validates: non-empty, every value is a finite number in [0, 100],
   * no duplicates. Serializes as JSON and stores via the standard setting key.
   */
  async setGstSlabs(slabs: number[]): Promise<RepositoryResult<Setting>> {
    if (!Array.isArray(slabs) || slabs.length === 0) {
      return {
        data: null,
        error: { message: 'At least one GST slab is required', code: 'VALIDATION_ERROR' } as any,
        success: false,
      };
    }
    const cleaned = Array.from(new Set(slabs.map(Number)))
      .filter((n) => Number.isFinite(n) && n >= 0 && n <= 100)
      .sort((a, b) => a - b);
    if (cleaned.length === 0) {
      return {
        data: null,
        error: { message: 'All GST slabs must be numbers between 0 and 100', code: 'VALIDATION_ERROR' } as any,
        success: false,
      };
    }
    return await settingsRepository.upsert(
      this.storeId,
      SettingKey.GST_SLABS,
      JSON.stringify(cleaned),
      this.currentUserId
    );
  }
}

// Singleton instance
export const settingsService = new SettingsService();
