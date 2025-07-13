-- TrackFood Flutter - Row Level Security (RLS) Policies
-- Execute these SQL statements in your Supabase SQL Editor

-- Enable Row Level Security at database level
ALTER DATABASE postgres SET row_security = on;

-- ===== PROFILES TABLE =====
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- ===== DIARY_ENTRIES TABLE =====
ALTER TABLE public.diary_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own diary entries"
  ON public.diary_entries FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own diary entries"
  ON public.diary_entries FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own diary entries"
  ON public.diary_entries FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own diary entries"
  ON public.diary_entries FOR DELETE
  USING (auth.uid() = user_id);

-- ===== WATER_INTAKE TABLE =====
ALTER TABLE public.water_intake ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own water intake"
  ON public.water_intake FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own water intake"
  ON public.water_intake FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own water intake"
  ON public.water_intake FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own water intake"
  ON public.water_intake FOR DELETE
  USING (auth.uid() = user_id);

-- ===== FASTING_SESSIONS TABLE =====
ALTER TABLE public.fasting_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own fasting sessions"
  ON public.fasting_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own fasting sessions"
  ON public.fasting_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own fasting sessions"
  ON public.fasting_sessions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own fasting sessions"
  ON public.fasting_sessions FOR DELETE
  USING (auth.uid() = user_id);

-- ===== USER_ACTIVITIES TABLE =====
ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own activities"
  ON public.user_activities FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own activities"
  ON public.user_activities FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own activities"
  ON public.user_activities FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own activities"
  ON public.user_activities FOR DELETE
  USING (auth.uid() = user_id);

-- ===== WEIGHT_HISTORY TABLE =====
ALTER TABLE public.weight_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own weight history"
  ON public.weight_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own weight history"
  ON public.weight_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own weight history"
  ON public.weight_history FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own weight history"
  ON public.weight_history FOR DELETE
  USING (auth.uid() = user_id);

-- ===== ABSTINENCE_CHALLENGES TABLE =====
ALTER TABLE public.abstinence_challenges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own challenges"
  ON public.abstinence_challenges FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own challenges"
  ON public.abstinence_challenges FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own challenges"
  ON public.abstinence_challenges FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own challenges"
  ON public.abstinence_challenges FOR DELETE
  USING (auth.uid() = user_id);

-- ===== PRODUCTS TABLE =====
-- Products have community features, so we need special policies
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Users can see approved products and their own products (regardless of status)
CREATE POLICY "Users can view approved products and own products"
  ON public.products FOR SELECT
  USING (is_verified = true OR auth.uid() = created_by);

CREATE POLICY "Users can insert own products"
  ON public.products FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own products"
  ON public.products FOR UPDATE
  USING (auth.uid() = created_by);

CREATE POLICY "Users can delete own products"
  ON public.products FOR DELETE
  USING (auth.uid() = created_by);

-- ===== RECIPES TABLE (if exists) =====
-- Check if recipes table exists before applying policies
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'recipes') THEN
        ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
        
        -- Allow viewing public recipes and own recipes
        CREATE POLICY "Users can view public recipes and own recipes"
          ON public.recipes FOR SELECT
          USING (auth.uid() = user_id OR is_public = true);

        CREATE POLICY "Users can insert own recipes"
          ON public.recipes FOR INSERT
          WITH CHECK (auth.uid() = user_id);

        CREATE POLICY "Users can update own recipes"
          ON public.recipes FOR UPDATE
          USING (auth.uid() = user_id);

        CREATE POLICY "Users can delete own recipes"
          ON public.recipes FOR DELETE
          USING (auth.uid() = user_id);
    END IF;
END $$;

-- ===== PERFORMANCE INDEXES =====
-- Add indexes for better performance with RLS queries

-- Index for diary entries by user and date
CREATE INDEX IF NOT EXISTS idx_diary_entries_user_date 
  ON public.diary_entries(user_id, entry_date);

-- Index for water intake by user and date
CREATE INDEX IF NOT EXISTS idx_water_intake_user_date 
  ON public.water_intake(user_id, date);

-- Index for fasting sessions by user
CREATE INDEX IF NOT EXISTS idx_fasting_sessions_user 
  ON public.fasting_sessions(user_id, is_active);

-- Index for activities by user and date
CREATE INDEX IF NOT EXISTS idx_user_activities_user_date 
  ON public.user_activities(user_id, activity_date);

-- Index for weight history by user
CREATE INDEX IF NOT EXISTS idx_weight_history_user 
  ON public.weight_history(user_id, recorded_date);

-- Index for challenges by user
CREATE INDEX IF NOT EXISTS idx_abstinence_challenges_user 
  ON public.abstinence_challenges(user_id, is_active);

-- Index for products by verification status
CREATE INDEX IF NOT EXISTS idx_products_verified 
  ON public.products(is_verified, created_by);

-- ===== SUCCESS MESSAGE =====
-- This will be shown in the Supabase SQL editor
SELECT 'Row Level Security (RLS) Policies successfully enabled for TrackFood Flutter!' as status;