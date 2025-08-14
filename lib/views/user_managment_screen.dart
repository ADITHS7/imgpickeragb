// views/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_viewmodel.dart';
import '../widgets/user_search_bar.dart';
import '../widgets/user_dropdown.dart';
import '../widgets/user_details_card.dart';

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<UserViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // App Logo/Image Container
                        Container(
                          width: 120,
                          height: 80,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withOpacity(
                                0.05,
                              ), // Milma brand color
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF8B2635).withOpacity(0.15),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/logo.png', // Your Milma logo
                              fit: BoxFit.contain, // Preserve logo proportions
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to icon if image fails to load
                                return Icon(
                                  Icons.agriculture,
                                  size: 36,
                                  color: Colors.black.withOpacity(0.05),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Milma Photo App',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black, // Milma brand color
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Society President Photo Management',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),

                  // Search Section
                  UserSearchBar(),

                  // Dropdown Section
                  UserDropdown(),

                  SizedBox(height: 16),

                  // Details Section
                  UserDetailsCard(),

                  SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
