// widgets/user_search_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_viewmodel.dart';

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
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
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
                  color:
                      viewModel.isLoading ? Colors.blue[600] : Colors.grey[500],
                  size: 22,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (viewModel.isLoading)
                    Container(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[600]!,
                          ),
                        ),
                      ),
                    ),
                  if (viewModel.searchController.text.isNotEmpty &&
                      !viewModel.isLoading)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      onPressed: () {
                        viewModel.searchController.clear();
                        viewModel.filterUsers('');
                        _focusNode.unfocus();
                      },
                    ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            viewModel.isApiConnected
                                ? Colors.green[500]
                                : Colors.red[500],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[400]!, width: 1),
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
              Future.delayed(Duration(milliseconds: 300), () {
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
