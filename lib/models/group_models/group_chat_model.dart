class GroupChatModel {
  final String groupName;
  final String groupImage;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;

  GroupChatModel({
    required this.groupName,
    required this.groupImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}
