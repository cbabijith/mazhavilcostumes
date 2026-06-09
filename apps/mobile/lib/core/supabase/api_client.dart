import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized API Client for communicating with Next.js Admin API
///
/// This client handles all HTTP requests to the backend server,
/// ensuring the mobile app acts as a thin client with no direct database access.
class ApiClient {
  late final Dio _dio;
  static ApiClient? _instance;
  final _storage = const FlutterSecureStorage();

  /// Singleton instance (lazy-loaded)
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    const baseUrl = 'https://mazhavilcostumes-admin.vercel.app/api';

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip token injection for the login endpoint (no token needed)
        if (!options.path.contains('/auth/login')) {
          try {
            // Add Next.js auth token if available.
            // Guard against secure storage hanging on some Android devices.
            final token = await _storage
                .read(key: 'access_token')
                .timeout(const Duration(seconds: 5), onTimeout: () => null);
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              print('[ApiClient] Sending auth token for ${options.path}');
              print('[ApiClient] Token preview: ${token.substring(0, 20)}...');
            } else {
              print('[ApiClient] No auth token available for ${options.path}');
            }
          } catch (e) {
            print('[ApiClient] Error reading auth token: $e');
          }
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 unauthorized - could trigger refresh
        print('[ApiClient] Error for ${error.requestOptions.path}: ${error.type}');
        print('[ApiClient] Status: ${error.response?.statusCode}');
        print('[ApiClient] Response: ${error.response?.data}');
        if (error.response?.statusCode == 401) {
          print('[ApiClient] 401 Unauthorized - token may be invalid');
          // TODO: Implement token refresh logic
        }
        return handler.next(error);
      },
    ));

    // Add response logging
    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        print('[ApiClient] Response for ${response.requestOptions.path}: ${response.statusCode}');
        return handler.next(response);
      },
    ));
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to user-friendly exceptions
  Exception _handleError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        if (responseData != null && responseData is Map) {
          message = responseData['error'] ?? 
                    responseData['message'] ?? 
                    'Server error occurred';
        } else {
          message = _getStatusMessage(statusCode);
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.unknown:
        message = 'Network error: ${error.message}';
        break;
      default:
        message = 'An unexpected error occurred';
    }
    
    return Exception(message);
  }

  String _getStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. The resource already exists or has conflicts.';
      case 500:
        return 'Internal server error. Please try again later.';
      default:
        return 'Request failed with status: $statusCode';
    }
  }
}

/// Global instance
final apiClient = ApiClient.instance;
