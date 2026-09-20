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
  /** JSON-stringified array of available GST percentage slabs, e.g. "[0,5,12,18,28]". */
  GST_SLABS = 'gst_slabs',
  /** The business's GST identification number (GSTIN) printed on invoices. */
  GST_NUMBER = 'gst_number',
}

/**
 * Indian GSTIN format: 2-digit state code + 10-char PAN + 1 entity code +
 * 'Z' + 1 checksum char (alphanumeric). Example: 32ATOPS2936C1ZO
 */
export const GSTIN_PATTERN = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/;

/** Default GSTIN shown/used until the merchant edits it in Settings. */
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
