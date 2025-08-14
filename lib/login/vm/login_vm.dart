import 'package:flutter/material.dart';
import 'package:imgpickapp/login/model/login_model.dart';
import 'package:imgpickapp/login/service/login_service.dart';
import 'package:imgpickapp/login/service/storage_service.dart';

enum LoginState { idle, loading, success, error }

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  LoginState _state = LoginState.idle;
  String _errorMessage = '';
  UserModel? _currentUser;
  LoginResponseModel? _loginResponse;

  // Getters
  LoginState get state => _state;
  String get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  LoginResponseModel? get loginResponse => _loginResponse;
  bool get isLoading => _state == LoginState.loading;

  // Form controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form validation
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _setState(LoginState.loading);

    try {
      final response = await _apiService.login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      _loginResponse = response;

      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _storageService.saveUser(response.data!);
        _setState(LoginState.success);
      } else {
        _errorMessage = response.error ?? response.message;
        _setState(LoginState.error);
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setState(LoginState.error);
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      if (await _storageService.isLoggedIn()) {
        _currentUser = await _storageService.getUser();
        if (_currentUser != null) {
          _setState(LoginState.success);
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> logout() async {
    try {
      await _storageService.clearUser();
      _currentUser = null;
      _loginResponse = null;
      _setState(LoginState.idle);
      clearForm();
    } catch (e) {
      // Silent error handling
    }
  }

  void clearForm() {
    usernameController.clear();
    passwordController.clear();
    _errorMessage = '';
    notifyListeners();
  }

  void _setState(LoginState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
