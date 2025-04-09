import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/chat_model.dart';

class ChatController extends GetxController {
  var onlineFriends = <UserModel>[].obs;
  var chatList = <ChatModel>[].obs;
  var isLoading = false.obs;
  var filteredChatList = <ChatModel>[].obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchOnlineFriends();
    fetchChatList();
  }

  void getChatDetailPage() {
    Get.toNamed("/chat_detail");
  }

 void filterChatList(String value) {
    if (value.isEmpty) {
      filteredChatList.assignAll(chatList);
    } else {
      filteredChatList.value = chatList
          .where((chat) => chat.sender.name
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    }
  }



  /// **Online arkadaşları getir (Simüle veri)**
  void fetchOnlineFriends() {
    onlineFriends.assignAll([
      UserModel(
        id: 1,
        name: "Alexander Rybak",
        username: "@alexenderrybak",
        profileImage: "https://randomuser.me/api/portraits/men/1.jpg",
        isOnline: true,
      ),
      UserModel(
        id: 2,
        name: "Sophia Moore",
        username: "@sophiamoore",
        profileImage: "https://randomuser.me/api/portraits/women/2.jpg",
        isOnline: false,
      ),
      UserModel(
        id: 3,
        name: "Daniel Smith",
        username: "@danielsmith",
        profileImage: "https://randomuser.me/api/portraits/men/3.jpg",
        isOnline: true,
      ),
      UserModel(
        id: 2,
        name: "Sophia Moore",
        username: "@sophiamoore",
        profileImage: "https://randomuser.me/api/portraits/women/2.jpg",
        isOnline: false,
      ),
      UserModel(
        id: 3,
        name: "Daniel Smith",
        username: "@danielsmith",
        profileImage: "https://randomuser.me/api/portraits/men/3.jpg",
        isOnline: true,
      ),
      UserModel(
        id: 4,
        name: "Emma Johnson",
        username: "@emmajohnson",
        profileImage: "https://randomuser.me/api/portraits/women/4.jpg",
        isOnline: false,
      ),
    ]);
  }

  /// **Mesaj listesini getir (Simüle veri)**
  void fetchChatList() {
    chatList.assignAll([
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
          username: "@alexenderrybak",
          profileImage: "https://randomuser.me/api/portraits/women/2.jpg",
          isOnline: false,
        ),
        lastMessage: "Bugün okulda olan olayı duydunuz mu?",
        lastMessageTime: "22:45",
        unreadCount: 5,
      ),
      ChatModel(
        sender: UserModel(
          id: 3,
          name: "Daniel Smith",
          username: "@danielsmith",
          profileImage: "https://randomuser.me/api/portraits/men/3.jpg",
          isOnline: true,
        ),
        lastMessage: "Yarın buluşuyor muyuz?",
        lastMessageTime: "21:30",
        unreadCount: 0,
      ),
      ChatModel(
        sender: UserModel(
          id: 2,
          name: "Sophia Moore",
          username: "@sophiamoore",
          profileImage: "https://randomuser.me/api/portraits/women/2.jpg",
          isOnline: false,
        ),
        lastMessage: "Bugün okulda olan olayı duydunuz mu?",
        lastMessageTime: "22:45",
        unreadCount: 5,
      ),
      ChatModel(
        sender: UserModel(
          id: 3,
          name: "Daniel Smith",
          username: "@danielsmith",
          profileImage: "https://randomuser.me/api/portraits/men/3.jpg",
          isOnline: true,
        ),
        lastMessage: "Yarın buluşuyor muyuz?",
        lastMessageTime: "21:30",
        unreadCount: 0,
      ),
      ChatModel(
        sender: UserModel(
          id: 2,
          name: "Sophia Moore",
          username: "@sophiamoore",
          profileImage: "https://randomuser.me/api/portraits/women/2.jpg",
          isOnline: false,
        ),
        lastMessage: "Bugün okulda olan olayı duydunuz mu?",
        lastMessageTime: "22:45",
        unreadCount: 5,
      ),
      ChatModel(
        sender: UserModel(
          id: 3,
          name: "Daniel Smith",
          username: "@danielsmith",
          profileImage: "https://randomuser.me/api/portraits/men/3.jpg",
          isOnline: true,
        ),
        lastMessage: "Yarın buluşuyor muyuz?",
        lastMessageTime: "21:30",
        unreadCount: 0,
      ),
    ]);
    filteredChatList.assignAll(chatList);
  }
}
