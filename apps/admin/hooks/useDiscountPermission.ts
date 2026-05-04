/**
 * Discount Permission Hooks (DEPRECATED)
 *
 * All staff roles can now apply discounts.
 * These hooks are kept for backward compatibility
 * but always return true.
 *
 * @module hooks/useDiscountPermission
 */

/**
 * Check if current user can apply product-level discounts.
 * Always returns true — all staff can give discounts.
 */
export function useProductDiscountPermission(): boolean {
  return true;
}

/**
 * Check if current user can apply order-level discounts.
 * Always returns true — all staff can give discounts.
 */
export function useOrderDiscountPermission(): boolean {
  return true;
}
