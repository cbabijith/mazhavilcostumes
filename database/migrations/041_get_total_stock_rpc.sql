-- Migration: Add get_total_stock RPC function
-- Replaces fetching all product rows and summing in JavaScript
-- Returns a single integer: SUM(quantity) for matching products

CREATE OR REPLACE FUNCTION get_total_stock(
  p_query TEXT DEFAULT NULL,
  p_category_id UUID DEFAULT NULL,
  p_store_id UUID DEFAULT NULL,
  p_branch_id UUID DEFAULT NULL,
  p_is_active BOOLEAN DEFAULT NULL,
  p_is_featured BOOLEAN DEFAULT NULL,
  p_min_price NUMERIC DEFAULT NULL,
  p_max_price NUMERIC DEFAULT NULL,
  p_in_stock BOOLEAN DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result INTEGER;
  where_clause TEXT := 'WHERE deleted_at IS NULL';
BEGIN
  IF p_query IS NOT NULL THEN
    where_clause := where_clause || format(
      ' AND (name ILIKE %L OR slug ILIKE %L OR sku ILIKE %L OR barcode ILIKE %L)',
      '%' || p_query || '%', '%' || p_query || '%', '%' || p_query || '%', '%' || p_query || '%'
    );
  END IF;

  IF p_category_id IS NOT NULL THEN
    where_clause := where_clause || format(' AND category_id = %L', p_category_id);
  END IF;

  IF p_store_id IS NOT NULL THEN
    where_clause := where_clause || format(' AND store_id = %L', p_store_id);
  END IF;

  IF p_is_active IS NOT NULL THEN
    where_clause := where_clause || format(' AND is_active = %L', p_is_active);
  END IF;

  IF p_is_featured IS NOT NULL THEN
    where_clause := where_clause || format(' AND is_featured = %L', p_is_featured);
  END IF;

  IF p_min_price IS NOT NULL THEN
    where_clause := where_clause || format(' AND price_per_day >= %L', p_min_price);
  END IF;

  IF p_max_price IS NOT NULL THEN
    where_clause := where_clause || format(' AND price_per_day <= %L', p_max_price);
  END IF;

  IF p_in_stock IS NOT NULL THEN
    IF p_in_stock THEN
      where_clause := where_clause || ' AND available_quantity > 0';
    ELSE
      where_clause := where_clause || ' AND available_quantity = 0';
    END IF;
  END IF;

  IF p_branch_id IS NOT NULL THEN
    where_clause := where_clause || format(' AND (branch_id = %L OR branch_id IS NULL)', p_branch_id);
  END IF;

  EXECUTE format('SELECT COALESCE(SUM(quantity), 0)::INTEGER FROM products %s', where_clause) INTO result;

  RETURN result;
END;
$$;

-- Grant access to authenticated users
GRANT EXECUTE ON FUNCTION get_total_stock TO authenticated;
GRANT EXECUTE ON FUNCTION get_total_stock TO anon;
