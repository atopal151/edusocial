import 'dart:async';

import 'package:edusocial/models/chat_models/chat_user_model.dart';
import '../profile_controller.dart';
import 'package:edusocial/services/chat_service.dart';
import 'package:edusocial/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/chat_models/chat_model.dart';
import '../../models/chat_models/group_chat_model.dart';
import '../group_controller/group_controller.dart';
import '../../components/print_full_text.dart';

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

  /// Groups tab badge'in anlık yenilenmesi için tetikleyici
  var groupUnreadTrigger = 0.obs;

  final TextEditingController searchController = TextEditingController();

  late SocketService _socketService;
  late StreamSubscription _privateMessageSubscription;
  late StreamSubscription _groupMessageSubscription;
  late StreamSubscription _unreadCountSubscription;
  
  // Kalıcı kırmızı nokta durumları
  var unreadConversationIds = <int>[].obs;
  var unreadGroupIds = <int>[].obs; // Grup mesajları için kalıcı kırmızı nokta durumları

  /// Sohbet ekranından çıkılırken okundu işaretlenen conversation; fetchChatList bu id'yi API ile tekrar unread yapmasın.
  int? _conversationIdMarkedAsReadOnExit;
  DateTime? _conversationMarkedAsReadAt;
  
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
  /// NOT: Bu fonksiyon artık API çağrısı yapmıyor, sadece mevcut GroupController.userGroups verisini kullanıyor
  /// API çağrısı sadece uygulama açılışında (GroupController.onInit) ve manuel refresh'te yapılıyor
  Future<void> fetchGroupList() async {
    try {
      debugPrint("🔄 ChatController.fetchGroupList() çağrıldı (API çağrısı yok)");
      
      // GroupController'dan mevcut grup listesini al (API çağrısı yok)
      final groupController = Get.find<GroupController>();
      // NOT: fetchUserGroups() kaldırıldı - artık sadece mevcut veriyi kullanıyoruz
      
      debugPrint("📊 GroupController'dan alınan grup sayısı: ${groupController.userGroups.length}");
      
      // GroupController'daki userGroups'u ChatController'daki groupChatList ile senkronize et
      // API'den gelen unreadCount değerlerini kullan
      for (final userGroup in groupController.userGroups) {
        final chatGroupIndex = groupChatList.indexWhere((g) => g.groupId == int.parse(userGroup.id));
        
        printFullText("🔄 Grup işleniyor: ${userGroup.name} (ID: ${userGroup.id}) - API unreadCount: ${userGroup.unreadCount}");
        
        if (chatGroupIndex != -1) {
          // ChatController'daki grubu güncelle - API'den gelen unreadCount değerini kullan
          final chatGroup = groupChatList[chatGroupIndex];
          chatGroup.groupName = userGroup.name;
          chatGroup.lastMessage = userGroup.description; // Geçici olarak description kullan
          chatGroup.lastMessageTime = userGroup.humanCreatedAt;
          
          // Socket'ten gelen anlık değeri koru: API'den gelen değer sadece daha büyükse veya mevcut değer 0 ise kullan
          // Bu sayede socket'ten gelen güncel veri API'nin gecikmeli cevabıyla ezilmez
          final currentUnreadCount = chatGroup.unreadCount;
          final apiUnreadCount = userGroup.unreadCount;
          
          // API'den gelen değer mevcut socket değerinden büyükse veya mevcut değer 0 ise API'yi kullan
          // Aksi halde socket'ten gelen daha yeni değeri koru
          if (apiUnreadCount > currentUnreadCount || currentUnreadCount == 0) {
            chatGroup.unreadCount = apiUnreadCount;
            chatGroup.hasUnreadMessages = apiUnreadCount > 0;
            debugPrint("🔄 Grup güncellendi (API öncelikli): ${userGroup.name} (ID: ${userGroup.id}) - API: $apiUnreadCount, Mevcut: $currentUnreadCount -> Final: ${chatGroup.unreadCount}");
          } else {
            debugPrint("🔄 Grup korundu (Socket öncelikli): ${userGroup.name} (ID: ${userGroup.id}) - Socket: $currentUnreadCount, API: $apiUnreadCount -> Final: $currentUnreadCount");
          }
          
          printFullText("🔄 Grup güncellendi: ${userGroup.name} (ID: ${userGroup.id}) - Final unreadCount: ${chatGroup.unreadCount} -> hasUnreadMessages: ${chatGroup.hasUnreadMessages}");
        } else {
          // Yeni grup ekle - API'den gelen unreadCount değerini kullan
          final newChatGroup = GroupChatModel(
            groupId: int.parse(userGroup.id),
            groupName: userGroup.name,
            groupImage: userGroup.avatarUrl,
            lastMessage: userGroup.description,
            lastMessageTime: userGroup.humanCreatedAt,
            unreadCount: userGroup.unreadCount, // API'den gelen değeri kullan
            hasUnreadMessages: userGroup.unreadCount > 0, // API'den gelen değere göre ayarla
          );
          
          groupChatList.add(newChatGroup);
          printFullText("🔄 Yeni grup eklendi: ${userGroup.name} (ID: ${userGroup.id}) - unreadCount: ${userGroup.unreadCount} -> hasUnreadMessages: ${newChatGroup.hasUnreadMessages}");
        }
      }
      
      // Filtrelenmiş listeyi de güncelle
      filteredGroupChatList.assignAll(groupChatList);
      
      // Kalıcı kırmızı nokta durumlarını uygula
      _updateGroupListUnreadStatus();
      
      // ProfileController'daki unread count'u güncelle (private + grup)
      updateProfileControllerUnreadCount(null);
      
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

      // Mevcut chat listesindeki unread count'ları koru (Socket'ten gelen anlık değerler)
      // API'den gelen değer sadece daha büyükse veya mevcut değer 0 ise kullan
      // Sohbet ekranından çıkarken okundu işaretlenen conversation'ı API ile tekrar unread yapma
      final justMarkedId = _conversationIdMarkedAsReadOnExit;
      final justMarkedAt = _conversationMarkedAsReadAt;
      final keepAsRead = justMarkedId != null &&
          justMarkedAt != null &&
          DateTime.now().difference(justMarkedAt).inSeconds < 15;

      for (final fetchedChat in filteredChats) {
        final existingChatIndex = chatList.indexWhere((c) => c.conversationId == fetchedChat.conversationId);
        if (existingChatIndex != -1) {
          final existingChat = chatList[existingChatIndex];
          final currentUnreadCount = existingChat.unreadCount;
          final apiUnreadCount = fetchedChat.unreadCount;
          final isJustMarkedAsRead = keepAsRead && fetchedChat.conversationId == justMarkedId;

          if (isJustMarkedAsRead) {
            existingChat.unreadCount = 0;
            existingChat.hasUnreadMessages = false;
            debugPrint("🔄 Chat: ${existingChat.name} (ID: ${fetchedChat.conversationId}) - Ekrandan çıkıldığında okundu, API değeri yok sayıldı");
          } else if (apiUnreadCount > currentUnreadCount || currentUnreadCount == 0) {
            existingChat.unreadCount = apiUnreadCount;
            existingChat.hasUnreadMessages = apiUnreadCount > 0;
          }
          // lastMessage güncellenebilir, diğer alanlar final olduğu için değiştirilemez
          existingChat.lastMessage = fetchedChat.lastMessage;
        }
      }
      if (keepAsRead) {
        _conversationIdMarkedAsReadOnExit = null;
        _conversationMarkedAsReadAt = null;
      }
      
      // Yeni chat'leri ekle (mevcut listede olmayanlar)
      for (final fetchedChat in filteredChats) {
        final exists = chatList.any((c) => c.conversationId == fetchedChat.conversationId);
        if (!exists) {
          chatList.add(fetchedChat);
        }
      }
      
      filteredChatList.assignAll(chatList);

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
  /// NOT: conversation:new_message event'indeki unread_count ve is_me alanları güvenilir değil
  /// Bu yüzden sender_id ile kendi user_id'mizi karşılaştırıyoruz
  Future<void> handleNewPrivateMessage(dynamic data) async {
    try {
      final conversationId = data['conversation_id'];
      final senderId = data['sender_id'];
      
      // Kendi user ID'mizi ProfileController'dan al
      int? myUserId;
      try {
        final profileController = Get.find<ProfileController>();
        myUserId = int.tryParse(profileController.userId.value);
      } catch (e) {
        debugPrint("⚠️ ProfileController bulunamadı: $e");
      }
      
      // Backend'in is_me alanı bazen yanlış geliyor, o yüzden sender_id ile karşılaştırıyoruz
      final isMyMessage = (myUserId != null && senderId == myUserId);
      
      debugPrint("📥 [ChatController] Yeni private mesaj alındı:");
      debugPrint("  - conversation_id: $conversationId");
      debugPrint("  - sender_id: $senderId");
      debugPrint("  - my_user_id: $myUserId");
      debugPrint("  - is_my_message: $isMyMessage");
      
      if (conversationId != null) {
        final chatIndex = chatList.indexWhere((c) => c.conversationId == conversationId);
        if (chatIndex != -1) {
          final chat = chatList[chatIndex];
          final intConvId = conversationId is int ? conversationId : int.tryParse(conversationId.toString());
          final justLeftThisChat = intConvId != null &&
              _conversationIdMarkedAsReadOnExit == intConvId &&
              _conversationMarkedAsReadAt != null &&
              DateTime.now().difference(_conversationMarkedAsReadAt!).inSeconds < 5;

          // Eğer başkasının mesajı ise (sender_id != my_user_id), unread count'u +1 artır
          if (!isMyMessage) {
            if (justLeftThisChat) {
              debugPrint("📥 [ChatController] ⏭️ Az önce bu sohbet okundu işaretlendi, unread artırılmadı (conversation: $conversationId)");
            } else {
              chat.unreadCount = chat.unreadCount + 1;
              chat.hasUnreadMessages = true;
              debugPrint("📥 [ChatController] ✅ Başkasının mesajı - unread count artırıldı: ${chat.unreadCount}");
            }
          } else {
            debugPrint("📥 [ChatController] ⏭️ Kendi mesajımız - unread count değişmedi");
          }
          
          // Listeyi refresh et
          chatList.refresh();
          filteredChatList.refresh();
          
          // ProfileController'ı da güncelle
          updateProfileControllerUnreadCount(null);
        }
      }

    } catch (e) {
      debugPrint("❌ [ChatController] Mesaj işleme hatası: $e");
    }
  }

  /// 📥 Yeni grup mesajı geldiğinde listeyi güncelle
  /// NOT: is_me alanı güvenilir değil, sender_id ile karşılaştırma yapıyoruz
  Future<void> handleNewGroupMessage(dynamic data) async {
    try {
      debugPrint("📡 [ChatController] Yeni grup mesajı geldi, işleniyor...");
      
      if (data != null && data is Map<String, dynamic>) {
        final senderId = data['sender_id'];
        
        // Kendi user ID'mizi ProfileController'dan al
        int? myUserId;
        try {
          final profileController = Get.find<ProfileController>();
          myUserId = int.tryParse(profileController.userId.value);
        } catch (e) {
          debugPrint("⚠️ ProfileController bulunamadı: $e");
        }
        
        // Backend'in is_me alanı bazen yanlış geliyor, o yüzden sender_id ile karşılaştırıyoruz
        final isMyMessage = (myUserId != null && senderId == myUserId);
        
        final groupData = data['group'];
        if (groupData != null && groupData is Map<String, dynamic>) {
          final groupId = groupData['id'];
          
          debugPrint("📡 [ChatController] Grup mesajı detayları:");
          debugPrint("  - group_id: $groupId");
          debugPrint("  - sender_id: $senderId");
          debugPrint("  - my_user_id: $myUserId");
          debugPrint("  - is_my_message: $isMyMessage");
          
          if (groupId != null) {
            final intId = groupId is int ? groupId : int.tryParse(groupId.toString());
            if (intId != null) {
              final groupIndex = groupChatList.indexWhere((g) => g.groupId == intId);
              if (groupIndex != -1) {
                final group = groupChatList[groupIndex];
                
                // Eğer başkasının mesajı ise (sender_id != my_user_id), unread count'u +1 artır
                if (!isMyMessage) {
                  group.unreadCount = group.unreadCount + 1;
                  group.hasUnreadMessages = true;
                  
                  debugPrint("📡 [ChatController] ✅ Başkasının grup mesajı - unread count artırıldı: ${group.unreadCount}");
                } else {
                  debugPrint("📡 [ChatController] ⏭️ Kendi grup mesajımız - unread count değişmedi");
                }
                
                // UI'ı güncelle (tab badge anlık yenilensin)
                groupChatList.refresh();
                groupUnreadTrigger.value++;

                // GroupController'daki veriyi de güncelle (tab bar badge için)
                try {
                  final groupController = Get.find<GroupController>();
                  final userGroupIndex = groupController.userGroups.indexWhere((g) => g.id == intId.toString());
                  if (userGroupIndex != -1) {
                    groupController.userGroups[userGroupIndex] = groupController.userGroups[userGroupIndex].copyWith(
                      unreadCount: group.unreadCount,
                      hasUnreadMessages: group.hasUnreadMessages,
                    );
                  }
                } catch (e) {
                  debugPrint("⚠️ GroupController sync error: $e");
                }
                
                // Toplam unread count'u da güncelle (ProfileController için)
                updateProfileControllerUnreadCount(null);
                
                debugPrint("✅ [ChatController] Grup ($intId) unread count güncellendi: ${group.unreadCount}");
              }
            }
          }
        }
      }

    } catch (e) {
      debugPrint("❌ [ChatController] Grup mesajı sonrası işleme hatası: $e");
    }
  }

  /// 🔴 Socket'ten gelen toplam okunmamış mesaj sayısını güncelle
  /// NOT: Bu event sadece referans amaçlı kullanılıyor, asıl count API'den ve liste'den hesaplanıyor
  Future<void> updateUnreadCount(dynamic data) async {
    debugPrint("📬 Socket'ten gelen okunmamış mesaj verisi: $data");
    
    int socketCount = 0;
    
    if (data is Map<String, dynamic>) {
      // Farklı key'leri kontrol et
      socketCount = data['count'] ?? 
                    data['total'] ?? 
                    data['unread'] ?? 
                    data['message_count'] ?? 
                    data['conversation_count'] ?? 0;
    } else if (data is int) {
      socketCount = data;
    } else {
      debugPrint("⚠️ Beklenmeyen data tipi: ${data.runtimeType}");
      return;
    }
    
    debugPrint("📬 Socket'ten gelen private count: $socketCount");
    
    // Liste üzerinden gerçek count'u hesapla (API'den gelen değerler)
    final actualPrivateCount = privateUnreadCount;
    final actualGroupCount = groupUnreadCount;
    final actualTotalCount = actualPrivateCount + actualGroupCount;
    
    debugPrint("📬 Liste üzerinden hesaplanan private count: $actualPrivateCount");
    debugPrint("📬 Liste üzerinden hesaplanan group count: $actualGroupCount");
    debugPrint("📬 Liste üzerinden hesaplanan toplam count: $actualTotalCount");
    
    // Socket count'u sadece log için kullan, asıl count'u liste'den al
    // Çünkü:
    // 1. conversation:new_message event'i yanlış unread_count gönderiyor
    // 2. API'den gelen değerler daha güvenilir
    // 3. Socket count'u sadece private içinmiş gibi görünüyor
    
    totalUnreadCount.value = actualTotalCount;
    debugPrint("📬 Liste count'u kullanıldı: $actualTotalCount (socket: $socketCount - sadece referans)");
    
    // ProfileController'daki unread count'u da güncelle
    updateProfileControllerUnreadCount(null); // null gönder ki getter'dan hesaplansın
    
    // Kalıcı olarak kaydet
    await ChatServices.saveTotalUnreadCount(totalUnreadCount.value);
    
    debugPrint("📬 Final total unread count: ${totalUnreadCount.value}");
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
    
    // Profile API'sini de yeniden yükle
    await _refreshProfileAfterMessageRead();
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
      
      // Chat'i bul ve local state'i güncelle (API'den gelen değerleri kullan)
      final chatIndex = chatList.indexWhere((chat) => chat.conversationId == targetConversationId);
      if (chatIndex != -1) {
        final chat = chatList[chatIndex];
        
        // Eğer chat'in unreadCount'u varsa, toplam count'tan çıkar
        if (chat.unreadCount > 0) {
          final newTotalCount = (totalUnreadCount.value - chat.unreadCount).clamp(0, double.infinity).toInt();
          totalUnreadCount.value = newTotalCount;
          await ChatServices.saveTotalUnreadCount(newTotalCount);
          debugPrint("📊 Toplam unread count güncellendi: ${totalUnreadCount.value} -> $newTotalCount (${chat.unreadCount} mesaj okundu)");
        }
        
        // Local state'i güncelle
        chat.unreadCount = 0;
        chat.hasUnreadMessages = false;
        debugPrint("📖 Chat okundu olarak işaretlendi: ${chat.name} (conversation: $targetConversationId)");
        
        // Filtrelenmiş listeyi de güncelle
        final filteredIndex = filteredChatList.indexWhere((c) => c.conversationId == targetConversationId);
        if (filteredIndex != -1) {
          filteredChatList[filteredIndex].hasUnreadMessages = false;
          filteredChatList[filteredIndex].unreadCount = 0;
        }
        
        // Observable'ları tetikle
        chatList.refresh();
        filteredChatList.refresh();
      }
      
      debugPrint("📖 Chat okundu olarak işaretlendi: conversationId=$targetConversationId");
      
      // Sohbet ekranından çıkınca refreshChatList API'den unread döndürebilir; bu conversation'ı kısa süre koru
      _conversationIdMarkedAsReadOnExit = targetConversationId;
      _conversationMarkedAsReadAt = DateTime.now();
      
      // Profile API'sini yeniden yükle ki unread_messages_total_count güncellensin
      _refreshProfileAfterMessageRead();
    } catch (e) {
      debugPrint("❌ markChatAsRead hatası: $e");
    }
  }

  /// 📬 Mesaj okunduktan sonra Profile API'sini yeniden yükle
  Future<void> _refreshProfileAfterMessageRead() async {
    try {
      final profileController = Get.find<ProfileController>();
      await profileController.loadProfile();
      debugPrint("✅ Profile API mesaj okunduktan sonra yeniden yüklendi");
    } catch (e) {
      debugPrint("❌ Profile API yeniden yüklenirken hata: $e");
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
    
    // Profile API'sini de yeniden yükle
    await _refreshProfileAfterMessageRead();
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
  /// NOT: Bu fonksiyon sadece uygulama açılışında ve manuel refresh'te çağrılmalı
  /// Socket mesajı geldiğinde API çağrısı yapılmaz, sadece socket verisi kullanılır
  Future<void> refreshChatListAndUnreadCounts() async {
    try {
      debugPrint("🔄 Chat listesi ve unread count'lar yenileniyor...");
      
      // Chat listesini yenile (grup listesi socket'ten güncellendiği için burada çağrılmıyor)
      await fetchChatList();
      // NOT: fetchGroupList() kaldırıldı - grup listesi socket'ten anlık güncelleniyor
      
      // API'den gelen unread count'ları kontrol et (Sadece Chat için)
      debugPrint("🔍 API'den gelen unread count'lar kontrol ediliyor...");
      int totalUnreadFromAPIChat = 0;
      int totalUnreadFromAPIGroup = 0;
      
      // Chat listesinden toplam unread count
      for (final chat in chatList) {
        totalUnreadFromAPIChat += chat.unreadCount;
      }
      debugPrint("🔍 API'den gelen toplam chat unread count: $totalUnreadFromAPIChat");
      
      // Grup listesinden toplam unread count (Socket'ten gelen değerler)
      for (final group in groupChatList) {
        totalUnreadFromAPIGroup += group.unreadCount;
      }
      debugPrint("🔍 Socket'ten gelen toplam grup unread count: $totalUnreadFromAPIGroup");
      
      final totalUnreadFromAPI = totalUnreadFromAPIChat + totalUnreadFromAPIGroup;
      debugPrint("🔍 TOPLAM unread count (chat API + grup socket): $totalUnreadFromAPI");
      
      // API'den gelen değerle mevcut total count'u senkronize et
      if (totalUnreadFromAPI != totalUnreadCount.value) {
        debugPrint("⚠️ Unread count uyumsuzluğu: API=$totalUnreadFromAPI, Mevcut=${totalUnreadCount.value}");
        totalUnreadCount.value = totalUnreadFromAPI;
        await ChatServices.saveTotalUnreadCount(totalUnreadFromAPI);
        debugPrint("✅ Total unread count güncellendi: $totalUnreadFromAPI");
      }
      
      // ProfileController'daki unread count'u güncelle (private + grup)
      updateProfileControllerUnreadCount(null);
      
      // Socket'ten güncel unread count'ları iste (sadece chat için)
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
    if (isClosed) return; // Controller dispose edilmişse işlemi durdur
    
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

  /// 📊 Kişisel mesajların toplam okunmamış sayısını hesapla (chatList'teki unreadCount değerlerini topla)
  int get privateUnreadCount {
    return chatList.fold(0, (sum, chat) => sum + chat.unreadCount);
  }
  
  /// 📬 ProfileController'daki unread count'u güncelle (private chat + grup chat)
  void updateProfileControllerUnreadCount(int? count) {
    try {
      final profileController = Get.find<ProfileController>();
      // Eğer count verilmediyse, toplam unread count'u hesapla (private + grup)
      final totalCount = count ?? totalUnreadCountValue;
      profileController.unreadMessagesTotalCount.value = totalCount;
      debugPrint("📬 ProfileController unread count güncellendi: $totalCount (private: ${totalUnreadCount.value}, grup: $groupUnreadCount)");
    } catch (e) {
      debugPrint("❌ ProfileController bulunamadı: $e");
    }
  }


  /// 📊 Grup mesajlarının toplam okunmamış sayısını hesapla (unreadCount değerlerini topla)
  int get groupUnreadCount {
    return groupChatList.fold(0, (sum, group) => sum + group.unreadCount);
  }

  /// 📊 Toplam okunmamış mesaj sayısını hesapla (private + grup)
  int get totalUnreadCountValue {
    return privateUnreadCount + groupUnreadCount;
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
        
        // NOT: Grup unread count'ları API'den alınıyor, socket'ten istenmiyor
        // Grup mesajı geldiğinde API'den grup listesi yenileniyor (handleNewGroupMessage içinde)
        
        debugPrint("✅ Conversation unread count istekleri gönderildi");
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
      printFullText('📨 =======================================');
      printFullText('📨 CHAT CONTROLLER - CONVERSATION UNREAD COUNT İŞLENİYOR');
      printFullText('📨 =======================================');
      printFullText('📨 Raw Data: $data');
      printFullText('📨 Data Type: ${data.runtimeType}');
      
      if (data is Map<String, dynamic>) {
        printFullText('📨 === DETAYLI ALAN ANALİZİ ===');
        printFullText('📨 Data Keys: ${data.keys.toList()}');
        
        // Tüm alanları yazdır
        for (String key in data.keys) {
          final value = data[key];
          printFullText('📨   $key: $value (Type: ${value.runtimeType})');
        }
        
        // Eğer data'da conversation_id ve unread_count varsa (TEK CHAT)
        if (data.containsKey('conversation_id')) {
          final conversationId = data['conversation_id'];
          final unreadCount = data['unread_count'] ?? 
                              data['count'] ?? 
                              data['message_count'] ?? 0;
          
          printFullText('📨 🔥 TEK CHAT İÇİN UNREAD COUNT GELDİ');
          printFullText('📨 🔥 Conversation ID: $conversationId');
          printFullText('📨 🔥 Unread Count: $unreadCount');
          
          // Chat'i bul ve hasUnreadMessages'ı ayarla
          final chatIndex = chatList.indexWhere((chat) => chat.conversationId == conversationId);
          if (chatIndex != -1) {
            final chat = chatList[chatIndex];
            printFullText('📨 ✅ Chat bulundu: ${chat.name}');
            chat.unreadCount = unreadCount;
            chat.hasUnreadMessages = unreadCount > 0;
            
            // Filtrelenmiş listeyi de güncelle
            final filteredIndex = filteredChatList.indexWhere((c) => c.conversationId == conversationId);
            if (filteredIndex != -1) {
              filteredChatList[filteredIndex].hasUnreadMessages = unreadCount > 0;
              filteredChatList[filteredIndex].unreadCount = unreadCount;
            }
            
            // Observable'ları tetikle
            chatList.refresh();
            filteredChatList.refresh();
            
            printFullText("📨 ✅ Conversation $conversationId unread count güncellendi: $unreadCount -> hasUnreadMessages: ${chat.hasUnreadMessages}");
          } else {
            printFullText("📨 ⚠️ Conversation $conversationId chat listesinde bulunamadı");
          }
        }
        // Eğer data bir liste ise (birden fazla conversation'ın unread count'u)
        else if (data.containsKey('conversations') && data['conversations'] is List) {
          final conversations = data['conversations'] as List;
          printFullText('📨 🔥 TOPLAM ${conversations.length} CHAT İÇİN UNREAD COUNT GELDİ');
          
          for (int i = 0; i < conversations.length; i++) {
            final conv = conversations[i];
            if (conv is Map<String, dynamic>) {
              final conversationId = conv['conversation_id'] ?? conv['id'];
              final unreadCount = conv['unread_count'] ?? 
                                  conv['count'] ?? 
                                  conv['message_count'] ?? 0;
              
              printFullText('📨   Chat ${i + 1}:');
              printFullText('📨     Conversation ID: $conversationId');
              printFullText('📨     Unread Count: $unreadCount');
              
              if (conversationId != null) {
                // Chat'i bul ve hasUnreadMessages'ı ayarla
                final chatIndex = chatList.indexWhere((chat) => chat.conversationId == conversationId);
                if (chatIndex != -1) {
                  final chat = chatList[chatIndex];
                  chat.unreadCount = unreadCount;
                  chat.hasUnreadMessages = unreadCount > 0;
                  
                  // Filtrelenmiş listeyi de güncelle
                  final filteredIndex = filteredChatList.indexWhere((c) => c.conversationId == conversationId);
                  if (filteredIndex != -1) {
                    filteredChatList[filteredIndex].hasUnreadMessages = unreadCount > 0;
                    filteredChatList[filteredIndex].unreadCount = unreadCount;
                  }
                  
                  printFullText("📨 ✅ Chat ${chat.name} (ID: $conversationId) güncellendi: $unreadCount");
                } else {
                  printFullText("📨 ⚠️ Chat (ID: $conversationId) chat listesinde bulunamadı");
                }
              }
            }
          }
          
          // Observable'ları tetikle
          chatList.refresh();
          filteredChatList.refresh();
          
          printFullText("📨 ✅ ${conversations.length} conversation'un unread count'u güncellendi");
        } else {
          printFullText('📨 ⚠️ Beklenmeyen data formatı - conversation_id veya conversations alanı yok');
        }
      } else {
        printFullText('📨 ⚠️ Data is not a Map, it is: ${data.runtimeType}');
      }
      
      printFullText('📨 =======================================');
    } catch (e) {
      printFullText("❌ Conversation unread count işleme hatası: $e");
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
      
      // Chat listesindeki toplam unread mesaj sayısını hesapla (conversation sayısı değil)
      final actualPrivateUnreadCount = chatList.fold(0, (sum, chat) => sum + chat.unreadCount);
      final actualGroupUnreadCount = groupChatList.fold(0, (sum, group) => sum + group.unreadCount);
      final totalActualUnreadCount = actualPrivateUnreadCount + actualGroupUnreadCount;
      final storedUnreadCount = totalUnreadCount.value;
      
      debugPrint("🔍 Private unread count: $actualPrivateUnreadCount");
      debugPrint("🔍 Group unread count: $actualGroupUnreadCount");
      debugPrint("🔍 Total unread count: $totalActualUnreadCount");
      debugPrint("🔍 Stored unread count: $storedUnreadCount");
      
      // Eğer uyumsuzluk varsa düzelt
      if (totalActualUnreadCount != storedUnreadCount) {
        debugPrint("⚠️ Unread count uyumsuzluğu tespit edildi!");
        debugPrint("⚠️ Toplam unread: $totalActualUnreadCount, Stored: $storedUnreadCount");
        
        // Gerçek toplam sayıyı kullan
        totalUnreadCount.value = totalActualUnreadCount;
        await ChatServices.saveTotalUnreadCount(totalActualUnreadCount);
        
        // ProfileController'ı da güncelle
        updateProfileControllerUnreadCount(totalActualUnreadCount);
        
        debugPrint("✅ Unread count düzeltildi: $storedUnreadCount -> $totalActualUnreadCount");
      } else {
        debugPrint("✅ Unread count'lar uyumlu");
      }
      
      // Eğer hiç unread yoksa count'u sıfırla
      if (totalActualUnreadCount == 0 && storedUnreadCount > 0) {
        debugPrint("⚠️ Hiç unread yok ama count > 0, sıfırlanıyor...");
        totalUnreadCount.value = 0;
        await ChatServices.saveTotalUnreadCount(0);
        updateProfileControllerUnreadCount(0);
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
      
      // Grup listesindeki hasUnreadMessages'ı false yap (API'den gelen değerleri kullan)
      final groupIndex = groupChatList.indexWhere((group) => group.groupId == groupIdInt);
      if (groupIndex != -1) {
        final group = groupChatList[groupIndex];
        
        // Eğer grup'un unreadCount'u varsa, toplam count'tan çıkar
        if (group.unreadCount > 0) {
          final newTotalCount = (totalUnreadCount.value - group.unreadCount).clamp(0, double.infinity).toInt();
          totalUnreadCount.value = newTotalCount;
          await ChatServices.saveTotalUnreadCount(newTotalCount);
          debugPrint("📊 Toplam unread count güncellendi: ${totalUnreadCount.value} -> $newTotalCount (${group.unreadCount} mesaj okundu)");
        }
        
        // Local state'i güncelle
        group.hasUnreadMessages = false;
        group.unreadCount = 0;
        debugPrint("📖 Grup okundu olarak işaretlendi: ${group.groupName} (groupId: $groupIdInt)");
        
        // Filtrelenmiş listeyi de güncelle
        final filteredIndex = filteredGroupChatList.indexWhere((g) => g.groupId == groupIdInt);
        if (filteredIndex != -1) {
          filteredGroupChatList[filteredIndex].hasUnreadMessages = false;
          filteredGroupChatList[filteredIndex].unreadCount = 0;
        }
        
        // Observable'ları tetikle
        groupChatList.refresh();
        filteredGroupChatList.refresh();
      }
      
      debugPrint("📖 Grup okundu olarak işaretlendi: groupId=$groupId");
    } catch (e) {
      debugPrint("❌ Grup okundu işaretleme hatası: $e");
    }
  }

  /// 📂 Kalıcı kırmızı nokta durumlarını yükle (Artık sadece toplam count için kullanılıyor)
  Future<void> _loadPersistentUnreadStatus() async {
    try {
      debugPrint("📂 Toplam unread count yükleniyor (local storage'dan)...");
      
      // Sadece toplam unread count'u yükle (yedek olarak)
      final savedTotalCount = await ChatServices.loadTotalUnreadCount();
      totalUnreadCount.value = savedTotalCount;
      debugPrint("✅ Toplam unread count yüklendi: $savedTotalCount");
      
      // Chat listesi API'den geldiğinde zaten unreadCount değerleri var, burada güncelleme yapmıyoruz
      // API'den gelen değerler kullanılacak
    } catch (e) {
      debugPrint("❌ Toplam unread count yüklenemedi: $e");
    }
  }

  /// 🔄 Chat listesindeki kırmızı nokta durumlarını güncelle (API'den gelen unreadCount değerlerini kullan)
  void _updateChatListUnreadStatus() {
    for (final chat in chatList) {
      // API'den gelen unreadCount değerini kullan
      chat.hasUnreadMessages = chat.unreadCount > 0;
      printFullText('🔄 Chat: ${chat.name} (ID: ${chat.conversationId}) - API unreadCount: ${chat.unreadCount} -> hasUnreadMessages: ${chat.hasUnreadMessages}');
    }
    chatList.refresh();
    
    for (final chat in filteredChatList) {
      // API'den gelen unreadCount değerini kullan
      chat.hasUnreadMessages = chat.unreadCount > 0;
    }
    filteredChatList.refresh();
    
    debugPrint("🔄 Chat listesi kırmızı nokta durumları güncellendi (API'den gelen değerler kullanıldı)");
  }

  /// 🔄 Grup listesindeki kırmızı nokta durumlarını güncelle (API'den gelen unreadCount değerlerini kullan)
  void _updateGroupListUnreadStatus() {
    for (final group in groupChatList) {
      // API'den gelen unreadCount değerini kullan
      group.hasUnreadMessages = group.unreadCount > 0;
      printFullText('🔄 Grup: ${group.groupName} (ID: ${group.groupId}) - API unreadCount: ${group.unreadCount} -> hasUnreadMessages: ${group.hasUnreadMessages}');
    }
    groupChatList.refresh();
    
    for (final group in filteredGroupChatList) {
      // API'den gelen unreadCount değerini kullan
      group.hasUnreadMessages = group.unreadCount > 0;
    }
    filteredGroupChatList.refresh();
    
    debugPrint("🔄 Grup listesi kırmızı nokta durumları güncellendi (API'den gelen değerler kullanıldı)");
    
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
      // Sadece toplam unread count'u kaydet (yedek olarak)
      await ChatServices.saveTotalUnreadCount(totalUnreadCount.value);
      debugPrint("💾 Toplam unread count kaydedildi: ${totalUnreadCount.value}");
    } catch (e) {
      debugPrint("❌ Toplam unread count kaydedilemedi: $e");
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
}
