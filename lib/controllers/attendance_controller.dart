import 'package:flutter/foundation.dart';
import '../services/attendance_service.dart';
import '../services/network_service.dart';
import '../services/geo_service.dart';
import '../services/device_service.dart';

class AttendanceController extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final GeoService _geoService = GeoService();
  final DeviceService _deviceService = DeviceService();

  // State variables
  bool _isLoading = false;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  String? _currentIpAddress;
  String? _currentLocation;
  Map<String, double>? _currentCoordinates;
  String? _errorMessage;
  String?
      _errorType; // 'device_approval', 'device_registration', 'network', 'general'
  Map<String, dynamic>? _currentAttendance;
  String? _successMessage; // Add success message state

  // Getters
  bool get isLoading => _isLoading;
  bool get isCheckingIn => _isCheckingIn;
  bool get isCheckingOut => _isCheckingOut;
  String? get currentIpAddress => _currentIpAddress;
  String? get currentLocation => _currentLocation;
  Map<String, double>? get currentCoordinates => _currentCoordinates;
  String? get errorMessage => _errorMessage;
  String? get errorType => _errorType;
  Map<String, dynamic>? get currentAttendance => _currentAttendance;
  String? get successMessage => _successMessage; // Add success message getter

  // Initialize and load initial data
  Future<void> initialize() async {
    await Future.wait([
      _loadNetworkInfo(),
      _loadLocationInfo(),
      _loadCurrentAttendance(),
      _registerDeviceSilently(),
    ]);

    // Debug device info
    await _deviceService.debugDeviceInfo();
  }

  // Load network information
  Future<void> _loadNetworkInfo() async {
    try {
      // Get both public and local IP addresses for comparison
      final publicIP = await NetworkService.getDeviceIPAddress();
      final localIP = await NetworkService.getLocalIPAddress();

      debugPrint('Network Info - Public IP: $publicIP, Local IP: $localIP');

      // Use local IP if available, otherwise use public IP
      // On web platform, local IP will be null, so we'll use public IP
      final ipAddress = localIP ?? publicIP;
      _currentIpAddress = ipAddress;

      debugPrint(
          'AttendanceController: Selected IP for attendance: $ipAddress');
      debugPrint(
          'AttendanceController: Is office network? ${ipAddress?.startsWith('192.168.100.')}');

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading network info: $e');
    }
  }

  // Load location information
  Future<void> _loadLocationInfo() async {
    try {
      final coordinates = await _geoService.getCoordinates();
      final locationString = await _geoService.getLocationString();

      _currentCoordinates = coordinates;
      _currentLocation = locationString;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading location info: $e');
    }
  }

  // Load current attendance status
  Future<void> _loadCurrentAttendance() async {
    try {
      final attendance = await _attendanceService.getCurrentAttendance();
      _currentAttendance = attendance;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading current attendance: $e');
    }
  }

  // Silently register device
  Future<void> _registerDeviceSilently() async {
    try {
      final success = await _deviceService.registerDeviceSilently();
      if (success) {
        debugPrint('Device registered silently');
      } else {
        debugPrint('Device registration failed silently');
      }
    } catch (e) {
      debugPrint('Error registering device silently: $e');
    }
  }

  // Refresh location and network info
  Future<void> refreshLocationAndNetwork() async {
    await Future.wait([
      _loadNetworkInfo(),
      _loadLocationInfo(),
      _loadCurrentAttendance(),
    ]);
  }

  // Check in
  Future<bool> checkIn() async {
    if (_isLoading) return false;

    _setLoading(true);
    _setCheckingIn(true);
    _clearError();

    try {
      // Refresh location and network info
      await refreshLocationAndNetwork();

      // For web platform, IP might be null, but backend will handle it
      final ipAddress = _currentIpAddress ?? 'unknown';

      debugPrint('AttendanceController: Sending check-in with IP: $ipAddress');

      final response = await _attendanceService.checkIn(
        ipAddress: ipAddress,
        latitude: _currentCoordinates?['latitude'],
        longitude: _currentCoordinates?['longitude'],
      );

      // Refresh current attendance status after successful check-in
      await _loadCurrentAttendance();

      // Extract success message from response
      final successMessage = response['successMessage'] as String?;
      if (successMessage != null) {
        _setSuccessMessage(successMessage);
      }

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
      _setCheckingIn(false);
    }
  }

  // Check out
  Future<bool> checkOut() async {
    if (_isLoading) return false;

    _setLoading(true);
    _setCheckingOut(true);
    _clearError();

    try {
      // Refresh location and network info
      await refreshLocationAndNetwork();

      // For web platform, IP might be null, but backend will handle it
      final ipAddress = _currentIpAddress ?? 'unknown';

      debugPrint('AttendanceController: Sending check-out with IP: $ipAddress');

      final response = await _attendanceService.checkOut(
        ipAddress: ipAddress,
        latitude: _currentCoordinates?['latitude'],
        longitude: _currentCoordinates?['longitude'],
      );

      // Refresh current attendance status after successful check-out
      await _loadCurrentAttendance();

      // Extract success message from response
      final successMessage = response['successMessage'] as String?;
      if (successMessage != null) {
        _setSuccessMessage(successMessage);
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString();

      // Simplified error handling for check-out
      if (errorMessage.contains('Already checked out today')) {
        _setError('Already checked out today', type: 'general');
      } else if (errorMessage.contains('not checked in')) {
        _setError('You need to check in first before checking out',
            type: 'general');
      } else if (errorMessage.contains('No internet connection')) {
        _setError(
            'No internet connection. Please check your network and try again.',
            type: 'network');
      } else {
        _setError('Check-out failed. Please try again.', type: 'general');
      }
      return false;
    } finally {
      _setLoading(false);
      _setCheckingOut(false);
    }
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Clear success message
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setCheckingIn(bool checkingIn) {
    _isCheckingIn = checkingIn;
    notifyListeners();
  }

  void _setCheckingOut(bool checkingOut) {
    _isCheckingOut = checkingOut;
    notifyListeners();
  }

  void _setError(String error, {String? type}) {
    _errorMessage = error;
    _errorType = type;
    _successMessage = null; // Clear success message when error occurs
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _errorType = null;
    notifyListeners();
  }

  void _setSuccessMessage(String message) {
    _successMessage = message;
    _errorMessage = null; // Clear error message when success occurs
    _errorType = null;
    notifyListeners();
  }
}
