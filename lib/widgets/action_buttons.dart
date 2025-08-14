// widgets/action_buttons.dart - UPDATED with user ID awareness
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
            // User ID indicator (optional - for debugging/admin purposes)
            if (viewModel.currentUserId != null)
              Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Text(
                  'Logged in as User ID: ${viewModel.currentUserId}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Update Image Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (viewModel.isLoading ||
                                viewModel.selectedImage == null ||
                                !viewModel.isApiConnected ||
                                viewModel.currentUserId ==
                                    null) // Check if user is logged in
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
                      viewModel.currentUserId == null
                          ? 'Login Required'
                          : 'Upload Image',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          viewModel.currentUserId == null
                              ? Colors.grey[400]
                              : Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
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
    // Check if user is logged in
    if (viewModel.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Please log in to upload images')),
            ],
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• Image will be resized to 150×150px\n• Format: JPG\n• Stored on server',
                      style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Uploaded by: User ID ${viewModel.currentUserId}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
}
