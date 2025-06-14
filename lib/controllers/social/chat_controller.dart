import 'package:edusocial/models/chat_models/chat_user_model.dart';
import 'package:edusocial/models/chat_models/last_message_model.dart';
import 'package:edusocial/services/chat_service.dart';
import 'package:edusocial/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  final SocketService _socketService = Get.find<SocketService>();
  final GetStorage _box = GetStorage();
  @override
  void onInit() {
    super.onInit();
    fetchChatList();
    fetchOnlineFriends();

    // Token'ı GetStorage'dan al
    String? token = _box.read('token');

    if (token != null && token.isNotEmpty) {
      //debugPrint('🔑 Storage token bulundu: $token');
      _socketService.connectSocket(token);
    } else {
      debugPrint('⚠️ Storage token bulunamadı. Socket bağlanmadı.');
    }

    // Şimdi socket bağlantısını başlatalım:
    //initSocketConnection(token);
  }

  /// 🔥 Online arkadaşları getir
  Future<void> fetchOnlineFriends() async {
    try {
      isLoading(true);
      final friends = await ChatServices.fetchOnlineFriends();
      onlineFriends.assignAll(friends);
      //debugPrint('Online Arkadaşlar:$friends', wrapWidth: 1024);
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

      // last_message alanı null olanları filtrelemiyoruz
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

/*
  /// 🔌 Socket bağlantısını başlat
  void initSocketConnection(String token) {
    socketService.connectSocket(token);

    socketService.onPrivateMessage((data) {
      handleNewPrivateMessage(data);
      if (Get.isRegistered<ChatDetailController>()) {
        Get.find<ChatDetailController>().onNewPrivateMessage(data);
      }
    });

    socketService.onGroupMessage((data) {
      handleNewGroupMessage(data);
    });

    socketService.onUnreadMessageCount((data) {
      updateUnreadCount(data['count']);
    });
  }
  /// 🔌 Socket bağlantısını kapat
  void disconnectSocket() {
    socketService.disconnectSocket();
    socketService.removeAllListeners();
  }
*/
  /// 📥 Yeni birebir mesaj geldiğinde listeyi güncelle
  void handleNewPrivateMessage(dynamic data) {
    //debugPrint("📡 Yeni birebir mesaj payload: $data");

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
          surname: data['sender']['surname'] ?? '',
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
  void getChatDetailPage(int chatId,
      {required String name,
      required String username,
      required String avatarUrl,
      required bool isOnline}) {
    Get.toNamed('/chat_detail', arguments: {
      'chatId': chatId,
      'name': name,
      'username': username,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
    });
  }

  void getGroupChatPage(String groupId) {
    Get.toNamed("/group_chat_detail", arguments: {
      'groupId': groupId,
    });
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
