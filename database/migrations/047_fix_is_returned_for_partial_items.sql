-- 044: Repair is_returned flags for partially returned order items
--
-- Background: before the partial-return feature, orderRepository.processReturn
-- stamped is_returned = true on every item it touched, even when only part of
-- the item's quantity had actually come back (e.g. quantity 3, returned 2).
-- That made partially returned items show as "Returned" in the admin UI.
--
-- New code sets is_returned = (returned_quantity >= quantity). This migration
-- repairs historical rows so existing partial orders display correctly.
--
-- Safe / idempotent: only flips rows that are currently inconsistent.

UPDATE order_items
SET is_returned = FALSE,
    updated_at = NOW()
WHERE is_returned = TRUE
  AND COALESCE(returned_quantity, 0) < quantity;

-- Defensive counterpart: make sure fully returned items are flagged as such.
UPDATE order_items
SET is_returned = TRUE,
    updated_at = NOW()
WHERE is_returned = FALSE
  AND COALESCE(returned_quantity, 0) >= quantity;
