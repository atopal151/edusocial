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
  final String? invitationStatus; // null, 'accepted', 'declined'
  final bool? isPending; // Davet beklemede mi?
  final bool? isMember; // Grup üyesi mi?

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
    this.invitationStatus,
    this.isPending,
    this.isMember,
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
      invitationStatus: json['invitation_status'],
      isPending: json['group']?['is_pending'],
      isMember: json['group']?['is_member'],
    );
  }

  EventModel copyWith({
    int? id,
    bool? isGroupEvent,
    int? groupId,
    int? userId,
    String? title,
    String? description,
    String? banner,
    String? location,
    String? startTime,
    String? endTime,
    String? status,
    String? bannerUrl,
    String? humanStartTime,
    String? humanEndTime,
    bool? hasReminder,
    String? invitationStatus,
    bool? isPending,
    bool? isMember,
  }) {
    return EventModel(
      id: id ?? this.id,
      isGroupEvent: isGroupEvent ?? this.isGroupEvent,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      banner: banner ?? this.banner,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      humanStartTime: humanStartTime ?? this.humanStartTime,
      humanEndTime: humanEndTime ?? this.humanEndTime,
      hasReminder: hasReminder ?? this.hasReminder,
      invitationStatus: invitationStatus ?? this.invitationStatus,
      isPending: isPending ?? this.isPending,
      isMember: isMember ?? this.isMember,
    );
  }
}
