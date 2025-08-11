// services/image_service.dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image != null ? File(image.path) : null;
    } catch (e) {
      throw Exception('Error picking image from gallery: $e');
    }
  }

  Future<File?> takePhotoFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      return photo != null ? File(photo.path) : null;
    } catch (e) {
      throw Exception('Error taking photo from camera: $e');
    }
  }
}
