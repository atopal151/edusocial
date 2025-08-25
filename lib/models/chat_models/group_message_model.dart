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
  final bool isPinned; // New field for pin status

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
    this.isPinned = false, // Default to false
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
}
