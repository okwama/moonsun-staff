import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/appConfig.dart';
import 'authService.dart';

class AllowedIpService {
  static String get baseUrl => AppConfig.allowedIpEndpoint;

  // Get all allowed IPs
  static Future<List<Map<String, dynamic>>> getAllowedIps() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token. Please login again.');
    }

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Map<String, dynamic>.from(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get allowed IPs');
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      print('Allowed IPs network error: $e');
      return [];
    }
  }

  // Check if IP is allowed
  static Future<bool> isIpAllowed(String ipAddress) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token. Please login again.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check/$ipAddress'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['allowed'] ?? false;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        return false;
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      print('IP check network error: $e');
      return false;
    }
  }

  // Create new allowed IP
  static Future<Map<String, dynamic>> createAllowedIp({
    required String ipAddress,
    String? description,
    bool isActive = true,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token. Please login again.');
    }

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'ipAddress': ipAddress,
          'description': description,
          'isActive': isActive,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Allowed IP created successfully',
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to create allowed IP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Update allowed IP
  static Future<Map<String, dynamic>> updateAllowedIp({
    required int id,
    String? ipAddress,
    String? description,
    bool? isActive,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token. Please login again.');
    }

    try {
      final updateData = <String, dynamic>{};
      if (ipAddress != null) updateData['ipAddress'] = ipAddress;
      if (description != null) updateData['description'] = description;
      if (isActive != null) updateData['isActive'] = isActive;

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Allowed IP updated successfully',
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to update allowed IP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Delete allowed IP
  static Future<Map<String, dynamic>> deleteAllowedIp(int id) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token. Please login again.');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Allowed IP deleted successfully',
        };
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to delete allowed IP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
