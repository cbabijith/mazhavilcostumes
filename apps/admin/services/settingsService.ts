/**
 * Settings Service
 *
 * Business logic layer for settings entities.
 *
 * @module services/settingsService
 */

import { RepositoryResult, RepositoryError } from '@/repository';
import { 
  Setting, 
  SettingKey,
  GSTIN_PATTERN,
  DEFAULT_GST_NUMBER,
} from '@/domain';
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
    if (key === SettingKey.GST_NUMBER) return this.setGstNumber(value);
    return await settingsRepository.upsert(
      this.storeId,
      key,
      value,
      this.currentUserId
    );
  }

  /**
   * Resolve the invoice GSTIN from the setting, store, then Mazhavil default.
   * An explicitly empty setting suppresses the GSTIN; read failures propagate.
   * @returns The resolved GSTIN or a repository error.
   */
  async getGstNumber(): Promise<RepositoryResult<string>> {
    const result = await settingsRepository.findByStoreAndKey(this.storeId, SettingKey.GST_NUMBER);
    if (!result.success) return { ...result, data: null };
    if (result.data) return { data: result.data.value.trim(), error: null, success: true };

    const storeResult = await settingsRepository.getStoreGstin(this.storeId);
    if (!storeResult.success) return { ...storeResult, data: null };
    return { data: storeResult.data?.trim() || DEFAULT_GST_NUMBER, error: null, success: true };
  }

  /**
   * Validate and save the GSTIN; an empty string removes it from bills.
   * @param value GSTIN entered in invoice settings.
   * @returns The saved setting or a validation/repository error.
   */
  async setGstNumber(value: string): Promise<RepositoryResult<Setting>> {
    const cleaned = value.trim().toUpperCase();
    if (cleaned !== '' && !GSTIN_PATTERN.test(cleaned)) {
      return {
        data: null,
        error: new RepositoryError(
          'Invalid GSTIN: enter 15 characters like 32ATOPS2936C1ZO, or leave it empty.',
          'VALIDATION_ERROR',
        ),
        success: false,
      };
    }
    return settingsRepository.upsert(this.storeId, SettingKey.GST_NUMBER, cleaned, this.currentUserId);
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
}

// Singleton instance
export const settingsService = new SettingsService();
