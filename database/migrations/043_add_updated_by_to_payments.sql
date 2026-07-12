-- Migration 043: Add Updated By Column to Payments Table
-- Adds updated_by column to the payments table for tracking who modified the payments.

ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES public.staff(id);
