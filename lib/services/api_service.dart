// services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../model/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.101.24:3000/api';
  static late Dio _dio;

  // Initialize Dio
  static void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        sendTimeout: Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

    // Add error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          print('API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // Get Dio instance
  static Dio get dio {
    if (!_dio.isInitialized) {
      initialize();
    }
    return _dio;
  }

  // Handle API response and errors
  static Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return {'success': true, 'data': response.data};
      }
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Request failed with status: ${response.statusCode}',
      );
    }
  }

  // Get all societies for dropdown
  static Future<List<User>> getAllSocieties() async {
    try {
      final response = await dio.get('/societies');
      final data = _handleResponse(response);

      if (data['success'] == true && data['data'] != null) {
        List<dynamic> societiesJson = data['data'];
        return societiesJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch societies: ${_getDioErrorMessage(e)}');
    } catch (e) {
      throw Exception('Failed to fetch societies: ${e.toString()}');
    }
  }

  // Get society details by soccode
  static Future<User> getSocietyDetails(String soccode) async {
    try {
      final response = await dio.get('/societies/$soccode');
      final data = _handleResponse(response);

      if (data['success'] == true && data['data'] != null) {
        return User.fromJson(data['data']);
      } else {
        throw Exception('Society not found');
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to fetch society details: ${_getDioErrorMessage(e)}',
      );
    } catch (e) {
      throw Exception('Failed to fetch society details: ${e.toString()}');
    }
  }

  // Search societies by query
  static Future<List<User>> searchSocieties(String query) async {
    if (query.trim().isEmpty) {
      return getAllSocieties();
    }

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await dio.get('/societies/search/$encodedQuery');
      final data = _handleResponse(response);

      if (data['success'] == true && data['data'] != null) {
        List<dynamic> societiesJson = data['data'];
        return societiesJson.map((json) => User.fromJson(json)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      throw Exception('Failed to search societies: ${_getDioErrorMessage(e)}');
    } catch (e) {
      throw Exception('Failed to search societies: ${e.toString()}');
    }
  }

  // Upload image for a society
  static Future<bool> uploadImage(String soccode, File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        '/societies/$soccode/upload',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final data = _handleResponse(response);
      return data['success'] == true;
    } on DioException catch (e) {
      throw Exception('Failed to upload image: ${_getDioErrorMessage(e)}');
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  // Delete image for a society
  static Future<bool> deleteImage(String soccode) async {
    try {
      final response = await dio.delete('/societies/$soccode/image');
      final data = _handleResponse(response);
      return data['success'] == true;
    } on DioException catch (e) {
      throw Exception('Failed to delete image: ${_getDioErrorMessage(e)}');
    } catch (e) {
      throw Exception('Failed to delete image: ${e.toString()}');
    }
  }

  // Get image URL for a society
  static String getImageUrl(String soccode) {
    return '$baseUrl/societies/$soccode/image';
  }

  // Check if API is healthy
  static Future<bool> checkHealth() async {
    try {
      final response = await dio.get(
        '/health',
        options: Options(receiveTimeout: Duration(seconds: 10)),
      );
      final data = _handleResponse(response);
      return data['success'] == true;
    } on DioException catch (e) {
      print('Health check failed: ${_getDioErrorMessage(e)}');
      return false;
    } catch (e) {
      print('Health check failed: ${e.toString()}');
      return false;
    }
  }

  // Get upload statistics
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await dio.get('/stats');
      final data = _handleResponse(response);

      if (data['success'] == true && data['data'] != null) {
        return data['data'];
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch statistics: ${_getDioErrorMessage(e)}');
    } catch (e) {
      throw Exception('Failed to fetch statistics: ${e.toString()}');
    }
  }

  // Helper method to extract meaningful error messages from DioException
  static String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        if (e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map<String, dynamic> && data['error'] != null) {
            return data['error'].toString();
          }
        }
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error - Check if server is running';
      case DioExceptionType.badCertificate:
        return 'Certificate error';
      case DioExceptionType.unknown:
        return 'Network error: ${e.message}';
      default:
        return 'Unknown error: ${e.message}';
    }
  }

  // Update base URL (useful for switching environments)
  static void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
}

// Extension to check if Dio is initialized
extension DioExtension on Dio {
  bool get isInitialized => interceptors.isNotEmpty;
}
