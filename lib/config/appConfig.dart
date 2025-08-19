import 'environment.dart';

class AppConfig {
  // Base URL for API endpoints
  static String get baseUrl => EnvironmentConfig.baseUrl;

  // API endpoints - Updated for modular structure
  static String get authEndpoint => '$baseUrl/auth';
  static String get staffEndpoint => '$baseUrl/users';
  static String get attendanceEndpoint => '$baseUrl/attendance';
  static String get leavesEndpoint => '$baseUrl/leaves';
  static String get outOfOfficeEndpoint => '$baseUrl/out-of-office';
  static String get allowedIpEndpoint => '$baseUrl/allowed-ip';

  // App settings
  static const String appName = 'Woosh';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Notification settings
  static const String notificationChannelId = 'woosh_channel';
  static const String notificationChannelName = 'Woosh Notifications';
  static const String scheduledNotificationChannelId =
      'woosh_scheduled_channel';
  static const String scheduledNotificationChannelName =
      'Woosh Scheduled Notifications';

  // Timezone
  static const String defaultTimezone = 'Africa/Nairobi';

  // Development settings
  static const bool enableDebugLogs = true;
  static const int requestTimeout = 30000; // 30 seconds

  // Environment detection
  static bool get isDevelopment =>
      const bool.fromEnvironment('dart.vm.product') == false;
  static bool get isProduction =>
      const bool.fromEnvironment('dart.vm.product') == true;

  // Get base URL based on environment
  static String get apiBaseUrl {
    if (isDevelopment) {
      return baseUrl;
    } else {
      // For production, you might want to use a different URL
      return baseUrl.replaceAll('localhost', 'your-production-domain.com');
    }
  }
}
