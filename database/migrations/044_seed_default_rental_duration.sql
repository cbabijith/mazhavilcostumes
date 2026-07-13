-- Migration: Seed default rental duration settings
INSERT INTO public.settings (store_id, key, value)
SELECT id, 'default_rental_duration', '3'
FROM public.stores
ON CONFLICT (store_id, key) DO NOTHING;
