// services/image_service.dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  static const int targetSize = 150;
  static const int jpegQuality = 85;

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return await _processImage(File(image.path));
      }
      return null;
    } catch (e) {
      throw Exception('Error picking image from gallery: $e');
    }
  }

  Future<File?> takePhotoFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        return await _processImage(File(photo.path));
      }
      return null;
    } catch (e) {
      throw Exception('Error taking photo from camera: $e');
    }
  }

  Future<File> _processImage(File imageFile) async {
    try {
      // Read the image file
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Decode the image using Flutter's codec
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: targetSize,
        targetHeight: targetSize,
      );

      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Convert to bytes
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final Uint8List processedBytes = byteData.buffer.asUint8List();

      // Create a new file with processed image
      final String directory = imageFile.parent.path;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String newPath = '$directory/processed_image_$timestamp.jpg';

      final File processedFile = File(newPath);
      await processedFile.writeAsBytes(processedBytes);

      // Delete the original file if it's different from the processed file
      if (imageFile.path != newPath) {
        try {
          await imageFile.delete();
        } catch (e) {
          // Ignore deletion errors
        }
      }

      return processedFile;
    } catch (e) {
      throw Exception('Error processing image: $e');
    }
  }

  // Helper method to get image info
  Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      return {
        'width': image.width,
        'height': image.height,
        'size': imageBytes.length,
      };
    } catch (e) {
      return {};
    }
  }
}
