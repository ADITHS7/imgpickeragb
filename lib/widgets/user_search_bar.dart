import 'package:flutter/material.dart';
import 'package:imgpickapp/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';

class UserSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        return TextField(
          controller: viewModel.searchController,
          decoration: InputDecoration(
            labelText: 'Search Users',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          onChanged: viewModel.filterUsers,
        );
      },
    );
  }
}
