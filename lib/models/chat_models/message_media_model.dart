class MessageMediaModel {
  final int id;
  final int userId;
  final int messageId;
  final int conversationId;
  final String path;
  final String type;
  final String fullPath;
  final String fileSize;
  final String humanCreatedAt;

  MessageMediaModel({
    required this.id,
    required this.userId,
    required this.messageId,
    required this.conversationId,
    required this.path,
    required this.type,
    required this.fullPath,
    required this.fileSize,
    required this.humanCreatedAt,
  });

  /// Dosya tipine göre görsel mi doküman mı olduğunu kontrol eder
  bool get isImage {
    return type.startsWith('image/');
  }

  /// Dosya tipine göre doküman olup olmadığını kontrol eder
  bool get isDocument {
    return type.startsWith('application/') || type.startsWith('text/');
  }

  /// PDF dosyası mı?
  bool get isPdf {
    return type == 'application/pdf';
  }

  /// Word dosyası mı?
  bool get isWord {
    return type == 'application/msword' || 
           type == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  }

  /// Text dosyası mı?
  bool get isText {
    return type == 'text/plain';
  }

  factory MessageMediaModel.fromJson(Map<String, dynamic> json) {
    return MessageMediaModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      messageId: json['message_id'] is int ? json['message_id'] : int.tryParse(json['message_id'].toString()) ?? 0,
      conversationId: json['conversation_id'] is int ? json['conversation_id'] : int.tryParse(json['conversation_id'].toString()) ?? 0,
      path: json['path'] ?? '',
      type: json['type'] ?? '',
      fullPath: json['full_path'] ?? '',
      fileSize: json['file_size'] ?? '',
      humanCreatedAt: json['human_created_at'] ?? '',
    );
  }
}
