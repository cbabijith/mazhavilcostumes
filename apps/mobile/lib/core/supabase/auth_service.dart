import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class AuthUser {
  final String id;
  final String email;
  final String role;
  final String? storeId;
  final String? branchId;
  final String? staffId;

  AuthUser({
    required this.id,
    required this.email,
    required this.role,
    this.storeId,
    this.branchId,
    this.staffId,
  });
}

class AuthService {
  final _storage = const FlutterSecureStorage();
  late final Dio _dio;

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://mazhavilcostumes-admin-dsak.vercel.app/api',
      ),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  // In-memory cache of the access token so isAuthenticated() can be synchronous.
  String? _cachedToken;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';
  static const _userRoleKey = 'user_role';
  static const _storeIdKey = 'store_id';
  static const _branchIdKey = 'branch_id';
  static const _staffIdKey = 'staff_id';

  /// Login using Next.js API
  Future<AuthUser?> login(String email, String password) async {
    try {
      debugPrint('[AuthService] Attempting login with: $email');
      
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      debugPrint('[AuthService] Response: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        // Store tokens (guard against secure storage hanging on some devices)
        await _persistSession(data).timeout(
          const Duration(seconds: 10),
          onTimeout: () => debugPrint('[AuthService] Storage write timed out'),
        );

        debugPrint('[AuthService] Login successful, user: ${data['email']}');

        final storeIdVal = data['store_id']?.toString();
        final branchIdVal = data['branch_id']?.toString();
        final staffIdVal = data['staff_id']?.toString();

        final storeId = (storeIdVal == 'null' || storeIdVal == 'undefined' || storeIdVal == '') ? null : storeIdVal;
        final branchId = (branchIdVal == 'null' || branchIdVal == 'undefined' || branchIdVal == '') ? null : branchIdVal;
        final staffId = (staffIdVal == 'null' || staffIdVal == 'undefined' || staffIdVal == '') ? null : staffIdVal;

        return AuthUser(
          id: data['id'],
          email: data['email'],
          role: data['role'],
          storeId: storeId,
          branchId: branchId,
          staffId: staffId,
        );
      } else {
        debugPrint('[AuthService] Login failed: ${response.data['error'] ?? 'Unknown error'}');
        return null;
      }
    } on DioException catch (e) {
      debugPrint('[AuthService] Dio error: ${e.message}');
      debugPrint('[AuthService] Response: ${e.response?.data}');
      debugPrint('[AuthService] Status code: ${e.response?.statusCode}');
      return null;
    } catch (e) {
      debugPrint('[AuthService] Login error: $e');
      return null;
    }
  }

  /// Helper to cleanly write or delete storage values to prevent stringified nulls
  Future<void> _writeCleanKey(String key, dynamic value) async {
    final strVal = value?.toString();
    if (strVal != null && strVal != 'null' && strVal != 'undefined' && strVal.isNotEmpty) {
      await _storage.write(key: key, value: strVal);
    } else {
      await _storage.delete(key: key);
    }
  }

  /// Persist the session tokens and user info to secure storage.
  Future<void> _persistSession(Map<String, dynamic> data) async {
    _cachedToken = data['access_token'] as String?;
    debugPrint('[AuthService] Caching token: ${_cachedToken?.substring(0, 20)}...');

    try {
      await _storage.write(key: _accessTokenKey, value: data['access_token']);
      debugPrint('[AuthService] access_token saved');
    } catch (e) {
      debugPrint('[AuthService] Failed to save access_token: $e');
    }

    try {
      await _storage.write(key: _refreshTokenKey, value: data['refresh_token']);
      debugPrint('[AuthService] refresh_token saved');
    } catch (e) {
      debugPrint('[AuthService] Failed to save refresh_token: $e');
    }

    await _storage.write(key: _userIdKey, value: data['id']?.toString());
    await _storage.write(key: _userEmailKey, value: data['email']?.toString());
    await _storage.write(key: _userRoleKey, value: data['role']?.toString());

    // Clean write to prevent stringified nulls
    await _writeCleanKey(_storeIdKey, data['store_id']);
    await _writeCleanKey(_branchIdKey, data['branch_id']);
    await _writeCleanKey(_staffIdKey, data['staff_id']);
  }

  /// Load the cached token from storage on app start.
  /// Returns true if an access token exists.
  Future<bool> loadSession() async {
    try {
      _cachedToken = await _storage
          .read(key: _accessTokenKey)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
    } catch (e) {
      debugPrint('[AuthService] loadSession error: $e');
      _cachedToken = null;
    }
    return _cachedToken != null;
  }

  /// Logout - clear all stored tokens
  Future<void> logout() async {
    _cachedToken = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _storeIdKey);
    await _storage.delete(key: _branchIdKey);
    await _storage.delete(key: _staffIdKey);
  }

  /// Check if user is authenticated (uses in-memory cache).
  bool isAuthenticated() {
    return _cachedToken != null;
  }

  /// Get current user
  Future<AuthUser?> getCurrentUser() async {
    try {
      final id = await _storage
          .read(key: _userIdKey)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      final email = await _storage
          .read(key: _userEmailKey)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      final role = await _storage
          .read(key: _userRoleKey)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      final storeIdVal = await _storage
          .read(key: _storeIdKey)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      final branchIdVal = await _storage
          .read(key: _branchIdKey)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      final staffIdVal = await _storage
          .read(key: _staffIdKey)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (id == null || email == null || role == null) {
        return null;
      }

      final storeId = (storeIdVal == 'null' || storeIdVal == 'undefined' || storeIdVal == '') ? null : storeIdVal;
      final branchId = (branchIdVal == 'null' || branchIdVal == 'undefined' || branchIdVal == '') ? null : branchIdVal;
      final staffId = (staffIdVal == 'null' || staffIdVal == 'undefined' || staffIdVal == '') ? null : staffIdVal;

      return AuthUser(
        id: id,
        email: email,
        role: role,
        storeId: storeId,
        branchId: branchId,
        staffId: staffId,
      );
    } catch (e) {
      debugPrint('[AuthService] getCurrentUser error: $e');
      return null;
    }
  }

  /// Get access token (synchronous, from in-memory cache)
  String? getAccessToken() {
    return _cachedToken;
  }

  /// Get access token (async, from secure storage - for app startup only)
  Future<String?> getAccessTokenFromStorage() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Refresh the access token using the refresh token
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await _storage
          .read(key: _refreshTokenKey)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      
      if (refreshToken == null) {
        debugPrint('[AuthService] No refresh token available');
        return false;
      }

      debugPrint('[AuthService] Attempting token refresh...');

      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        // Update in-memory cache
        _cachedToken = data['access_token'] as String?;
        debugPrint('[AuthService] Token refreshed successfully');

        // Persist new tokens (with timeout to avoid hangs)
        try {
          await _storage.write(key: _accessTokenKey, value: data['access_token'])
              .timeout(const Duration(seconds: 5), onTimeout: () {
            debugPrint('[AuthService] Storage write timed out');
          });
          await _storage.write(key: _refreshTokenKey, value: data['refresh_token'])
              .timeout(const Duration(seconds: 5), onTimeout: () {
            debugPrint('[AuthService] Storage write timed out');
          });
        } catch (e) {
          debugPrint('[AuthService] Failed to save refreshed tokens: $e');
        }

        return true;
      } else {
        debugPrint('[AuthService] Token refresh failed: ${response.data['error']}');
        return false;
      }
    } catch (e) {
      debugPrint('[AuthService] Token refresh error: $e');
      return false;
    }
  }
}

final authService = AuthService();
