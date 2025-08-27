enum GroupMessageType { text, image, link, poll, document, textWithLinks, survey }

class GroupMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final GroupMessageType messageType;
  final DateTime timestamp;
  final bool isSentByMe;
  final List<String>? pollOptions;
  final String? additionalText;
  final String name;
  final String surname;
  final String username;
  final String profileImage;
  final List<String>? links;
  final List<String>? media; // Media dosyaları için
  final bool? isMultipleChoice;
  final int? surveyId;
  final List<int>? choiceIds;
  final Map<String, dynamic>? surveyData;
  final bool isPinned; // Pin durumu için field ekle


  GroupMessageModel({
    required this.id,
    required this.senderId,
    required this.name,
    required this.surname,
    required this.username,
    required this.profileImage,
    required this.receiverId,
    required this.content,
    required this.messageType,
    required this.timestamp,
    required this.isSentByMe,
    this.pollOptions,
    this.additionalText,
    this.links,
    this.media,
    this.isMultipleChoice,
    this.surveyId,
    this.choiceIds,
    this.surveyData,
    this.isPinned = false, // Default value for isPinned
  });

  // Create a copy with updated pin status
  GroupMessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    GroupMessageType? messageType,
    DateTime? timestamp,
    bool? isSentByMe,
    List<String>? pollOptions,
    String? additionalText,
    String? name,
    String? surname,
    String? username,
    String? profileImage,
    List<String>? links,
    List<String>? media,
    bool? isMultipleChoice,
    int? surveyId,
    List<int>? choiceIds,
    Map<String, dynamic>? surveyData,
    bool? isPinned,
  }) {
    return GroupMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      pollOptions: pollOptions ?? this.pollOptions,
      additionalText: additionalText ?? this.additionalText,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      links: links ?? this.links,
      media: media ?? this.media,
      isMultipleChoice: isMultipleChoice ?? this.isMultipleChoice,
      surveyId: surveyId ?? this.surveyId,
      choiceIds: choiceIds ?? this.choiceIds,
      surveyData: surveyData ?? this.surveyData,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  // Factory constructor to create GroupMessageModel from JSON
  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    // Determine message type
    GroupMessageType messageType = GroupMessageType.text;
    if (json['type'] == 'poll') {
      messageType = GroupMessageType.poll;
    } else if (json['type'] == 'survey') {
      messageType = GroupMessageType.survey;
    } else if (json['media'] != null && (json['media'] as List).isNotEmpty) {
      if (json['content']?.toString().isNotEmpty == true) {
        messageType = GroupMessageType.textWithLinks;
      } else {
        messageType = GroupMessageType.image;
      }
    } else if (json['links'] != null && (json['links'] as List).isNotEmpty) {
      messageType = GroupMessageType.link;
    } else if (json['document'] != null) {
      messageType = GroupMessageType.document;
    }

    // Parse timestamp
    final timestamp = json['created_at'] != null 
        ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
        : DateTime.now();

    // Parse poll options
    List<String>? pollOptions;
    if (json['poll_options'] != null) {
      pollOptions = List<String>.from(json['poll_options']);
    }

    // Parse links
    List<String>? links;
    if (json['links'] != null) {
      links = List<String>.from(json['links']);
    }

    // Parse media
    List<String>? media;
    if (json['media'] != null) {
      media = List<String>.from(json['media']);
    }

    // Parse survey data
    Map<String, dynamic>? surveyData;
    if (json['survey'] != null) {
      surveyData = Map<String, dynamic>.from(json['survey']);
    }

    // Parse isPinned status
    final bool isPinned = json['is_pinned'] == true;


    return GroupMessageModel(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['group_id']?.toString() ?? '',
      content: json['content'] ?? json['message'] ?? '',
      messageType: messageType,
      timestamp: timestamp,
      isSentByMe: json['is_sent_by_me'] == true || json['is_me'] == true,
      pollOptions: pollOptions,
      additionalText: json['additional_text'],
      name: json['sender']?['name'] ?? json['name'] ?? '',
      surname: json['sender']?['surname'] ?? json['surname'] ?? '',
      username: json['sender']?['username'] ?? json['username'] ?? '',
      profileImage: json['sender']?['avatar_url'] ?? json['profile_image'] ?? '',
      links: links,
      media: media,
      isMultipleChoice: json['is_multiple_choice'],
      surveyId: json['survey_id'],
      choiceIds: json['choice_ids'] != null ? List<int>.from(json['choice_ids']) : null,
      surveyData: surveyData,
      isPinned: isPinned,
    );
  }
}
