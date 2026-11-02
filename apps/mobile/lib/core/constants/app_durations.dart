/// Shared timing policy for startup, searches, and short-lived report caches.
abstract final class AppDurations {
  static const searchDebounce = Duration(milliseconds: 300);
  static const analyticsCache = Duration(seconds: 30);
  static const splashAnimation = Duration(milliseconds: 300);
  static const storageTimeout = Duration(seconds: 5);
  static const snapshotReadTimeout = Duration(milliseconds: 200);
  static const startupSnapshotMaxAge = Duration(hours: 24);
  static const shopUtcOffset = Duration(hours: 5, minutes: 30);
}
