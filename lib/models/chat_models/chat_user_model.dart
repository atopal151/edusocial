class ChatUserModel {
  final int id;
  final String name;
  final String username;
  final String profileImage;
  final bool isOnline;

  ChatUserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.profileImage,
    this.isOnline = false,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ChatUserModel(
        id: 0,
        name: '',
        username: '',
        profileImage: '',
      );
    }
    return ChatUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      profileImage: json['avatar'] ?? '',
      isOnline: json['is_online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatar': profileImage,
      'is_online': isOnline,
    };
  }
}
