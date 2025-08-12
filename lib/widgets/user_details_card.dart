// widgets/user_details_card.dart
import 'package:flutter/material.dart';
import 'package:imgpickapp/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'dart:io';

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
                    Icon(Icons.person_off, size: 60, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No users available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                    Icon(
                      Icons.account_circle,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'User Profile',
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

                // Name Display (Read-only)
                Container(
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
                      Text(
                        'User Name',
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
                          Icon(Icons.person, size: 18, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            viewModel.selectedUser!.name,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

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
}
