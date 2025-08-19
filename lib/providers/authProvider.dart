import 'package:flutter/material.dart';
import '../models/user.dart';
import '../controllers/authController.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;
  bool get isLoggedOut => _user == null && _isInitialized;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final authController = AuthController();
      final result = await authController.checkAuthStatus();

      if (result['success'] && result['isAuthenticated']) {
        _user = result['user'];
      } else {
        _user = null;
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = true;
      _user = null;
      notifyListeners();
    }
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authController = AuthController();
      final result = await authController.loginUser(phone, password);

      if (result['success']) {
        _user = result['user'];
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _user = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred';
      _user = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(
      String name, String phone, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authController = AuthController();
      final result =
          await authController.signupUser(name, phone, email, password);

      if (result['success']) {
        _user = result['user'];
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _user = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'An unexpected error occurred';
      _user = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      final authController = AuthController();
      await authController.logoutUser();
      _user = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> deleteAccount() async {
    final authController = AuthController();
    final result = await authController.deleteAccount();
    if (result['success']) {
      await logout();
    } else {
      throw Exception(result['message'] ?? 'Account deletion failed');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check if user is authenticated and token is valid
  Future<bool> checkAuthStatus() async {
    try {
      final authController = AuthController();
      final result = await authController.checkAuthStatus();

      if (result['success'] && result['isAuthenticated']) {
        _user = result['user'];
        notifyListeners();
        return true;
      } else {
        _user = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _user = null;
      notifyListeners();
      return false;
    }
  }

  /// Refresh user data from storage
  Future<void> refreshUser() async {
    try {
      final authController = AuthController();
      final result = await authController.refreshUserData();

      if (result['success']) {
        _user = result['user'];
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get current user's name or default text
  String getUserName() {
    return _user?.name ?? 'User';
  }

  /// Get current user's role
  String getUserRole() {
    return _user?.role ?? 'Staff';
  }

  /// Get current user's department
  String getUserDepartment() {
    return _user?.department ?? 'General';
  }

  /// Check if user is active
  bool isUserActive() {
    return _user?.isActive ?? false;
  }

  /// Validate phone number
  bool validatePhoneNumber(String phone) {
    final authController = AuthController();
    return authController.validatePhoneNumber(phone);
  }

  /// Validate email
  bool validateEmail(String email) {
    final authController = AuthController();
    return authController.validateEmail(email);
  }

  /// Validate password
  bool validatePassword(String password) {
    final authController = AuthController();
    return authController.validatePassword(password);
  }
}
