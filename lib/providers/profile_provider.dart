import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/profile_service.dart';
import '../services/authService.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService.instance;

  User? _profile;
  bool _isLoading = false;
  String? _error;

  User? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileService.getMyProfile(token);
      if (_profile == null) {
        _error = 'Failed to load profile';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    final token = await AuthService.getToken();
    if (token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _profileService.updateProfile(
        token,
        profileData,
      );

      if (success) {
        // Reload profile to get updated data
        await loadProfile();
        return true;
      } else {
        _error = 'Failed to update profile';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    final token = await AuthService.getToken();
    if (token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _profileService.changePassword(
        token,
        currentPassword,
        newPassword,
      );

      if (success) {
        return true;
      } else {
        _error = 'Failed to change password';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    loadProfile();
  }
}
 