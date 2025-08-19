import 'package:flutter/foundation.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/leave_controller.dart';
import 'package:woosh_portal/providers/authProvider.dart';

class ControllersProvider extends ChangeNotifier {
  late AttendanceController attendanceController;
  late LeaveController leaveController;

  final AuthProvider authProvider;

  ControllersProvider(this.authProvider) {
    _initializeControllers();
  }

  void _initializeControllers() {
    attendanceController = AttendanceController();
    leaveController = LeaveController(authProvider);
  }

  // Initialize all controllers
  Future<void> initializeControllers() async {
    await Future.wait([
      attendanceController.initialize(),
      leaveController.initialize(),
    ]);
  }

  // Refresh all controllers
  Future<void> refreshAll() async {
    await Future.wait([
      attendanceController.refreshLocationAndNetwork(),
      leaveController.refresh(),
    ]);
  }

  @override
  void dispose() {
    attendanceController.dispose();
    leaveController.dispose();
    super.dispose();
  }
}
