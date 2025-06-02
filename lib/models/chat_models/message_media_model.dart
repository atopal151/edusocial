class MessageMediaModel {
  final int id;
  final int userId;
  final int messageId;
  final int conversationId;
  final String path;

  MessageMediaModel({
    required this.id,
    required this.userId,
    required this.messageId,
    required this.conversationId,
    required this.path,
  });

  factory MessageMediaModel.fromJson(Map<String, dynamic> json) {
    return MessageMediaModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      messageId: json['message_id'] is int ? json['message_id'] : int.tryParse(json['message_id'].toString()) ?? 0,
      conversationId: json['conversation_id'] is int ? json['conversation_id'] : int.tryParse(json['conversation_id'].toString()) ?? 0,
      path: json['path'] ?? '',
    );
  }
}
