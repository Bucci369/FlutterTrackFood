-- TrackFood Flutter - SAFE RLS Policies Update
-- This script only creates policies that don't already exist

-- Enable Row Level Security at database level
ALTER DATABASE postgres SET row_security = on;

-- ===== SAFE POLICY CREATION FUNCTION =====
DO $$
DECLARE
    policy_exists BOOLEAN;
BEGIN
    -- Helper function to check if policy exists
    -- We'll use this pattern for all policies

    -- ===== PROFILES TABLE =====
    ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

    -- Check and create profiles policies
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'profiles' AND policyname = 'Users can view own profile'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can view own profile"
          ON public.profiles FOR SELECT
          USING (auth.uid() = id);
        RAISE NOTICE 'Created policy: Users can view own profile';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can view own profile';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'profiles' AND policyname = 'Users can insert own profile'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can insert own profile"
          ON public.profiles FOR INSERT
          WITH CHECK (auth.uid() = id);
        RAISE NOTICE 'Created policy: Users can insert own profile';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can insert own profile';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'profiles' AND policyname = 'Users can update own profile'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can update own profile"
          ON public.profiles FOR UPDATE
          USING (auth.uid() = id);
        RAISE NOTICE 'Created policy: Users can update own profile';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can update own profile';
    END IF;

    -- ===== DIARY_ENTRIES TABLE =====
    ALTER TABLE public.diary_entries ENABLE ROW LEVEL SECURITY;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'diary_entries' AND policyname = 'Users can view own diary entries'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can view own diary entries"
          ON public.diary_entries FOR SELECT
          USING (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Users can view own diary entries';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can view own diary entries';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'diary_entries' AND policyname = 'Users can insert own diary entries'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can insert own diary entries"
          ON public.diary_entries FOR INSERT
          WITH CHECK (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Users can insert own diary entries';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can insert own diary entries';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'diary_entries' AND policyname = 'Users can update own diary entries'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can update own diary entries"
          ON public.diary_entries FOR UPDATE
          USING (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Users can update own diary entries';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can update own diary entries';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'diary_entries' AND policyname = 'Users can delete own diary entries'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can delete own diary entries"
          ON public.diary_entries FOR DELETE
          USING (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Users can delete own diary entries';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can delete own diary entries';
    END IF;

    -- ===== WATER_INTAKE TABLE =====
    ALTER TABLE public.water_intake ENABLE ROW LEVEL SECURITY;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'water_intake' AND policyname = 'Users can view own water intake'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can view own water intake"
          ON public.water_intake FOR SELECT
          USING (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Users can view own water intake';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can view own water intake';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'water_intake' AND policyname = 'Users can insert own water intake'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can insert own water intake"
          ON public.water_intake FOR INSERT
          WITH CHECK (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Users can insert own water intake';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can insert own water intake';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'water_intake' AND policyname = 'Users can update own water intake'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can update own water intake"
          ON public.water_intake FOR UPDATE
          USING (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Users can update own water intake';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can update own water intake';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'water_intake' AND policyname = 'Users can delete own water intake'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can delete own water intake"
          ON public.water_intake FOR DELETE
          USING (auth.uid() = user_id);
        RAISE NOTICE 'Created policy: Users can delete own water intake';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can delete own water intake';
    END IF;

    -- ===== CHECK FOR OTHER TABLES =====
    -- Only create policies for tables that exist

    -- FASTING_SESSIONS
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'fasting_sessions') THEN
        ALTER TABLE public.fasting_sessions ENABLE ROW LEVEL SECURITY;
        
        SELECT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'fasting_sessions' AND policyname = 'Users can view own fasting sessions'
        ) INTO policy_exists;
        
        IF NOT policy_exists THEN
            CREATE POLICY "Users can view own fasting sessions"
              ON public.fasting_sessions FOR SELECT
              USING (auth.uid() = user_id);
            RAISE NOTICE 'Created policy: Users can view own fasting sessions';
        ELSE
            RAISE NOTICE 'Policy already exists: Users can view own fasting sessions';
        END IF;

        SELECT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'fasting_sessions' AND policyname = 'Users can insert own fasting sessions'
        ) INTO policy_exists;
        
        IF NOT policy_exists THEN
            CREATE POLICY "Users can insert own fasting sessions"
              ON public.fasting_sessions FOR INSERT
              WITH CHECK (auth.uid() = user_id);
            RAISE NOTICE 'Created policy: Users can insert own fasting sessions';
        ELSE
            RAISE NOTICE 'Policy already exists: Users can insert own fasting sessions';
        END IF;

        SELECT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'fasting_sessions' AND policyname = 'Users can update own fasting sessions'
        ) INTO policy_exists;
        
        IF NOT policy_exists THEN
            CREATE POLICY "Users can update own fasting sessions"
              ON public.fasting_sessions FOR UPDATE
              USING (auth.uid() = user_id);
            RAISE NOTICE 'Created policy: Users can update own fasting sessions';
        ELSE
            RAISE NOTICE 'Policy already exists: Users can update own fasting sessions';
        END IF;

        SELECT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'fasting_sessions' AND policyname = 'Users can delete own fasting sessions'
        ) INTO policy_exists;
        
        IF NOT policy_exists THEN
            CREATE POLICY "Users can delete own fasting sessions"
              ON public.fasting_sessions FOR DELETE
              USING (auth.uid() = user_id);
            RAISE NOTICE 'Created policy: Users can delete own fasting sessions';
        ELSE
            RAISE NOTICE 'Policy already exists: Users can delete own fasting sessions';
        END IF;
    ELSE
        RAISE NOTICE 'Table fasting_sessions does not exist - skipping policies';
    END IF;

    -- USER_ACTIVITIES
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_activities') THEN
        ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;
        
        SELECT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'user_activities' AND policyname = 'Users can view own activities'
        ) INTO policy_exists;
        
        IF NOT policy_exists THEN
            CREATE POLICY "Users can view own activities"
              ON public.user_activities FOR SELECT
              USING (auth.uid() = user_id);
            RAISE NOTICE 'Created policy: Users can view own activities';
        ELSE
            RAISE NOTICE 'Policy already exists: Users can view own activities';
        END IF;

        SELECT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'user_activities' AND policyname = 'Users can insert own activities'
        ) INTO policy_exists;
        
        IF NOT policy_exists THEN
            CREATE POLICY "Users can insert own activities"
              ON public.user_activities FOR INSERT
              WITH CHECK (auth.uid() = user_id);
            RAISE NOTICE 'Created policy: Users can insert own activities';
        ELSE
            RAISE NOTICE 'Policy already exists: Users can insert own activities';
        END IF;

        SELECT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'user_activities' AND policyname = 'Users can update own activities'
        ) INTO policy_exists;
        
        IF NOT policy_exists THEN
            CREATE POLICY "Users can update own activities"
              ON public.user_activities FOR UPDATE
              USING (auth.uid() = user_id);
            RAISE NOTICE 'Created policy: Users can update own activities';
        ELSE
            RAISE NOTICE 'Policy already exists: Users can update own activities';
        END IF;

        SELECT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'user_activities' AND policyname = 'Users can delete own activities'
        ) INTO policy_exists;
        
        IF NOT policy_exists THEN
            CREATE POLICY "Users can delete own activities"
              ON public.user_activities FOR DELETE
              USING (auth.uid() = user_id);
            RAISE NOTICE 'Created policy: Users can delete own activities';
        ELSE
            RAISE NOTICE 'Policy already exists: Users can delete own activities';
        END IF;
    ELSE
        RAISE NOTICE 'Table user_activities does not exist - skipping policies';
    END IF;

    -- PRODUCTS
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'products') THEN
        ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
        
        SELECT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'products' AND policyname = 'Users can view approved products and own products'
        ) INTO policy_exists;
        
        IF NOT policy_exists THEN
            CREATE POLICY "Users can view approved products and own products"
              ON public.products FOR SELECT
              USING (is_verified = true OR auth.uid() = created_by);
            RAISE NOTICE 'Created policy: Users can view approved products and own products';
        ELSE
            RAISE NOTICE 'Policy already exists: Users can view approved products and own products';
        END IF;

        SELECT EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE tablename = 'products' AND policyname = 'Users can insert own products'
        ) INTO policy_exists;
        
        IF NOT policy_exists THEN
            CREATE POLICY "Users can insert own products"
              ON public.products FOR INSERT
              WITH CHECK (auth.uid() = created_by);
            RAISE NOTICE 'Created policy: Users can insert own products';
        ELSE
            RAISE NOTICE 'Policy already exists: Users can insert own products';
        END IF;
    ELSE
        RAISE NOTICE 'Table products does not exist - skipping policies';
    END IF;

    RAISE NOTICE '=== RLS POLICIES UPDATE COMPLETED ===';
    RAISE NOTICE 'All existing policies were preserved, only missing policies were added.';
END $$;