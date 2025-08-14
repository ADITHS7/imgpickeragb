// ========== UPDATED STORAGE SERVICE ==========
import 'dart:convert';
import 'package:imgpickapp/login/model/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<void> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await prefs.setBool(_isLoggedInKey, true);
    } catch (e) {
      // Silent error handling
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      // Silent error handling
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      // Silent error handling
    }
  }
}
