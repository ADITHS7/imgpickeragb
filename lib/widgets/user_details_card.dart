// widgets/user_details_card.dart
import 'package:flutter/material.dart';
import 'package:imgpickapp/viewmodel/user_viewmodel.dart';
import 'package:imgpickapp/widgets/action_buttons.dart';
import 'package:imgpickapp/widgets/image_section.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class UserDetailsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.selectedUser == null) {
          return Card(
            elevation: 4,
            child: Center(
              child: Text(
                'No users available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'User Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                ImageSection(),
                SizedBox(height: 20),

                // Name Input
                TextField(
                  controller: viewModel.nameController,
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[50],
                    errorText:
                        viewModel.errorMessage.isNotEmpty
                            ? viewModel.errorMessage
                            : null,
                  ),
                ),
                SizedBox(height: 20),

                ActionButtons(),

                SizedBox(height: 12),
                Text(
                  'User ${viewModel.currentUserIndex + 1} of ${viewModel.totalUsers}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
