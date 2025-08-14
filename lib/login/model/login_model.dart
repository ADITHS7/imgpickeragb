// ========== USER MODEL ==========
class UserModel {
  final String id;
  final String username;

  UserModel({required this.id, required this.username});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
      );
    } catch (e) {
      // Return default values on error
      return UserModel(id: '', username: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username};
  }

  @override
  String toString() {
    return 'UserModel{id: $id, username: $username}';
  }
}

// ========== LOGIN RESPONSE MODEL ==========
class LoginResponseModel {
  final bool success;
  final String message;
  final UserModel? data;
  final String? error;

  LoginResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different ways success might be represented
      bool success = false;
      if (json['success'] is bool) {
        success = json['success'];
      } else if (json['success'] is String) {
        success = json['success'].toString().toLowerCase() == 'true';
      } else {
        // Fallback: check if message indicates success
        success =
            json['message']?.toString().toLowerCase().contains('success') ==
            true;
      }

      return LoginResponseModel(
        success: success,
        message: json['message']?.toString() ?? 'No message provided',
        data: json['data'] != null ? UserModel.fromJson(json['data']) : null,
        error: json['error']?.toString(),
      );
    } catch (e) {
      return LoginResponseModel(
        success: false,
        message: 'Failed to parse server response',
        error: 'Parsing error',
      );
    }
  }

  @override
  String toString() {
    return 'LoginResponseModel{success: $success, message: $message, data: $data, error: $error}';
  }
}
