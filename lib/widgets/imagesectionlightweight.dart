// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import '../viewmodel/user_viewmodel.dart';

// class ImageSectionLightweight extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<UserViewModel>(
//       builder: (context, viewModel, child) {
//         return Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey[200]!, width: 1),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.04),
//                 blurRadius: 8,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // Image Display Area
//               Container(
//                 height: 200,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                   color: Colors.grey[50],
//                 ),
//                 child: Center(
//                   child: Container(
//                     width: 150,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey[300]!, width: 2),
//                       color: Colors.white,
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(6),
//                       child: _buildImageWidget(viewModel),
//                     ),
//                   ),
//                 ),
//               ),

//               // Size Info Banner
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   border: Border(
//                     top: BorderSide(color: Colors.grey[200]!, width: 1),
//                     bottom: BorderSide(color: Colors.grey[200]!, width: 1),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
//                     SizedBox(width: 8),
//                     Text(
//                       'Images will be resized to 150×150px on upload',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.blue[700],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Action Buttons
//               Container(
//                 padding: EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed:
//                             viewModel.isLoading
//                                 ? null
//                                 : () =>
//                                     _handleCameraCapture(context, viewModel),
//                         icon:
//                             viewModel.isLoading
//                                 ? SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white,
//                                     ),
//                                   ),
//                                 )
//                                 : Icon(Icons.camera_alt_outlined, size: 20),
//                         label: Text(
//                           'Camera',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green[600],
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           elevation: 0,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed:
//                             viewModel.isLoading
//                                 ? null
//                                 : () => _handleGalleryPick(context, viewModel),
//                         icon:
//                             viewModel.isLoading
//                                 ? SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white,
//                                     ),
//                                   ),
//                                 )
//                                 : Icon(Icons.photo_library_outlined, size: 20),
//                         label: Text(
//                           'Gallery',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange[600],
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           elevation: 0,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _handleCameraCapture(
//     BuildContext context,
//     UserViewModel viewModel,
//   ) async {
//     try {
//       await viewModel.takePhotoFromCamera();
//       if (viewModel.selectedImage != null) {
//         await _resizeImageLightweight(viewModel.selectedImage!);
//         _showImageProcessedMessage(context);
//       }
//     } catch (e) {
//       _showErrorMessage(context, 'Failed to capture image: ${e.toString()}');
//     }
//   }

//   Future<void> _handleGalleryPick(
//     BuildContext context,
//     UserViewModel viewModel,
//   ) async {
//     try {
//       await viewModel.pickImageFromGallery();
//       if (viewModel.selectedImage != null) {
//         await _resizeImageLightweight(viewModel.selectedImage!);
//         _showImageProcessedMessage(context);
//       }
//     } catch (e) {
//       _showErrorMessage(context, 'Failed to pick image: ${e.toString()}');
//     }
//   }

//   // Lightweight resize using only Flutter's built-in capabilities
//   Future<void> _resizeImageLightweight(File imageFile) async {
//     try {
//       // Read image bytes with size check
//       final imageBytes = await imageFile.readAsBytes();

//       // Skip processing if file is already small (likely already processed)
//       if (imageBytes.length < 50000) {
//         // Less than 50KB, likely already processed
//         return;
//       }

//       // Decode to ui.Image
//       final ui.Codec codec = await ui.instantiateImageCodec(
//         imageBytes,
//         targetWidth: 150,
//         targetHeight: 150,
//       );
//       final ui.FrameInfo frameInfo = await codec.getNextFrame();
//       final ui.Image image = frameInfo.image;

//       // Convert back to bytes as PNG (smaller file size)
//       final ByteData? byteData = await image.toByteData(
//         format: ui.ImageByteFormat.png,
//       );
//       if (byteData != null) {
//         final Uint8List resizedBytes = byteData.buffer.asUint8List();
//         await imageFile.writeAsBytes(resizedBytes);
//       }

//       // Dispose of the image to free memory
//       image.dispose();
//     } catch (e) {
//       print('Lightweight resize failed: $e');
//       // Don't throw error, just continue with original image
//     }
//   }

//   void _showImageProcessedMessage(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.white, size: 20),
//             SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Image processed and resized to 150×150px',
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.green[600],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showErrorMessage(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.error, color: Colors.white, size: 20),
//             SizedBox(width: 8),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: Colors.red[600],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }

//   Widget _buildImageWidget(UserViewModel viewModel) {
//     if (viewModel.selectedImage != null) {
//       return Stack(
//         children: [
//           Image.file(
//             viewModel.selectedImage!,
//             fit: BoxFit.cover,
//             width: 150,
//             height: 150,
//             errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
//           ),
//           Positioned(
//             top: 4,
//             right: 4,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.9),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 '150×150',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 9,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     } else if (viewModel.selectedUser?.imagePath != null) {
//       return Image.file(
//         File(viewModel.selectedUser!.imagePath!),
//         fit: BoxFit.cover,
//         width: 150,
//         height: 150,
//         errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
//       );
//     } else if (viewModel.selectedUser?.hasImage == true) {
//       // Try to load from server/assets path
//       return FutureBuilder<bool>(
//         future: _checkImageExists(viewModel.selectedUser!.soccode),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return _buildLoadingWidget();
//           } else if (snapshot.data == true) {
//             return Image.network(
//               _getImageUrl(viewModel.selectedUser!.soccode),
//               fit: BoxFit.cover,
//               width: 150,
//               height: 150,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return _buildLoadingWidget();
//               },
//               errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
//             );
//           } else {
//             return _buildErrorWidget();
//           }
//         },
//       );
//     } else {
//       return _buildPlaceholderWidget(viewModel);
//     }
//   }

//   Future<bool> _checkImageExists(String soccode) async {
//     try {
//       // You can implement your own logic here to check if image exists
//       // This is just a placeholder - replace with your actual image check logic
//       await Future.delayed(
//         Duration(milliseconds: 500),
//       ); // Simulate network call
//       return false; // Return true if image exists on server
//     } catch (e) {
//       return false;
//     }
//   }

//   String _getImageUrl(String soccode) {
//     // Replace with your actual image URL pattern
//     return 'https://your-server.com/images/society_photos$soccode.jpg';
//   }

//   Widget _buildLoadingWidget() {
//     return Container(
//       width: 150,
//       height: 150,
//       color: Colors.grey[100],
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 24,
//             height: 24,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Loading...',
//             style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlaceholderWidget(UserViewModel viewModel) {
//     return Container(
//       width: 150,
//       height: 150,
//       color: Colors.grey[100],
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.add_photo_alternate_outlined,
//             size: 32,
//             color: Colors.grey[400],
//           ),
//           SizedBox(height: 8),
//           Text(
//             viewModel.selectedUser == null ? 'Select society' : 'No image',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           Text(
//             '150×150px',
//             style: TextStyle(fontSize: 10, color: Colors.grey[500]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Container(
//       width: 150,
//       height: 150,
//       color: Colors.red[50],
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 28, color: Colors.red[400]),
//           SizedBox(height: 8),
//           Text(
//             'Load Error',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: Colors.red[600],
//             ),
//           ),
//           Text(
//             'Use Camera/Gallery',
//             style: TextStyle(fontSize: 10, color: Colors.red[500]),
//           ),
//         ],
//       ),
//     );
//   }
// }
