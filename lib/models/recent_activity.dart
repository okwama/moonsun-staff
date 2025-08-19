class RecentActivity {
  final String type; // 'attendance', 'task', 'notice'
  final int id;
  final String title;
  final String subtitle;
  final DateTime date;

  RecentActivity({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'],
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      date: DateTime.parse(json['date']),
    );
  }
}
