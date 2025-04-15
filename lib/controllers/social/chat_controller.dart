import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/chat_model.dart';
import '../../models/group_chat_model.dart';

class ChatController extends GetxController {
  var onlineFriends = <UserModel>[].obs;
  var chatList = <ChatModel>[].obs;
  var groupChatList = <GroupChatModel>[].obs; // ✅ Grup mesajları listesi
  var isLoading = false.obs;
  var filteredChatList = <ChatModel>[].obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchOnlineFriends();
    fetchChatList();
    fetchGroupChats(); // ✅ Grup verilerini getir
  }

  void getChatDetailPage() {
    Get.toNamed("/chat_detail");
  }

  void getGroupChatPage() {
    Get.toNamed("/group_chat_detail");
  }

  /// ✅ Arama filtresi sadece bireysel sohbetlerde uygulanıyor
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

  /// ✅ Online arkadaşlar (simülasyon)
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
        id: 4,
        name: "Emma Johnson",
        username: "@emmajohnson",
        profileImage: "https://randomuser.me/api/portraits/women/4.jpg",
        isOnline: false,
      ),
    ]);
  }

  /// ✅ Kişisel mesajlar (simülasyon)
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
          username: "@sophiamoore",
          profileImage: "https://randomuser.me/api/portraits/women/2.jpg",
          isOnline: false,
        ),
        lastMessage: "Bugün okulda olan olayı duydunuz mu?",
        lastMessageTime: "22:45",
        unreadCount: 5,
      ),
    ]);
    filteredChatList.assignAll(chatList);
  }

  /// ✅ Grup mesajları (simülasyon)
  void fetchGroupChats() {
    groupChatList.assignAll([
      GroupChatModel(
        groupName: "Flutter Öğrencileri",
        groupImage: "https://cdn-icons-png.flaticon.com/512/194/194938.png",
        lastMessage: "Yeni bir ödev konusu paylaştım, kontrol edebilirsiniz.",
        lastMessageTime: "20:45",
        unreadCount: 3,
      ),
      GroupChatModel(
        groupName: "Kitap Kulübü",
        groupImage: "https://cdn-icons-png.flaticon.com/512/616/616408.png",
        lastMessage: "Bir sonraki kitap: 'Körlük' - Jose Saramago",
        lastMessageTime: "19:30",
        unreadCount: 0,
      ),
      GroupChatModel(
        groupName: "CS50 Türkiye",
        groupImage: "https://cdn-icons-png.flaticon.com/512/1010/1010046.png",
        lastMessage: "Cuma günü Zoom'da mini hackathon var, katılan?",
        lastMessageTime: "17:10",
        unreadCount: 6,
      ),
    ]);
  }
}
