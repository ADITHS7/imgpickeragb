// widgets/action_buttons.dart
import 'package:flutter/material.dart';
import 'package:imgpickapp/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';

class ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Update Image and Delete Image Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (viewModel.isLoading ||
                                viewModel.selectedImage == null ||
                                !viewModel.isApiConnected)
                            ? null
                            : () => _handleUpdateImage(context, viewModel),
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
                            : Icon(Icons.cloud_upload, size: 20),
                    label: Text(
                      'Upload Image',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                // SizedBox(width: 12),
                // Expanded(
                //   child: ElevatedButton.icon(
                //     onPressed:
                //         (viewModel.isLoading ||
                //                 viewModel.selectedUser?.hasImage != true ||
                //                 !viewModel.isApiConnected)
                //             ? null
                //             : () => _handleDeleteImage(context, viewModel),
                //     icon: Icon(Icons.delete_outline, size: 20),
                //     label: Text(
                //       'Delete Image',
                //       style: TextStyle(fontWeight: FontWeight.w600),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.red[600],
                //       foregroundColor: Colors.white,
                //       padding: EdgeInsets.symmetric(vertical: 14),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       elevation: 2,
                //     ),
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 16),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        (viewModel.isLoading || !viewModel.canGoPrevious)
                            ? null
                            : viewModel.previousUser,
                    icon: Icon(Icons.arrow_back_ios, size: 18),
                    label: Text(
                      'Previous',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        (viewModel.isLoading || !viewModel.canGoNext)
                            ? null
                            : viewModel.nextUser,
                    icon: Icon(Icons.arrow_forward_ios, size: 18),
                    label: Text(
                      'Next',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Refresh Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: viewModel.isLoading ? null : viewModel.refreshData,
                icon:
                    viewModel.isLoading
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        )
                        : Icon(Icons.refresh, size: 18),
                label: Text(
                  'Refresh Data',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  side: BorderSide(color: Colors.blue[300]!),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleUpdateImage(BuildContext context, UserViewModel viewModel) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.cloud_upload, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text('Upload Image'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload image for ${viewModel.selectedUser!.societyname}?'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '• Image will be resized to 150×150px\n• Format: JPG\n• Stored on server',
                  style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Upload'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await viewModel.updateUserImage();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Image uploaded successfully! (150×150px JPG)',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (viewModel.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text(viewModel.errorMessage)),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // void _handleDeleteImage(BuildContext context, UserViewModel viewModel) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         title: Row(
  //           children: [
  //             Icon(Icons.delete_outline, color: Colors.red[600]),
  //             SizedBox(width: 8),
  //             Text('Delete Image'),
  //           ],
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Are you sure you want to delete the image for ${viewModel.selectedUser!.societyname}?',
  //               style: TextStyle(fontSize: 16),
  //             ),
  //             SizedBox(height: 12),
  //             Container(
  //               padding: EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: Colors.red[50],
  //                 borderRadius: BorderRadius.circular(6),
  //               ),
  //               child: Text(
  //                 'This action cannot be undone. The image will be permanently removed from the server.',
  //                 style: TextStyle(fontSize: 12, color: Colors.red[800]),
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red[600],
  //               foregroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //             child: Text('Delete'),
  //             onPressed: () async {
  //               Navigator.of(context).pop();
  //               final success = await viewModel.deleteUserImage();
  //               if (success) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Row(
  //                       children: [
  //                         Icon(
  //                           Icons.check_circle,
  //                           color: Colors.white,
  //                           size: 20,
  //                         ),
  //                         SizedBox(width: 8),
  //                         Text('Image deleted successfully!'),
  //                       ],
  //                     ),
  //                     backgroundColor: Colors.green[600],
  //                     behavior: SnackBarBehavior.floating,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                 );
  //               } else if (viewModel.errorMessage.isNotEmpty) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Row(
  //                       children: [
  //                         Icon(Icons.error, color: Colors.white, size: 20),
  //                         SizedBox(width: 8),
  //                         Expanded(child: Text(viewModel.errorMessage)),
  //                       ],
  //                     ),
  //                     backgroundColor: Colors.red[600],
  //                     behavior: SnackBarBehavior.floating,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                 );
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
