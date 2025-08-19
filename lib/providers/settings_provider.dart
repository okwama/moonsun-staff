import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsService? _settingsService;

  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Settings state
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';
  bool _hapticFeedback = true;
  bool _soundEffects = true;
  int _autoLockTimeout = 5;
  bool _analyticsConsent = false;
  bool _crashReporting = true;
  String? _firstLaunchDate;
  String? _lastSettingsUpdate;

  SettingsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      _settingsService = await SettingsService.getInstance();
      await _loadSettings();
      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize settings: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricEnabled => _biometricEnabled;
  String get selectedLanguage => _selectedLanguage;
  bool get hapticFeedback => _hapticFeedback;
  bool get soundEffects => _soundEffects;
  int get autoLockTimeout => _autoLockTimeout;
  bool get analyticsConsent => _analyticsConsent;
  bool get crashReporting => _crashReporting;
  String? get firstLaunchDate => _firstLaunchDate;
  String? get lastSettingsUpdate => _lastSettingsUpdate;

  // Load all settings from local storage
  Future<void> _loadSettings() async {
    if (_settingsService == null) return;

    _setLoading(true);
    try {
      await _settingsService!.initializeFirstLaunch();

      _isDarkMode = await _settingsService!.isDarkMode;
      _notificationsEnabled = await _settingsService!.notificationsEnabled;
      _biometricEnabled = await _settingsService!.biometricEnabled;
      _selectedLanguage = await _settingsService!.selectedLanguage;
      _hapticFeedback = await _settingsService!.hapticFeedback;
      _soundEffects = await _settingsService!.soundEffects;
      _autoLockTimeout = await _settingsService!.autoLockTimeout;
      _analyticsConsent = await _settingsService!.analyticsConsent;
      _crashReporting = await _settingsService!.crashReporting;
      _firstLaunchDate = await _settingsService!.firstLaunchDate;
      _lastSettingsUpdate = await _settingsService!.lastSettingsUpdate;

      _error = null;
    } catch (e) {
      _error = 'Failed to load settings: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Refresh settings
  Future<void> refresh() async {
    await _loadSettings();
  }

  // Update dark mode
  Future<void> setDarkMode(bool value) async {
    try {
      await _settingsService!.setDarkMode(value);
      _isDarkMode = value;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update dark mode: $e';
      notifyListeners();
    }
  }

  // Update notifications
  Future<void> setNotificationsEnabled(bool value) async {
    try {
      await _settingsService!.setNotificationsEnabled(value);
      _notificationsEnabled = value;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update notifications: $e';
      notifyListeners();
    }
  }

  // Update biometric
  Future<void> setBiometricEnabled(bool value) async {
    try {
      await _settingsService!.setBiometricEnabled(value);
      _biometricEnabled = value;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update biometric settings: $e';
      notifyListeners();
    }
  }

  // Update language
  Future<void> setSelectedLanguage(String value) async {
    try {
      await _settingsService!.setSelectedLanguage(value);
      _selectedLanguage = value;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update language: $e';
      notifyListeners();
    }
  }

  // Update haptic feedback
  Future<void> setHapticFeedback(bool value) async {
    try {
      await _settingsService!.setHapticFeedback(value);
      _hapticFeedback = value;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update haptic feedback: $e';
      notifyListeners();
    }
  }

  // Update sound effects
  Future<void> setSoundEffects(bool value) async {
    try {
      await _settingsService!.setSoundEffects(value);
      _soundEffects = value;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update sound effects: $e';
      notifyListeners();
    }
  }

  // Update auto lock timeout
  Future<void> setAutoLockTimeout(int value) async {
    try {
      await _settingsService!.setAutoLockTimeout(value);
      _autoLockTimeout = value;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update auto lock timeout: $e';
      notifyListeners();
    }
  }

  // Update analytics consent
  Future<void> setAnalyticsConsent(bool value) async {
    try {
      await _settingsService!.setAnalyticsConsent(value);
      _analyticsConsent = value;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update analytics consent: $e';
      notifyListeners();
    }
  }

  // Update crash reporting
  Future<void> setCrashReporting(bool value) async {
    try {
      await _settingsService!.setCrashReporting(value);
      _crashReporting = value;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update crash reporting: $e';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _setLoading(true);
    try {
      await _settingsService!.clearAllSettings();
      await _loadSettings();
    } catch (e) {
      _error = 'Failed to reset settings: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
