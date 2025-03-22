class UserModel {
  final int id;
  final String name;
  final String username;
  final String profileImage;
  final bool isOnline;

  UserModel( {
    required this.id,
    required this.name,
    required this.profileImage,
    required this.isOnline,required this.username,
  });
}

class ChatModel {
  final UserModel sender;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;

  ChatModel({
    required this.sender,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}
