

enum MessageType { text, image, link, poll, document }

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType messageType;
  final DateTime timestamp;
  final bool isSentByMe;
  final List<String>? pollOptions; // ✅ Eklenen alan

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.messageType,
    required this.timestamp,
    required this.isSentByMe,
    this.pollOptions,
  });
}
