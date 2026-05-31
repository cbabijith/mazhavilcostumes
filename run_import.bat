@echo off
REM ============================================================================
-- Run Product Import SQL via Terminal
-- ============================================================================
REM
-- INSTRUCTIONS:
-- 1. Update the SERVICE_ROLE_KEY below with your actual service role key
-- 2. Update the DATABASE_URL with your Supabase project URL
-- 3. Run this script: run_import.bat
REM ============================================================================

SET SERVICE_ROLE_KEY=your-service-role-key-here
SET DATABASE_URL=postgresql://postgres.%SERVICE_ROLE_KEY%@aws-0-ap-south-1.pooler.supabase.com:6543/postgres

REM Run the SQL file
psql "%DATABASE_URL%" -f database\migrations\024_import_products_complete.sql

echo Import completed!
pause
