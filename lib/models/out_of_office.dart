class OutOfOffice {
  final int id;
  final int staffId;
  final String title;
  final String reason;
  final DateTime date;
  final int status; // 0=pending, 1=approved, 2=declined
  final int? approvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  OutOfOffice({
    required this.id,
    required this.staffId,
    required this.title,
    required this.reason,
    required this.date,
    required this.status,
    this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OutOfOffice.fromJson(Map<String, dynamic> json) {
    return OutOfOffice(
      id: json['id'],
      staffId: json['staff_id'],
      title: json['title'],
      reason: json['reason'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      approvedBy: json['approved_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
