// viewmodels/user_view_model.dart
import 'package:flutter/material.dart';
import 'package:imgpickapp/model/user_model.dart';
import 'package:imgpickapp/services/image_services.dart';
import 'dart:io';

import '../services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final ImageService _imageService = ImageService();

  // Private state
  List<User> _users = [];
  List<User> _filteredUsers = [];
  User? _selectedUser;
  File? _selectedImage;
  int _currentUserIndex = 0;
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';

  // Controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Getters
  List<User> get users => List.unmodifiable(_users);
  List<User> get filteredUsers => List.unmodifiable(_filteredUsers);
  User? get selectedUser => _selectedUser;
  File? get selectedImage => _selectedImage;
  int get currentUserIndex => _currentUserIndex;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get canGoNext =>
      _users.isNotEmpty && _currentUserIndex < _users.length - 1;
  bool get canGoPrevious => _users.isNotEmpty && _currentUserIndex > 0;
  int get totalUsers => _users.length;

  UserViewModel() {
    _initializeUsers();
  }

  void _initializeUsers() {
    _users = _userService.getAllUsers();
    _filteredUsers = List.from(_users);
    if (_users.isNotEmpty) {
      _selectedUser = _users[0];
      nameController.text = _selectedUser!.name;
      _loadUserImage();
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void filterUsers(String query) {
    _searchQuery = query;
    searchController.text = query;
    _filteredUsers = _userService.searchUsers(query);
    notifyListeners();
  }

  void selectUser(User user) {
    _selectedUser = user;
    _currentUserIndex = _users.indexOf(user);
    nameController.text = user.name;
    _loadUserImage();
    _clearError();
    notifyListeners();
  }

  void _loadUserImage() {
    if (_selectedUser?.imagePath != null) {
      _selectedImage = File(_selectedUser!.imagePath!);
    } else {
      _selectedImage = null;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      _setLoading(true);
      _clearError();

      final image = await _imageService.pickImageFromGallery();
      if (image != null) {
        _selectedImage = image;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pick image from gallery: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> takePhotoFromCamera() async {
    try {
      _setLoading(true);
      _clearError();

      final photo = await _imageService.takePhotoFromCamera();
      if (photo != null) {
        _selectedImage = photo;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to take photo: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUser() async {
    if (_selectedUser == null || nameController.text.trim().isEmpty) {
      _setError('Please enter a valid name');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final updatedUser = _selectedUser!.copyWith(
        name: nameController.text.trim(),
        imagePath: _selectedImage?.path,
      );

      final success = _userService.updateUser(updatedUser);
      if (success) {
        _selectedUser = updatedUser;
        _users = _userService.getAllUsers();
        _filteredUsers = _userService.searchUsers(_searchQuery);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update user');
        return false;
      }
    } catch (e) {
      _setError('Error updating user: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser() async {
    if (_selectedUser == null) {
      _setError('No user selected');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final success = _userService.deleteUser(_selectedUser!.id);
      if (success) {
        _users = _userService.getAllUsers();
        _filteredUsers = _userService.searchUsers(_searchQuery);

        // Select next available user
        if (_users.isNotEmpty) {
          _currentUserIndex =
              _currentUserIndex >= _users.length
                  ? _users.length - 1
                  : _currentUserIndex;
          _selectedUser = _users[_currentUserIndex];
          nameController.text = _selectedUser!.name;
          _loadUserImage();
        } else {
          _selectedUser = null;
          _selectedImage = null;
          _currentUserIndex = 0;
          nameController.clear();
        }

        notifyListeners();
        return true;
      } else {
        _setError('Failed to delete user');
        return false;
      }
    } catch (e) {
      _setError('Error deleting user: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void nextUser() {
    if (canGoNext) {
      _currentUserIndex++;
      _selectedUser = _users[_currentUserIndex];
      nameController.text = _selectedUser!.name;
      _loadUserImage();
      _clearError();
      notifyListeners();
    }
  }

  void previousUser() {
    if (canGoPrevious) {
      _currentUserIndex--;
      _selectedUser = _users[_currentUserIndex];
      nameController.text = _selectedUser!.name;
      _loadUserImage();
      _clearError();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
