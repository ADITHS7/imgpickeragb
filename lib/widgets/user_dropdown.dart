// widgets/user_dropdown.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../viewmodel/user_viewmodel.dart';
import '../model/user_model.dart';

class UserDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        // Check if selected user is in filtered list
        User? dropdownValue;
        if (viewModel.selectedUser != null &&
            viewModel.filteredUsers.any(
              (user) => user.soccode == viewModel.selectedUser!.soccode,
            )) {
          dropdownValue = viewModel.filteredUsers.firstWhere(
            (user) => user.soccode == viewModel.selectedUser!.soccode,
          );
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<User>(
              isExpanded: true,
              value: dropdownValue,
              hint: Row(
                children: [
                  Icon(Icons.business, color: Colors.grey[500], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viewModel.filteredUsers.isEmpty
                          ? 'No societies found'
                          : 'Select a society',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              icon:
                  viewModel.isLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      )
                      : Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              items:
                  viewModel.filteredUsers.isEmpty
                      ? []
                      : viewModel.filteredUsers.map((User user) {
                        return DropdownMenuItem<User>(
                          value: user,
                          child: _buildDropdownItem(user),
                        );
                      }).toList(),
              onChanged:
                  (viewModel.isLoading || viewModel.filteredUsers.isEmpty)
                      ? null
                      : (User? newUser) {
                        if (newUser != null) {
                          viewModel.selectUser(newUser);
                        }
                      },
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownItem(User user) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          // Society code badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue[300]!),
            ),
            child: Text(
              user.soccode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
          ),
          SizedBox(width: 12),

          // Society info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.societyname,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.district?.isNotEmpty == true ||
                    user.hq?.isNotEmpty == true)
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      [
                        user.district,
                        user.hq,
                      ].where((item) => item?.isNotEmpty == true).join(' • '),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // Upload status indicator
          Container(
            width: 10,
            height: 10,
            margin: EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: user.uploaded == 1 ? Colors.green[600] : Colors.grey[400],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (user.uploaded == 1 ? Colors.green : Colors.grey)
                      .withOpacity(0.3),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Society Profile Widget
class SocietyProfileWidget extends StatelessWidget {
  final User? selectedUser;
  final VoidCallback? onCameraPressed;
  final VoidCallback? onGalleryPressed;

  const SocietyProfileWidget({
    Key? key,
    this.selectedUser,
    this.onCameraPressed,
    this.onGalleryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.business, color: Colors.blue[700], size: 24),
                SizedBox(width: 12),
                Text(
                  'Society Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                Spacer(),
                if (selectedUser != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '1/1171',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Image Section
          Container(
            margin: EdgeInsets.all(16),
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildImageSection(),
          ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCameraPressed,
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text(
                      'Camera',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onGalleryPressed,
                    icon: Icon(Icons.photo_library, color: Colors.white),
                    label: Text(
                      'Gallery',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Society Details
          if (selectedUser != null) _buildSocietyDetails(),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    // Check if image exists for selected user
    String? imagePath;
    if (selectedUser != null) {
      imagePath =
          'assets/society_photos/society_photos${selectedUser!.soccode}.jpeg';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child:
            selectedUser == null
                ? _buildPlaceholder('Select a society to view image')
                : _buildImageWidget(imagePath),
      ),
    );
  }

  Widget _buildImageWidget(String? imagePath) {
    return FutureBuilder<bool>(
      future: _imageExists(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.data == true && imagePath != null) {
          return Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          );
        } else {
          return _buildNoImageWidget();
        }
      },
    );
  }

  Future<bool> _imageExists(String? path) async {
    if (path == null) return false;
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  Widget _buildPlaceholder(String message) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.red[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Tap Camera or Gallery to add image',
              style: TextStyle(color: Colors.red[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoImageWidget() {
    return Container(
      color: Colors.blue[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: Colors.blue[400]),
            SizedBox(height: 8),
            Text(
              'No image available',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Use Camera or Gallery to add image',
              style: TextStyle(color: Colors.blue[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocietyDetails() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildDetailRow('Society Code', selectedUser!.soccode, Icons.code),
          SizedBox(height: 12),
          _buildDetailRow(
            'Society Name',
            selectedUser!.societyname,
            Icons.business,
          ),
          if (selectedUser!.district?.isNotEmpty == true) ...[
            SizedBox(height: 12),
            _buildDetailRow(
              'District',
              selectedUser!.district!,
              Icons.location_on,
            ),
          ],
          if (selectedUser!.hq?.isNotEmpty == true) ...[
            SizedBox(height: 12),
            _buildDetailRow(
              'Headquarters',
              selectedUser!.hq!,
              Icons.location_city,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
