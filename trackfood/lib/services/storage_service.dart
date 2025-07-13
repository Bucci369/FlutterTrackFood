import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient client = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // Getter for current user
  String? get currentUserId => client.auth.currentUser?.id;

  // Storage buckets
  static const String profileImagesBucket = 'profile-images';
  static const String productImagesBucket = 'product-images';
  static const String recipeImagesBucket = 'recipe-images';

  // === Profile Images ===

  /// Picks an image from gallery or camera for profile
  Future<File?> pickProfileImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking profile image: $e');
      return null;
    }
  }

  /// Uploads profile image to Supabase Storage
  Future<String?> uploadProfileImage(File imageFile) async {
    if (currentUserId == null) return null;
    
    try {
      final String fileName = '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = 'profiles/$fileName';
      
      final Uint8List fileBytes = await imageFile.readAsBytes();
      
      await client.storage
          .from(profileImagesBucket)
          .uploadBinary(filePath, fileBytes, fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true, // Overwrite existing file
          ));

      // Get public URL
      final String publicUrl = client.storage
          .from(profileImagesBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  /// Deletes profile image from storage
  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final Uri uri = Uri.parse(imageUrl);
      final String filePath = uri.pathSegments.sublist(2).join('/'); // Remove bucket from path
      
      await client.storage
          .from(profileImagesBucket)
          .remove([filePath]);
      
      return true;
    } catch (e) {
      print('Error deleting profile image: $e');
      return false;
    }
  }

  // === Product Images ===

  /// Picks an image for product
  Future<File?> pickProductImage({ImageSource source = ImageSource.camera}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking product image: $e');
      return null;
    }
  }

  /// Uploads product image to Supabase Storage
  Future<String?> uploadProductImage(File imageFile, String productCode) async {
    if (currentUserId == null) return null;
    
    try {
      final String uniqueId = const Uuid().v4();
      final String fileName = '${productCode}_${uniqueId}.jpg';
      final String filePath = 'products/$fileName';
      
      final Uint8List fileBytes = await imageFile.readAsBytes();
      
      await client.storage
          .from(productImagesBucket)
          .uploadBinary(filePath, fileBytes, fileOptions: const FileOptions(
            cacheControl: '86400', // 24 hours
            upsert: false, // Don't overwrite
          ));

      // Get public URL
      final String publicUrl = client.storage
          .from(productImagesBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading product image: $e');
      return null;
    }
  }

  // === Recipe Images ===

  /// Picks an image for recipe
  Future<File?> pickRecipeImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking recipe image: $e');
      return null;
    }
  }

  /// Uploads recipe image to Supabase Storage
  Future<String?> uploadRecipeImage(File imageFile) async {
    if (currentUserId == null) return null;
    
    try {
      final String uniqueId = const Uuid().v4();
      final String fileName = '${currentUserId}_$uniqueId.jpg';
      final String filePath = 'recipes/$fileName';
      
      final Uint8List fileBytes = await imageFile.readAsBytes();
      
      await client.storage
          .from(recipeImagesBucket)
          .uploadBinary(filePath, fileBytes, fileOptions: const FileOptions(
            cacheControl: '86400', // 24 hours
            upsert: false,
          ));

      // Get public URL
      final String publicUrl = client.storage
          .from(recipeImagesBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading recipe image: $e');
      return null;
    }
  }

  // === Generic File Operations ===

  /// Lists files in a bucket for current user
  Future<List<FileObject>> listUserFiles(String bucketName, {String? folder}) async {
    if (currentUserId == null) return [];
    
    try {
      final String path = folder != null ? '$folder/$currentUserId' : currentUserId!;
      
      final List<FileObject> files = await client.storage
          .from(bucketName)
          .list(path: path);
      
      return files;
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }

  /// Gets file size info
  Future<int?> getFileSize(String bucketName, String filePath) async {
    try {
      final List<FileObject> files = await client.storage
          .from(bucketName)
          .list(path: filePath);
      
      if (files.isNotEmpty) {
        return files.first.metadata?['size'] as int?;
      }
      return null;
    } catch (e) {
      print('Error getting file size: $e');
      return null;
    }
  }

  /// Checks if bucket exists and creates policies if needed
  Future<bool> ensureBucketsExist() async {
    try {
      final List<Bucket> buckets = await client.storage.listBuckets();
      final List<String> bucketNames = buckets.map((b) => b.id).toList();
      
      // Check if our buckets exist
      final List<String> requiredBuckets = [
        profileImagesBucket,
        productImagesBucket,
        recipeImagesBucket,
      ];
      
      for (String bucketName in requiredBuckets) {
        if (!bucketNames.contains(bucketName)) {
          print('Bucket $bucketName does not exist. Please create it in Supabase dashboard.');
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('Error checking buckets: $e');
      return false;
    }
  }
}

/// Provider to make the StorageService instance available to the rest of the app
final storageServiceProvider = Provider((ref) => StorageService());

/// Provider for profile image upload state
final profileImageUploadProvider = StateNotifierProvider<ProfileImageUploadNotifier, AsyncValue<String?>>((ref) {
  return ProfileImageUploadNotifier(ref.read(storageServiceProvider));
});

class ProfileImageUploadNotifier extends StateNotifier<AsyncValue<String?>> {
  final StorageService _storageService;

  ProfileImageUploadNotifier(this._storageService) : super(const AsyncValue.data(null));

  Future<void> uploadImage(File imageFile) async {
    state = const AsyncValue.loading();
    try {
      final String? imageUrl = await _storageService.uploadProfileImage(imageFile);
      state = AsyncValue.data(imageUrl);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}