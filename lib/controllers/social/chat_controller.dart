import 'package:edusocial/models/chat_models/chat_user_model.dart';
import 'package:edusocial/models/chat_models/last_message_model.dart';
import 'package:edusocial/services/chat_service.dart';
import 'package:edusocial/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/chat_models/chat_model.dart';
import '../../models/chat_models/group_chat_model.dart';

class ChatController extends GetxController {
  /// Observable veriler
  var onlineFriends = <ChatUserModel>[].obs;
  var chatList = <ChatModel>[].obs;
  var groupChatList = <GroupChatModel>[].obs;
  var filteredChatList = <ChatModel>[].obs;
  var filteredGroupChatList = <GroupChatModel>[].obs;
  var isLoading = false.obs;

  final TextEditingController searchController = TextEditingController();

  /// Socket servisi
  final SocketService socketService = Get.find<SocketService>();

  @override
  void onInit() {
    super.onInit();
    fetchChatList();
    fetchOnlineFriends();
    // Burada istersen API çağrıları yapılabilir.
  }

  /// 🔥 Online arkadaşları getir
  Future<void> fetchOnlineFriends() async {
    try {
      isLoading(true);
      final friends = await ChatServices.fetchOnlineFriends();
      onlineFriends.assignAll(friends);
    } catch (e) {
      debugPrint('Online arkadaşlar çekilirken hata: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchChatList() async {
    try {
      isLoading(true);
      final fetchedChats = await ChatServices.fetchChatList();

      // last_message alanı null olanları filtrele
      final filteredChats =
          fetchedChats.where((chat) => chat.lastMessage != null).toList();

      chatList.assignAll(filteredChats);
      filteredChatList.assignAll(filteredChats);
    } catch (e) {
      debugPrint('Chat listesi çekilirken hata: $e');
    } finally {
      isLoading(false);
    }
  }

  /// 🔌 Socket bağlantısını başlat
  void initSocketConnection(String token) {
    socketService.connectSocket(token);

    /// Birebir mesaj dinleyicisi
    socketService.onPrivateMessage((data) {
      handleNewPrivateMessage(data);
    });

    /// Grup mesajı dinleyicisi
    socketService.onGroupMessage((data) {
      handleNewGroupMessage(data);
    });

    /// Okunmamış mesaj sayısı dinleyicisi
    socketService.onUnreadMessageCount((data) {
      updateUnreadCount(data['count']);
    });
  }

  /// 🔌 Socket bağlantısını kapat
  void disconnectSocket() {
    socketService.disconnectSocket();
    socketService.removeAllListeners();
  }

  /// 📥 Yeni birebir mesaj geldiğinde listeyi güncelle
  void handleNewPrivateMessage(dynamic data) {
    debugPrint("📡 Yeni birebir mesaj payload: $data");

    try {
      final conversationId = data['conversation_id'] ?? 0;
      final message = data['message'] ?? '';
      final timestamp = data['created_at'] ?? '';

      final index =
          chatList.indexWhere((chat) => chat.conversationId == conversationId);
      if (index != -1) {
        // Var olan sohbeti güncelle
        chatList[index].lastMessage = LastMessage(
          message: message,
          createdAt: timestamp,
        );
        chatList[index].unreadCount += 1;
      } else {
        // Yeni sohbet ekle
        chatList.add(ChatModel(
          id: data['sender_id'] ?? 0,
          name: data['sender']['name'] ?? '',
          username: data['sender']['username'] ?? '',
          avatar: data['sender']['avatar_url'] ?? '',
          conversationId: conversationId,
          isOnline:
              true, // opsiyonel, backend'den çekilmiyorsa true/false atayabilirsin
          unreadCount: 1,
          lastMessage: LastMessage(
            message: message,
            createdAt: timestamp,
          ),
        ));
      }

      filteredChatList.assignAll(chatList);
    } catch (e) {
      debugPrint("❌ Hata handleNewPrivateMessage: $e");
    }
  }

  /// 📥 Yeni grup mesajı geldiğinde listeyi güncelle
  void handleNewGroupMessage(dynamic data) {
    final groupId = data['group_id'];
    final message = data['message'];
    final timestamp = data['created_at'];

    final index = groupChatList.indexWhere((group) => group.groupId == groupId);
    if (index != -1) {
      groupChatList[index].lastMessage = message;
      groupChatList[index].lastMessageTime = timestamp;
      groupChatList[index].unreadCount += 1;
    } else {
      groupChatList.add(GroupChatModel(
        groupId: groupId,
        groupName: data['group_name'] ?? 'Yeni Grup',
        groupImage: data['sender']['avatar_url'],
        lastMessage: message,
        lastMessageTime: timestamp,
        unreadCount: 1,
      ));
    }

    filteredGroupChatList.assignAll(groupChatList);
  }

  /// 🔴 Okunmamış mesaj sayısını güncelle
  void updateUnreadCount(int count) {
    for (var chat in chatList) {
      chat.unreadCount = count;
    }
    filteredChatList.assignAll(chatList);
  }

  /// 📃 Chat detay sayfasına yönlendir
  void getChatDetailPage(int conversationId) {
    Get.toNamed("/chat_detail", arguments: {
      'conversationId': conversationId, // int veya String olabilir
    });
  }

  void getGroupChatPage() {
    Get.toNamed("/group_chat_detail");
  }

  /// 🔍 Arama filtresi
  void filterChatList(String value) {
    if (value.isEmpty) {
      filteredChatList.assignAll(chatList);
      filteredGroupChatList.assignAll(groupChatList);
    } else {
      final query = value.toLowerCase();
      filteredChatList.value = chatList
          .where((chat) => chat.username.toLowerCase().contains(query))
          .toList();

      filteredGroupChatList.value = groupChatList
          .where((group) => group.groupName.toLowerCase().contains(query))
          .toList();
    }
  }
}
