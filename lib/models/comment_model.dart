class CommentModel {
  final int id;
  final String content;
  final String userName;
  final String userAvatar;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.content,
    required this.userName,
    required this.userAvatar,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return CommentModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      userName: user['username'] ?? '',
      userAvatar: user['avatar_url'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Yorum(id: $id, user: $userName, content: $content, date: $createdAt)';
  }
}
