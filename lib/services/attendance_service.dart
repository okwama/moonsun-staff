import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:woosh_portal/config/environment.dart';
import 'package:woosh_portal/services/network_service.dart';
import 'package:woosh_portal/services/geo_service.dart';
import 'package:woosh_portal/services/authService.dart';
import 'package:woosh_portal/services/device_service.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  static String get baseUrl => EnvironmentConfig.baseUrl;
  final GeoService _geoService = GeoService();
  final DeviceService _deviceService = DeviceService();

  Future<Map<String, dynamic>> checkIn({
    required String ipAddress,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Check network connectivity
      if (!await NetworkService.isConnected()) {
        throw Exception('No internet connection');
      }

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Get user data to get staff ID
      final user = await AuthService.getUser();
      if (user == null) {
        throw Exception('User data not found');
      }

      // Validate that user ID is a positive integer
      if (user.id <= 0) {
        throw Exception('Invalid staff ID: must be a positive number');
      }

      debugPrint('Check-in: User ID = ${user.id}, IP = $ipAddress');

      // Ensure device is registered before check-in
      final deviceRegistered = await _deviceService.registerDeviceSilently();
      if (!deviceRegistered) {
        debugPrint(
            'Warning: Device registration failed, but proceeding with check-in');
      }

      // Get coordinates if not provided
      if (latitude == null || longitude == null) {
        final coordinates = await _geoService.getCoordinates();
        if (coordinates != null) {
          latitude = coordinates['latitude'];
          longitude = coordinates['longitude'];
        }
      }

      // Get device ID for validation
      final deviceId = await _deviceService.getDeviceId();

      final requestBody = {
        'staffId': user.id, // Add staffId parameter
        'deviceId': deviceId, // Add deviceId for validation
        'ipAddress': ipAddress,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      debugPrint('Check-in request body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/attendance/check-in'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Check-in response status: ${response.statusCode}');
      debugPrint('Check-in response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Add success message to response data
        responseData['successMessage'] = response.statusCode == 201
            ? 'Successfully checked in!'
            : 'Check-in completed successfully!';

        return responseData;
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Check-in failed';

        // Handle specific device-related errors
        if (errorMessage.contains('not approved') ||
            errorMessage.contains('not registered')) {
          throw Exception(errorMessage);
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Check-in error: $e');
    }
  }

  Future<Map<String, dynamic>> checkOut({
    required String ipAddress,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Check network connectivity
      if (!await NetworkService.isConnected()) {
        throw Exception('No internet connection');
      }

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Get user data to get staff ID
      final user = await AuthService.getUser();
      if (user == null) {
        throw Exception('User data not found');
      }

      // Validate that user ID is a positive integer
      if (user.id <= 0) {
        throw Exception('Invalid staff ID: must be a positive number');
      }

      debugPrint('Check-out: User ID = ${user.id}, IP = $ipAddress');

      // Get coordinates if not provided
      if (latitude == null || longitude == null) {
        final coordinates = await _geoService.getCoordinates();
        if (coordinates != null) {
          latitude = coordinates['latitude'];
          longitude = coordinates['longitude'];
        }
      }

      // Get device ID (but don't validate it)
      final deviceId = await _deviceService.getDeviceId();

      final requestBody = {
        'deviceId': deviceId ?? 'unknown', // Use 'unknown' if deviceId is null
        'ipAddress': ipAddress,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      debugPrint('Check-out request body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/attendance/check-out/${user.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Check-out response status: ${response.statusCode}');
      debugPrint('Check-out response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Add success message to response data
        responseData['successMessage'] = response.statusCode == 201
            ? 'Successfully checked out!'
            : 'Check-out completed successfully!';

        return responseData;
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Check-out failed';

        // Simplified error handling - just throw the error message
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Check-out error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAttendanceHistory() async {
    try {
      // Check network connectivity
      if (!await NetworkService.isConnected()) {
        throw Exception('No internet connection');
      }

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Get user data to get staff ID
      final user = await AuthService.getUser();
      if (user == null) {
        throw Exception('User data not found');
      }

      debugPrint(
          'Fetching attendance history from: $baseUrl/attendance/staff/${user.id}');

      final response = await http.get(
        Uri.parse(
            '$baseUrl/attendance/staff/${user.id}'), // Use correct endpoint
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Attendance history response status: ${response.statusCode}');
      debugPrint('Attendance history response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns array directly, not wrapped in 'data' field
        return List<Map<String, dynamic>>.from(data ?? []);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Failed to fetch attendance history');
      }
    } catch (e) {
      throw Exception('Attendance history error: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentAttendance() async {
    try {
      // Check network connectivity
      if (!await NetworkService.isConnected()) {
        throw Exception('No internet connection');
      }

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Get user data to get staff ID
      final user = await AuthService.getUser();
      if (user == null) {
        throw Exception('User data not found');
      }

      debugPrint('Fetching current attendance for current user');

      final response = await http.get(
        Uri.parse('$baseUrl/attendance/staff/${user.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Current attendance response status: ${response.statusCode}');
      debugPrint('Current attendance response body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle empty response body
        if (response.body.isEmpty || response.body.trim() == '') {
          debugPrint('Empty response body - no current attendance');
          return null;
        }

        try {
          final data = jsonDecode(response.body);
          return data;
        } catch (jsonError) {
          debugPrint('JSON parsing error: $jsonError');
          // If JSON parsing fails, return null (no current attendance)
          return null;
        }
      } else if (response.statusCode == 404) {
        // No current attendance found
        debugPrint('No current attendance found (404)');
        return null;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Failed to fetch current attendance');
      }
    } catch (e) {
      debugPrint('Current attendance error: $e');
      // Return null instead of throwing error for better UX
      return null;
    }
  }
}
