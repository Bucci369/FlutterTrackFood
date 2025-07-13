-- TrackFood Flutter - Supabase Storage Buckets Setup (FIXED)
-- Execute these SQL statements in your Supabase SQL Editor

-- ===== CREATE STORAGE BUCKETS =====

-- Profile Images Bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'profile-images',
  'profile-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Product Images Bucket  
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'product-images',
  'product-images', 
  true,
  3145728, -- 3MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Recipe Images Bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'recipe-images',
  'recipe-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- ===== STORAGE POLICIES =====
-- We'll create policies safely, checking if they exist first

DO $$
DECLARE
    policy_exists BOOLEAN;
BEGIN
    -- ===== PROFILE IMAGES BUCKET POLICIES =====

    -- Check and create profile images policies
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
        AND policyname = 'Public profile images are viewable by authenticated users'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Public profile images are viewable by authenticated users"
        ON storage.objects FOR SELECT
        USING (
          bucket_id = 'profile-images' 
          AND auth.role() = 'authenticated'
        );
        RAISE NOTICE 'Created policy: Public profile images are viewable by authenticated users';
    ELSE
        RAISE NOTICE 'Policy already exists: Public profile images are viewable by authenticated users';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
        AND policyname = 'Users can upload their own profile images'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can upload their own profile images"
        ON storage.objects FOR INSERT
        WITH CHECK (
          bucket_id = 'profile-images'
          AND auth.uid()::text = (storage.foldername(name))[1]
          AND auth.role() = 'authenticated'
        );
        RAISE NOTICE 'Created policy: Users can upload their own profile images';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can upload their own profile images';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
        AND policyname = 'Users can update their own profile images'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can update their own profile images"
        ON storage.objects FOR UPDATE
        USING (
          bucket_id = 'profile-images'
          AND auth.uid()::text = (storage.foldername(name))[1]
          AND auth.role() = 'authenticated'
        );
        RAISE NOTICE 'Created policy: Users can update their own profile images';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can update their own profile images';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
        AND policyname = 'Users can delete their own profile images'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can delete their own profile images"
        ON storage.objects FOR DELETE
        USING (
          bucket_id = 'profile-images'
          AND auth.uid()::text = (storage.foldername(name))[1]
          AND auth.role() = 'authenticated'
        );
        RAISE NOTICE 'Created policy: Users can delete their own profile images';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can delete their own profile images';
    END IF;

    -- ===== PRODUCT IMAGES BUCKET POLICIES =====

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
        AND policyname = 'Product images are viewable by authenticated users'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Product images are viewable by authenticated users"
        ON storage.objects FOR SELECT
        USING (
          bucket_id = 'product-images'
          AND auth.role() = 'authenticated'
        );
        RAISE NOTICE 'Created policy: Product images are viewable by authenticated users';
    ELSE
        RAISE NOTICE 'Policy already exists: Product images are viewable by authenticated users';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
        AND policyname = 'Authenticated users can upload product images'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Authenticated users can upload product images"
        ON storage.objects FOR INSERT
        WITH CHECK (
          bucket_id = 'product-images'
          AND auth.role() = 'authenticated'
        );
        RAISE NOTICE 'Created policy: Authenticated users can upload product images';
    ELSE
        RAISE NOTICE 'Policy already exists: Authenticated users can upload product images';
    END IF;

    -- ===== RECIPE IMAGES BUCKET POLICIES =====

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
        AND policyname = 'Recipe images are viewable by authenticated users'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Recipe images are viewable by authenticated users"
        ON storage.objects FOR SELECT
        USING (
          bucket_id = 'recipe-images'
          AND auth.role() = 'authenticated'
        );
        RAISE NOTICE 'Created policy: Recipe images are viewable by authenticated users';
    ELSE
        RAISE NOTICE 'Policy already exists: Recipe images are viewable by authenticated users';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
        AND policyname = 'Users can upload recipe images in their folder'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can upload recipe images in their folder"
        ON storage.objects FOR INSERT
        WITH CHECK (
          bucket_id = 'recipe-images'
          AND auth.uid()::text = (storage.foldername(name))[1]
          AND auth.role() = 'authenticated'
        );
        RAISE NOTICE 'Created policy: Users can upload recipe images in their folder';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can upload recipe images in their folder';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
        AND policyname = 'Users can update their own recipe images'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can update their own recipe images"
        ON storage.objects FOR UPDATE
        USING (
          bucket_id = 'recipe-images'
          AND auth.uid()::text = (storage.foldername(name))[1]
          AND auth.role() = 'authenticated'
        );
        RAISE NOTICE 'Created policy: Users can update their own recipe images';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can update their own recipe images';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
        AND policyname = 'Users can delete their own recipe images'
    ) INTO policy_exists;
    
    IF NOT policy_exists THEN
        CREATE POLICY "Users can delete their own recipe images"
        ON storage.objects FOR DELETE
        USING (
          bucket_id = 'recipe-images'
          AND auth.uid()::text = (storage.foldername(name))[1]
          AND auth.role() = 'authenticated'
        );
        RAISE NOTICE 'Created policy: Users can delete their own recipe images';
    ELSE
        RAISE NOTICE 'Policy already exists: Users can delete their own recipe images';
    END IF;

    RAISE NOTICE '=== STORAGE BUCKETS AND POLICIES SETUP COMPLETED ===';
END $$;

-- ===== STORAGE FUNCTIONS =====

-- Function to clean up orphaned storage files
CREATE OR REPLACE FUNCTION clean_storage_orphans()
RETURNS void AS $$
BEGIN
  -- Delete profile images where user no longer exists
  DELETE FROM storage.objects 
  WHERE bucket_id = 'profile-images'
  AND (storage.foldername(name))[1]::uuid NOT IN (
    SELECT id::text FROM auth.users
  );
  
  -- Delete recipe images where user no longer exists
  DELETE FROM storage.objects 
  WHERE bucket_id = 'recipe-images'
  AND (storage.foldername(name))[1]::uuid NOT IN (
    SELECT id::text FROM auth.users
  );
  
  RAISE NOTICE 'Storage cleanup completed';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===== TRIGGERS FOR CLEANUP =====

-- Function to delete user's storage files when user is deleted
CREATE OR REPLACE FUNCTION delete_user_storage_files()
RETURNS TRIGGER AS $$
BEGIN
  -- Delete profile images
  DELETE FROM storage.objects 
  WHERE bucket_id = 'profile-images'
  AND (storage.foldername(name))[1] = OLD.id::text;
  
  -- Delete recipe images
  DELETE FROM storage.objects 
  WHERE bucket_id = 'recipe-images'
  AND (storage.foldername(name))[1] = OLD.id::text;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on user deletion (only if it doesn't exist)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'on_user_deleted_cleanup_storage'
    ) THEN
        CREATE TRIGGER on_user_deleted_cleanup_storage
          AFTER DELETE ON auth.users
          FOR EACH ROW EXECUTE FUNCTION delete_user_storage_files();
        RAISE NOTICE 'Created trigger: on_user_deleted_cleanup_storage';
    ELSE
        RAISE NOTICE 'Trigger already exists: on_user_deleted_cleanup_storage';
    END IF;
END $$;

-- ===== STORAGE STATISTICS (FIXED) =====

-- View for storage usage statistics (with proper type casting)
CREATE OR REPLACE VIEW storage_usage_stats AS
SELECT 
  bucket_id,
  COUNT(*) as file_count,
  SUM(
    CASE 
      WHEN metadata->>'size' IS NOT NULL AND metadata->>'size' ~ '^[0-9]+$'
      THEN (metadata->>'size')::bigint 
      ELSE 0 
    END
  ) as total_size_bytes,
  ROUND(
    SUM(
      CASE 
        WHEN metadata->>'size' IS NOT NULL AND metadata->>'size' ~ '^[0-9]+$'
        THEN (metadata->>'size')::bigint 
        ELSE 0 
      END
    ) / 1024.0 / 1024.0, 2
  ) as total_size_mb,
  AVG(
    CASE 
      WHEN metadata->>'size' IS NOT NULL AND metadata->>'size' ~ '^[0-9]+$'
      THEN (metadata->>'size')::bigint 
      ELSE NULL 
    END
  )::bigint as avg_file_size_bytes
FROM storage.objects 
GROUP BY bucket_id;

-- ===== SUCCESS MESSAGE =====
SELECT 'Supabase Storage buckets and policies successfully configured for TrackFood Flutter!' as status;