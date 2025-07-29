import 'dart:async';

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

  @override
  void onClose() {
    _privateMessageSubscription.cancel();
    _groupMessageSubscription.cancel();
    _unreadCountSubscription.cancel();
    searchController.dispose();
    super.onClose();
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

  /// Private message listener'ını duraklat (ChatDetailController aktifken)
  void pausePrivateMessageListener() {
    try {
      debugPrint('⏸️ PAUSE REQUEST: ChatController private message listener pause requested');
      debugPrint('⏸️ Current state: isPaused=${_privateMessageSubscription.isPaused}');
      
      if (!_privateMessageSubscription.isPaused) {
        _privateMessageSubscription.pause();
        debugPrint('⏸️ SUCCESS: ChatController private message listener paused');
      } else {
        debugPrint('⏸️ ALREADY PAUSED: ChatController private message listener was already paused');
      }
      
      // Verification
      debugPrint('⏸️ VERIFICATION: isPaused=${_privateMessageSubscription.isPaused}');
      
    } catch (e) {
      debugPrint('❌ PAUSE ERROR: Private message listener pause failed: $e');
    }
  }

  /// Private message listener'ını devam ettir
  void resumePrivateMessageListener() {
    try {
      debugPrint('▶️ RESUME REQUEST: ChatController private message listener resume requested');
      debugPrint('▶️ Current state: isPaused=${_privateMessageSubscription.isPaused}');
      
      if (_privateMessageSubscription.isPaused) {
        _privateMessageSubscription.resume();
        debugPrint('▶️ SUCCESS: ChatController private message listener resumed');
      } else {
        debugPrint('▶️ ALREADY ACTIVE: ChatController private message listener was already active');
      }
      
      // Verification  
      debugPrint('▶️ VERIFICATION: isPaused=${_privateMessageSubscription.isPaused}');
      
    } catch (e) {
      debugPrint('❌ RESUME ERROR: Private message listener resume failed: $e');
    }
  }

  /// Group message listener'ını duraklat
  void pauseGroupMessageListener() {
    try {
      debugPrint('⏸️ PAUSE REQUEST: ChatController group message listener pause requested');
      debugPrint('⏸️ Current state: isPaused=${_groupMessageSubscription.isPaused}');
      
      if (!_groupMessageSubscription.isPaused) {
        _groupMessageSubscription.pause();
        debugPrint('⏸️ SUCCESS: ChatController group message listener paused');
      } else {
        debugPrint('⏸️ ALREADY PAUSED: ChatController group message listener was already paused');
      }
      
      // Verification
      debugPrint('⏸️ VERIFICATION: isPaused=${_groupMessageSubscription.isPaused}');
      
    } catch (e) {
      debugPrint('❌ PAUSE ERROR: Group message listener pause failed: $e');
    }
  }

  /// Group message listener'ını devam ettir
  void resumeGroupMessageListener() {
    try {
      debugPrint('▶️ RESUME REQUEST: ChatController group message listener resume requested');
      debugPrint('▶️ Current state: isPaused=${_groupMessageSubscription.isPaused}');
      
      if (_groupMessageSubscription.isPaused) {
        _groupMessageSubscription.resume();
        debugPrint('▶️ SUCCESS: ChatController group message listener resumed');
      } else {
        debugPrint('▶️ ALREADY ACTIVE: ChatController group message listener was already active');
      }
      
      // Verification  
      debugPrint('▶️ VERIFICATION: isPaused=${_groupMessageSubscription.isPaused}');
      
    } catch (e) {
      debugPrint('❌ RESUME ERROR: Group message listener resume failed: $e');
    }
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
    debugPrint("📡 [ChatController] Yeni birebir mesaj payload alındı");
    debugPrint("📡 [ChatController] Listener State: isPaused=${_privateMessageSubscription.isPaused}");
    debugPrint("📡 [ChatController] Processing: $data");

    try {
      final conversationId = data['conversation_id'] ?? 0;
      final messageContent = data['message'] ?? '';
      final timestamp = data['created_at'] ?? '';
      
      // Socket'ten gelen is_me field'ını kontrol et (kendi mesajını unread count'a dahil etme)
      final isMyMessage = data['is_me'] == true;
      
      debugPrint("📡 [ChatController] Mesaj detayları: conversationId=$conversationId, isMyMessage=$isMyMessage");

      final index =
          chatList.indexWhere((chat) => chat.conversationId == conversationId);
      if (index != -1) {
        // Var olan sohbeti güncelle
        final chat = chatList[index];
        
        // Son mesajı güncelle
        chat.lastMessage = LastMessage(
          message: messageContent,
          createdAt: timestamp,
        );
        
        // Sadece başkasının mesajıysa unread count artır (API'den gelen değeri koru)
        if (!isMyMessage) {
          chat.unreadCount += 1;
          debugPrint("📬 [ChatController] Unread count artırıldı: ${chat.name} (${chat.unreadCount})");
        } else {
          debugPrint("📤 [ChatController] Kendi mesajım, unread count artırılmadı");
        }

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
          unreadCount: isMyMessage ? 0 : 1, // Kendi mesajıysa 0, değilse 1
          lastMessage: LastMessage(
            message: messageContent,
            createdAt: timestamp,
          ),
        );
        chatList.insert(0, newChat);
        debugPrint("📝 [ChatController] Yeni chat oluşturuldu: ${newChat.name} (unread: ${newChat.unreadCount})");
      }

      // Filtrelenmiş listeyi de güncelle
      filterChatList(searchController.text);
      
      debugPrint("✅ [ChatController] Mesaj işleme tamamlandı");

    } catch (e) {
      debugPrint("❌ [ChatController] Hata handleNewPrivateMessage: $e");
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

  /// 📃 Chat detay sayfasına git
  void getChatDetailPage({
    required int userId,
    int? conversationId,
    required String name,
    required String avatarUrl,
    required bool isOnline,
    required String username,
  }) async {
    // Chat açıldığında o chat'in unreadCount'unu sıfırla
    markChatAsRead(userId, conversationId);
    
    // Chat detail sayfasına git ve döndüğünde chat listesini yenile
    await Get.toNamed('/chat_detail', arguments: {
      'userId': userId,
      'conversationId': conversationId,
      'name': name,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'username': username,
    });
    
    // Chat detail sayfasından döndüğünde verileri yenile
    debugPrint("🔄 Chat detail sayfasından dönüldü, chat listesi yenileniyor...");
    await refreshAllChatData();
  }

  /// 📖 Chat'i okundu olarak işaretle (Local state'i güncelle)
  void markChatAsRead(int userId, int? conversationId) {
    try {
      // UserId veya conversationId ile chat bul
      int chatIndex = -1;
      
      if (conversationId != null) {
        // Önce conversationId ile bul
        chatIndex = chatList.indexWhere((chat) => chat.conversationId == conversationId);
      }
      
      if (chatIndex == -1) {
        // conversationId ile bulunamadıysa userId ile bul
        chatIndex = chatList.indexWhere((chat) => chat.id == userId);
      }
      
      if (chatIndex != -1) {
        final chat = chatList[chatIndex];
        if (chat.unreadCount > 0) {
          debugPrint("📖 Chat okundu olarak işaretleniyor: ${chat.name} (unread: ${chat.unreadCount} -> 0)");
          chat.unreadCount = 0;
          
          // Filtrelenmiş listeyi de güncelle
          final filteredIndex = filteredChatList.indexWhere((c) => c.id == chat.id);
          if (filteredIndex != -1) {
            filteredChatList[filteredIndex].unreadCount = 0;
          }
          
          // Observable'ları tetikle
          chatList.refresh();
          filteredChatList.refresh();
        }
      }
    } catch (e) {
      debugPrint("❌ markChatAsRead hatası: $e");
    }
  }

  void getGroupChatPage(String groupId) async {
    // Grup chat sayfasına git ve döndüğünde chat listesini yenile
    await Get.toNamed("/group_chat_detail", arguments: {
      'groupId': groupId,
    });
    
    // Grup chat sayfasından döndüğünde verileri yenile
    debugPrint("🔄 Grup chat sayfasından dönüldü, chat listesi yenileniyor...");
    await refreshAllChatData();
  }

  /// 🔄 Tüm chat verilerini yenile
  Future<void> refreshAllChatData() async {
    try {
      await Future.wait([
        fetchChatList(),
        fetchOnlineFriends(),
      ]);
      debugPrint("✅ Tüm chat verileri başarıyla yenilendi");
    } catch (e) {
      debugPrint("❌ Chat verileri yenileme hatası: $e");
    }
  }

  /// 🔍 Arama filtresi - Hem people hem de groups için
  void filterChatList(String value) {
    if (value.isEmpty) {
      filteredChatList.assignAll(chatList);
      filteredGroupChatList.assignAll(groupChatList);
    } else {
      final query = value.toLowerCase();
      
      // People listesi için filtreleme
      filteredChatList.value = chatList
          .where((chat) => 
              chat.username.toLowerCase().contains(query) ||
              chat.name.toLowerCase().contains(query))
          .toList();

      // Groups listesi için filtreleme
      filteredGroupChatList.value = groupChatList
          .where((group) => 
              group.groupName.toLowerCase().contains(query) ||
              group.lastMessage.toLowerCase().contains(query))
          .toList();
    }
  }

  /// 📊 Toplam okunmamış mesaj sayısını hesapla
  int get totalUnreadCount {
    int privateChatUnread = chatList.fold(0, (sum, chat) => sum + chat.unreadCount);
    int groupChatUnread = groupChatList.fold(0, (sum, group) => sum + group.unreadCount);
    return privateChatUnread + groupChatUnread;
  }

  /// 📊 Kişisel mesajların toplam okunmamış sayısını hesapla (API'den gelen değerlere göre)
  int get privateUnreadCount {
    return chatList.fold(0, (sum, chat) => sum + chat.unreadCount);
  }
}
