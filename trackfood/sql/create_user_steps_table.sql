-- Create the user_steps table to store daily step counts
-- This table is needed for the pedometer functionality in the Flutter app

CREATE TABLE public.user_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL,
  steps INT DEFAULT 0 NOT NULL,
  source TEXT NOT NULL, -- 'sensor' or 'manual'
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
  
  -- It's good practice to have a unique constraint per user per day for sensor data,
  -- but since we can have multiple manual entries, we'll handle aggregation in the app.
  -- A partial unique index could be an option for advanced use cases.
  -- CONSTRAINT unique_sensor_steps_per_day UNIQUE (user_id, date, source) WHERE (source = 'sensor')
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_steps ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS
-- 1. Users can see their own step records.
CREATE POLICY "Enable read access for own user"
ON public.user_steps
FOR SELECT
USING (auth.uid() = user_id);

-- 2. Users can insert their own step records.
CREATE POLICY "Enable insert for own user"
ON public.user_steps
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 3. Users can update their own step records.
CREATE POLICY "Enable update for own user"
ON public.user_steps
FOR UPDATE
USING (auth.uid() = user_id);

-- 4. Users can delete their own step records.
CREATE POLICY "Enable delete for own user"
ON public.user_steps
FOR DELETE
USING (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX idx_user_steps_user_date ON public.user_steps(user_id, date);

-- Success message
SELECT 'User Steps table with RLS policies successfully created!' as status;