class User {
  final int id;
  final String name;
  final String? photoUrl;
  final String emplNo;
  final String idNo;
  final String role;
  final String? phoneNumber;
  final String? department;
  final String? businessEmail;
  final String? departmentEmail;
  final double salary;
  final String employmentType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isActiveField;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.emplNo,
    required this.idNo,
    required this.role,
    this.phoneNumber,
    this.department,
    this.businessEmail,
    this.departmentEmail,
    required this.salary,
    required this.employmentType,
    required this.createdAt,
    required this.updatedAt,
    required this.isActiveField,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'],
      emplNo: json['emplNo'] ?? '',
      idNo: json['idNo'] ?? '',
      role: json['role'] ?? '',
      phoneNumber: json['phoneNumber'],
      department: json['department'],
      businessEmail: json['businessEmail'],
      departmentEmail: json['departmentEmail'],
      salary: _parseDouble(json['salary']),
      employmentType: json['employmentType'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActiveField: _parseInt(json['isActiveField']),
      isActive: json['isActive'] ?? false,
    );
  }

  // Helper method to safely parse integers
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  // Helper method to safely parse doubles
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'emplNo': emplNo,
      'idNo': idNo,
      'role': role,
      'phoneNumber': phoneNumber,
      'department': department,
      'businessEmail': businessEmail,
      'departmentEmail': departmentEmail,
      'salary': salary,
      'employmentType': employmentType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActiveField': isActiveField,
      'isActive': isActive,
    };
  }

  // Helper getters for compatibility
  String get email => businessEmail ?? departmentEmail ?? '';
  String get phone => phoneNumber ?? '';
  String get status => isActive ? 'active' : 'inactive';
}
