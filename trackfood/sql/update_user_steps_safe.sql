-- TrackFood Flutter - SAFE User Steps Table Update
-- This script only adds missing RLS policies and indexes to existing user_steps table

DO $$
DECLARE
    policy_exists BOOLEAN;
    index_exists BOOLEAN;
BEGIN
    -- Check if user_steps table exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_steps') THEN
        RAISE EXCEPTION 'Table user_steps does not exist. Please create it first.';
    END IF;

    RAISE NOTICE 'Table user_steps already exists - updating RLS policies and indexes';

    -- ===== ENABLE RLS =====
    ALTER TABLE public.user_steps ENABLE ROW LEVEL SECURITY;
    RAISE NOTICE 'Row Level Security enabled for user_steps table';

    -- ===== CREATE MISSING POLICIES =====

    -- Policy 1: SELECT
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'user_steps' AND policyname = 'Enable read access for own user'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Enable read access for own user"
        ON public.user_steps
        FOR SELECT
        USING (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Enable read access for own user';
    ELSE
        RAISE NOTICE 'Policy already exists: Enable read access for own user';
    END IF;

    -- Policy 2: INSERT
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'user_steps' AND policyname = 'Enable insert for own user'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Enable insert for own user"
        ON public.user_steps
        FOR INSERT
        WITH CHECK (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Enable insert for own user';
    ELSE
        RAISE NOTICE 'Policy already exists: Enable insert for own user';
    END IF;

    -- Policy 3: UPDATE
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'user_steps' AND policyname = 'Enable update for own user'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Enable update for own user"
        ON public.user_steps
        FOR UPDATE
        USING (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Enable update for own user';
    ELSE
        RAISE NOTICE 'Policy already exists: Enable update for own user';
    END IF;

    -- Policy 4: DELETE
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'user_steps' AND policyname = 'Enable delete for own user'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Enable delete for own user"
        ON public.user_steps
        FOR DELETE
        USING (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Enable delete for own user';
    ELSE
        RAISE NOTICE 'Policy already exists: Enable delete for own user';
    END IF;

    -- ===== CREATE MISSING INDEX =====
    
    -- Check if performance index exists
    SELECT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'user_steps' AND indexname = 'idx_user_steps_user_date'
    ) INTO index_exists;
    
    IF NOT index_exists THEN
        CREATE INDEX idx_user_steps_user_date ON public.user_steps(user_id, date);
        RAISE NOTICE 'Created index: idx_user_steps_user_date';
    ELSE
        RAISE NOTICE 'Index already exists: idx_user_steps_user_date';
    END IF;

    -- ===== VERIFY TABLE STRUCTURE =====
    
    -- Check if required columns exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_steps' AND column_name = 'user_id'
    ) THEN
        RAISE WARNING 'Column user_id missing in user_steps table';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_steps' AND column_name = 'date'
    ) THEN
        RAISE WARNING 'Column date missing in user_steps table';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_steps' AND column_name = 'steps'
    ) THEN
        RAISE WARNING 'Column steps missing in user_steps table';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_steps' AND column_name = 'source'
    ) THEN
        RAISE WARNING 'Column source missing in user_steps table';
    END IF;

    RAISE NOTICE '=== USER STEPS TABLE UPDATE COMPLETED ===';
    RAISE NOTICE 'All RLS policies and indexes are now properly configured.';
END $$;

-- Show current table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_steps'
ORDER BY ordinal_position;

-- Show current policies
SELECT 
    policyname,
    cmd,
    permissive,
    roles,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'user_steps';

-- Success message
SELECT 'User Steps table successfully updated with RLS policies!' as status;