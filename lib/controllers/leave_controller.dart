import 'package:flutter/foundation.dart';
import 'package:woosh_portal/providers/authProvider.dart';
import '../services/leave_service.dart';
import '../models/leave_request.dart';

class LeaveController extends ChangeNotifier {
  final LeaveService _leaveService;
  final AuthProvider authProvider;

  // State variables
  List<LeaveRequest> _leaveRequests = [];
  List<LeaveType> _leaveTypes = [];
  List<Map<String, dynamic>> _leaveBalances = [];
  Map<String, dynamic>? _leaveStats;
  bool _isLoading = false;
  bool _isLoadingRequests = false;
  bool _isLoadingTypes = false;
  bool _isLoadingBalances = false;
  bool _isLoadingStats = false;
  String? _errorMessage;

  // Getters
  List<LeaveRequest> get leaveRequests => _leaveRequests;
  List<LeaveType> get leaveTypes => _leaveTypes;
  List<Map<String, dynamic>> get leaveBalances => _leaveBalances;
  Map<String, dynamic>? get leaveStats => _leaveStats;
  bool get isLoading => _isLoading;
  bool get isLoadingRequests => _isLoadingRequests;
  bool get isLoadingTypes => _isLoadingTypes;
  bool get isLoadingBalances => _isLoadingBalances;
  bool get isLoadingStats => _isLoadingStats;
  String? get errorMessage => _errorMessage;

  LeaveController(AuthProvider authProvider)
      : _leaveService = LeaveService(authProvider),
        authProvider = authProvider;

  // Initialize and load data
  Future<void> initialize() async {
    await loadData();
  }

  // Load all data
  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([
        _loadLeaveRequests(),
        _loadLeaveTypes(),
        _loadLeaveBalances(),
        _loadLeaveStats(),
      ]);
    } catch (e) {
      if (e.toString().contains('Authentication failed')) {
        _setError('Please login again to access leave features.');
      } else {
        _setError('Error loading data: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Load leave requests using stored procedure
  Future<void> _loadLeaveRequests({LeaveStatus? status}) async {
    _setLoadingRequests(true);

    try {
      final requests = await _leaveService.getMyLeaveRequests(status: status);
      _leaveRequests = requests;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading leave requests: $e');
      _setError('Failed to load leave requests: $e');
    } finally {
      _setLoadingRequests(false);
    }
  }

  // Load leave types
  Future<void> _loadLeaveTypes() async {
    _setLoadingTypes(true);

    try {
      final types = await _leaveService.getLeaveTypes();
      _leaveTypes = types;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading leave types: $e');
    } finally {
      _setLoadingTypes(false);
    }
  }

  // Load leave types only
  Future<void> loadLeaveTypesOnly() async {
    await _loadLeaveTypes();
  }

  // Load leave balances using stored procedure
  Future<void> _loadLeaveBalances({int? year}) async {
    _setLoadingBalances(true);

    try {
      final balances = await _leaveService.getMyLeaveBalances(year: year);
      _leaveBalances = balances;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading leave balances: $e');
    } finally {
      _setLoadingBalances(false);
    }
  }

  // Load leave statistics using stored procedure
  Future<void> _loadLeaveStats({int? year}) async {
    _setLoadingStats(true);

    try {
      final stats = await _leaveService.getMyLeaveStats(year: year);
      _leaveStats = stats;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading leave stats: $e');
    } finally {
      _setLoadingStats(false);
    }
  }

  // Create leave request using stored procedure
  Future<bool> createLeaveRequest({
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    bool isHalfDay = false,
    String? attachmentUrl,
  }) async {
    try {
      final user = authProvider.user;
      if (user == null) throw Exception('User not found');

      final result = await _leaveService.createLeaveRequest(
        leaveTypeId: leaveTypeId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        isHalfDay: isHalfDay,
        attachmentUrl: attachmentUrl,
      );

      if (result['success'] == true) {
        await loadData(); // Refresh all data
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to create leave request');
        return false;
      }
    } catch (e) {
      _setError('Error creating leave request: $e');
      return false;
    }
  }

  // Cancel leave request
  Future<bool> cancelLeaveRequest(int requestId) async {
    try {
      final result = await _leaveService.cancelLeaveRequest(requestId);
      if (result['success'] == true) {
        await loadData(); // Refresh all data
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to cancel leave request');
        return false;
      }
    } catch (e) {
      _setError('Error cancelling leave request: $e');
      return false;
    }
  }

  // Get leave requests by status
  Future<void> loadLeaveRequestsByStatus(LeaveStatus status) async {
    await _loadLeaveRequests(status: status);
  }

  // Get leave balance by type ID
  Map<String, dynamic>? getLeaveBalanceByTypeId(int typeId) {
    try {
      return _leaveBalances.firstWhere(
        (balance) =>
            balance['leave_type_id'] == typeId ||
            balance['leaveTypeId'] == typeId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get leave type by ID
  LeaveType? getLeaveTypeById(int id) {
    try {
      return _leaveTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get leave request by ID
  Future<LeaveRequest?> getLeaveRequestById(int requestId) async {
    try {
      return await _leaveService.getLeaveRequestById(requestId);
    } catch (e) {
      _setError('Error getting leave request: $e');
      return null;
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadData();
  }

  // Refresh specific data
  Future<void> refreshLeaveRequests() async {
    await _loadLeaveRequests();
  }

  Future<void> refreshLeaveBalances() async {
    await _loadLeaveBalances();
  }

  Future<void> refreshLeaveStats() async {
    await _loadLeaveStats();
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingRequests(bool loading) {
    _isLoadingRequests = loading;
    notifyListeners();
  }

  void _setLoadingTypes(bool loading) {
    _isLoadingTypes = loading;
    notifyListeners();
  }

  void _setLoadingBalances(bool loading) {
    _isLoadingBalances = loading;
    notifyListeners();
  }

  void _setLoadingStats(bool loading) {
    _isLoadingStats = loading;
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
