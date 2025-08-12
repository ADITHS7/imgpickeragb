// services/image_service.dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Error picking image from gallery: $e');
    }
  }

  Future<File?> takePhotoFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      throw Exception('Error taking photo from camera: $e');
    }
  }

  // Helper method to get image info
  Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    try {
      final fileStat = await imageFile.stat();

      return {
        'path': imageFile.path,
        'size': fileStat.size,
        'lastModified': fileStat.modified.toIso8601String(),
        'exists': await imageFile.exists(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Validate image file
  bool isValidImageFile(File imageFile) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final extension = imageFile.path.toLowerCase();

    return validExtensions.any((ext) => extension.endsWith(ext));
  }

  // Get file size in human readable format
  String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
