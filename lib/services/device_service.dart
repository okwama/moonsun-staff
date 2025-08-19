import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:woosh_portal/config/environment.dart';
import 'package:woosh_portal/services/authService.dart';
import 'package:woosh_portal/services/network_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  static String get baseUrl => EnvironmentConfig.baseUrl;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Cache for device registration status
  bool _isDeviceRegistered = false;
  String? _lastRegisteredDeviceId;
  DateTime? _lastRegistrationTime;

  // Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Check if device registration is cached and valid
  Future<bool> _isDeviceRegistrationCached() async {
    if (!_isDeviceRegistered ||
        _lastRegisteredDeviceId == null ||
        _lastRegistrationTime == null) {
      return false;
    }

    // Check if cache has expired
    final now = DateTime.now();
    if (now.difference(_lastRegistrationTime!) > _cacheDuration) {
      debugPrint('Device registration cache expired');
      _clearDeviceRegistrationCache();
      return false;
    }

    // Check if device ID has changed
    final currentDeviceId = await getDeviceId();
    if (currentDeviceId != _lastRegisteredDeviceId) {
      debugPrint('Device ID changed, clearing cache');
      _clearDeviceRegistrationCache();
      return false;
    }

    debugPrint('Device registration cache is valid');
    return true;
  }

  /// Clear device registration cache
  void _clearDeviceRegistrationCache() {
    _isDeviceRegistered = false;
    _lastRegisteredDeviceId = null;
    _lastRegistrationTime = null;
    debugPrint('Device registration cache cleared');
  }

  /// Public method to clear device registration cache (useful for logout)
  void clearDeviceRegistrationCache() {
    _clearDeviceRegistrationCache();
  }

  /// Generate unique device ID
  Future<String> getDeviceId() async {
    try {
      if (kIsWeb) {
        // Web: Use browser fingerprint or timestamp
        return 'web_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return 'android_${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return 'ios_${iosInfo.identifierForVendor ?? 'unknown'}';
      }
      return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return 'error_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Get device information
  Future<Map<String, String>> getDeviceInfo() async {
    try {
      final deviceId = await getDeviceId();
      final packageInfo = await PackageInfo.fromPlatform();

      Map<String, String> deviceInfo = {
        'deviceId': deviceId,
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };

      if (kIsWeb) {
        deviceInfo['deviceType'] = 'web';
        deviceInfo['deviceName'] = 'Web Browser';
        deviceInfo['deviceModel'] = 'Web Platform';
        deviceInfo['osVersion'] = 'Web';
      } else if (Platform.isAndroid) {
        try {
          final androidInfo = await _deviceInfo.androidInfo;
          debugPrint(
              'Android Device Info: brand=${androidInfo.brand}, model=${androidInfo.model}, version=${androidInfo.version.release}');
          deviceInfo['deviceType'] = 'android';
          deviceInfo['deviceName'] =
              '${androidInfo.brand ?? 'Android'} ${androidInfo.model ?? 'Unknown'}';
          deviceInfo['deviceModel'] = androidInfo.model ?? 'Unknown';
          deviceInfo['osVersion'] =
              'Android ${androidInfo.version.release ?? 'Unknown'}';
        } catch (androidError) {
          debugPrint('Error getting Android device info: $androidError');
          deviceInfo['deviceType'] = 'android';
          deviceInfo['deviceName'] = 'Android Device';
          deviceInfo['deviceModel'] = 'Unknown';
          deviceInfo['osVersion'] = 'Android Unknown';
        }
      } else if (Platform.isIOS) {
        try {
          final iosInfo = await _deviceInfo.iosInfo;
          debugPrint(
              'iOS Device Info: name=${iosInfo.name}, model=${iosInfo.model}, systemVersion=${iosInfo.systemVersion}');
          deviceInfo['deviceType'] = 'ios';
          deviceInfo['deviceName'] =
              '${iosInfo.name ?? 'iPhone'} ${iosInfo.model ?? 'Unknown'}';
          deviceInfo['deviceModel'] = iosInfo.model ?? 'Unknown';
          deviceInfo['osVersion'] = 'iOS ${iosInfo.systemVersion ?? 'Unknown'}';
        } catch (iosError) {
          debugPrint('Error getting iOS device info: $iosError');
          deviceInfo['deviceType'] = 'ios';
          deviceInfo['deviceName'] = 'iPhone Device';
          deviceInfo['deviceModel'] = 'Unknown';
          deviceInfo['osVersion'] = 'iOS Unknown';
        }
      }

      // Ensure all required fields are present
      deviceInfo['deviceName'] ??= 'Unknown Device';
      deviceInfo['deviceModel'] ??= 'Unknown';
      deviceInfo['osVersion'] ??= 'Unknown';
      deviceInfo['appVersion'] ??= '1.0.0';

      debugPrint('Final device info: $deviceInfo');
      return deviceInfo;
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return {
        'deviceId': await getDeviceId(),
        'deviceType': kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios'),
        'deviceName': 'Unknown Device',
        'deviceModel': 'Unknown',
        'osVersion': 'Unknown',
        'appVersion': '1.0.0',
      };
    }
  }

  /// Silently register device with backend (with caching)
  /// Note: Backend device registration is not available in modular structure
  /// This method now just returns true to allow attendance to proceed
  Future<bool> registerDeviceSilently() async {
    try {
      // Check if device registration is already cached
      if (await _isDeviceRegistrationCached()) {
        debugPrint('Using cached device registration');
        return true;
      }

      // Since the modularized backend doesn't have a devices module,
      // we'll just cache the device info locally and return true
      final deviceInfo = await getDeviceInfo();

      debugPrint('Device info collected: $deviceInfo');
      debugPrint(
          'Device registration skipped (not available in modular backend)');

      // Cache the device info locally
      _isDeviceRegistered = true;
      _lastRegisteredDeviceId = deviceInfo['deviceId'];
      _lastRegistrationTime = DateTime.now();

      return true;
    } catch (e) {
      debugPrint('Error in device registration: $e');
      return false;
    }
  }

  /// Validate device before check-in
  /// Note: Backend device validation is not available in modular structure
  /// This method now just returns true to allow attendance to proceed
  Future<bool> validateDevice() async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        debugPrint('No user data available for device validation');
        return false;
      }

      final deviceInfo = await getDeviceInfo();
      debugPrint(
          'Device validation skipped (not available in modular backend)');
      debugPrint('Device info: $deviceInfo');

      // Since the modularized backend doesn't have a devices module,
      // we'll just return true to allow attendance to proceed
      return true;
    } catch (e) {
      debugPrint('Error in device validation: $e');
      return false;
    }
  }

  /// Get user's registered devices
  /// Note: Backend device management is not available in modular structure
  /// This method now returns empty list
  Future<List<Map<String, dynamic>>> getUserDevices() async {
    try {
      debugPrint('Device management not available in modular backend');
      return [];
    } catch (e) {
      throw Exception('Error fetching user devices: $e');
    }
  }

  /// Get user's device statistics
  /// Note: Backend device management is not available in modular structure
  /// This method now returns empty stats
  Future<Map<String, dynamic>> getUserDeviceStats() async {
    try {
      debugPrint('Device management not available in modular backend');
      return {};
    } catch (e) {
      throw Exception('Error fetching user device stats: $e');
    }
  }

  /// Test function to debug device info
  Future<void> debugDeviceInfo() async {
    try {
      debugPrint('=== DEVICE INFO DEBUG ===');
      debugPrint('Platform: ${Platform.operatingSystem}');
      debugPrint('Is Web: $kIsWeb');

      final deviceId = await getDeviceId();
      debugPrint('Device ID: $deviceId');

      final deviceInfo = await getDeviceInfo();
      debugPrint('Full Device Info: $deviceInfo');

      if (Platform.isIOS) {
        try {
          final iosInfo = await _deviceInfo.iosInfo;
          debugPrint('Raw iOS Info:');
          debugPrint('  name: ${iosInfo.name}');
          debugPrint('  model: ${iosInfo.model}');
          debugPrint('  systemVersion: ${iosInfo.systemVersion}');
          debugPrint('  identifierForVendor: ${iosInfo.identifierForVendor}');
          debugPrint('  utsname.sysname: ${iosInfo.utsname.sysname}');
          debugPrint('  utsname.nodename: ${iosInfo.utsname.nodename}');
          debugPrint('  utsname.release: ${iosInfo.utsname.release}');
          debugPrint('  utsname.version: ${iosInfo.utsname.version}');
          debugPrint('  utsname.machine: ${iosInfo.utsname.machine}');
        } catch (e) {
          debugPrint('Error getting raw iOS info: $e');
        }
      }

      debugPrint('=== END DEVICE INFO DEBUG ===');
    } catch (e) {
      debugPrint('Error in debugDeviceInfo: $e');
    }
  }
}
