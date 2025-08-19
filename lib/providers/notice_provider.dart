import 'package:flutter/foundation.dart';
import 'package:woosh_portal/models/notice.dart';

class NoticeProvider with ChangeNotifier {
  List<Notice> _notices = [];
  List<Notice> _recentNotices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Notice> get notices => _notices;
  List<Notice> get recentNotices => _recentNotices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notices
      .where((notice) => notice.status == 1)
      .length; // Status 1 = unread

  Future<void> fetchNotices({String? token}) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('NoticeProvider: Notices not available in modular backend');
      _notices = [];
      debugPrint('NoticeProvider: No notices available');
    } catch (e) {
      debugPrint('NoticeProvider: Error fetching notices: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchRecentNotices({String? token, int limit = 10}) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint(
          'NoticeProvider: Recent notices not available in modular backend');
      _recentNotices = [];
      debugPrint('NoticeProvider: No recent notices available');
    } catch (e) {
      debugPrint('NoticeProvider: Error fetching recent notices: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh({String? token}) async {
    debugPrint('NoticeProvider: Refreshing notices...');
    await Future.wait([
      fetchNotices(token: token),
      fetchRecentNotices(token: token),
    ]);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
