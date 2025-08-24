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
  final bool? isMultipleChoice;
  final int? surveyId;
  final List<int>? choiceIds;
  final Map<String, dynamic>? surveyData;

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
    this.isMultipleChoice,
    this.surveyId,
    this.choiceIds,
    this.surveyData,
  });
}
