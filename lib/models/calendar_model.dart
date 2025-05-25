class Reminder {
  final int id;
  final String title;
  final String dateTime;
  final bool sendNotification;
  final String color;

  Reminder({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.sendNotification,
    required this.color,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      title: json['description'] ?? '',
      dateTime: json['notification_time'] ?? '',
      sendNotification: json['send_notification'] ?? true,
      color: json['color'] ?? '#36C897', // varsayılan renk atanabilir
    );
  }
}
