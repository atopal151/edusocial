import 'dart:async';

import 'package:edusocial/models/chat_models/chat_user_model.dart';
import 'package:edusocial/models/chat_models/last_message_model.dart';
import 'package:edusocial/services/chat_service.dart';
import 'package:edusocial/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/chat_models/chat_model.dart';
import '../../models/chat_models/group_chat_model.dart';
import '../group_controller/group_controller.dart';

class ChatController extends GetxController with WidgetsBindingObserver {
  /// Observable veriler
  var onlineFriends = <ChatUserModel>[].obs;
  var chatList = <ChatModel>[].obs;
  var groupChatList = <GroupChatModel>[].obs;
  var filteredChatList = <ChatModel>[].obs;
  var filteredGroupChatList = <GroupChatModel>[].obs;
  var isLoading = false.obs;
  
  // Socket'ten gelen toplam okunmamış mesaj sayısı
  var totalUnreadCount = 0.obs;

  final TextEditingController searchController = TextEditingController();

  late SocketService _socketService;
  late StreamSubscription _privateMessageSubscription;
  late StreamSubscription _groupMessageSubscription;
  late StreamSubscription _unreadCountSubscription;
  
  // Kalıcı kırmızı nokta durumları
  var unreadConversationIds = <int>[].obs;
  var unreadGroupIds = <int>[].obs; // Grup mesajları için kalıcı kırmızı nokta durumları
  
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    
    // Socket service'i initialize et
    _socketService = Get.find<SocketService>();
    
    // Kalıcı kırmızı nokta durumlarını yükle
    _loadPersistentUnreadStatus();
    
    _setupSocketListeners();
    
    // Uygulama başlatıldığında chat ve grup listelerini çek
    fetchChatList();
    fetchGroupList();
    fetchOnlineFriends();
    
    // Socket bağlantısı hazır olduğunda conversation bazında unread count iste
    Future.delayed(Duration(seconds: 2), () {
      _requestConversationUnreadCounts();
      
      // Toplam unread count'u da iste
      if (_socketService.isConnected.value) {
        _socketService.sendMessage('get:unread_count', {});
      }
    });
    
    // 5 saniye sonra tekrar kontrol et
    Future.delayed(Duration(seconds: 5), () {
      _requestConversationUnreadCounts();
      if (_socketService.isConnected.value) {
        _socketService.sendMessage('get:unread_count', {});
      }
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
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

    _groupMessageSubscription = _socketService.onGroupMessage.listen((data) async {
      await handleNewGroupMessage(data);
    });

    _unreadCountSubscription = _socketService.onUnreadMessageCount.listen((data) async {
      await updateUnreadCount(data);
    });

    // Conversation bazında unread count dinleyicisi
    _socketService.onPerChatUnreadCount.listen((data) {
      handleConversationUnreadCount(data);
    });
    
    // Grup bazında unread count dinleyicisi
    _socketService.onPerChatUnreadCount.listen((data) {
      handleGroupUnreadCountFromSocket(data);
    });
    
    debugPrint("✅ [ChatController] Tüm socket dinleyicileri ayarlandı");
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
        debugPrint('▶️ ALREADY RESUMED: ChatController private message listener was already active');
      }
      
      // Verification  
      debugPrint('▶️ VERIFICATION: isPaused=${_privateMessageSubscription.isPaused}');
      
    } catch (e) {
      debugPrint('❌ RESUME ERROR: Private message listener resume failed: $e');
    }
  }

  /// Group message listener'ını duraklat (Artık kullanılmıyor - sürekli aktif)
  void pauseGroupMessageListener() {
    debugPrint('⚠️ Group message listener artık duraklatılmıyor - sürekli aktif');
  }

  /// Group message listener'ını devam ettir (Artık kullanılmıyor - sürekli aktif)
  void resumeGroupMessageListener() {
    debugPrint('⚠️ Group message listener artık devam ettirilmiyor - sürekli aktif');
  }

  /// 🔥 Online arkadaşları getir (is_recent alanına göre filtrele)
  Future<void> fetchOnlineFriends() async {
    try {
      final friends = await ChatServices.fetchOnlineFriends();
      
      // is_recent alanına göre filtrele - sadece son aktif olanları göster
      final recentFriends = friends.where((friend) => friend.isRecent == true).toList();
      
      onlineFriends.assignAll(recentFriends);
      debugPrint('✅ Online arkadaşlar filtrelendi: ${friends.length} -> ${recentFriends.length}');
    } catch (e) {
      debugPrint('❌ Online arkadaşlar çekilirken hata: $e');
    } finally {
      // isLoading(false); // Removed as per new_code
    }
  }

  /// 🔥 Grup listesini getir ve ChatController'daki groupChatList ile senkronize et
  Future<void> fetchGroupList() async {
    try {
      debugPrint("🔄 ChatController.fetchGroupList() çağrıldı");
      
      // GroupController'dan grup listesini al
      final groupController = Get.find<GroupController>();
      await groupController.fetchUserGroups();
      
      debugPrint("📊 GroupController'dan alınan grup sayısı: ${groupController.userGroups.length}");
      
      // GroupController'daki userGroups'u ChatController'daki groupChatList ile senkronize et
      for (final userGroup in groupController.userGroups) {
        final chatGroupIndex = groupChatList.indexWhere((g) => g.groupId == int.parse(userGroup.id));
        
        debugPrint("🔄 Grup işleniyor: ${userGroup.name} (ID: ${userGroup.id})");
        
        if (chatGroupIndex != -1) {
          // ChatController'daki grubu güncelle
          final chatGroup = groupChatList[chatGroupIndex];
          chatGroup.groupName = userGroup.name;
          chatGroup.lastMessage = userGroup.description; // Geçici olarak description kullan
          chatGroup.lastMessageTime = userGroup.humanCreatedAt;
          
          debugPrint("🔄 Grup güncellendi: ${userGroup.name} (ID: ${userGroup.id})");
        } else {
          // Yeni grup ekle
          final newChatGroup = GroupChatModel(
            groupId: int.parse(userGroup.id),
            groupName: userGroup.name,
            groupImage: userGroup.avatarUrl,
            lastMessage: userGroup.description,
            lastMessageTime: userGroup.humanCreatedAt,
            hasUnreadMessages: false, // Başlangıçta false
          );
          
          groupChatList.add(newChatGroup);
          debugPrint("🔄 Yeni grup eklendi: ${userGroup.name} (ID: ${userGroup.id})");
        }
      }
      
      // Filtrelenmiş listeyi de güncelle
      filteredGroupChatList.assignAll(groupChatList);
      
      // Kalıcı kırmızı nokta durumlarını uygula
      _updateGroupListUnreadStatus();
      
    } catch (e) {
      debugPrint('❌ Grup listesi çekilirken hata: $e');
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

      // Kalıcı kırmızı nokta durumlarını uygula
      _updateChatListUnreadStatus();

      debugPrint("✅ Chat listesi güncellendi. Toplam: ${chatList.length} sohbet");
    } catch (e) {
      debugPrint('❌ Chat listesi çekilirken hata: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Chat listesini yenile (mesaj gönderildikten sonra çağrılır)
  Future<void> refreshChatList() async {
    debugPrint("🔄 Chat listesi yenileniyor...");
    await fetchChatList();
  }

  /// 📥 Yeni birebir mesaj geldiğinde listeyi güncelle
  Future<void> handleNewPrivateMessage(dynamic data) async {
    try {

      final conversationId = data['conversation_id'];
      final messageContent = data['message'] ?? '';
      final timestamp = data['created_at'] ?? '';
      final isRead = data['is_read'] ?? false;
      
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

        // Socket'ten gelen is_read bilgisine göre kalıcı kırmızı nokta durumunu ayarla
        if (!isRead) {
          // Okunmamış mesaj - kalıcı kırmızı nokta ekle
          if (!unreadConversationIds.contains(conversationId)) {
            unreadConversationIds.add(conversationId);
            await ChatServices.markConversationAsUnread(conversationId);
            
            // Toplam unread count'u güncelle (1 artır)
            final newTotalCount = totalUnreadCount.value + 1;
            totalUnreadCount.value = newTotalCount;
            await ChatServices.saveTotalUnreadCount(newTotalCount);
            debugPrint("📊 Toplam unread count artırıldı: ${totalUnreadCount.value} -> $newTotalCount");
          }
          chat.hasUnreadMessages = true;
          debugPrint("🔴 [ChatController] KALICI KIRMIZI NOKTA EKLENDİ: ${chat.name} (conversation: $conversationId)");
        } else {
          // Okunmuş mesaj - kalıcı kırmızı nokta kaldır
          if (unreadConversationIds.contains(conversationId)) {
            unreadConversationIds.remove(conversationId);
            await ChatServices.markConversationAsRead(conversationId);
            
            // Toplam unread count'u güncelle (1 azalt)
            final newTotalCount = (totalUnreadCount.value - 1).clamp(0, double.infinity).toInt();
            totalUnreadCount.value = newTotalCount;
            await ChatServices.saveTotalUnreadCount(newTotalCount);
            debugPrint("📊 Toplam unread count azaltıldı: ${totalUnreadCount.value} -> $newTotalCount");
          }
          chat.hasUnreadMessages = false;
          debugPrint("⚪ [ChatController] KALICI KIRMIZI NOKTA KALDIRILDI: ${chat.name} (conversation: $conversationId)");
        }
        
        // Her mesaj işleminden sonra count'ları doğrula
        await _validateAndFixUnreadCount();

        // Güncellenen sohbeti listenin en başına taşı
        chatList.removeAt(index);
        chatList.insert(0, chat);

        // Filtrelenmiş listeyi de güncelle
        final filteredIndex = filteredChatList.indexWhere((c) => c.conversationId == conversationId);
        if (filteredIndex != -1) {
          final filteredChat = filteredChatList[filteredIndex];
          filteredChat.lastMessage = chat.lastMessage;
          filteredChat.hasUnreadMessages = chat.hasUnreadMessages;
          filteredChatList.removeAt(filteredIndex);
          filteredChatList.insert(0, filteredChat);
        }

        // Observable'ları tetikle
        chatList.refresh();
        filteredChatList.refresh();

      } else {
        // Yeni sohbet ekle - bu durumda API'den chat listesini yeniden çek
        debugPrint("📡 [ChatController] Yeni conversation bulundu, chat listesi yenileniyor...");
        fetchChatList();
      }

      debugPrint("✅ [ChatController] Mesaj işleme tamamlandı");
    } catch (e) {
      debugPrint("❌ [ChatController] Mesaj işleme hatası: $e");
    }
  }

  /// 📥 Yeni grup mesajı geldiğinde listeyi güncelle (private chat'teki gibi)
  Future<void> handleNewGroupMessage(dynamic data) async {
    try {
      debugPrint("📡 [ChatController] Yeni grup mesajı geldi: $data");
      
      // Grup mesajı nested yapıda geliyor, message alanından al
      dynamic messageData = data;
      if (data.containsKey('message') && data['message'] is Map<String, dynamic>) {
        messageData = data['message'];
        debugPrint("📡 [ChatController] Nested message yapısı tespit edildi");
      }
      
      final groupId = messageData['group_id'];
      final messageContent = messageData['message'] ?? '';
      final timestamp = messageData['created_at'] ?? '';
      final isRead = messageData['is_read'] ?? false;
      
      debugPrint("📡 [ChatController] Group ID: $groupId, isRead: $isRead");

      final index = groupChatList.indexWhere((group) => group.groupId == groupId);
      
      if (index != -1) {
        // Var olan grubu güncelle
        final group = groupChatList[index];
        
        // Son mesajı güncelle
        group.lastMessage = messageContent;
        group.lastMessageTime = timestamp;

        // Socket'ten gelen is_read bilgisine göre kalıcı kırmızı nokta durumunu ayarla
        if (!isRead) {
          // Okunmamış mesaj - kalıcı kırmızı nokta ekle
          if (!unreadGroupIds.contains(groupId)) {
            unreadGroupIds.add(groupId);
            await ChatServices.markGroupAsUnread(groupId);
            
            // Toplam unread count'u güncelle (1 artır)
            final newTotalCount = totalUnreadCount.value + 1;
            totalUnreadCount.value = newTotalCount;
            await ChatServices.saveTotalUnreadCount(newTotalCount);
            debugPrint("📊 Toplam unread count artırıldı: ${totalUnreadCount.value} -> $newTotalCount");
          }
          group.hasUnreadMessages = true;
          debugPrint("🔴 [ChatController] GRUP KALICI KIRMIZI NOKTA EKLENDİ: ${group.groupName} (group: $groupId)");
        } else {
          // Okunmuş mesaj - kalıcı kırmızı nokta kaldır
          if (unreadGroupIds.contains(groupId)) {
            unreadGroupIds.remove(groupId);
            await ChatServices.markGroupAsRead(groupId);
            
            // Toplam unread count'u güncelle (1 azalt)
            final newTotalCount = (totalUnreadCount.value - 1).clamp(0, double.infinity).toInt();
            totalUnreadCount.value = newTotalCount;
            await ChatServices.saveTotalUnreadCount(newTotalCount);
            debugPrint("📊 Toplam unread count azaltıldı: ${totalUnreadCount.value} -> $newTotalCount");
          }
          group.hasUnreadMessages = false;
          debugPrint("⚪ [ChatController] GRUP KALICI KIRMIZI NOKTA KALDIRILDI: ${group.groupName} (group: $groupId)");
        }
        
        // Her mesaj işleminden sonra count'ları doğrula
        await _validateAndFixUnreadCount();

        // Güncellenen grubu listenin en başına taşı
        groupChatList.removeAt(index);
        groupChatList.insert(0, group);
      
        // Filtrelenmiş listeyi de güncelle
        final filteredIndex = filteredGroupChatList.indexWhere((g) => g.groupId == groupId);
        if (filteredIndex != -1) {
          final filteredGroup = filteredGroupChatList[filteredIndex];
          filteredGroup.lastMessage = group.lastMessage;
          filteredGroup.lastMessageTime = group.lastMessageTime;
          filteredGroup.hasUnreadMessages = group.hasUnreadMessages;
          filteredGroupChatList.removeAt(filteredIndex);
          filteredGroupChatList.insert(0, filteredGroup);
        }
      
        // Observable'ları tetikle
        groupChatList.refresh();
        filteredGroupChatList.refresh();

      } else {
        // Yeni grup ekle - bu durumda API'den grup listesini yeniden çek
        debugPrint("📡 [ChatController] Yeni grup bulundu, grup listesi yenileniyor...");
        await fetchGroupList(); // Grup listesini yenile
      }

      debugPrint("✅ [ChatController] Grup mesaj işleme tamamlandı");
    } catch (e) {
      debugPrint("❌ [ChatController] Grup mesaj işleme hatası: $e");
    }
  }

  /// 🔴 Socket'ten gelen toplam okunmamış mesaj sayısını güncelle
  Future<void> updateUnreadCount(dynamic data) async {
    debugPrint("📬 Socket'ten gelen toplam okunmamış mesaj verisi: $data");
    
    int count = 0;
    
    if (data is Map<String, dynamic>) {
      // Farklı key'leri kontrol et
      count = data['count'] ?? 
              data['total'] ?? 
              data['unread'] ?? 
              data['message_count'] ?? 
              data['conversation_count'] ?? 0;
    } else if (data is int) {
      count = data;
    } else {
      debugPrint("⚠️ Beklenmeyen data tipi: ${data.runtimeType}");
      return;
    }
    
    totalUnreadCount.value = count;
    
    // Kalıcı olarak kaydet
    await ChatServices.saveTotalUnreadCount(count);
    
    // Count'u doğrula ve düzelt
    await _validateAndFixUnreadCount();
  }

  /// 📃 Chat detay sayfasına git
  void getChatDetailPage({
    required int userId,
    int? conversationId,
    required String name,
    required String avatarUrl,
    required bool isOnline,
    required String username,
    bool? isVerified,
  }) async {
    // Chat açıldığında o chat'in hasUnreadMessages'ını false yap
    await markChatAsRead(userId, conversationId);
    
    // Chat detail sayfasına git
    await Get.toNamed('/chat_detail', arguments: {
      'userId': userId,
      'conversationId': conversationId,
      'name': name,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'username': username,
      'isVerified': isVerified,
    });
    
    // Chat detail sayfasından döndüğünde socket'ten güncel unread count'u kontrol et
    debugPrint("🔄 Chat detail sayfasından dönüldü, socket'ten güncel unread count kontrol ediliyor...");
    await _checkAndUpdateUnreadCountAfterChat();
  }

  /// 📖 Chat'i okundu olarak işaretle (Local state'i güncelle)
  Future<void> markChatAsRead(int userId, int? conversationId) async {
    try {
      debugPrint("📖 markChatAsRead çağrıldı: userId=$userId, conversationId=$conversationId");
      
      // Conversation ID varsa onu kullan, yoksa user ID ile bul
      int? targetConversationId = conversationId;
      
      if (targetConversationId == null) {
        // User ID ile conversation'ı bul
        final chat = chatList.firstWhereOrNull((chat) => chat.id == userId);
        if (chat != null) {
          targetConversationId = chat.conversationId;
        }
      }
      
      if (targetConversationId == null) {
        debugPrint("⚠️ markChatAsRead: Conversation ID bulunamadı");
        return;
      }
      
      // Kalıcı kırmızı nokta durumunu güncelle
      if (unreadConversationIds.contains(targetConversationId)) {
        unreadConversationIds.remove(targetConversationId);
        await ChatServices.markConversationAsRead(targetConversationId);
        debugPrint("✅ [ChatController] KALICI KIRMIZI NOKTA KALDIRILDI: conversation $targetConversationId");
        
        // Toplam unread count'u güncelle (1 azalt)
        final newTotalCount = (totalUnreadCount.value - 1).clamp(0, double.infinity).toInt();
        totalUnreadCount.value = newTotalCount;
        await ChatServices.saveTotalUnreadCount(newTotalCount);
        debugPrint("📊 Toplam unread count güncellendi: ${totalUnreadCount.value} -> $newTotalCount");
      }
      
      // Chat'i bul ve hasUnreadMessages'ı false yap
      final chatIndex = chatList.indexWhere((chat) => chat.conversationId == targetConversationId);
      if (chatIndex != -1) {
        final chat = chatList[chatIndex];
        if (chat.hasUnreadMessages) {
          chat.hasUnreadMessages = false;
          debugPrint("📖 Chat okundu olarak işaretlendi: ${chat.name}");
          
          // Filtrelenmiş listeyi de güncelle
          final filteredIndex = filteredChatList.indexWhere((c) => c.conversationId == targetConversationId);
          if (filteredIndex != -1) {
            filteredChatList[filteredIndex].hasUnreadMessages = false;
          }
          
          // Observable'ları tetikle
          chatList.refresh();
          filteredChatList.refresh();
        }
      }
      
      debugPrint("📖 Chat okundu olarak işaretlendi: conversationId=$targetConversationId");
    } catch (e) {
      debugPrint("❌ markChatAsRead hatası: $e");
    }
  }

  void getGroupChatPage(String groupId) async {
    // Grup chat sayfasına git ve döndüğünde chat listesini yenile
    await Get.toNamed("/group_chat_detail", arguments: {
      'groupId': groupId,
    });
    
    // Grup chat sayfasından döndüğünde grubu okunmuş olarak işaretle
    debugPrint("🔄 Grup chat sayfasından dönüldü, grup okunmuş olarak işaretleniyor...");
    await _markGroupAsRead(groupId);
    await _checkAndUpdateUnreadCountAfterChat();
  }

  /// 🔄 Tüm chat verilerini yenile
  Future<void> refreshAllChatData() async {
    try {
      await Future.wait([
        fetchChatList(),
        fetchGroupList(),
        fetchOnlineFriends(),
      ]);
      debugPrint("✅ Chat verileri yenilendi");
    } catch (e) {
      debugPrint("❌ Chat verileri yenileme hatası: $e");
    }
  }

  /// 🔄 Chat listesini ve unread count'ları tamamen yenile
  Future<void> refreshChatListAndUnreadCounts() async {
    try {
      debugPrint("🔄 Chat listesi ve unread count'lar yenileniyor...");
      
      // Chat ve grup listelerini yenile
      await fetchChatList();
      await fetchGroupList();
      
      // Mevcut unread conversation'ları kontrol et
      debugPrint("🔍 Mevcut unread conversation'lar kontrol ediliyor...");
      debugPrint("🔍 Unread conversation ID'leri: $unreadConversationIds");
      
      // Eğer hiç unread conversation yoksa ama total count > 0 ise, count'u sıfırla
      if (unreadConversationIds.isEmpty && totalUnreadCount.value > 0) {
        debugPrint("⚠️ Unread conversation yok ama total count > 0, count sıfırlanıyor...");
        totalUnreadCount.value = 0;
        await ChatServices.saveTotalUnreadCount(0);
        debugPrint("✅ Total unread count sıfırlandı");
      }
      
      // Socket'ten güncel unread count'ları iste
      if (_socketService.isConnected.value) {
        debugPrint("📤 Socket'ten güncel unread count isteniyor...");
        
        // Toplam unread count'u iste
        _socketService.sendMessage('get:unread_count', {});
        
        // Conversation bazında unread count'ları iste
        _requestConversationUnreadCounts();
        
        // 3 saniye bekle ve tekrar iste (socket gecikmeli olabilir)
        await Future.delayed(Duration(seconds: 3));
        _socketService.sendMessage('get:unread_count', {});
        _socketService.sendMessage('get:conversation_unread_counts', {});
        
        // 5 saniye daha bekle ve son kez iste
        await Future.delayed(Duration(seconds: 2));
        _socketService.sendMessage('get:unread_count', {});
        
        // Son kontrol: Eğer hala uyumsuzluk varsa düzelt
        await Future.delayed(Duration(seconds: 2));
        _validateAndFixUnreadCount();
      }
      
      debugPrint("✅ Chat listesi ve unread count'lar yenilendi");
    } catch (e) {
      debugPrint("❌ Chat listesi ve unread count yenileme hatası: $e");
    }
  }


  /// 🔍 Socket count'u kontrol et ve gerekirse senkronize et
  void _checkAndSyncWithSocketCount() {
    try {
      debugPrint("🔍 Socket count kontrolü:");
      debugPrint("  - Socket bağlantı durumu: ${_socketService.isConnected.value}");
      
      // Socket bağlıysa, toplam unread count'u dinle
      if (_socketService.isConnected.value) {
        // Hemen socket count iste
        debugPrint("📤 Socket count isteniyor...");
        _socketService.sendMessage('get:unread_count', {});
        
        // 3 saniye sonra tekrar iste
        Future.delayed(Duration(seconds: 3), () {
          debugPrint("⏰ 3 saniye geçti, socket count tekrar isteniyor...");
          _socketService.sendMessage('get:unread_count', {});
        });
      } else {
        debugPrint("⚠️ Socket bağlı değil, sadece API'den chat listesi çekiliyor...");
      }
      
    } catch (e) {
      debugPrint("❌ Socket count kontrol hatası: $e");
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

  /// 📊 Kişisel mesajların toplam okunmamış sayısını hesapla (Socket'ten gelen değer)
  int get privateUnreadCount {
    return totalUnreadCount.value;
  }

  /// 📊 Grup mesajlarının toplam okunmamış sayısını hesapla
  int get groupUnreadCount {
    return groupChatList.where((group) => group.hasUnreadMessages).length;
  }

  /// 📊 Toplam okunmamış mesaj sayısını hesapla
  int get totalUnreadCountValue {
    int privateChatUnread = totalUnreadCount.value;
    int groupChatUnread = groupChatList.fold(0, (sum, group) => sum + group.unreadCount);
    return privateChatUnread + groupChatUnread;
  }

  /// 🔍 Conversation bazında unread count'ları iste
  void _requestConversationUnreadCounts() {
    try {
      debugPrint("🔍 Conversation bazında unread count'lar isteniyor...");
      
      if (_socketService.isConnected.value) {
        // Socket'ten conversation bazında unread count'ları iste
        _socketService.sendMessage('get:conversation_unread_counts', {});
        _socketService.sendMessage('request:per_chat_unread', {});
        _socketService.sendMessage('conversation:get_unread_details', {});
        _socketService.sendMessage('get:unread_count', {});
        
        // Grup bazında unread count'ları iste
        _socketService.sendMessage('get:group_unread_counts', {});
        _socketService.sendMessage('request:per_group_unread', {});
        _socketService.sendMessage('group:get_unread_details', {});
        _socketService.sendMessage('get:group_unread_count', {});
        
        debugPrint("✅ Conversation ve grup unread count istekleri gönderildi");
      } else {
        debugPrint("⚠️ Socket bağlı değil, conversation unread count istenemiyor");
      }
    } catch (e) {
      debugPrint("❌ Conversation unread count isteği hatası: $e");
    }
  }

  /// 📨 Conversation bazında unread count'ları handle et
  void handleConversationUnreadCount(dynamic data) {
    try {
      
      if (data is Map<String, dynamic>) {
        // Eğer data'da conversation_id ve unread_count varsa
        if (data.containsKey('conversation_id')) {
          final conversationId = data['conversation_id'];
          final unreadCount = data['unread_count'] ?? 
                              data['count'] ?? 
                              data['message_count'] ?? 0;
          
          
          // Chat'i bul ve hasUnreadMessages'ı ayarla
          final chatIndex = chatList.indexWhere((chat) => chat.conversationId == conversationId);
          if (chatIndex != -1) {
            final chat = chatList[chatIndex];
            chat.hasUnreadMessages = unreadCount > 0;
            
            // Filtrelenmiş listeyi de güncelle
            final filteredIndex = filteredChatList.indexWhere((c) => c.conversationId == conversationId);
            if (filteredIndex != -1) {
              filteredChatList[filteredIndex].hasUnreadMessages = unreadCount > 0;
            }
            
            // Observable'ları tetikle
            chatList.refresh();
            filteredChatList.refresh();
            
            debugPrint("✅ Conversation $conversationId unread count güncellendi: $unreadCount -> hasUnreadMessages: ${chat.hasUnreadMessages}");
          }
        }
        // Eğer data bir liste ise (birden fazla conversation'ın unread count'u)
        else if (data.containsKey('conversations') && data['conversations'] is List) {
          final conversations = data['conversations'] as List;
          debugPrint("📨 ${conversations.length} conversation'un unread count'u işleniyor...");
          
          for (final conv in conversations) {
            if (conv is Map<String, dynamic>) {
              final conversationId = conv['conversation_id'] ?? conv['id'];
              final unreadCount = conv['unread_count'] ?? 
                                  conv['count'] ?? 
                                  conv['message_count'] ?? 0;
              
              if (conversationId != null) {
                debugPrint("📨 Conversation $conversationId: $unreadCount unread");
                
                // Chat'i bul ve hasUnreadMessages'ı ayarla
                final chatIndex = chatList.indexWhere((chat) => chat.conversationId == conversationId);
                if (chatIndex != -1) {
                  final chat = chatList[chatIndex];
                  chat.hasUnreadMessages = unreadCount > 0;
                  
                  // Filtrelenmiş listeyi de güncelle
                  final filteredIndex = filteredChatList.indexWhere((c) => c.conversationId == conversationId);
                  if (filteredIndex != -1) {
                    filteredChatList[filteredIndex].hasUnreadMessages = unreadCount > 0;
                  }
                }
              }
            }
          }
          
          // Observable'ları tetikle
          chatList.refresh();
          filteredChatList.refresh();
          
          debugPrint("✅ ${conversations.length} conversation'un unread count'u güncellendi");
        }
      }
    } catch (e) {
      debugPrint("❌ Conversation unread count işleme hatası: $e");
    }
  }

  /// 🔍 Socket count'u kontrol et (public metod)
  void checkSocketCount() {
    debugPrint("🔍 Socket count kontrolü başlatılıyor...");
    _checkAndSyncWithSocketCount();
    
    // 3 saniye sonra tekrar kontrol et
    Future.delayed(Duration(seconds: 3), () {
      debugPrint("🔄 Socket count tekrar kontrol ediliyor...");
      _checkAndSyncWithSocketCount();
    });
  }

  /// 🔄 Chat'ten çıktıktan sonra socket'ten güncel unread count'u kontrol et
  Future<void> _checkAndUpdateUnreadCountAfterChat() async {
    try {
      debugPrint("🔄 Chat'ten çıktıktan sonra unread count kontrol ediliyor...");
      
      // Socket bağlıysa güncel unread count'u iste
      if (_socketService.isConnected.value) {
        debugPrint("📤 Socket'ten güncel unread count isteniyor...");
        
        // Toplam unread count'u iste
        _socketService.sendMessage('get:unread_count', {});
        
        // Conversation bazında unread count'ları da iste
        _requestConversationUnreadCounts();
        
        // 2 saniye bekle ve tekrar iste (socket gecikmeli olabilir)
        await Future.delayed(Duration(seconds: 2));
        _socketService.sendMessage('get:unread_count', {});
        
        // 5 saniye daha bekle ve son kez iste
        await Future.delayed(Duration(seconds: 3));
        _socketService.sendMessage('get:unread_count', {});
        
        debugPrint("✅ Chat'ten çıktıktan sonra unread count kontrolü tamamlandı");
      } else {
        debugPrint("⚠️ Socket bağlı değil, unread count kontrol edilemiyor");
      }
    } catch (e) {
      debugPrint("❌ Chat'ten çıktıktan sonra unread count kontrol hatası: $e");
    }
  }

  /// 🔍 Unread count'ları doğrula ve düzelt
  Future<void> _validateAndFixUnreadCount() async {
    try {
      debugPrint("🔍 Unread count'lar doğrulanıyor...");
      
      // Chat listesindeki unread conversation sayısını hesapla
      final actualUnreadCount = chatList.where((chat) => chat.hasUnreadMessages).length;
      final actualUnreadGroupCount = groupChatList.where((group) => group.hasUnreadMessages).length;
      final totalActualUnreadCount = actualUnreadCount + actualUnreadGroupCount;
      final storedUnreadCount = totalUnreadCount.value;
      
      // Eğer uyumsuzluk varsa düzelt
      if (totalActualUnreadCount != storedUnreadCount) {
        debugPrint("⚠️ Unread count uyumsuzluğu tespit edildi!");
        debugPrint("⚠️ Toplam unread: $totalActualUnreadCount, Stored: $storedUnreadCount");
        
        // Gerçek toplam sayıyı kullan
        totalUnreadCount.value = totalActualUnreadCount;
        await ChatServices.saveTotalUnreadCount(totalActualUnreadCount);
        
        debugPrint("✅ Unread count düzeltildi: $storedUnreadCount -> $totalActualUnreadCount");
      } else {
        debugPrint("✅ Unread count'lar uyumlu");
      }
      
      // Eğer hiç unread yoksa count'u sıfırla
      if (totalActualUnreadCount == 0 && storedUnreadCount > 0) {
        debugPrint("⚠️ Hiç unread yok ama count > 0, sıfırlanıyor...");
        totalUnreadCount.value = 0;
        await ChatServices.saveTotalUnreadCount(0);
        debugPrint("✅ Total unread count sıfırlandı");
      }
      
    } catch (e) {
      debugPrint("❌ Unread count doğrulama hatası: $e");
    }
  }

  /// 📖 Grubu okundu olarak işaretle
  Future<void> _markGroupAsRead(String groupId) async {
    try {
      final groupIdInt = int.tryParse(groupId);
      if (groupIdInt == null) {
        debugPrint("⚠️ _markGroupAsRead: Geçersiz group ID: $groupId");
        return;
      }
      
      debugPrint("📖 Grup okundu olarak işaretleniyor: $groupId");
      
      // Kalıcı kırmızı nokta durumunu güncelle
      if (unreadGroupIds.contains(groupIdInt)) {
        unreadGroupIds.remove(groupIdInt);
        await ChatServices.markGroupAsRead(groupIdInt);
        debugPrint("✅ [ChatController] GRUP KALICI KIRMIZI NOKTA KALDIRILDI: group $groupIdInt");
        
        // Toplam unread count'u güncelle (1 azalt)
        final newTotalCount = (totalUnreadCount.value - 1).clamp(0, double.infinity).toInt();
        totalUnreadCount.value = newTotalCount;
        await ChatServices.saveTotalUnreadCount(newTotalCount);
        debugPrint("📊 Toplam unread count güncellendi: ${totalUnreadCount.value} -> $newTotalCount");
      }
      
      // Grup listesindeki hasUnreadMessages'ı false yap
      final groupIndex = groupChatList.indexWhere((group) => group.groupId == groupIdInt);
      if (groupIndex != -1) {
        final group = groupChatList[groupIndex];
        if (group.hasUnreadMessages) {
          group.hasUnreadMessages = false;
          debugPrint("📖 Grup okundu olarak işaretlendi: ${group.groupName}");
          
          // Filtrelenmiş listeyi de güncelle
          final filteredIndex = filteredGroupChatList.indexWhere((g) => g.groupId == groupIdInt);
          if (filteredIndex != -1) {
            filteredGroupChatList[filteredIndex].hasUnreadMessages = false;
          }
          
          // Observable'ları tetikle
          groupChatList.refresh();
          filteredGroupChatList.refresh();
        }
      }
      
      debugPrint("📖 Grup okundu olarak işaretlendi: groupId=$groupId");
    } catch (e) {
      debugPrint("❌ Grup okundu işaretleme hatası: $e");
    }
  }

  /// 📂 Kalıcı kırmızı nokta durumlarını yükle
  Future<void> _loadPersistentUnreadStatus() async {
    try {
      debugPrint("📂 Kalıcı kırmızı nokta durumları yükleniyor...");
      
      // Private chat'ler için
      final unreadIds = await ChatServices.loadUnreadChats();
      unreadConversationIds.assignAll(unreadIds);
      debugPrint("✅ Kalıcı private chat kırmızı nokta durumları yüklendi: $unreadIds");
      
      // Grup mesajları için
      final unreadGroupIds = await ChatServices.loadUnreadGroups();
      unreadGroupIds.assignAll(unreadGroupIds);
      debugPrint("✅ Kalıcı grup mesaj kırmızı nokta durumları yüklendi: $unreadGroupIds");
      
      // Toplam unread count'u yükle
      final savedTotalCount = await ChatServices.loadTotalUnreadCount();
      totalUnreadCount.value = savedTotalCount;
      debugPrint("✅ Kalıcı toplam unread count yüklendi: $savedTotalCount");
      
      // Chat listesini güncelle
      _updateChatListUnreadStatus();
      _updateGroupListUnreadStatus();
    } catch (e) {
      debugPrint("❌ Kalıcı kırmızı nokta durumları yüklenemedi: $e");
    }
  }

  /// 🔄 Chat listesindeki kırmızı nokta durumlarını güncelle
  void _updateChatListUnreadStatus() {
    for (final chat in chatList) {
      chat.hasUnreadMessages = unreadConversationIds.contains(chat.conversationId);
    }
    chatList.refresh();
    
    for (final chat in filteredChatList) {
      chat.hasUnreadMessages = unreadConversationIds.contains(chat.conversationId);
    }
    filteredChatList.refresh();
    
    debugPrint("🔄 Chat listesi kırmızı nokta durumları güncellendi");
  }

  /// 🔄 Grup listesindeki kırmızı nokta durumlarını güncelle
  void _updateGroupListUnreadStatus() {
    for (final group in groupChatList) {
      group.hasUnreadMessages = unreadGroupIds.contains(group.groupId);
    }
    groupChatList.refresh();
    
    for (final group in filteredGroupChatList) {
      group.hasUnreadMessages = unreadGroupIds.contains(group.groupId);
    }
    filteredGroupChatList.refresh();
    
    debugPrint("🔄 Grup listesi kırmızı nokta durumları güncellendi");
    
    // GroupController'ı da güncelle (tab bar'daki count için)
    try {
      Get.find<GroupController>();
      // GroupController'ın groupUnreadCount getter'ı artık ChatController'dan veri alacak
      debugPrint("🔄 GroupController tab bar count güncellendi");
    } catch (e) {
      debugPrint("⚠️ GroupController bulunamadı: $e");
    }
  }

  /// 💾 Kalıcı kırmızı nokta durumlarını kaydet
  Future<void> _savePersistentUnreadStatus() async {
    try {
      await ChatServices.saveUnreadChats(unreadConversationIds.toList());
      debugPrint("💾 Kalıcı kırmızı nokta durumları kaydedildi");
    } catch (e) {
      debugPrint("❌ Kalıcı kırmızı nokta durumları kaydedilemedi: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
        debugPrint("📱 Uygulama duraklatıldı - kırmızı nokta durumları kaydediliyor...");
        _savePersistentUnreadStatus();
        break;
      case AppLifecycleState.resumed:
        debugPrint("📱 Uygulama devam ettirildi - kırmızı nokta durumları yükleniyor...");
        _loadPersistentUnreadStatus();
        break;
      default:
        break;
    }
  }

  /// 📊 Socket'ten gelen grup unread count'unu handle et
  void handleGroupUnreadCount(int groupId, int unreadCount) {
    try {
      debugPrint("📊 [ChatController] Socket'ten gelen grup unread count: groupId=$groupId, unreadCount=$unreadCount");
      
      // Grup listesinde bu grubu bul ve unread count'unu güncelle
      final groupIndex = groupChatList.indexWhere((group) => group.groupId == groupId);
      if (groupIndex != -1) {
        final group = groupChatList[groupIndex];
        group.unreadCount = unreadCount;
        group.hasUnreadMessages = unreadCount > 0;
        
        // Kalıcı kırmızı nokta durumunu güncelle
        if (unreadCount > 0) {
          if (!unreadGroupIds.contains(groupId)) {
            unreadGroupIds.add(groupId);
            ChatServices.markGroupAsUnread(groupId);
            debugPrint("🔴 [ChatController] GRUP KALICI KIRMIZI NOKTA EKLENDİ: group $groupId");
          }
        } else {
          if (unreadGroupIds.contains(groupId)) {
            unreadGroupIds.remove(groupId);
            ChatServices.markGroupAsRead(groupId);
            debugPrint("✅ [ChatController] GRUP KALICI KIRMIZI NOKTA KALDIRILDI: group $groupId");
          }
        }
        
        // Filtrelenmiş listeyi de güncelle
        final filteredIndex = filteredGroupChatList.indexWhere((g) => g.groupId == groupId);
        if (filteredIndex != -1) {
          filteredGroupChatList[filteredIndex].unreadCount = unreadCount;
          filteredGroupChatList[filteredIndex].hasUnreadMessages = unreadCount > 0;
        }
        
        // Observable'ları tetikle
        groupChatList.refresh();
        filteredGroupChatList.refresh();
        
        debugPrint("✅ [ChatController] Grup unread count güncellendi: ${group.groupName} = $unreadCount");
      } else {
        debugPrint("⚠️ [ChatController] Grup bulunamadı: groupId=$groupId");
      }
    } catch (e) {
      debugPrint("❌ [ChatController] Grup unread count handle hatası: $e");
    }
  }

  /// 📊 Socket'ten gelen grup unread count event'ini handle et (private chat'teki gibi)
  void handleGroupUnreadCountFromSocket(dynamic data) {
    try {
      debugPrint("📊 [ChatController] Socket'ten gelen grup unread count event: $data");
      
      if (data is Map<String, dynamic>) {
        // Eğer data'da group_id ve unread_count varsa
        if (data.containsKey('group_id')) {
          final groupId = data['group_id'];
          final unreadCount = data['unread_count'] ?? 
                              data['count'] ?? 
                              data['message_count'] ?? 0;
          
          debugPrint("📊 [ChatController] Group ID: $groupId, Unread Count: $unreadCount");
          
          // Grup'u bul ve hasUnreadMessages'ı ayarla
          final groupIndex = groupChatList.indexWhere((group) => group.groupId == groupId);
          if (groupIndex != -1) {
            final group = groupChatList[groupIndex];
            group.unreadCount = unreadCount;
            group.hasUnreadMessages = unreadCount > 0;
            
            // Kalıcı kırmızı nokta durumunu güncelle
            if (unreadCount > 0) {
              if (!unreadGroupIds.contains(groupId)) {
                unreadGroupIds.add(groupId);
                ChatServices.markGroupAsUnread(groupId);
                debugPrint("🔴 [ChatController] GRUP KALICI KIRMIZI NOKTA EKLENDİ: group $groupId");
              }
            } else {
              if (unreadGroupIds.contains(groupId)) {
                unreadGroupIds.remove(groupId);
                ChatServices.markGroupAsRead(groupId);
                debugPrint("✅ [ChatController] GRUP KALICI KIRMIZI NOKTA KALDIRILDI: group $groupId");
              }
            }
            
            // Filtrelenmiş listeyi de güncelle
            final filteredIndex = filteredGroupChatList.indexWhere((g) => g.groupId == groupId);
            if (filteredIndex != -1) {
              filteredGroupChatList[filteredIndex].unreadCount = unreadCount;
              filteredGroupChatList[filteredIndex].hasUnreadMessages = unreadCount > 0;
            }
            
            // Observable'ları tetikle
            groupChatList.refresh();
            filteredGroupChatList.refresh();
            
            debugPrint("✅ [ChatController] Grup unread count güncellendi: ${group.groupName} = $unreadCount");
          } else {
            debugPrint("⚠️ [ChatController] Grup bulunamadı: groupId=$groupId");
          }
        }
        // Eğer data bir liste ise (birden fazla grubun unread count'u)
        else if (data.containsKey('groups') && data['groups'] is List) {
          final groups = data['groups'] as List;
          debugPrint("📊 [ChatController] ${groups.length} grubun unread count'u işleniyor...");
          
          for (final group in groups) {
            if (group is Map<String, dynamic>) {
              final groupId = group['group_id'] ?? group['id'];
              final unreadCount = group['unread_count'] ?? 
                                  group['count'] ?? 
                                  group['message_count'] ?? 0;
              
              if (groupId != null) {
                debugPrint("📊 [ChatController] Group $groupId: $unreadCount unread");
                
                // Grup'u bul ve hasUnreadMessages'ı ayarla
                final groupIndex = groupChatList.indexWhere((g) => g.groupId == groupId);
                if (groupIndex != -1) {
                  final g = groupChatList[groupIndex];
                  g.unreadCount = unreadCount;
                  g.hasUnreadMessages = unreadCount > 0;
                  
                  // Kalıcı kırmızı nokta durumunu güncelle
                  if (unreadCount > 0) {
                    if (!unreadGroupIds.contains(groupId)) {
                      unreadGroupIds.add(groupId);
                      ChatServices.markGroupAsUnread(groupId);
                    }
                  } else {
                    if (unreadGroupIds.contains(groupId)) {
                      unreadGroupIds.remove(groupId);
                      ChatServices.markGroupAsRead(groupId);
                    }
                  }
                  
                  // Filtrelenmiş listeyi de güncelle
                  final filteredIndex = filteredGroupChatList.indexWhere((g) => g.groupId == groupId);
                  if (filteredIndex != -1) {
                    filteredGroupChatList[filteredIndex].unreadCount = unreadCount;
                    filteredGroupChatList[filteredIndex].hasUnreadMessages = unreadCount > 0;
                  }
                }
              }
            }
          }
          
          // Observable'ları tetikle
          groupChatList.refresh();
          filteredGroupChatList.refresh();
          
          debugPrint("✅ [ChatController] ${groups.length} grubun unread count'u güncellendi");
        }
      }
    } catch (e) {
      debugPrint("❌ [ChatController] Grup unread count event handle hatası: $e");
    }
  }
}
