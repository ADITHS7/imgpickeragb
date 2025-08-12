// services/user_service.dart
import 'dart:io';
import '../model/user_model.dart';
import 'api_service.dart';

class UserService {
  // Cache for users to avoid repeated API calls
  List<User>? _cachedUsers;
  DateTime? _lastFetchTime;
  static const Duration cacheValidDuration = Duration(minutes: 5);

  // Search cache to improve search performance
  final Map<String, List<User>> _searchCache = {};
  final Map<String, DateTime> _searchCacheTime = {};
  static const Duration searchCacheValidDuration = Duration(minutes: 2);

  // Singleton pattern
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal() {
    // Initialize API service
    ApiService.initialize();
  }

  // Check if main cache is valid
  bool get _isCacheValid {
    if (_cachedUsers == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < cacheValidDuration;
  }

  // Check if search cache is valid for a query
  bool _isSearchCacheValid(String query) {
    if (!_searchCache.containsKey(query) ||
        !_searchCacheTime.containsKey(query)) {
      return false;
    }
    return DateTime.now().difference(_searchCacheTime[query]!) <
        searchCacheValidDuration;
  }

  // Get all users (with enhanced caching)
  Future<List<User>> getAllUsers() async {
    try {
      if (_isCacheValid && _cachedUsers != null) {
        return List.from(_cachedUsers!);
      }

      final users = await ApiService.getAllSocieties();
      _cachedUsers = users;
      _lastFetchTime = DateTime.now();

      return List.from(users);
    } catch (e) {
      // If API fails and we have cached data, return cached data
      if (_cachedUsers != null) {
        print('API failed, returning cached data: $e');
        return List.from(_cachedUsers!);
      }
      throw Exception('Failed to load societies: $e');
    }
  }

  // Get user by soccode with caching update
  Future<User?> getUserBySoccode(String soccode) async {
    try {
      final user = await ApiService.getSocietyDetails(soccode);

      // Update user in cache if it exists
      if (_cachedUsers != null) {
        final index = _cachedUsers!.indexWhere((u) => u.soccode == soccode);
        if (index != -1) {
          _cachedUsers![index] = user;
        } else {
          // Add new user to cache if not found
          _cachedUsers!.add(user);
        }
      }

      return user;
    } catch (e) {
      print('Error getting user details: $e');

      // Try to find in cache as fallback
      if (_cachedUsers != null) {
        try {
          return _cachedUsers!.firstWhere((user) => user.soccode == soccode);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
  }

  // Search users with enhanced caching
  Future<List<User>> searchUsers(String query) async {
    try {
      final trimmedQuery = query.trim();

      if (trimmedQuery.isEmpty) {
        return await getAllUsers();
      }

      // Return cached search result if valid
      if (_isSearchCacheValid(trimmedQuery)) {
        return List.from(_searchCache[trimmedQuery]!);
      }

      // Perform API search
      final searchResults = await ApiService.searchSocieties(trimmedQuery);

      // Cache the search results
      _searchCache[trimmedQuery] = searchResults;
      _searchCacheTime[trimmedQuery] = DateTime.now();

      return searchResults;
    } catch (e) {
      // Fallback to cached search if API fails
      if (_cachedUsers != null) {
        final results =
            _cachedUsers!
                .where(
                  (user) =>
                      user.soccode.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      user.societyname.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();

        print('API search failed, using cached search: $e');
        return results;
      }
      throw Exception('Failed to search societies: $e');
    }
  }

  // Refresh user data from API (force fresh data)
  Future<User?> refreshUser(String soccode) async {
    try {
      final updatedUser = await ApiService.getSocietyDetails(soccode);

      // Update in main cache if exists
      if (_cachedUsers != null) {
        final index = _cachedUsers!.indexWhere(
          (user) => user.soccode == soccode,
        );
        if (index != -1) {
          _cachedUsers![index] = updatedUser;
        }
      }

      // Clear related search cache entries
      _clearSearchCacheForUser(soccode);

      return updatedUser;
    } catch (e) {
      print('Failed to refresh user data: $e');
      throw Exception('Failed to refresh user data: $e');
    }
  }

  // Upload image with enhanced error handling and proper response handling
  Future<Map<String, dynamic>> uploadImage(
    String soccode,
    File imageFile,
  ) async {
    try {
      if (!await imageFile.exists()) {
        return {'success': false, 'error': 'Image file does not exist'};
      }

      final success = await ApiService.uploadImage(soccode, imageFile);

      if (success) {
        // Refresh user data to get updated status
        final updatedUser = await refreshUser(soccode);
        return {
          'success': true,
          'message': 'Image uploaded successfully',
          'user': updatedUser?.toJson(),
        };
      } else {
        return {'success': false, 'error': 'Failed to upload image'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Upload failed: $e'};
    }
  }

  // Delete image with enhanced error handling
  Future<Map<String, dynamic>> deleteImage(String soccode) async {
    try {
      final success = await ApiService.deleteImage(soccode);

      if (success) {
        // Refresh user data to get updated status
        final updatedUser = await refreshUser(soccode);
        return {
          'success': true,
          'message': 'Image deleted successfully',
          'user': updatedUser?.toJson(),
        };
      } else {
        return {'success': false, 'error': 'Failed to delete image'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Delete failed: $e'};
    }
  }

  // Update user in cache (for local updates)
  Future<bool> updateUserInCache(User updatedUser) async {
    try {
      // Update cached user if exists
      if (_cachedUsers != null) {
        final index = _cachedUsers!.indexWhere(
          (user) => user.soccode == updatedUser.soccode,
        );
        if (index != -1) {
          _cachedUsers![index] = updatedUser;
        }
      }

      // Clear related search cache
      _clearSearchCacheForUser(updatedUser.soccode);

      return true;
    } catch (e) {
      print('Error updating user in cache: $e');
      return false;
    }
  }

  // Get image URL
  String getImageUrl(String soccode) {
    return ApiService.getImageUrl(soccode);
  }

  // Clear all cache (enhanced)
  void clearCache() {
    _cachedUsers = null;
    _lastFetchTime = null;
    _searchCache.clear();
    _searchCacheTime.clear();
  }

  // Clear search cache only
  void clearSearchCache() {
    _searchCache.clear();
    _searchCacheTime.clear();
  }

  // Clear search cache entries related to a specific user
  void _clearSearchCacheForUser(String soccode) {
    final keysToRemove = <String>[];

    for (final entry in _searchCache.entries) {
      if (entry.value.any((user) => user.soccode == soccode)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _searchCache.remove(key);
      _searchCacheTime.remove(key);
    }
  }

  // Get enhanced cache status
  Map<String, dynamic> getCacheStatus() {
    return {
      'hasCachedData': _cachedUsers != null,
      'cacheSize': _cachedUsers?.length ?? 0,
      'lastFetchTime': _lastFetchTime?.toIso8601String(),
      'isValid': _isCacheValid,
      'searchCacheSize': _searchCache.length,
      'searchCacheKeys': _searchCache.keys.toList(),
      'cacheValidDuration': cacheValidDuration.inMinutes,
      'searchCacheValidDuration': searchCacheValidDuration.inMinutes,
    };
  }

  // Get statistics with enhanced error handling
  Future<Map<String, dynamic>> getStats() async {
    try {
      final stats = await ApiService.getStats();
      return {'success': true, 'data': stats};
    } catch (e) {
      return {'success': false, 'error': 'Failed to get statistics: $e'};
    }
  }

  // Check API health with enhanced response
  Future<Map<String, dynamic>> checkApiHealth() async {
    try {
      final isHealthy = await ApiService.checkHealth();
      return {
        'success': isHealthy,
        'status': isHealthy ? 'healthy' : 'unhealthy',
        'timestamp': DateTime.now().toIso8601String(),
        'message': isHealthy ? 'API is accessible' : 'API is not accessible',
      };
    } catch (e) {
      return {
        'success': false,
        'status': 'error',
        'error': 'Health check failed: $e',
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Failed to connect to API server',
      };
    }
  }

  // Check if API is available (simple boolean)
  Future<bool> isApiAvailable() async {
    try {
      return await ApiService.checkHealth();
    } catch (e) {
      return false;
    }
  }

  // Get users with images
  Future<List<User>> getUsersWithImages() async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.where((user) => user.hasImage).toList();
    } catch (e) {
      print('Failed to get users with images: $e');
      return [];
    }
  }

  // Get users without images
  Future<List<User>> getUsersWithoutImages() async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.where((user) => !user.hasImage).toList();
    } catch (e) {
      print('Failed to get users without images: $e');
      return [];
    }
  }

  // Get users by upload status
  Future<List<User>> getUsersByUploadStatus(int uploadStatus) async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.where((user) => user.uploaded == uploadStatus).toList();
    } catch (e) {
      print('Failed to get users by upload status: $e');
      return [];
    }
  }

  // Get users by district
  Future<List<User>> getUsersByDistrict(String district) async {
    try {
      final allUsers = await getAllUsers();
      return allUsers
          .where(
            (user) => user.district?.toLowerCase() == district.toLowerCase(),
          )
          .toList();
    } catch (e) {
      print('Failed to get users by district: $e');
      return [];
    }
  }

  // Force refresh all data
  Future<List<User>> forceRefresh() async {
    clearCache();
    return await getAllUsers();
  }

  // Preload data for better performance
  Future<void> preloadData() async {
    try {
      await getAllUsers();
      print('User data preloaded successfully');
    } catch (e) {
      print('Failed to preload user data: $e');
    }
  }

  // Validate user data
  bool isValidUser(User user) {
    return user.soccode.isNotEmpty && user.societyname.isNotEmpty;
  }

  // Get user count from cache or API
  Future<int> getUserCount() async {
    try {
      if (_isCacheValid && _cachedUsers != null) {
        return _cachedUsers!.length;
      }

      final users = await getAllUsers();
      return users.length;
    } catch (e) {
      return _cachedUsers?.length ?? 0;
    }
  }

  // Get cached user count (immediate, no API call)
  int get cachedUserCount => _cachedUsers?.length ?? 0;

  // Legacy methods for backward compatibility
  int get userCount => _cachedUsers?.length ?? 0;

  @Deprecated('Use deleteImage(String soccode) instead')
  bool deleteUser(int userId) {
    print(
      'deleteUser(int) is deprecated. Use deleteImage(String soccode) instead.',
    );
    return false;
  }

  @Deprecated('Adding users should be done through backend API')
  User? addUser(User newUser) {
    print('addUser is not implemented for this API structure.');
    return null;
  }

  // Cleanup resources
  void dispose() {
    clearCache();
  }
}
