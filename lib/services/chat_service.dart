

import '../models/chat_model.dart';

class ChatServices {
  /// **Online arkadaş listesini API'den çekme (Simüle)**
  static Future<List<UserModel>> fetchOnlineFriends() async {
    await Future.delayed(Duration(seconds: 1)); // Simüle gecikme
    return [
      UserModel(
        id: 1,
        name: "Alexander Rybak",
        username: "@alexenderrybak",
        profileImage: "https://randomuser.me/api/portraits/men/1.jpg",
        isOnline: true,
      ),
      UserModel(
        id: 2,
        username: "@sophiemorre",
        name: "Sophia Moore",
        profileImage: "https://randomuser.me/api/portraits/women/2.jpg",
        isOnline: false,
      ),
    ];
  }

  /// **Mesaj listesini API'den çekme (Simüle)**
  static Future<List<ChatModel>> fetchChatList() async {
    await Future.delayed(Duration(seconds: 1)); // Simüle gecikme
    return [
      ChatModel(
        sender: UserModel(
          id: 1,
          name: "Alexander Rybak",
        username: "@alexenderrybak",
          profileImage: "https://randomuser.me/api/portraits/men/1.jpg",
          isOnline: true,
        ),
        lastMessage: "Geziciler Dostoyevski'yi İsviçre peyniri sanıyor",
        lastMessageTime: "23:08",
        unreadCount: 12,
      ),
      ChatModel(
        sender: UserModel(
          id: 2,
          name: "Sophia Moore",
        username: "@sophiemorre",
          profileImage: "https://randomuser.me/api/portraits/women/2.jpg",
          isOnline: false,
        ),
        lastMessage: "Bugün okulda olan olayı duydunuz mu?",
        lastMessageTime: "22:45",
        unreadCount: 5,
      ),
    ];
  }
}
