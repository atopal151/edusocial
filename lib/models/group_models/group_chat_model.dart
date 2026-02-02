
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
  final String? replyId;
  final String? replyMessageText;
  final String? replyMessageSenderName;
  final bool replyHasImageMedia;
  final bool replyHasLinkMedia;

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
    this.isPinned = false,
    this.replyId,
    this.replyMessageText,
    this.replyMessageSenderName,
    this.replyHasImageMedia = false,
    this.replyHasLinkMedia = false,
  });

  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    final isPinned = json['is_pinned'] == true || (json['is_pinned'] is int && json['is_pinned'] == 1);

    String? replyId = json['reply_id']?.toString();
    String? replyMessageText;
    String? replyMessageSenderName;
    bool replyHasImageMedia = false;
    bool replyHasLinkMedia = false;
    final replyMessage = json['reply_message'] ?? json['reply'];
    if (replyMessage is Map<String, dynamic>) {
      replyMessageText = replyMessage['content']?.toString() ?? replyMessage['message']?.toString();
      final replySender = replyMessage['sender'] ?? replyMessage['user'];
      if (replySender is Map<String, dynamic>) {
        replyMessageSenderName = replySender['name']?.toString();
      }
      final replyMedia = replyMessage['media'] as List<dynamic>?;
      if (replyMedia != null && replyMedia.isNotEmpty) {
        replyHasImageMedia = true;
      }
      final replyLinks = replyMessage['links'] as List<dynamic>? ?? replyMessage['group_chat_link'] as List<dynamic>?;
      if (replyLinks != null && replyLinks.isNotEmpty) {
        replyHasLinkMedia = true;
      }
    }

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
      replyId: replyId,
      replyMessageText: replyMessageText,
      replyMessageSenderName: replyMessageSenderName,
      replyHasImageMedia: replyHasImageMedia,
      replyHasLinkMedia: replyHasLinkMedia,
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