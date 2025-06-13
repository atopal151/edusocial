class DetailMediaModel {
  final int id;
  final int userId;
  final int messageId;
  final int conversationId;
  final String type;
  final String fullPath;
  final String? fileSize;     // Opsiyonel çünkü bazı medya türlerinde olmayabilir
  final DateTime? createdAt;  // Tarihi parse edelim

  DetailMediaModel({
    required this.id,
    required this.userId,
    required this.messageId,
    required this.conversationId,
    required this.type,
    required this.fullPath,
    this.fileSize,
    this.createdAt,
  });

  factory DetailMediaModel.fromJson(Map<String, dynamic> json) {
    return DetailMediaModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      messageId: json['message_id'] is int ? json['message_id'] : int.tryParse(json['message_id'].toString()) ?? 0,
      conversationId: json['conversation_id'] is int ? json['conversation_id'] : int.tryParse(json['conversation_id'].toString()) ?? 0,
      type: json['type'] ?? '',
      fullPath: json['full_path'] ?? '',
      fileSize: json['file_size'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
