import 'package:flutter/foundation.dart';

class GreetingUtils {
  /// Returns a dynamic greeting based on the current time
  /// Uses device time to determine the appropriate greeting
  static String getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    debugPrint('🕐 Current hour: $hour');

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  /// Returns a greeting with emoji for more visual appeal
  static String getGreetingWithEmoji() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon 🌤️';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening 🌅';
    } else {
      return 'Good Night 🌙';
    }
  }

  /// Returns a more casual greeting
  static String getCasualGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }

  /// Returns greeting with time context
  static String getGreetingWithTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final timeString =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    if (hour >= 5 && hour < 12) {
      return 'Good Morning ($timeString)';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon ($timeString)';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening ($timeString)';
    } else {
      return 'Good Night ($timeString)';
    }
  }

  /// Returns a greeting based on custom time ranges
  /// Useful for testing or custom time periods
  static String getCustomGreeting({
    int? customHour,
    Map<String, List<int>>? timeRanges,
  }) {
    final hour = customHour ?? DateTime.now().hour;

    // Default time ranges if none provided
    final ranges = timeRanges ??
        {
          'Good Morning': [5, 12],
          'Good Afternoon': [12, 17],
          'Good Evening': [17, 21],
          'Good Night': [21, 5],
        };

    for (final entry in ranges.entries) {
      final greeting = entry.key;
      final range = entry.value;

      if (range.length == 2) {
        final start = range[0];
        final end = range[1];

        if (start <= end) {
          // Normal range (e.g., 5-12)
          if (hour >= start && hour < end) {
            return greeting;
          }
        } else {
          // Wrapping range (e.g., 21-5 for night)
          if (hour >= start || hour < end) {
            return greeting;
          }
        }
      }
    }

    // Fallback
    return 'Hello';
  }

  /// Returns the current time period as a string
  static String getTimePeriod() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'evening';
    } else {
      return 'night';
    }
  }

  /// Returns true if it's currently morning hours
  static bool isMorning() {
    final hour = DateTime.now().hour;
    return hour >= 5 && hour < 12;
  }

  /// Returns true if it's currently afternoon hours
  static bool isAfternoon() {
    final hour = DateTime.now().hour;
    return hour >= 12 && hour < 17;
  }

  /// Returns true if it's currently evening hours
  static bool isEvening() {
    final hour = DateTime.now().hour;
    return hour >= 17 && hour < 21;
  }

  /// Returns true if it's currently night hours
  static bool isNight() {
    final hour = DateTime.now().hour;
    return hour >= 21 || hour < 5;
  }
}
