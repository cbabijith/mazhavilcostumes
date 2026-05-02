/**
 * Discount Permission Hooks
 *
 * Checks whether the current user can apply product-level
 * or order-level discounts based on their role and staff toggles.
 *
 * Admin always has full discount access.
 * Manager/Staff need explicit toggles enabled.
 *
 * @module hooks/useDiscountPermission
 */

import { useAppStore } from '@/stores';
import { usePermissions } from './usePermissions';

/**
 * Check if current user can apply product-level discounts
 * (edit rent amount + per-item discount)
 */
export function useProductDiscountPermission(): boolean {
  const { isAdmin } = usePermissions();
  const user = useAppStore((s) => s.user);
  return isAdmin || user?.can_give_product_discount === true;
}

/**
 * Check if current user can apply order-level discounts
 */
export function useOrderDiscountPermission(): boolean {
  const { isAdmin } = usePermissions();
  const user = useAppStore((s) => s.user);
  return isAdmin || user?.can_give_order_discount === true;
}
