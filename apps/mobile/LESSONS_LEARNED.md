# Lessons Learned - Mazhavil Costumes Mobile App

This document captures common mistakes and lessons learned during development to avoid repeating them in future projects.

---

## Authentication & API Layer

### ❌ Mistake: Direct Supabase Access from Mobile App
**Problem:** Mobile app accessed Supabase directly, violating the thin client architecture. This made it impossible to enforce server-side business logic and RBAC.

**Solution:** Mobile app should only communicate with Next.js API endpoints. All business logic, validation, and RBAC must live on the server.

**Reference:** All repositories in `lib/features/*/repositories/` now use `ApiClient` (Dio) instead of Supabase client.

---

### ❌ Mistake: Auth Interceptor Hangs on Login Request
**Problem:** The auth interceptor called `await _storage.read('access_token')` on **every** request, including `/auth/login`. On Android, `flutter_secure_storage` can hang on the platform channel during first keystore access. Since this happened before the request was dispatched, Dio's `connectTimeout` never fired, causing infinite loading with no error.

**Solution:**
1. Skip token injection for the login endpoint (no token needed)
2. Wrap storage reads in `try-catch` with a timeout
3. Use in-memory token cache for synchronous `isAuthenticated()` checks

**Code:**
```dart
// api_client.dart
onRequest: (options, handler) async {
  if (!options.path.contains('/auth/login')) {
    try {
      final token = await _storage
          .read(key: 'access_token')
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('[ApiClient] Error reading auth token: $e');
    }
  }
  return handler.next(options);
}
```

---

### ❌ Mistake: `isAuthenticated()` Compared Future to null
**Problem:** `isAuthenticated()` was calling `await _storage.read()` but the method signature was synchronous, so it was comparing a `Future` object to `null` (always `true`). This caused the splash screen to always navigate to the dashboard even when logged out.

**Solution:** Use an in-memory cache for the access token so `isAuthenticated()` can be synchronous and correct.

**Code:**
```dart
class AuthService {
  String? _cachedToken;

  bool isAuthenticated() {
    return _cachedToken != null; // Correct: checks actual value
  }

  Future<bool> loadSession() async {
    _cachedToken = await _storage.read(key: 'access_token');
    return _cachedToken != null;
  }
}
```

---

### ❌ Mistake: Storage Writes Can Also Hang
**Problem:** After successful login, the app hung while writing tokens to secure storage.

**Solution:** Wrap storage writes in a timeout to prevent indefinite hangs.

**Code:**
```dart
await _persistSession(data).timeout(
  const Duration(seconds: 10),
  onTimeout: () => debugPrint('[AuthService] Storage write timed out'),
);
```

---

## Riverpod State Management

### ❌ Mistake: Circular Dependency with Global Singleton
**Problem:** `authServiceProvider` tried to use a global `authService` singleton, which created a circular dependency with `apiClient`. This caused `throwProviderException` at runtime.

**Solution:** Make the auth service a proper Riverpod provider and read it via `ref.read()`.

**Code:**
```dart
// Correct
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final authService = ref.read(authServiceProvider);
    // ...
  }
}
```

---

### ❌ Mistake: Provider Order Matters
**Problem:** `AuthNotifier` tried to read `authServiceProvider` before it was defined, causing a provider exception.

**Solution:** Define providers before they are used. Move provider definitions to the top of the file.

---

## Flutter Secure Storage

### ❌ Mistake: No Timeout on Platform Channel Calls
**Problem:** `flutter_secure_storage` can hang indefinitely on some Android devices when accessing the keystore for the first time.

**Solution:** Always wrap secure storage operations in a timeout.

**Code:**
```dart
final token = await _storage
    .read(key: 'access_token')
    .timeout(const Duration(seconds: 5), onTimeout: () => null);
```

---

## Environment Configuration

### ❌ Mistake: .env File Not Bundled with App
**Problem:** Flutter didn't include `.env` in the build, causing `FileNotFoundError` at runtime.

**Solution:** Add `.env` to the assets section in `pubspec.yaml`.

**Code:**
```yaml
flutter:
  assets:
    - assets/images/logo_paris.svg
    - .env
```

---

### ❌ Mistake: Hardcoded Supabase Credentials
**Problem:** Supabase URL and anon key were hardcoded in `main.dart`, making it difficult to change environments.

**Solution:** Use environment variables and provide fallback defaults.

**Code:**
```dart
try {
  await dotenv.load(fileName: '.env');
} catch (e) {
  print('[main] .env file not found, using default API_BASE_URL');
}
```

---

## API Client Design

### ❌ Mistake: Unused Circular Import
**Problem:** `api_client.dart` imported `auth_service.dart` which wasn't used, creating unnecessary coupling.

**Solution:** Remove unused imports to keep dependencies clean.

---

### ❌ Mistake: Error Handling Not User-Friendly
**Problem:** Dio errors were thrown as raw exceptions without user-friendly messages.

**Solution:** Implement centralized error handling in the API client.

**Code:**
```dart
Exception _handleError(DioException error) {
  String message;
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      message = 'Connection timeout. Please check your internet connection.';
      break;
    case DioExceptionType.badResponse:
      message = error.response?.data['error'] ?? 'Server error occurred';
      break;
    // ...
  }
  return Exception(message);
}
```

---

## Architecture Patterns

### ❌ Mistake: Skipping Layers
**Problem:** Components sometimes imported repositories or services directly, bypassing the hooks layer.

**Solution:** Always follow the layered architecture: Domain → Repository → Service → Hooks → Components.

---

### ❌ Mistake: Business Logic in Components
**Problem:** Complex calculations and validation logic lived in UI components.

**Solution:** Move all business logic to the service layer. Components should only handle presentation.

---

## Debugging

### ❌ Mistake: Insufficient Logging
**Problem:** When login hung, there were no debug messages to identify where it stopped.

**Solution:** Add detailed debug logging at key points:
- Request start
- Token injection
- Response received
- Error conditions

**Code:**
```dart
debugPrint('[AuthService] Attempting login with: $email');
debugPrint('[AuthService] Response: ${response.data}');
debugPrint('[AuthService] Dio error: ${e.message}');
```

---

## Testing

### ❌ Mistake: No Hot Reload After Critical Changes
**Problem:** After fixing the interceptor, the app wasn't hot restarted, so the old interceptor code was still running.

**Solution:** Always perform a **hot restart** (press `R`) after changes to:
- Singletons
- Interceptors
- Provider definitions
- `main.dart` changes

---

## Checklist for New Projects

- [ ] Mobile app only communicates with backend API (no direct DB access)
- [ ] All storage operations wrapped in timeouts
- [ ] Auth interceptor skips token injection for login endpoint
- [ ] Use in-memory cache for synchronous auth checks
- [ ] Riverpod providers defined before use
- [ ] `.env` file added to pubspec.yaml assets
- [ ] Environment variables loaded with fallback defaults
- [ ] Centralized error handling in API client
- [ ] Detailed debug logging at key points
- [ ] Hot restart after singleton/interceptor changes
