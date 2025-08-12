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
                        (viewModel.isLoading || viewModel.selectedImage == null)
                            ? null
                            : () => _handleUpdateImage(context, viewModel),
                    icon: Icon(Icons.save),
                    label: Text('Update Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (viewModel.isLoading ||
                                viewModel.selectedUser?.imagePath == null)
                            ? null
                            : () => _handleDeleteImage(context, viewModel),
                    icon: Icon(Icons.delete),
                    label: Text('Delete Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (viewModel.isLoading || !viewModel.canGoPrevious)
                            ? null
                            : viewModel.previousUser,
                    icon: Icon(Icons.arrow_back),
                    label: Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (viewModel.isLoading || !viewModel.canGoNext)
                            ? null
                            : viewModel.nextUser,
                    icon: Icon(Icons.arrow_forward),
                    label: Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _handleUpdateImage(BuildContext context, UserViewModel viewModel) async {
    final success = await viewModel.updateUserImage();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image updated successfully! (150x150px JPEG)'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (viewModel.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleDeleteImage(BuildContext context, UserViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Image'),
          content: Text(
            'Are you sure you want to delete the image for ${viewModel.selectedUser!.name}?',
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await viewModel.deleteUserImage();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Image deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (viewModel.errorMessage.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(viewModel.errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
