/**
 * Settings Domain Types
 *
 * Type definitions for the settings domain.
 *
 * @module domain/types/settings
 */

// Setting Key Enum
export enum SettingKey {
  IS_GST_ENABLED = 'is_gst_enabled',
  INVOICE_PREFIX = 'invoice_prefix',
  PAYMENT_TERMS = 'payment_terms',
  AUTHORIZED_SIGNATURE = 'authorized_signature',
  GST_NUMBER = 'gst_number',
}

/** GSTIN format: state code, PAN, entity code, Z, and checksum character. */
export const GSTIN_PATTERN = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$/;

/** Mazhavil's default invoice GSTIN, used only when no value is configured. */
export const DEFAULT_GST_NUMBER = '32ATOPS2936C1ZO';

// Setting Entity
export interface Setting {
  readonly id: string;
  readonly store_id: string;
  key: SettingKey;
  value: string;
  readonly updated_by: string | null;
  readonly updated_at: string;
}

// Create Setting DTO
export interface CreateSettingDTO {
  store_id: string;
  key: SettingKey;
  value: string;
  updated_by?: string;
}

// Update Setting DTO
export interface UpdateSettingDTO {
  value: string;
  updated_by?: string;
}

// Setting Validation Result
export interface SettingValidationResult {
  is_valid: boolean;
  errors: string[];
}
