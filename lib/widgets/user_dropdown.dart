// widgets/user_dropdown.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_viewmodel.dart';
import '../model/user_model.dart';

class UserDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<User>(
                isExpanded: true,
                value: dropdownValue,
                hint: Row(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        viewModel.filteredUsers.isEmpty
                            ? 'No societies found'
                            : 'Select a society',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
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
                              Colors.blue[600]!,
                            ),
                          ),
                        )
                        : Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                          size: 24,
                        ),
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue[200]!, width: 1),
            ),
            child: Text(
              user.soccode,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.blue[800],
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.societyname,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (user.district?.isNotEmpty == true ||
                    user.hq?.isNotEmpty == true)
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      [user.district, user.hq]
                          .where((item) => item?.isNotEmpty == true)
                          .take(2) // Limit to 2 items to prevent overflow
                          .join(' • '),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            margin: EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: user.uploaded == 1 ? Colors.green[500] : Colors.grey[400],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (user.uploaded == 1
                          ? Colors.green[300]
                          : Colors.grey[300])!
                      .withOpacity(0.5),
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
