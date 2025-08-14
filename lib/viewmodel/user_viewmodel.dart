// viewmodel/user_viewmodel.dart - UPDATED with Storage Integration
import 'package:flutter/material.dart';
import 'package:imgpickapp/login/service/storage_service.dart';
import 'package:imgpickapp/services/image_services.dart';
import 'dart:io';
import '../model/user_model.dart';
import '../services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final ImageService _imageService = ImageService();
  final StorageService _storageService = StorageService(); // Add this

  // Private state
  List<User> _users = [];
  List<User> _filteredUsers = [];
  User? _selectedUser;
  File? _selectedImage;
  int _currentUserIndex = 0;
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  bool _isApiConnected = false;
  bool _isInitialized = false;
  String? _currentUserId; // Add this to store current user ID

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
  bool get isApiConnected => _isApiConnected;
  bool get isInitialized => _isInitialized;
  String? get currentUserId => _currentUserId; // Add this getter

  UserViewModel() {
    _initializeUsers();
  }

  Future<void> _initializeUsers() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      // Load current user ID from storage
      await _loadCurrentUserId();

      // Check API connection first
      final healthCheck = await _userService.checkApiHealth();
      _isApiConnected = healthCheck['success'] == true;

      if (!_isApiConnected) {
        _setError(
          'API server is not available. Please check your connection and try again.',
        );
        _setLoading(false);
        notifyListeners();
        return;
      }

      // Load users from API
      await _loadUsersFromApi();

      // Select first user if available
      if (_users.isNotEmpty) {
        await _selectUserByIndex(0);
      } else {
        _setError('No societies found in the database.');
      }

      _isInitialized = true;
      _clearError();
    } catch (e) {
      _setError('Failed to initialize: ${e.toString()}');
      print('Initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add this method to load current user ID from storage
  Future<void> _loadCurrentUserId() async {
    try {
      final user = await _storageService.getUser();
      _currentUserId = user?.id?.toString();
      print('Loaded user ID from storage: $_currentUserId');
    } catch (e) {
      print('Error loading user ID from storage: $e');
      _currentUserId = null;
    }
  }

  // Update user image via API with user_id from storage
  Future<bool> updateUserImage() async {
    if (_selectedUser == null) {
      _setError('No society selected');
      return false;
    }

    if (_selectedImage == null) {
      _setError('No image selected to upload');
      return false;
    }

    if (!_isApiConnected) {
      _setError('API connection required for upload');
      return false;
    }

    if (_currentUserId == null) {
      _setError('User not logged in. Please log in again.');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      // Upload image via UserService with user_id
      final result = await _userService.uploadImage(
        _selectedUser!.soccode,
        _selectedImage!,
        _currentUserId!, // Pass the user_id from storage
      );

      if (result['success'] == true) {
        // Update user in both lists
        if (result['user'] != null) {
          final updatedUser = User.fromJson(result['user']);
          _selectedUser = updatedUser;

          // Update in main users list
          final mainIndex = _users.indexWhere(
            (u) => u.soccode == _selectedUser!.soccode,
          );
          if (mainIndex != -1) {
            _users[mainIndex] = updatedUser;
          }

          // Update in filtered list
          final filteredIndex = _filteredUsers.indexWhere(
            (u) => u.soccode == _selectedUser!.soccode,
          );
          if (filteredIndex != -1) {
            _filteredUsers[filteredIndex] = updatedUser;
          }
        }

        // Clear selected image after successful upload
        _selectedImage = null;
        notifyListeners();
        return true;
      } else {
        _setError(result['error'] ?? 'Failed to upload image to server');
        return false;
      }
    } catch (e) {
      _setError('Error uploading image: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Rest of your existing methods remain the same...
  // (filterUsers, selectUser, _loadUsersFromApi, etc.)

  Future<void> _loadUsersFromApi() async {
    try {
      _users = await _userService.getAllUsers();
      _filteredUsers = List.from(_users);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load societies: ${e.toString()}');
    }
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

  // Filter users by search query with API integration
  Future<void> filterUsers(String query) async {
    _searchQuery = query;

    if (!_isApiConnected) {
      _setError('API connection required for search');
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      if (query.trim().isEmpty) {
        // Reset to show all users
        _filteredUsers = List.from(_users);
        // Restore selected user if it was previously selected
        if (_selectedUser != null) {
          _currentUserIndex = _users.indexWhere(
            (u) => u.soccode == _selectedUser!.soccode,
          );
          if (_currentUserIndex == -1) _currentUserIndex = 0;
        }
      } else {
        // Perform search
        _filteredUsers = await _userService.searchUsers(query);

        // Check if current selected user is in filtered results
        if (_selectedUser != null) {
          final isSelectedUserInResults = _filteredUsers.any(
            (user) => user.soccode == _selectedUser!.soccode,
          );

          if (!isSelectedUserInResults) {
            // Clear selection if current user not in results
            _selectedUser = null;
            _selectedImage = null;
            _currentUserIndex = 0;
            nameController.clear();
          } else {
            // Update current user index based on filtered results
            _currentUserIndex = _filteredUsers.indexWhere(
              (u) => u.soccode == _selectedUser!.soccode,
            );
          }
        }

        // If no user is selected and we have results, select first one
        if (_selectedUser == null && _filteredUsers.isNotEmpty) {
          await selectUser(_filteredUsers[0]);
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
      _filteredUsers = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Select user and load details from API
  Future<void> selectUser(User user) async {
    try {
      _setLoading(true);
      _clearError();

      // Find index in current filtered list
      _currentUserIndex = _filteredUsers.indexWhere(
        (u) => u.soccode == user.soccode,
      );
      if (_currentUserIndex == -1) _currentUserIndex = 0;

      // Load fresh user details from API
      final updatedUser = await _userService.getUserBySoccode(user.soccode);
      if (updatedUser != null) {
        _selectedUser = updatedUser;
        nameController.text = _selectedUser!.societyname;
        _loadUserImage();
      } else {
        _setError('Failed to load society details');
      }
    } catch (e) {
      _setError('Failed to select society: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _selectUserByIndex(int index) async {
    // Use filtered users for navigation when searching
    final userList = _searchQuery.isEmpty ? _users : _filteredUsers;
    if (index >= 0 && index < userList.length) {
      await selectUser(userList[index]);
    }
  }

  void _loadUserImage() {
    // Clear any locally selected image when loading user
    _selectedImage = null;
    notifyListeners();
  }

  // Get image URL for network loading
  String? getImageUrl() {
    if (_selectedUser != null && _selectedUser!.hasImage) {
      return _userService.getImageUrl(_selectedUser!.soccode);
    }
    return null;
  }

  // Pick image from gallery
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

  // Take photo from camera
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

  // Delete user image via API
  Future<bool> deleteUserImage() async {
    if (_selectedUser == null) {
      _setError('No society selected');
      return false;
    }

    if (!_selectedUser!.hasImage) {
      _setError('No image to delete');
      return false;
    }

    if (!_isApiConnected) {
      _setError('API connection required for delete operation');
      return false;
    }

    if (_currentUserId == null) {
      _setError('User not logged in. Please log in again.');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      // Delete image via UserService with user_id
      final result = await _userService.deleteImage(
        _selectedUser!.soccode,
        _currentUserId!, // Pass the user_id from storage
      );

      if (result['success'] == true) {
        // Update user in both lists
        if (result['user'] != null) {
          final updatedUser = User.fromJson(result['user']);
          _selectedUser = updatedUser;

          // Update in main users list
          final mainIndex = _users.indexWhere(
            (u) => u.soccode == _selectedUser!.soccode,
          );
          if (mainIndex != -1) {
            _users[mainIndex] = updatedUser;
          }

          // Update in filtered list
          final filteredIndex = _filteredUsers.indexWhere(
            (u) => u.soccode == _selectedUser!.soccode,
          );
          if (filteredIndex != -1) {
            _filteredUsers[filteredIndex] = updatedUser;
          }
        }

        _selectedImage = null;
        notifyListeners();
        return true;
      } else {
        _setError(result['error'] ?? 'Failed to delete image from server');
        return false;
      }
    } catch (e) {
      _setError('Error deleting image: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Navigation methods
  Future<void> nextUser() async {
    final userList = _searchQuery.isEmpty ? _users : _filteredUsers;
    if (_currentUserIndex < userList.length - 1) {
      await _selectUserByIndex(_currentUserIndex + 1);
    }
  }

  Future<void> previousUser() async {
    final userList = _searchQuery.isEmpty ? _users : _filteredUsers;
    if (_currentUserIndex > 0) {
      await _selectUserByIndex(_currentUserIndex - 1);
    }
  }

  // Updated navigation getters for search context
  bool get canGoNextInContext {
    final userList = _searchQuery.isEmpty ? _users : _filteredUsers;
    return userList.isNotEmpty && _currentUserIndex < userList.length - 1;
  }

  bool get canGoPreviousInContext {
    final userList = _searchQuery.isEmpty ? _users : _filteredUsers;
    return userList.isNotEmpty && _currentUserIndex > 0;
  }

  // Get current context info
  String get currentContextInfo {
    final userList = _searchQuery.isEmpty ? _users : _filteredUsers;
    if (userList.isEmpty) return '0/0';
    return '${_currentUserIndex + 1}/${userList.length}';
  }

  // Refresh all data from API
  Future<void> refreshData() async {
    try {
      _setLoading(true);
      _clearError();

      // Reload current user ID from storage
      await _loadCurrentUserId();

      // Check API connection
      final healthCheck = await _userService.checkApiHealth();
      _isApiConnected = healthCheck['success'] == true;

      if (!_isApiConnected) {
        _setError('API server is not available. Please check your connection.');
        return;
      }

      // Clear cache and reload data
      _userService.clearCache();
      await _loadUsersFromApi();

      // Re-apply current search if any
      if (_searchQuery.isNotEmpty) {
        await filterUsers(_searchQuery);
      } else {
        // Refresh current user if selected
        if (_selectedUser != null) {
          await selectUser(_selectedUser!);
        } else if (_users.isNotEmpty) {
          await _selectUserByIndex(0);
        }
      }

      _clearError();
    } catch (e) {
      _setError('Failed to refresh data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Get upload statistics from API
  Future<Map<String, dynamic>?> getUploadStats() async {
    if (!_isApiConnected) {
      _setError('API connection required for statistics');
      return null;
    }

    try {
      final stats = await _userService.getStats();
      if (stats['success'] == true) {
        return stats['data'];
      } else {
        _setError(stats['error'] ?? 'Failed to get statistics');
        return null;
      }
    } catch (e) {
      _setError('Failed to get statistics: ${e.toString()}');
      return null;
    }
  }

  // Check API connection status
  Future<void> checkApiConnection() async {
    try {
      final healthCheck = await _userService.checkApiHealth();
      _isApiConnected = healthCheck['success'] == true;
      if (_isApiConnected) {
        _clearError();
      } else {
        _setError(healthCheck['message'] ?? 'API server is not reachable');
      }
      notifyListeners();
    } catch (e) {
      _isApiConnected = false;
      _setError('Failed to check API connection: ${e.toString()}');
      notifyListeners();
    }
  }

  // Reset to initial state
  void reset() {
    _users.clear();
    _filteredUsers.clear();
    _selectedUser = null;
    _selectedImage = null;
    _currentUserIndex = 0;
    _isLoading = false;
    _errorMessage = '';
    _searchQuery = '';
    _isApiConnected = false;
    _isInitialized = false;
    _currentUserId = null; // Reset user ID too

    searchController.clear();
    nameController.clear();

    notifyListeners();
  }

  // Retry initialization if it failed
  Future<void> retryInitialization() async {
    _isInitialized = false;
    reset();
    await _initializeUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    nameController.dispose();
    _userService.dispose();
    super.dispose();
  }
}
