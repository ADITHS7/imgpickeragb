// widgets/user_details_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_viewmodel.dart';
import 'image_section.dart';
import 'action_buttons.dart';

class UserDetailsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.selectedUser == null) {
          return Container(
            height: 400,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!viewModel.isApiConnected) ...[
                      Icon(Icons.cloud_off, size: 60, color: Colors.red[400]),
                      SizedBox(height: 16),
                      Text(
                        'API Connection Failed',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please check server connection',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed:
                            viewModel.isLoading ? null : viewModel.refreshData,
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ] else ...[
                      Icon(Icons.business, size: 60, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No societies available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try refreshing the data',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed:
                            viewModel.isLoading ? null : viewModel.refreshData,
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.business, color: Colors.blue[600], size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Society Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${viewModel.currentUserIndex + 1}/${viewModel.totalUsers}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Image Section
                ImageSection(),
                SizedBox(height: 20),

                // Society Information
                _buildSocietyInfo(viewModel),

                // Error Display
                if (viewModel.errorMessage.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[600],
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 20),

                // Action Buttons
                ActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocietyInfo(UserViewModel viewModel) {
    final user = viewModel.selectedUser!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Society Code
          _buildInfoRow(
            icon: Icons.code,
            label: 'Society Code',
            value: user.soccode,
          ),
          SizedBox(height: 12),

          // Society Name
          _buildInfoRow(
            icon: Icons.business,
            label: 'Society Name',
            value: user.societyname,
          ),

          // Optional fields (only show if not null/empty)
          if (user.pandiunit?.isNotEmpty == true) ...[
            SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.domain,
              label: 'Pandi Unit',
              value: user.pandiunit!,
            ),
          ],

          if (user.district?.isNotEmpty == true) ...[
            SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.location_city,
              label: 'District',
              value: user.district!,
            ),
          ],

          if (user.hq?.isNotEmpty == true) ...[
            SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.home_work,
              label: 'Headquarters',
              value: user.hq!,
            ),
          ],

          SizedBox(height: 12),

          // Upload Status
          Row(
            children: [
              Icon(
                user.uploaded == 1 ? Icons.cloud_done : Icons.cloud_off,
                size: 18,
                color:
                    user.uploaded == 1 ? Colors.green[600] : Colors.grey[600],
              ),
              SizedBox(width: 8),
              Text(
                'Upload Status',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      user.uploaded == 1 ? Colors.green[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  user.uploaded == 1 ? 'Uploaded' : 'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        user.uploaded == 1
                            ? Colors.green[700]
                            : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
