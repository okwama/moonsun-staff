import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsService {
  static const String _darkModeKey = 'isDarkMode';
  static const String _notificationsKey = 'notificationsEnabled';
  static const String _biometricKey = 'biometricEnabled';
  static const String _languageKey = 'selectedLanguage';
  static const String _hapticFeedbackKey = 'hapticFeedback';
  static const String _soundEffectsKey = 'soundEffects';
  static const String _autoLockTimeoutKey = 'autoLockTimeout';
  static const String _analyticsConsentKey = 'analyticsConsent';
  static const String _crashReportingKey = 'crashReporting';
  static const String _firstLaunchKey = 'firstLaunchDate';
  static const String _lastSettingsUpdateKey = 'lastSettingsUpdate';
  static const String _attendanceStatusKey = 'attendanceStatus';
  static const String _attendanceDataKey = 'attendanceData';
  static const String _lastAttendanceUpdateKey = 'lastAttendanceUpdate';

  static SettingsService? _instance;
  static SharedPreferences? _prefs;

  SettingsService._();

  static Future<SettingsService> getInstance() async {
    if (_instance == null) {
      _instance = SettingsService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Theme Settings
  Future<bool> get isDarkMode async {
    final prefs = await _getPrefs();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_darkModeKey, value);
    await _updateLastSettingsUpdate();
  }

  // Notification Settings
  Future<bool> get notificationsEnabled async {
    final prefs = await _getPrefs();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_notificationsKey, value);
    await _updateLastSettingsUpdate();
  }

  // Biometric Settings
  Future<bool> get biometricEnabled async {
    final prefs = await _getPrefs();
    return prefs.getBool(_biometricKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_biometricKey, value);
    await _updateLastSettingsUpdate();
  }

  // Language Settings
  Future<String> get selectedLanguage async {
    final prefs = await _getPrefs();
    return prefs.getString(_languageKey) ?? 'English';
  }

  Future<void> setSelectedLanguage(String value) async {
    final prefs = await _getPrefs();
    await prefs.setString(_languageKey, value);
    await _updateLastSettingsUpdate();
  }

  // Haptic Feedback
  Future<bool> get hapticFeedback async {
    final prefs = await _getPrefs();
    return prefs.getBool(_hapticFeedbackKey) ?? true;
  }

  Future<void> setHapticFeedback(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_hapticFeedbackKey, value);
    await _updateLastSettingsUpdate();
  }

  // Sound Effects
  Future<bool> get soundEffects async {
    final prefs = await _getPrefs();
    return prefs.getBool(_soundEffectsKey) ?? true;
  }

  Future<void> setSoundEffects(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_soundEffectsKey, value);
    await _updateLastSettingsUpdate();
  }

  // Auto Lock Timeout (in minutes)
  Future<int> get autoLockTimeout async {
    final prefs = await _getPrefs();
    return prefs.getInt(_autoLockTimeoutKey) ?? 5; // Default 5 minutes
  }

  Future<void> setAutoLockTimeout(int value) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_autoLockTimeoutKey, value);
    await _updateLastSettingsUpdate();
  }

  // Analytics Consent
  Future<bool> get analyticsConsent async {
    final prefs = await _getPrefs();
    return prefs.getBool(_analyticsConsentKey) ?? false;
  }

  Future<void> setAnalyticsConsent(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_analyticsConsentKey, value);
    await _updateLastSettingsUpdate();
  }

  // Crash Reporting
  Future<bool> get crashReporting async {
    final prefs = await _getPrefs();
    return prefs.getBool(_crashReportingKey) ?? true;
  }

  Future<void> setCrashReporting(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_crashReportingKey, value);
    await _updateLastSettingsUpdate();
  }

  // First Launch Date
  Future<String?> get firstLaunchDate async {
    final prefs = await _getPrefs();
    return prefs.getString(_firstLaunchKey);
  }

  Future<void> setFirstLaunchDate(String value) async {
    final prefs = await _getPrefs();
    await prefs.setString(_firstLaunchKey, value);
  }

  // Last Settings Update
  Future<String?> get lastSettingsUpdate async {
    final prefs = await _getPrefs();
    return prefs.getString(_lastSettingsUpdateKey);
  }

  Future<void> _updateLastSettingsUpdate() async {
    final prefs = await _getPrefs();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(_lastSettingsUpdateKey, now);
  }

  // Attendance State Management
  Future<int?> get attendanceStatus async {
    final prefs = await _getPrefs();
    return prefs.getInt(_attendanceStatusKey);
  }

  Future<void> setAttendanceStatus(int? status) async {
    final prefs = await _getPrefs();
    if (status != null) {
      await prefs.setInt(_attendanceStatusKey, status);
    } else {
      await prefs.remove(_attendanceStatusKey);
    }
    await _updateLastAttendanceUpdate();
  }

  Future<Map<String, dynamic>?> get attendanceData async {
    final prefs = await _getPrefs();
    final data = prefs.getString(_attendanceDataKey);
    if (data != null) {
      return Map<String, dynamic>.from(jsonDecode(data));
    }
    return null;
  }

  Future<void> setAttendanceData(Map<String, dynamic>? data) async {
    final prefs = await _getPrefs();
    if (data != null) {
      await prefs.setString(_attendanceDataKey, jsonEncode(data));
    } else {
      await prefs.remove(_attendanceDataKey);
    }
    await _updateLastAttendanceUpdate();
  }

  Future<String?> get lastAttendanceUpdate async {
    final prefs = await _getPrefs();
    return prefs.getString(_lastAttendanceUpdateKey);
  }

  Future<void> _updateLastAttendanceUpdate() async {
    final prefs = await _getPrefs();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(_lastAttendanceUpdateKey, now);
  }

  // Clear attendance data
  Future<void> clearAttendanceData() async {
    final prefs = await _getPrefs();
    await prefs.remove(_attendanceStatusKey);
    await prefs.remove(_attendanceDataKey);
    await prefs.remove(_lastAttendanceUpdateKey);
  }

  // Initialize first launch
  Future<void> initializeFirstLaunch() async {
    final firstLaunch = await firstLaunchDate;
    if (firstLaunch == null) {
      await setFirstLaunchDate(DateTime.now().toIso8601String());
    }
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  // Get all settings as a map
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'isDarkMode': await isDarkMode,
      'notificationsEnabled': await notificationsEnabled,
      'biometricEnabled': await biometricEnabled,
      'selectedLanguage': await selectedLanguage,
      'hapticFeedback': await hapticFeedback,
      'soundEffects': await soundEffects,
      'autoLockTimeout': await autoLockTimeout,
      'analyticsConsent': await analyticsConsent,
      'crashReporting': await crashReporting,
      'firstLaunchDate': await firstLaunchDate,
      'lastSettingsUpdate': await lastSettingsUpdate,
      'attendanceStatus': await attendanceStatus,
      'attendanceData': await attendanceData,
      'lastAttendanceUpdate': await lastAttendanceUpdate,
    };
  }

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
