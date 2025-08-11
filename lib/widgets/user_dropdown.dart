// widgets/user_dropdown.dart
import 'package:flutter/material.dart';
import 'package:imgpickapp/model/user_model.dart';
import 'package:imgpickapp/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';

class UserDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<User>(
              isExpanded: true,
              value: viewModel.selectedUser,
              hint: Text('Select a user'),
              items:
                  viewModel.filteredUsers.map((User user) {
                    return DropdownMenuItem<User>(
                      value: user,
                      child: Text(user.name),
                    );
                  }).toList(),
              onChanged: (User? newUser) {
                if (newUser != null) {
                  viewModel.selectUser(newUser);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
