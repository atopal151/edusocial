class CommentModel {
  final int id;
  final String content;
  final String userName;
  final String userAvatar;
  final String createdAt;
  final int? parentId; // Yanıtlanan yorumun ID'si
  final List<CommentModel> replies; // Alt yorumlar
  final bool isReply; // Bu yorum bir yanıt mı?

  CommentModel({
    required this.id,
    required this.content,
    required this.userName,
    required this.userAvatar,
    required this.createdAt,
    this.parentId,
    this.replies = const [],
    this.isReply = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    
    // Alt yorumları parse et
    List<CommentModel> replies = [];
    if (json['replies'] != null && json['replies'] is List) {
      replies = (json['replies'] as List)
          .map((reply) => CommentModel.fromJson(reply))
          .toList();
    }
    
    return CommentModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      userName: user['username'] ?? '',
      userAvatar: user['avatar_url'] ?? '',
      createdAt: json['created_at'] ?? '',
      parentId: json['parent_id'],
      replies: replies,
      isReply: json['parent_id'] != null,
    );
  }

  @override
  String toString() {
    return 'Yorum(id: $id, user: $userName, content: $content, date: $createdAt, parentId: $parentId, replies: ${replies.length})';
  }
}
