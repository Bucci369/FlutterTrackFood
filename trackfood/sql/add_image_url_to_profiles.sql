-- Add image_url column to profiles table for profile pictures
-- This is needed for the Storage functionality we implemented

-- Add image_url column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'image_url'
    ) THEN
        ALTER TABLE public.profiles ADD COLUMN image_url TEXT;
        RAISE NOTICE 'image_url column added to profiles table';
    ELSE
        RAISE NOTICE 'image_url column already exists in profiles table';
    END IF;
END $$;

-- Success message
SELECT 'Profiles table updated with image_url column!' as status;