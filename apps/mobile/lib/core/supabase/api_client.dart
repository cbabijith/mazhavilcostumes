import 'package:dio/dio.dart';
import 'auth_service.dart';

/// Centralized API Client for communicating with Next.js Admin API
///
/// This client handles all HTTP requests to the backend server,
/// ensuring the mobile app acts as a thin client with no direct database access.
class ApiClient {
  late final Dio _dio;
  Dio get dio => _dio;
  static ApiClient? _instance;
  static final _auth = authService;
  
  // Track if a token refresh is in progress to avoid multiple concurrent refreshes
  bool _isRefreshing = false;
  final List<void Function()> _refreshQueue = [];

  /// Singleton instance (lazy-loaded)
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  ApiClient._internal() {
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://mazhavilcostumes-admin.vercel.app/api',
    );

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
      listFormat: ListFormat.multi,
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Skip token injection for the login endpoint (no token needed)
        if (!options.path.contains('/auth/login')) {
          // Use in-memory token from AuthService to avoid secure storage hangs
          final token = _auth.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('[ApiClient] Sending auth token for ${options.path}');
            print('[ApiClient] Token preview: ${token.substring(0, 20)}...');
          } else {
            print('[ApiClient] No auth token available for ${options.path}');
          }
        }
        print('[ApiClient] Request: ${options.method} ${options.baseUrl}${options.path} params: ${options.queryParameters}');
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 unauthorized - trigger token refresh
        print('[ApiClient] Error for ${error.requestOptions.path}: ${error.type}');
        print('[ApiClient] Status: ${error.response?.statusCode}');
        print('[ApiClient] Response: ${error.response?.data}');
        
        if (error.response?.statusCode == 401 && !error.requestOptions.path.contains('/auth/refresh')) {
          print('[ApiClient] 401 Unauthorized - attempting token refresh');
          
          // If refresh is already in progress, queue this request
          if (_isRefreshing) {
            print('[ApiClient] Refresh already in progress, queuing request');
            _refreshQueue.add(() {
              // Retry the original request with new token
              _retryRequest(error.requestOptions, handler);
            });
            return;
          }
          
          // Start refresh process
          _isRefreshing = true;
          print('[ApiClient] Starting token refresh');
          
          final success = await _auth.refreshAccessToken();
          
          _isRefreshing = false;
          
          if (success) {
            print('[ApiClient] Token refresh successful, retrying queued requests');
            // Retry all queued requests
            for (final callback in _refreshQueue) {
              callback();
            }
            _refreshQueue.clear();
            
            // Retry the original request
            _retryRequest(error.requestOptions, handler);
            return;
          } else {
            print('[ApiClient] Token refresh failed, clearing queue');
            _refreshQueue.clear();
            // Refresh failed, let the error propagate
            return handler.next(error);
          }
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

  /// Retry a failed request with the new access token
  void _retryRequest(RequestOptions requestOptions, ErrorInterceptorHandler handler) {
    // Update the Authorization header with the new token
    final newToken = _auth.getAccessToken();
    if (newToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
      print('[ApiClient] Retrying request with new token: ${requestOptions.path}');
    }
    
    // Clone the request options and retry
    _dio.fetch(requestOptions).then(
      (response) => handler.resolve(response),
      onError: (e) => handler.next(e),
    );
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
