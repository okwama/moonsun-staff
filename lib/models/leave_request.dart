enum LeaveStatus { pending, approved, rejected, cancelled }

class LeaveRequest {
  final int id;
  final int employeeId;
  final int leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final String? notes;
  final int? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields from stored procedure
  final String? leaveTypeName;
  final String? leaveTypeDescription;
  final String? employeeName;
  final String? employeeEmail;
  final String? approverName;
  final int? totalDaysRequested;
  final bool isHalfDay;
  final String? attachmentUrl;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.notes,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.leaveTypeName,
    this.leaveTypeDescription,
    this.employeeName,
    this.employeeEmail,
    this.approverName,
    this.totalDaysRequested,
    this.isHalfDay = false,
    this.attachmentUrl,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? json['employeeId'] ?? 0,
      leaveTypeId: json['leave_type_id'] ?? json['leaveTypeId'] ?? 0,
      startDate: DateTime.parse(json['start_date'] ?? json['startDate']),
      endDate: DateTime.parse(json['end_date'] ?? json['endDate']),
      reason: json['reason'] ?? '',
      status: LeaveStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'pending'),
        orElse: () => LeaveStatus.pending,
      ),
      notes: json['notes'],
      approvedBy: json['approved_by'] ?? json['approvedBy'],
      approvedAt: json['approved_at'] != null || json['approvedAt'] != null
          ? DateTime.parse(json['approved_at'] ?? json['approvedAt'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
      leaveTypeName: json['leave_type_name'],
      leaveTypeDescription: json['leave_type_description'],
      employeeName: json['employee_name'],
      employeeEmail: json['employee_email'],
      approverName: json['approver_name'],
      totalDaysRequested: json['total_days_requested'],
      isHalfDay: json['is_half_day'] ?? json['isHalfDay'] ?? false,
      attachmentUrl: json['attachment_url'] ?? json['attachmentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'leaveTypeId': leaveTypeId,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'reason': reason,
      'status': status.toString().split('.').last,
      'notes': notes,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'leaveTypeName': leaveTypeName,
      'leaveTypeDescription': leaveTypeDescription,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
      'approverName': approverName,
      'totalDaysRequested': totalDaysRequested,
      'isHalfDay': isHalfDay,
      'attachmentUrl': attachmentUrl,
    };
  }

  // Helper method to get status color
  String get statusColor {
    switch (status) {
      case LeaveStatus.pending:
        return '#FFA500'; // Orange
      case LeaveStatus.approved:
        return '#4CAF50'; // Green
      case LeaveStatus.rejected:
        return '#F44336'; // Red
      case LeaveStatus.cancelled:
        return '#9E9E9E'; // Grey
    }
  }

  // Helper method to get status text
  String get statusText {
    switch (status) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class LeaveType {
  final int id;
  final String name;
  final String description;
  final int defaultDays;
  final bool isActive;

  LeaveType({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultDays,
    required this.isActive,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'] ?? 0, // Add null check with default value
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      defaultDays: json['default_days'] ?? json['defaultDays'] ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }
}

// New model for leave balance from stored procedure
class LeaveBalance {
  final int id;
  final int employeeId;
  final int leaveTypeId;
  final int year;
  final int totalDays;
  final int usedDays;
  final int remainingDays;
  final String? leaveTypeName;
  final String? leaveTypeDescription;
  final String? employeeName;
  final int availableDays;

  LeaveBalance({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.year,
    required this.totalDays,
    required this.usedDays,
    required this.remainingDays,
    this.leaveTypeName,
    this.leaveTypeDescription,
    this.employeeName,
    required this.availableDays,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? json['employeeId'] ?? 0,
      leaveTypeId: json['leave_type_id'] ?? json['leaveTypeId'] ?? 0,
      year: json['year'] ?? DateTime.now().year,
      totalDays: json['total_days'] ?? json['totalDays'] ?? 0,
      usedDays: json['used_days'] ?? json['usedDays'] ?? 0,
      remainingDays: json['remaining_days'] ?? json['remainingDays'] ?? 0,
      leaveTypeName: json['leave_type_name'],
      leaveTypeDescription: json['leave_type_description'],
      employeeName: json['employee_name'],
      availableDays: json['available_days'] ?? json['availableDays'] ?? 0,
    );
  }
}
