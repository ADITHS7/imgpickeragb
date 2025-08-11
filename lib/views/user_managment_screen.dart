// views/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:imgpickapp/viewmodel/user_viewmodel.dart';
import 'package:imgpickapp/widgets/loading_overlay.dart';
import 'package:imgpickapp/widgets/user_details_card.dart';
import 'package:imgpickapp/widgets/user_dropdown.dart';
import 'package:imgpickapp/widgets/user_search_bar.dart';
import 'package:provider/provider.dart';

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          return LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UserSearchBar(),
                  SizedBox(height: 16),
                  UserDropdown(),
                  SizedBox(height: 20),
                  Expanded(child: UserDetailsCard()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
