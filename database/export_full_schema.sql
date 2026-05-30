-- ============================================================================
-- Complete Database Schema Export
-- Run this in Supabase SQL Editor to export full schema
-- Copy all results to save your complete database structure
-- ============================================================================

-- 1. All Tables and Columns
SELECT 
    'TABLES' as section,
    t.table_name,
    c.column_name,
    c.ordinal_position,
    c.column_default,
    c.is_nullable,
    c.data_type,
    c.character_maximum_length,
    c.numeric_precision,
    c.numeric_scale,
    c.is_identity,
    c.identity_generation
FROM information_schema.tables t
LEFT JOIN information_schema.columns c ON t.table_name = c.table_name AND t.table_schema = c.table_schema
WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name, c.ordinal_position;

-- 2. Primary Keys
SELECT 
    'PRIMARY_KEYS' as section,
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;

-- 3. Foreign Keys
SELECT 
    'FOREIGN_KEYS' as section,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    tc.constraint_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;

-- 4. Unique Constraints
SELECT 
    'UNIQUE_CONSTRAINTS' as section,
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'UNIQUE'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;

-- 5. Check Constraints
SELECT 
    'CHECK_CONSTRAINTS' as section,
    tc.table_name,
    cc.check_clause,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc
    ON tc.constraint_name = cc.constraint_name
WHERE tc.constraint_type = 'CHECK'
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_name;

-- 6. All Indexes
SELECT 
    'INDEXES' as section,
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- 7. All Functions (RPCs)
SELECT 
    'FUNCTIONS' as section,
    routine_name,
    routine_type,
    data_type,
    routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND routine_type = 'FUNCTION'
ORDER BY routine_name;

-- 8. All Triggers
SELECT 
    'TRIGGERS' as section,
    trigger_name,
    event_object_table,
    action_statement,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- 9. Table Comments
SELECT 
    'TABLE_COMMENTS' as section,
    t.table_name,
    pgd.description
FROM information_schema.tables t
LEFT JOIN pg_description pgd ON pgd.objoid = (SELECT oid FROM pg_class WHERE relname = t.table_name)
    AND pgd.objsubid = 0
WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name;

-- 10. Column Comments
SELECT 
    'COLUMN_COMMENTS' as section,
    t.table_name,
    c.column_name,
    pgd.description
FROM information_schema.tables t
JOIN information_schema.columns c ON t.table_name = c.table_name AND t.table_schema = c.table_schema
LEFT JOIN pg_description pgd ON pgd.objoid = (SELECT oid FROM pg_class WHERE relname = t.table_name)
    AND pgd.objsubid = c.ordinal_position
WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name, c.ordinal_position;
