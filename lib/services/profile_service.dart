import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/appConfig.dart';
import '../models/user.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  static ProfileService get instance => _instance;

  Future<User?> getMyProfile(String token) async {
    try {
      print(
          'Profile service: Making request to ${AppConfig.baseUrl}/staff/profile/me');
      print('Profile service: Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/staff/profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Profile service: Response status: ${response.statusCode}');
      print('Profile service: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception(
            'Failed to load profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Profile service error: $e');
      return null;
    }
  }

  Future<bool> updateProfile(
      String token, Map<String, dynamic> profileData) async {
    try {
      final response = await http.patch(
        Uri.parse('${AppConfig.baseUrl}/staff/profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Profile service error: $e');
      return false;
    }
  }

  Future<bool> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/staff/profile/me/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      print('Profile service error: $e');
      return false;
    }
  }
}
 