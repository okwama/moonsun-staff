enum AttendanceStatus { pending, checkedIn, checkedOut }

enum AttendanceType { regular, overtime, leave }

class Attendance {
  final int id;
  final int staffId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? checkInIp;
  final String? checkOutIp;
  final AttendanceStatus status;
  final AttendanceType type;
  final double? totalHours;
  final double overtimeHours;
  final bool isLate;
  final int lateMinutes;
  final String? deviceInfo;
  final String timezone;
  final String shiftStart;
  final String shiftEnd;
  final bool isEarlyDeparture;
  final int earlyDepartureMinutes;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.staffId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInIp,
    this.checkOutIp,
    required this.status,
    required this.type,
    this.totalHours,
    required this.overtimeHours,
    required this.isLate,
    required this.lateMinutes,
    this.deviceInfo,
    required this.timezone,
    required this.shiftStart,
    required this.shiftEnd,
    required this.isEarlyDeparture,
    required this.earlyDepartureMinutes,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Informative status messages
  String get statusMessage {
    switch (status) {
      case AttendanceStatus.pending:
        return 'No attendance record for today';
      case AttendanceStatus.checkedIn:
        if (isLate) {
          return 'Checked in late ($lateMinutes minutes)';
        }
        return 'Successfully checked in';
      case AttendanceStatus.checkedOut:
        String message = 'Checked out';
        if (isEarlyDeparture) {
          message += ' ($earlyDepartureMinutes minutes early)';
        }
        if (overtimeHours > 0) {
          message += ' • ${overtimeHours.toStringAsFixed(1)}h overtime';
        }
        return message;
    }
  }

  // Status description for UI
  String get statusDescription {
    switch (status) {
      case AttendanceStatus.pending:
        return 'You haven\'t checked in today yet';
      case AttendanceStatus.checkedIn:
        if (isLate) {
          return 'You checked in $lateMinutes minutes after your shift started';
        }
        return 'You\'re currently checked in and working';
      case AttendanceStatus.checkedOut:
        String desc = 'You\'ve completed your shift for today';
        if (isEarlyDeparture) {
          desc += '\nLeft $earlyDepartureMinutes minutes early';
        }
        if (overtimeHours > 0) {
          desc += '\nWorked ${overtimeHours.toStringAsFixed(1)} hours overtime';
        }
        return desc;
    }
  }

  // Time summary
  String get timeSummary {
    if (checkInTime == null) return 'Not checked in';

    if (checkOutTime == null) {
      final duration = DateTime.now().difference(checkInTime!);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return 'Working for ${hours}h ${minutes}m';
    }

    final duration = checkOutTime!.difference(checkInTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m total';
  }

  // Check-in time formatted
  String get checkInTimeFormatted {
    if (checkInTime == null) return 'Not checked in';
    return '${checkInTime!.hour.toString().padLeft(2, '0')}:${checkInTime!.minute.toString().padLeft(2, '0')}';
  }

  // Check-out time formatted
  String get checkOutTimeFormatted {
    if (checkOutTime == null) return 'Not checked out';
    return '${checkOutTime!.hour.toString().padLeft(2, '0')}:${checkOutTime!.minute.toString().padLeft(2, '0')}';
  }

  // Shift time range
  String get shiftTimeRange {
    return '$shiftStart - $shiftEnd';
  }

  // Location info
  String get locationInfo {
    if (checkInLocation != null && checkInLocation!.isNotEmpty) {
      return checkInLocation!;
    }
    if (checkInLatitude != null && checkInLongitude != null) {
      return '${checkInLatitude!.toStringAsFixed(4)}, ${checkInLongitude!.toStringAsFixed(4)}';
    }
    return 'Location not available';
  }

  // Check-out location info
  String get checkOutLocationInfo {
    if (checkOutLocation != null && checkOutLocation!.isNotEmpty) {
      return checkOutLocation!;
    }
    if (checkOutLatitude != null && checkOutLongitude != null) {
      return '${checkOutLatitude!.toStringAsFixed(4)}, ${checkOutLongitude!.toStringAsFixed(4)}';
    }
    return 'Location not available';
  }

  // Status color for UI
  String get statusColor {
    switch (status) {
      case AttendanceStatus.pending:
        return '#FF6B35'; // Orange
      case AttendanceStatus.checkedIn:
        return isLate
            ? '#FF6B35'
            : '#4CAF50'; // Orange if late, Green if on time
      case AttendanceStatus.checkedOut:
        return '#2196F3'; // Blue
    }
  }

  // Can check in today
  bool get canCheckIn {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final attendanceDate = DateTime(date.year, date.month, date.day);

    return todayDate.isAtSameMomentAs(attendanceDate) &&
        status == AttendanceStatus.pending;
  }

  // Can check out today
  bool get canCheckOut {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final attendanceDate = DateTime(date.year, date.month, date.day);

    return todayDate.isAtSameMomentAs(attendanceDate) &&
        status == AttendanceStatus.checkedIn;
  }

  // Is today's attendance
  bool get isToday {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final attendanceDate = DateTime(date.year, date.month, date.day);
    return todayDate.isAtSameMomentAs(attendanceDate);
  }

  // Performance indicators
  String get performanceIndicator {
    if (status == AttendanceStatus.checkedOut) {
      if (isLate && isEarlyDeparture) {
        return '⚠️ Late arrival and early departure';
      } else if (isLate) {
        return '⚠️ Late arrival';
      } else if (isEarlyDeparture) {
        return '⚠️ Early departure';
      } else if (overtimeHours > 0) {
        return '⭐ Overtime work';
      } else {
        return '✅ Perfect attendance';
      }
    }
    return '';
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double? safeToDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Helper function to safely convert to int
    int safeToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    return Attendance(
      id: json['id'],
      staffId: json['staffId'],
      date: DateTime.parse(json['date']),
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,
      checkInLatitude: safeToDouble(json['checkInLatitude']),
      checkInLongitude: safeToDouble(json['checkInLongitude']),
      checkOutLatitude: safeToDouble(json['checkOutLatitude']),
      checkOutLongitude: safeToDouble(json['checkOutLongitude']),
      checkInLocation: json['checkInLocation'],
      checkOutLocation: json['checkOutLocation'],
      checkInIp: json['checkInIp'],
      checkOutIp: json['checkOutIp'],
      status: AttendanceStatus.values.firstWhere(
        (e) => e.index == json['status'],
        orElse: () => AttendanceStatus.checkedIn,
      ),
      type: AttendanceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AttendanceType.regular,
      ),
      totalHours: safeToDouble(json['totalHours']),
      overtimeHours: safeToDouble(json['overtimeHours']) ?? 0.0,
      isLate: json['isLate'] ?? false,
      lateMinutes: safeToInt(json['lateMinutes']),
      deviceInfo: json['deviceInfo'],
      timezone: json['timezone'] ?? 'UTC',
      shiftStart: json['shiftStart'] ?? '09:00:00',
      shiftEnd: json['shiftEnd'] ?? '17:00:00',
      isEarlyDeparture: json['isEarlyDeparture'] ?? false,
      earlyDepartureMinutes: safeToInt(json['earlyDepartureMinutes']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'date': date.toIso8601String().split('T')[0],
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'checkInLatitude': checkInLatitude,
      'checkInLongitude': checkInLongitude,
      'checkOutLatitude': checkOutLatitude,
      'checkOutLongitude': checkOutLongitude,
      'checkInLocation': checkInLocation,
      'checkOutLocation': checkOutLocation,
      'checkInIp': checkInIp,
      'checkOutIp': checkOutIp,
      'status': status.index,
      'type': type.toString().split('.').last,
      'totalHours': totalHours,
      'overtimeHours': overtimeHours,
      'isLate': isLate,
      'lateMinutes': lateMinutes,
      'deviceInfo': deviceInfo,
      'timezone': timezone,
      'shiftStart': shiftStart,
      'shiftEnd': shiftEnd,
      'isEarlyDeparture': isEarlyDeparture,
      'earlyDepartureMinutes': earlyDepartureMinutes,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
