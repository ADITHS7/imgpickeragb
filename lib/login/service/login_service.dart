// ========== UPDATED API SERVICE ==========
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:imgpickapp/env.dart';
import 'package:imgpickapp/login/model/login_model.dart';

class ApiService {
  static const Duration timeoutDuration = Duration(seconds: 30);

  static Dio? _dio;

  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: timeoutDuration,
          receiveTimeout: timeoutDuration,
          sendTimeout: timeoutDuration,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );
    }
    return _dio!;
  }

  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final data = {'username': username, 'password': password};

      // Updated endpoint to match your users login API
      final response = await dio.post('/users/login', data: data);

      // Check if response is HTML instead of JSON
      final contentType = response.headers.value('content-type');
      if (contentType?.contains('text/html') == true) {
        return LoginResponseModel(
          success: false,
          message: 'Service temporarily unavailable',
          error: 'Server error',
        );
      }

      // Check if response data is null or empty
      if (response.data == null) {
        return LoginResponseModel(
          success: false,
          message: 'No response from server',
          error: 'Empty response',
        );
      }

      // Get response data
      Map<String, dynamic> responseData;

      if (response.data is String) {
        return LoginResponseModel(
          success: false,
          message: 'Invalid response format',
          error: 'Invalid format',
        );
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else {
        return LoginResponseModel(
          success: false,
          message: 'Invalid response format',
          error: 'Unexpected data type',
        );
      }

      // Handle successful responses
      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(responseData);
      }
      // Handle client/server errors
      else if (response.statusCode! >= 400) {
        return LoginResponseModel(
          success: false,
          message: responseData['message'] ?? 'Login failed',
          error: responseData['error'] ?? 'Authentication error',
        );
      }
      // Handle other status codes
      else {
        return LoginResponseModel(
          success: false,
          message: 'Service temporarily unavailable',
          error: 'Server error',
        );
      }
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return LoginResponseModel(
            success: false,
            message: 'Connection timeout',
            error: 'Request timeout',
          );

        case DioExceptionType.connectionError:
          return LoginResponseModel(
            success: false,
            message: 'Network connection failed',
            error: 'Connection error',
          );

        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          final responseData = e.response?.data;

          if (statusCode == 401) {
            return LoginResponseModel(
              success: false,
              message: 'Invalid credentials',
              error: 'Unauthorized',
            );
          } else if (statusCode == 404) {
            return LoginResponseModel(
              success: false,
              message: 'Account not found',
              error: 'Not found',
            );
          } else if (statusCode != null && statusCode >= 400) {
            String errorMessage = 'Server error';

            if (responseData is Map<String, dynamic>) {
              errorMessage = responseData['message'] ?? errorMessage;
            }

            return LoginResponseModel(
              success: false,
              message: errorMessage,
              error: 'Server error',
            );
          }
          break;

        case DioExceptionType.cancel:
          return LoginResponseModel(
            success: false,
            message: 'Request cancelled',
            error: 'Cancelled',
          );

        case DioExceptionType.badCertificate:
          return LoginResponseModel(
            success: false,
            message: 'Security error',
            error: 'Certificate error',
          );

        case DioExceptionType.unknown:
        default:
          return LoginResponseModel(
            success: false,
            message: 'Network error',
            error: 'Unknown error',
          );
      }

      return LoginResponseModel(
        success: false,
        message: 'An error occurred',
        error: 'Unexpected error',
      );
    } on SocketException catch (e) {
      return LoginResponseModel(
        success: false,
        message: 'Network connection failed',
        error: 'Socket error',
      );
    } catch (e) {
      return LoginResponseModel(
        success: false,
        message: 'An unexpected error occurred',
        error: 'General error',
      );
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await dio.get(
        '/health',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static void dispose() {
    _dio?.close();
    _dio = null;
  }
}
