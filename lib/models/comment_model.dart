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
      id: json['id'],
      content: json['content'] ?? '',
      userName: user['full_name'] ?? '',
      userAvatar: user['avatar'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
