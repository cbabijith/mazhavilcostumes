/// Shared timing policy for startup, searches, and short-lived report caches.
abstract final class AppDurations {
  static const searchDebounce = Duration(milliseconds: 300);
  static const analyticsCache = Duration(seconds: 30);
  static const splashAnimation = Duration(milliseconds: 300);
  static const storageTimeout = Duration(seconds: 5);
}
