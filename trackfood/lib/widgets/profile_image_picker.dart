import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';

class ProfileImagePicker extends ConsumerStatefulWidget {
  final String? currentImageUrl;
  final Function(String?)? onImageChanged;
  final double size;

  const ProfileImagePicker({
    super.key,
    this.currentImageUrl,
    this.onImageChanged,
    this.size = 120,
  });

  @override
  ConsumerState<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends ConsumerState<ProfileImagePicker> {
  File? _selectedImage;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _showImagePicker,
      child: Stack(
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryBackground,
              border: Border.all(
                color: AppColors.separator,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _buildImageWidget(),
            ),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.label.withValues(alpha: 0.5),
                ),
                child: const Center(
                  child: CupertinoActivityIndicator(color: CupertinoColors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(
                  color: AppColors.background,
                  width: 2,
                ),
              ),
              child: const Icon(
                CupertinoIcons.camera,
                size: 20,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    }

    if (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.currentImageUrl!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        placeholder: (context, url) => const Center(
          child: CupertinoActivityIndicator(),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      color: AppColors.secondaryBackground,
      child: Icon(
        CupertinoIcons.person_fill,
        size: widget.size * 0.4,
        color: AppColors.placeholder,
      ),
    );
  }

  void _showImagePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Profilbild auswählen'),
        message: const Text('Woher möchtest du dein Profilbild wählen?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Kamera'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Galerie'),
          ),
          if (widget.currentImageUrl != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _removeImage();
              },
              isDestructiveAction: true,
              child: const Text('Bild entfernen'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final File? image = await storageService.pickProfileImage(source: source);
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
        
        await _uploadImage(image);
      }
    } catch (e) {
      _showError('Fehler beim Auswählen des Bildes: $e');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final storageService = ref.read(storageServiceProvider);
      final supabaseService = ref.read(supabaseServiceProvider);
      
      // Upload image to storage
      final String? imageUrl = await storageService.uploadProfileImage(imageFile);
      
      if (imageUrl != null) {
        // Update profile in database
        final String? userId = supabaseService.currentUserId;
        if (userId != null) {
          await supabaseService.updateProfileImage(userId, imageUrl);
          widget.onImageChanged?.call(imageUrl);
        }
      } else {
        throw Exception('Upload fehlgeschlagen');
      }
    } catch (e) {
      _showError('Fehler beim Hochladen: $e');
      setState(() {
        _selectedImage = null;
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _removeImage() async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final String? userId = supabaseService.currentUserId;
      
      if (userId != null) {
        // Remove image URL from profile
        await supabaseService.updateProfileImage(userId, '');
        widget.onImageChanged?.call(null);
        
        setState(() {
          _selectedImage = null;
        });
      }
    } catch (e) {
      _showError('Fehler beim Entfernen des Bildes: $e');
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Fehler'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}