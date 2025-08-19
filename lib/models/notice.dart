class Notice {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int countryId;
  final int status;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.countryId,
    required this.status,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      countryId: json['countryId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'countryId': countryId,
      'status': status,
    };
  }
}
