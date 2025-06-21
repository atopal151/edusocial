import 'dart:async';

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

  final GetStorage _box = GetStorage();
  late SocketService _socketService;
  late StreamSubscription _privateMessageSubscription;
  late StreamSubscription _groupMessageSubscription;
  late StreamSubscription _unreadCountSubscription;
  
  @override
  void onInit() {
    super.onInit();
    _socketService = Get.find<SocketService>();
    _setupSocketListeners();
    fetchChatList();
    fetchOnlineFriends();
  }

  /// Socket bağlantısını kur
  void _connectSocket() {
    final token = _box.read('token');
    if (token != null && token.isNotEmpty) {
      _socketService.connect(token);
    }
  }

  /// Socket event dinleyicilerini ayarla
  void _setupSocketListeners() {
    _privateMessageSubscription = _socketService.onPrivateMessage.listen((data) {
      handleNewPrivateMessage(data);
    });

    _groupMessageSubscription = _socketService.onGroupMessage.listen((data) {
      handleNewGroupMessage(data);
    });

    _unreadCountSubscription = _socketService.onUnreadMessageCount.listen((data) {
      updateUnreadCount(data['count'] ?? 0);
    });
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

  /// 📥 Yeni birebir mesaj geldiğinde listeyi güncelle
  void handleNewPrivateMessage(dynamic data) {
    debugPrint("📡 Yeni birebir mesaj payload: $data");

    try {
      final conversationId = data['conversation_id'] ?? 0;
      final messageContent = data['message'] ?? '';
      final timestamp = data['created_at'] ?? '';

      final index =
          chatList.indexWhere((chat) => chat.conversationId == conversationId);
      if (index != -1) {
        // Var olan sohbeti güncelle
        final chat = chatList[index];
        
        // Son mesajı ve okunmamış sayısını güncelle
        chat.lastMessage = LastMessage(
          message: messageContent,
          createdAt: timestamp,
        );
        chat.unreadCount += 1;

        // Güncellenen sohbeti listenin en başına taşı
        chatList.removeAt(index);
        chatList.insert(0, chat);

      } else {
        // Yeni sohbet ekle
        final sender = data['sender'] ?? {};
        final newChat = ChatModel(
          id: sender['id'] ?? 0,
          name: sender['name'] ?? '',
          surname: sender['surname'] ?? '',
          username: sender['username'] ?? '',
          avatar: sender['avatar_url'] ?? '',
          conversationId: conversationId,
          isOnline: true, // Yeni mesaj geldiyse online kabul edilebilir
          unreadCount: 1,
          lastMessage: LastMessage(
            message: messageContent,
            createdAt: timestamp,
          ),
        );
        chatList.insert(0, newChat);
      }

      // Filtrelenmiş listeyi de güncelle
      filterChatList(searchController.text);

    } catch (e) {
      debugPrint("❌ Hata handleNewPrivateMessage: $e");
    }
  }

  /// 📥 Yeni grup mesajı geldiğinde listeyi güncelle
  void handleNewGroupMessage(dynamic data) {
    debugPrint("📡 Yeni grup mesajı payload: $data");
    
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

    // Filtrelenmiş listeyi de güncelle
    filterChatList(searchController.text);
  }

  /// 🔴 Okunmamış mesaj sayısını güncelle
  void updateUnreadCount(int count) {
    debugPrint("📬 Okunmamış mesaj sayısı: $count");
    // Burada genel okunmamış mesaj sayısını güncelleyebilirsin
    // Örneğin AppBar'da badge göstermek için
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

  @override
  void onClose() {
    _privateMessageSubscription.cancel();
    _groupMessageSubscription.cancel();
    _unreadCountSubscription.cancel();
    super.onClose();
  }
}
