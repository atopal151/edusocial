
class GroupChatModel {
  final int id;
  final int groupId;
  final int userId;
  final String message;
  final String messageType;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String humanCreatedAt;
  final Map<String, dynamic> user;
  final List<GroupChatMediaModel> media;
  final List<GroupChatLinkModel> groupChatLink;
  final int? surveyId;
  final Map<String, dynamic>? survey;
  final bool isPinned; // Pin status field

  GroupChatModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.message,
    required this.messageType,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.humanCreatedAt,
    required this.user,
    required this.media,
    required this.groupChatLink,
    this.surveyId,
    this.survey,
    this.isPinned = false, // Default to false
  });

  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    // Parse pin status
    final isPinned = json['is_pinned'] == true || (json['is_pinned'] is int && json['is_pinned'] == 1);
    

    
    return GroupChatModel(
      id: json['id'] ?? 0,
      groupId: json['group_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? 'text',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
      humanCreatedAt: json['human_created_at'] ?? '',
      user: json['user'] as Map<String, dynamic>? ?? {},
      media: (json['media'] as List<dynamic>?)
              ?.map((media) => GroupChatMediaModel.fromJson(media))
              .toList() ??
          [],
      groupChatLink: (json['group_chat_link'] as List<dynamic>?)
              ?.map((link) => GroupChatLinkModel.fromJson(link))
              .toList() ??
          [],
      surveyId: json['survey_id'],
      survey: json['survey'] as Map<String, dynamic>?,
      isPinned: isPinned,
    );
  }
}

class GroupChatMediaModel {
  final int id;
  final int groupId;
  final int groupChatId;
  final int userId;
  final String title;
  final String path;
  final String type;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  final String fullPath;
  final String fileSize;
  final String humanCreatedAt;

  GroupChatMediaModel({
    required this.id,
    required this.groupId,
    required this.groupChatId,
    required this.userId,
    required this.title,
    required this.path,
    required this.type,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.fullPath,
    required this.fileSize,
    required this.humanCreatedAt,
  });

  factory GroupChatMediaModel.fromJson(Map<String, dynamic> json) {
    return GroupChatMediaModel(
      id: json['id'] ?? 0,
      groupId: json['group_id'] ?? 0,
      groupChatId: json['group_chat_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      path: json['path'] ?? '',
      type: json['type'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      fullPath: json['full_path'] ?? '',
      fileSize: json['file_size'] ?? '',
      humanCreatedAt: json['human_created_at'] ?? '',
    );
  }
}

class GroupChatLinkModel {
  final int id;
  final int groupId;
  final int groupChatId;
  final int userId;
  final String linkTitle;
  final String link;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  GroupChatLinkModel({
    required this.id,
    required this.groupId,
    required this.groupChatId,
    required this.userId,
    required this.linkTitle,
    required this.link,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupChatLinkModel.fromJson(Map<String, dynamic> json) {
    return GroupChatLinkModel(
      id: json['id'] ?? 0,
      groupId: json['group_id'] ?? 0,
      groupChatId: json['group_chat_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      linkTitle: json['link_title'] ?? '',
      link: json['link'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
} 