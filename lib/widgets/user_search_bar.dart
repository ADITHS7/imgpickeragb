// widgets/user_search_bar.dart
import 'package:flutter/material.dart';
import 'package:imgpickapp/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';

class UserSearchBar extends StatefulWidget {
  @override
  _UserSearchBarState createState() => _UserSearchBarState();
}

class _UserSearchBarState extends State<UserSearchBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: viewModel.searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: 'Search Societies',
              hintText: 'Enter society code or name...',
              prefixIcon: Container(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.search,
                  color: viewModel.isLoading ? Colors.blue : Colors.grey[600],
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading indicator
                  if (viewModel.isLoading)
                    Container(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ),
                    ),

                  // Clear button
                  if (viewModel.searchController.text.isNotEmpty &&
                      !viewModel.isLoading)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      onPressed: () {
                        viewModel.searchController.clear();
                        viewModel.filterUsers('');
                        _focusNode.unfocus();
                      },
                    ),

                  // API status indicator
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      viewModel.isApiConnected
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      size: 16,
                      color:
                          viewModel.isApiConnected
                              ? Colors.green[600]
                              : Colors.red[600],
                    ),
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            onChanged: (value) {
              // Debounce search to avoid too many API calls
              Future.delayed(Duration(milliseconds: 500), () {
                if (viewModel.searchController.text == value) {
                  viewModel.filterUsers(value);
                }
              });
            },
            onSubmitted: (value) {
              viewModel.filterUsers(value);
              _focusNode.unfocus();
            },
          ),
        );
      },
    );
  }
}
