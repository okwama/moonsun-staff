import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:woosh_portal/providers/authProvider.dart';
import 'package:woosh_portal/controllers/attendance_controller.dart';
import 'package:woosh_portal/widgets/success_popup.dart';
import 'package:woosh_portal/utils/error_utils.dart';
import 'package:woosh_portal/utils/greeting_utils.dart';

class ButtonConfig {
  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  ButtonConfig({
    required this.text,
    required this.color,
    required this.icon,
    required this.onPressed,
  });
}

class StatusInfo {
  final String text;
  final Color color;
  final IconData icon;

  StatusInfo({
    required this.text,
    required this.color,
    required this.icon,
  });
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late AttendanceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AttendanceController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCheckIn() async {
    final success = await _controller.checkIn();

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (context) => const SuccessPopup(
          title: 'Check-in Successful',
          message: 'You have been checked in successfully!',
          actionText: 'Great!',
        ),
      );
    } else if (mounted && _controller.errorMessage != null) {
      // Show device-specific dialog for device approval errors
      if (_controller.errorType == 'device_approval' ||
          _controller.errorType == 'device_registration') {
        ErrorUtils.showDeviceApprovalError(
          context,
          message: _controller.errorMessage!,
          onContactAdmin: () {
            // TODO: Implement contact admin functionality
            // This could open email, phone, or in-app messaging
            debugPrint('Contact admin functionality to be implemented');
          },
        );
        // Clear the error after showing the dialog
        _controller.clearError();
      } else {
        // Show regular error popup for other errors
        ErrorUtils.showErrorPopup(
          context,
          error: Exception(_controller.errorMessage),
          onRetry: _handleCheckIn,
        );
      }
    }
  }

  Future<void> _handleCheckOut() async {
    final success = await _controller.checkOut();

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (context) => const SuccessPopup(
          title: 'Check-out Successful',
          message: 'You have been checked out successfully!',
          actionText: 'Great!',
        ),
      );
    } else if (mounted && _controller.errorMessage != null) {
      // Show device-specific dialog for device approval errors
      if (_controller.errorType == 'device_approval' ||
          _controller.errorType == 'device_registration') {
        ErrorUtils.showDeviceApprovalError(
          context,
          message: _controller.errorMessage!,
          onContactAdmin: () {
            // TODO: Implement contact admin functionality
            // This could open email, phone, or in-app messaging
            debugPrint('Contact admin functionality to be implemented');
          },
        );
        // Clear the error after showing the dialog
        _controller.clearError();
      } else {
        // Show regular error popup for other errors
        ErrorUtils.showErrorPopup(
          context,
          error: Exception(_controller.errorMessage),
          onRetry: _handleCheckOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Clock In/Out',
            style: GoogleFonts.interTight(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          elevation: 0,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.refreshLocationAndNetwork(),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: ChangeNotifierProvider.value(
          value: _controller,
          child: Consumer<AttendanceController>(
            builder: (context, controller, child) {
              return RefreshIndicator(
                onRefresh: () => controller.refreshLocationAndNetwork(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(isTablet ? 32 : 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 600 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome Header
                          _buildWelcomeHeader(user, isTablet),
                          SizedBox(height: isTablet ? 32 : 24),

                          // Current Status Card
                          _buildCurrentStatusCard(controller, isTablet),
                          SizedBox(height: isTablet ? 32 : 24),

                          // Device Info Card
                          _buildDeviceInfoCard(controller, isTablet),
                          SizedBox(height: isTablet ? 32 : 24),

                          // Action Buttons
                          _buildActionButtons(controller, isTablet),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(user, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isTablet ? 56 : 48,
                height: isTablet ? 56 : 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_filled,
                  color: Colors.white,
                  size: isTablet ? 32 : 28,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      GreetingUtils.getGreeting(),
                      style: GoogleFonts.interTight(
                        fontSize: isTablet ? 28 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.name ?? 'User',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 18 : 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard(
      AttendanceController controller, bool isTablet) {
    final statusInfo = _getStatusInfo(controller);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusInfo.color.withOpacity(0.1),
            statusInfo.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusInfo.color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: isTablet ? 80 : 64,
            height: isTablet ? 80 : 64,
            decoration: BoxDecoration(
              color: statusInfo.color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: statusInfo.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              statusInfo.icon,
              size: isTablet ? 40 : 32,
              color: statusInfo.color,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          Text(
            'Current Status',
            style: GoogleFonts.interTight(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            statusInfo.text,
            style: GoogleFonts.interTight(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: statusInfo.color,
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 20,
              vertical: isTablet ? 16 : 12,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).primaryColor,
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Text(
                  _getCurrentTime(),
                  style: GoogleFonts.interTight(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (controller.currentAttendance != null) ...[
            SizedBox(height: isTablet ? 20 : 16),
            _buildAttendanceInfo(controller, isTablet),
          ],
        ],
      ),
    );
  }

  StatusInfo _getStatusInfo(AttendanceController controller) {
    if (controller.currentAttendance == null) {
      return StatusInfo(
        text: 'Ready to Clock In',
        color: Colors.blue,
        icon: Icons.schedule,
      );
    }

    final status = controller.currentAttendance!['status'];
    if (status == 0) {
      return StatusInfo(
        text: 'Pending',
        color: Colors.orange,
        icon: Icons.pending,
      );
    } else if (status == 1) {
      return StatusInfo(
        text: 'Checked In',
        color: Colors.green,
        icon: Icons.check_circle,
      );
    } else if (status == 2) {
      return StatusInfo(
        text: 'Checked Out',
        color: Colors.red,
        icon: Icons.logout,
      );
    }

    return StatusInfo(
      text: 'Unknown Status',
      color: Colors.grey,
      icon: Icons.help,
    );
  }

  Widget _buildDeviceInfoCard(AttendanceController controller, bool isTablet) {
    final children = <Widget>[
      _buildInfoRow(
          'IP Address', controller.currentIpAddress ?? 'Loading...', isTablet),
      _buildInfoRow(
          'Location', controller.currentLocation ?? 'Loading...', isTablet),
    ];

    if (controller.currentCoordinates != null) {
      children.addAll([
        _buildInfoRow(
          'Latitude',
          controller.currentCoordinates!['latitude']?.toStringAsFixed(6) ??
              'N/A',
          isTablet,
        ),
        _buildInfoRow(
          'Longitude',
          controller.currentCoordinates!['longitude']?.toStringAsFixed(6) ??
              'N/A',
          isTablet,
        ),
      ]);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isTablet ? 48 : 40,
                height: isTablet ? 48 : 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.devices,
                  color: Theme.of(context).primaryColor,
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Information',
                      style: GoogleFonts.interTight(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Current device and location details',
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 14 : 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 20),
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.05),
              ),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AttendanceController controller, bool isTablet) {
    final buttonConfig = _getButtonConfig(controller);

    return Container(
      width: double.infinity,
      height: isTablet ? 80 : 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            buttonConfig.color,
            buttonConfig.color.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: buttonConfig.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: controller.isLoading ? null : buttonConfig.onPressed,
          child: Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.isLoading) ...[
                  SizedBox(
                    width: isTablet ? 24 : 20,
                    height: isTablet ? 24 : 20,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                ] else ...[
                  Icon(
                    buttonConfig.icon,
                    color: Colors.white,
                    size: isTablet ? 28 : 24,
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                ],
                Text(
                  buttonConfig.text,
                  style: GoogleFonts.interTight(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonConfig _getButtonConfig(AttendanceController controller) {
    if (controller.isLoading) {
      if (controller.isCheckingIn) {
        return ButtonConfig(
          text: 'Checking In...',
          color: Colors.green,
          icon: Icons.login,
          onPressed: () {},
        );
      } else if (controller.isCheckingOut) {
        return ButtonConfig(
          text: 'Checking Out...',
          color: Colors.red,
          icon: Icons.logout,
          onPressed: () {},
        );
      }
    }

    if (controller.currentAttendance == null) {
      return ButtonConfig(
        text: 'Check In',
        color: Colors.green,
        icon: Icons.login,
        onPressed: _handleCheckIn,
      );
    }

    final status = controller.currentAttendance!['status'];
    if (status == 1) {
      // Checked in - show check out button
      return ButtonConfig(
        text: 'Check Out',
        color: Colors.red,
        icon: Icons.logout,
        onPressed: _handleCheckOut,
      );
    } else if (status == 2) {
      // Checked out - show completed state
      return ButtonConfig(
        text: 'Already Checked Out',
        color: Colors.grey,
        icon: Icons.check_circle,
        onPressed: () {},
      );
    } else {
      // Pending or other status - show check in button
      return ButtonConfig(
        text: 'Check In',
        color: Colors.green,
        icon: Icons.login,
        onPressed: _handleCheckIn,
      );
    }
  }

  Widget _buildInfoRow(String label, String value, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 32 : 28,
            height: isTablet ? 32 : 28,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForLabel(label),
              color: Theme.of(context).primaryColor,
              size: isTablet ? 18 : 16,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
                SizedBox(height: isTablet ? 4 : 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? 16 : 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'ip address':
        return Icons.wifi;
      case 'location':
        return Icons.location_on;
      case 'latitude':
        return Icons.explore;
      case 'longitude':
        return Icons.explore_outlined;
      case 'check-in time':
        return Icons.login;
      case 'check-out time':
        return Icons.logout;
      case 'total hours':
        return Icons.access_time;
      default:
        return Icons.info_outline;
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildAttendanceInfo(AttendanceController controller, bool isTablet) {
    final attendance = controller.currentAttendance!;
    final checkInTime = attendance['checkInTime'];
    final checkOutTime = attendance['checkOutTime'];
    final totalHours = attendance['totalHours'];

    return Column(
      children: [
        if (checkInTime != null) ...[
          _buildInfoRow('Check-in Time', _formatTime(checkInTime), isTablet),
          SizedBox(height: isTablet ? 8 : 6),
        ],
        if (checkOutTime != null) ...[
          _buildInfoRow('Check-out Time', _formatTime(checkOutTime), isTablet),
          SizedBox(height: isTablet ? 8 : 6),
        ],
        if (totalHours != null) ...[
          _buildInfoRow(
              'Total Hours', '${_safeToFixed(totalHours, 2)} hrs', isTablet),
        ],
      ],
    );
  }

  String _formatTime(String timeString) {
    try {
      debugPrint('🕐 Formatting time: $timeString');

      // Handle ISO format with 'T' separator (UTC time from backend)
      if (timeString.contains('T')) {
        final utcDateTime = DateTime.parse(timeString);
        // Convert UTC to local time (Africa/Nairobi)
        final localDateTime = utcDateTime.toLocal();
        debugPrint('🕐 UTC: $utcDateTime -> Local: $localDateTime');
        debugPrint(
            '🕐 UTC Hour: ${utcDateTime.hour}, Local Hour: ${localDateTime.hour}');
        debugPrint(
            '🕐 UTC Minute: ${utcDateTime.minute}, Local Minute: ${localDateTime.minute}');
        debugPrint('🕐 Timezone offset: ${utcDateTime.timeZoneOffset}');
        debugPrint('🕐 Local timezone: ${DateTime.now().timeZoneName}');
        // Format as HH:MM in local time
        return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
      }

      // Handle space-separated format
      if (timeString.contains(' ')) {
        final timePart = timeString.split(' ')[1];
        return timePart.substring(0, 5); // Get HH:MM part
      }

      // If it's already in HH:MM format, return as is
      if (timeString.length >= 5 && timeString.contains(':')) {
        return timeString.substring(0, 5);
      }

      return timeString;
    } catch (e) {
      debugPrint('❌ Error formatting time: $e for timeString: $timeString');
      return timeString;
    }
  }

  String _safeToFixed(dynamic value, int fractionDigits) {
    double? numValue;
    if (value is double) {
      numValue = value;
    } else if (value is int) {
      numValue = value.toDouble();
    } else if (value is String) {
      numValue = double.tryParse(value);
    }
    return numValue != null ? numValue.toStringAsFixed(fractionDigits) : '--';
  }
}
