// views/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:imgpickapp/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';

import '../widgets/user_search_bar.dart';
import '../widgets/user_dropdown.dart';
import '../widgets/user_details_card.dart';
import '../widgets/loading_overlay.dart';

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<UserViewModel>(
          builder: (context, viewModel, child) {
            return LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Section
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(Icons.people, size: 40, color: Colors.blue[600]),
                          SizedBox(height: 8),
                          Text(
                            'User Management',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage user profiles and images',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Section
                    UserSearchBar(),
                    SizedBox(height: 16),

                    // Dropdown Section
                    UserDropdown(),
                    SizedBox(height: 20),

                    // Details Section
                    UserDetailsCard(),

                    // Extra bottom padding for scroll
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
