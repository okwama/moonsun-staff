import 'dart:convert';
import 'package:http/http.dart' as http;
import 'authService.dart';
import '../models/leave_request.dart';
import '../providers/authProvider.dart';
import '../config/appConfig.dart';

class LeaveService {
  static String get baseUrl => AppConfig.leavesEndpoint;

  final AuthProvider authProvider;

  LeaveService(this.authProvider);

  // Get staff leave requests using stored procedure
  Future<List<LeaveRequest>> getMyLeaveRequests({
    LeaveStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token. Please login again.');
    }

    final queryParams = <String, String>{};
    if (status != null) {
      queryParams['status'] = status.toString().split('.').last;
    }
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
    }

    final uri =
        Uri.parse('$baseUrl/my-requests').replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LeaveRequest.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get leave requests');
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      // Return empty list for network errors to prevent app crashes
      print('Leave requests network error: $e');
      return [];
    }
  }

  // Create leave request using stored procedure
  Future<Map<String, dynamic>> createLeaveRequest({
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    bool isHalfDay = false,
    String? attachmentUrl,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token. Please login again.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'leaveTypeId': leaveTypeId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          'reason': reason ?? '',
          'isHalfDay': isHalfDay,
          'attachmentUrl': attachmentUrl,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'requestId': responseData['id'],
          'message':
              responseData['message'] ?? 'Leave request created successfully',
          'data': responseData,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Failed to create leave request');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Cancel leave request
  Future<Map<String, dynamic>> cancelLeaveRequest(int requestId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token. Please login again.');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/request/$requestId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Leave request cancelled successfully',
          'data': responseData,
        };
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Failed to cancel leave request');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get leave balance using stored procedure
  Future<List<Map<String, dynamic>>> getMyLeaveBalances({
    int? year,
    int? leaveTypeId,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token. Please login again.');
    }

    final queryParams = <String, String>{};
    if (year != null) {
      queryParams['year'] = year.toString();
    }
    if (leaveTypeId != null) {
      queryParams['leaveTypeId'] = leaveTypeId.toString();
    }

    final uri =
        Uri.parse('$baseUrl/my-balances').replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data != null) {
          return [data];
        } else {
          return [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 404) {
        // Return empty list if endpoint doesn't exist yet
        return [];
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get leave balances');
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      // Return empty list for network errors to prevent app crashes
      return [];
    }
  }

  // Get leave types
  Future<List<LeaveType>> getLeaveTypes() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token. Please login again.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/types'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LeaveType.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 500) {
        // Log the error for debugging
        print('Leave types 500 error: ${response.body}');
        // Return empty list for server errors to prevent app crashes
        return [];
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get leave types');
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      // Return empty list for network errors to prevent app crashes
      return [];
    }
  }

  // Get leave statistics using stored procedure
  Future<Map<String, dynamic>> getMyLeaveStats({int? year}) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token. Please login again.');
    }

    final queryParams = <String, String>{};
    if (year != null) {
      queryParams['year'] = year.toString();
    }

    final uri =
        Uri.parse('$baseUrl/my-stats').replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get leave stats');
      }
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        rethrow;
      }
      // Return empty stats for network errors to prevent app crashes
      return {
        'total_requests': 0,
        'pending_requests': 0,
        'approved_requests': 0,
        'total_days_taken': 0,
      };
    }
  }

  // Get specific leave request by ID
  Future<LeaveRequest> getLeaveRequestById(int requestId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No authentication token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/requests/$requestId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return LeaveRequest.fromJson(jsonDecode(response.body));
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to get leave request');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
