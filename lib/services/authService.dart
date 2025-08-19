import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/appConfig.dart';
import 'device_service.dart';

class AuthService {
  static String get baseUrl => AppConfig.baseUrl;
  static String get tokenKey => AppConfig.tokenKey;
  static String get userKey => AppConfig.userKey;

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Store token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Store user data
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(user.toJson()));
  }

  // Get stored user data
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Clear stored data
  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  // Login
  static Future<Map<String, dynamic>> login(
      String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.authEndpoint}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['access_token']);
        await saveUser(User.fromJson(data['user']));
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Signup
  static Future<Map<String, dynamic>> signup(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.authEndpoint}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'photoUrl': 'https://randomuser.me/api/portraits/lego/1.jpg',
          'emplNo': 'EMP${DateTime.now().millisecondsSinceEpoch}',
          'idNo': 'ID${DateTime.now().millisecondsSinceEpoch}',
          'role': 'staff',
          'phoneNumber': phone,
          'password': password,
          'department': 'General',
          'businessEmail': email,
          'salary': 30000.0,
          'employmentType': 'Permanent',
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await saveToken(data['access_token']);
        await saveUser(User.fromJson(data['user']));
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Signup failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Try to call logout endpoint, but don't fail if it doesn't work
        try {
          await http.post(
            Uri.parse('${AppConfig.authEndpoint}/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 5));
        } catch (e) {
          // Ignore logout endpoint errors - token might be expired
          print('Logout endpoint error (ignored): $e');
        }
      }
    } catch (e) {
      // Ignore any other logout errors
      print('Logout error (ignored): $e');
    } finally {
      // Always clear local data regardless of backend response
      await clearData();

      // Clear device registration cache on logout
      DeviceService().clearDeviceRegistrationCache();
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('${AppConfig.authEndpoint}/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to get profile'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
