class MessageLinkModel {
  final int id;
  final int conversationId;
  final int messageId;
  final int userId;
  final String linkTitle;
  final String link;

  MessageLinkModel({
    required this.id,
    required this.conversationId,
    required this.messageId,
    required this.userId,
    required this.linkTitle,
    required this.link,
  });

  factory MessageLinkModel.fromJson(Map<String, dynamic> json) {
    return MessageLinkModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      conversationId: json['conversation_id'] is int ? json['conversation_id'] : int.tryParse(json['conversation_id'].toString()) ?? 0,
      messageId: json['message_id'] is int ? json['message_id'] : int.tryParse(json['message_id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      linkTitle: json['link_title'] ?? '',
      link: json['link'] ?? '',
    );
  }
}
