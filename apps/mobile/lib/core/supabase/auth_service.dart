import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';

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
  final _api = apiClient;

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
      
      final response = await _api.post('/auth/login', data: {
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

        return AuthUser(
          id: data['id'],
          email: data['email'],
          role: data['role'],
          storeId: data['store_id'],
          branchId: data['branch_id'],
          staffId: data['staff_id'],
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

    await _storage.write(key: _userIdKey, value: data['id']);
    await _storage.write(key: _userEmailKey, value: data['email']);
    await _storage.write(key: _userRoleKey, value: data['role']);
    await _storage.write(key: _storeIdKey, value: data['store_id']);
    await _storage.write(key: _branchIdKey, value: data['branch_id']);
    await _storage.write(key: _staffIdKey, value: data['staff_id']);
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
      final storeId = await _storage
          .read(key: _storeIdKey)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      final branchId = await _storage
          .read(key: _branchIdKey)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      final staffId = await _storage
          .read(key: _staffIdKey)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (id == null || email == null || role == null) {
        return null;
      }

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

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
}
