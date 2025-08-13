import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../viewmodel/user_viewmodel.dart';

class ImageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Image Display Area - Fixed 150x150 aspect ratio
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.grey[50],
                ),
                child: Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _buildImageWidget(viewModel),
                    ),
                  ),
                ),
              ),

              // Size Info Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Server will resize images to 150×150px on upload',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            viewModel.isLoading
                                ? null
                                : () =>
                                    _handleCameraCapture(context, viewModel),
                        icon:
                            viewModel.isLoading
                                ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Icon(Icons.camera_alt_outlined, size: 20),
                        label: Text(
                          'Camera',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            viewModel.isLoading
                                ? null
                                : () => _handleGalleryPick(context, viewModel),
                        icon:
                            viewModel.isLoading
                                ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Icon(Icons.photo_library_outlined, size: 20),
                        label: Text(
                          'Gallery',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleCameraCapture(
    BuildContext context,
    UserViewModel viewModel,
  ) async {
    try {
      await viewModel.takePhotoFromCamera();
      if (viewModel.selectedImage != null) {
        _showImageSelectedMessage(context);
      }
    } catch (e) {
      _showErrorMessage(context, 'Failed to capture image: ${e.toString()}');
    }
  }

  Future<void> _handleGalleryPick(
    BuildContext context,
    UserViewModel viewModel,
  ) async {
    try {
      await viewModel.pickImageFromGallery();
      if (viewModel.selectedImage != null) {
        _showImageSelectedMessage(context);
      }
    } catch (e) {
      _showErrorMessage(context, 'Failed to pick image: ${e.toString()}');
    }
  }

  Widget _buildImageWidget(UserViewModel viewModel) {
    // Priority 1: Show newly selected image (ready to upload)
    if (viewModel.selectedImage != null) {
      return _buildSelectedImageWidget(viewModel.selectedImage!);
    }

    // Priority 2: Show existing image from server
    if (viewModel.selectedUser != null) {
      return _buildExistingImageWidget(viewModel);
    }

    // Priority 3: Show placeholder
    return _buildPlaceholderWidget(viewModel);
  }

  Widget _buildSelectedImageWidget(File imageFile) {
    return FutureBuilder<bool>(
      future: _checkFileExists(imageFile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.data == true) {
          return Stack(
            children: [
              Image.file(
                imageFile,
                fit: BoxFit.cover,
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading selected image: $error');
                  return _buildErrorWidget('Failed to load selected image');
                },
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'READY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return _buildErrorWidget('Selected image not found');
        }
      },
    );
  }

  Widget _buildExistingImageWidget(UserViewModel viewModel) {
    final user = viewModel.selectedUser!;

    // Check if user has an uploaded image
    if (user.uploaded == 1 && user.hasImage) {
      // Use the API endpoint to get the image
      String? imageUrl = viewModel.getImageUrl();

      if (imageUrl != null) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 150,
          height: 150,
          headers: {'User-Agent': 'Flutter App', 'Cache-Control': 'no-cache'},
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return Stack(
                children: [
                  child,
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'API',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return _buildLoadingWidget();
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image from API for ${user.soccode}: $error');
            print('Tried URL: $imageUrl');
            return _buildNoImageAvailable();
          },
        );
      }
    }

    // No image available
    return _buildNoImageAvailable();
  }

  Future<bool> _checkFileExists(File file) async {
    try {
      return await file.exists();
    } catch (e) {
      print('Error checking file existence: $e');
      return false;
    }
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: 150,
      height: 150,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Loading...',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 20, color: Colors.red[600]),
          ),
          SizedBox(height: 6),
          Text(
            'Image Error',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            'Use Camera/Gallery',
            style: TextStyle(fontSize: 8, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoImageAvailable() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[200]!, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_not_supported,
              size: 20,
              color: Colors.orange[600],
            ),
          ),
          SizedBox(height: 6),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.orange[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            'Add with Camera/Gallery',
            style: TextStyle(fontSize: 8, color: Colors.orange[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderWidget(UserViewModel viewModel) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 24,
              color: Colors.blue[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            viewModel.selectedUser == null ? 'Select society' : 'Add image',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            'Tap Camera/Gallery',
            style: TextStyle(fontSize: 9, color: Colors.blue[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            '(→ 150×150px)',
            style: TextStyle(
              fontSize: 8,
              color: Colors.blue[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSelectedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Image selected! Ready to upload (server will resize to 150×150px)',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
