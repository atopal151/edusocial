class EventModel {
  final int id;
  final bool isGroupEvent;
  final int groupId;
  final int userId;
  final String title;
  final String description;
  final String banner;
  final String location;
  final String startTime;
  final String endTime;
  final String status;
  final String bannerUrl;
  final String humanStartTime;
  final String humanEndTime;
  final bool hasReminder;

  EventModel({
    required this.id,
    required this.isGroupEvent,
    required this.groupId,
    required this.userId,
    required this.title,
    required this.description,
    required this.banner,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.bannerUrl,
    required this.humanStartTime,
    required this.humanEndTime,
    required this.hasReminder,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      isGroupEvent: json['is_group_event'],
      groupId: json['group_id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      banner: json['banner'],
      location: json['location'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      bannerUrl: json['banner_url'],
      humanStartTime: json['human_start_time'],
      humanEndTime: json['human_end_time'],
      hasReminder: json['has_reminder'],
    );
  }
}
