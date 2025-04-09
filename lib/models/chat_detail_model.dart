

enum MessageType { text, image, link, poll }

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType messageType;
  final DateTime timestamp;
  final bool isSentByMe;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.messageType,
    required this.timestamp,
    required this.isSentByMe,
  });
}
