import '../services/authService.dart';
import '../models/user.dart';
import '../services/notification_service.dart';
import 'package:http/http.dart' as http;

class AuthController {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  // Login user
  Future<Map<String, dynamic>> loginUser(String phone, String password) async {
    try {
      final result = await AuthService.login(phone, password);

      if (result['success']) {
        final user = User.fromJson(result['data']['user']);

        // Show success notification
        await NotificationService.instance.showNotification(
          title: 'Login Successful',
          body: 'Welcome back, ${user.name}!',
          type: NotificationType.success,
        );

        return {
          'success': true,
          'user': user,
          'message': 'Login successful',
        };
      } else {
        // Show error notification
        await NotificationService.instance.showNotification(
          title: 'Login Failed',
          body: result['message'],
          type: NotificationType.error,
        );

        return {
          'success': false,
          'message': result['message'],
        };
      }
    } catch (e) {
      await NotificationService.instance.showNotification(
        title: 'Login Error',
        body: 'An unexpected error occurred',
        type: NotificationType.error,
      );

      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  // Signup user
  Future<Map<String, dynamic>> signupUser(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    try {
      final result = await AuthService.signup(name, phone, email, password);

      if (result['success']) {
        final user = User.fromJson(result['data']['user']);

        // Show success notification
        await NotificationService.instance.showNotification(
          title: 'Account Created',
          body: 'Welcome to Woosh, ${user.name}!',
          type: NotificationType.success,
        );

        return {
          'success': true,
          'user': user,
          'message': 'Account created successfully',
        };
      } else {
        // Show error notification
        await NotificationService.instance.showNotification(
          title: 'Signup Failed',
          body: result['message'],
          type: NotificationType.error,
        );

        return {
          'success': false,
          'message': result['message'],
        };
      }
    } catch (e) {
      await NotificationService.instance.showNotification(
        title: 'Signup Error',
        body: 'An unexpected error occurred',
        type: NotificationType.error,
      );

      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  // Logout user
  Future<Map<String, dynamic>> logoutUser() async {
    try {
      final currentUser = await AuthService.getUser();
      final userName = currentUser?.name ?? 'User';

      await AuthService.logout();

      // Show logout notification
      await NotificationService.instance.showNotification(
        title: 'Logged Out',
        body: 'Goodbye, $userName! You have been successfully logged out.',
        type: NotificationType.info,
      );

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      await NotificationService.instance.showNotification(
        title: 'Logout Error',
        body: 'There was an issue logging you out. Please try again.',
        type: NotificationType.error,
      );

      return {
        'success': false,
        'message': 'Logout failed: $e',
      };
    }
  }

  // Check authentication status
  Future<Map<String, dynamic>> checkAuthStatus() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'isAuthenticated': false,
          'message': 'No token found',
        };
      }

      final user = await AuthService.getUser();
      if (user != null) {
        return {
          'success': true,
          'isAuthenticated': true,
          'user': user,
          'message': 'User is authenticated',
        };
      }

      return {
        'success': false,
        'isAuthenticated': false,
        'message': 'No user data found',
      };
    } catch (e) {
      return {
        'success': false,
        'isAuthenticated': false,
        'message': 'Error checking auth status: $e',
      };
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final result = await AuthService.getProfile();

      if (result['success']) {
        return {
          'success': true,
          'data': result['data'],
          'message': 'Profile retrieved successfully',
        };
      } else {
        return {
          'success': false,
          'message': result['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting profile: $e',
      };
    }
  }

  // Refresh user data
  Future<Map<String, dynamic>> refreshUserData() async {
    try {
      final user = await AuthService.getUser();
      if (user != null) {
        return {
          'success': true,
          'user': user,
          'message': 'User data refreshed',
        };
      } else {
        return {
          'success': false,
          'message': 'No user data found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error refreshing user data: $e',
      };
    }
  }

  // Validate phone number
  bool validatePhoneNumber(String phone) {
    return RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone);
  }

  // Validate email
  bool validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  bool validatePassword(String password) {
    return password.length >= 6;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await AuthService.getToken();
    return {'Authorization': 'Bearer $token'};
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('https://your.api.url/users/account'),
        headers: await getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
