class Reminder {
  final int id;
  final String title;
  final String dateTime;
  final bool sendNotification;

  Reminder({
    required this.id,
    required this.title,
    required this.dateTime,
    this.sendNotification = true,
  });
}