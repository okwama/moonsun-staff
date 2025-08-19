import 'package:flutter/foundation.dart';
import '../services/attendance_service.dart';
import '../services/network_service.dart';
import '../services/geo_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final NetworkService _networkService = NetworkService();
  final GeoService _geoService = GeoService();

  Map<String, dynamic>? _currentAttendance;
  bool _isLoading = false;
  String? _errorMessage;
  String?
      _errorType; // 'device_approval', 'device_registration', 'network', 'general'

  // Getters
  Map<String, dynamic>? get currentAttendance => _currentAttendance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorType => _errorType;

  // Computed properties
  int? get status => _currentAttendance?['status'];
  bool get isCheckedIn => status == 1;
  bool get isCheckedOut => status == 2;
  bool get isPending => status == 0;
  bool get hasAttendance => _currentAttendance != null;

  // Initialize and load current attendance
  Future<void> initialize() async {
    await loadCurrentAttendance();
  }

  // Load current attendance status
  Future<void> loadCurrentAttendance() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final attendance = await _attendanceService.getCurrentAttendance();
      _currentAttendance = attendance;
      debugPrint('Attendance loaded: ${attendance?['status']}');
    } catch (e) {
      _setError('Failed to load attendance: $e');
      debugPrint('Error loading attendance: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh attendance status
  Future<void> refresh() async {
    await loadCurrentAttendance();
  }

  // Check in
  Future<bool> checkIn() async {
    if (_isLoading) return false;

    _setLoading(true);
    _clearError();

    try {
      // Get network and location info
      final ipAddress = await NetworkService.getLocalIPAddress() ??
          await NetworkService.getDeviceIPAddress() ??
          'unknown';

      final coordinates = await _geoService.getCoordinates();

      // Perform check-in
      await _attendanceService.checkIn(
        ipAddress: ipAddress,
        latitude: coordinates?['latitude'],
        longitude: coordinates?['longitude'],
      );

      // Refresh current attendance status
      await loadCurrentAttendance();
      return true;
    } catch (e) {
      final errorMessage = e.toString();

      // Provide user-friendly error messages
      if (errorMessage.contains('Already checked in today')) {
        _setError('Already checked in today', type: 'general');
      } else if (errorMessage.contains('not approved')) {
        _setError(
            'This device is not approved for check-in. Please contact your administrator to approve this device.',
            type: 'device_approval');
      } else if (errorMessage.contains('not registered')) {
        _setError(
            'This device is not registered. Please contact your administrator to register this device.',
            type: 'device_registration');
      } else if (errorMessage.contains('IP address') ||
          errorMessage.contains('not allowed')) {
        _setError('Check-in is only allowed from the office network',
            type: 'network');
      } else {
        _setError('Check-in failed. Please try again.', type: 'general');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check out
  Future<bool> checkOut() async {
    if (_isLoading) return false;

    debugPrint('🔄 Starting checkout process...');
    _setLoading(true);
    _clearError();

    try {
      // Get network and location info
      final ipAddress = await NetworkService.getLocalIPAddress() ??
          await NetworkService.getDeviceIPAddress() ??
          'unknown';

      final coordinates = await _geoService.getCoordinates();

      debugPrint('📍 Checkout - IP: $ipAddress, Coordinates: $coordinates');

      // Perform check-out
      final result = await _attendanceService.checkOut(
        ipAddress: ipAddress,
        latitude: coordinates?['latitude'],
        longitude: coordinates?['longitude'],
      );

      debugPrint('✅ Checkout service completed successfully: $result');

      // Refresh current attendance status
      await loadCurrentAttendance();

      debugPrint('🔄 Checkout process completed - returning true');
      return true;
    } catch (e) {
      debugPrint('❌ Checkout failed with error: $e');
      final errorMessage = e.toString();

      // Provide user-friendly error messages
      if (errorMessage.contains('Already checked out today')) {
        _setError('Already checked out today', type: 'general');
      } else if (errorMessage.contains('not checked in')) {
        _setError('You need to check in first before checking out',
            type: 'general');
      } else if (errorMessage.contains('not approved')) {
        _setError(
            'This device is not approved for check-out. Please contact your administrator to approve this device.',
            type: 'device_approval');
      } else if (errorMessage.contains('not registered')) {
        _setError(
            'This device is not registered. Please contact your administrator to register this device.',
            type: 'device_registration');
      } else if (errorMessage.contains('IP address') ||
          errorMessage.contains('not allowed')) {
        _setError('Check-out is only allowed from the office network',
            type: 'network');
      } else {
        _setError('Check-out failed. Please try again.', type: 'general');
      }
      return false;
    } finally {
      _setLoading(false);
      debugPrint('🏁 Checkout process finished');
    }
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error, {String? type}) {
    _errorMessage = error;
    _errorType = type;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _errorType = null;
    notifyListeners();
  }
}
