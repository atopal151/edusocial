import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import '../../components/buttons/custom_button.dart';
import '../../models/chat_models/group_message_model.dart';
import '../../models/group_models/group_detail_model.dart';
import '../../models/document_model.dart';
import '../../models/link_model.dart';
import '../../services/group_services/group_service.dart';
import '../../services/language_service.dart';
import '../../services/socket_services.dart';
import '../../services/survey_service.dart';
import '../../services/pin_message_service.dart';
import '../profile_controller.dart';
import '../../components/snackbars/custom_snackbar.dart';

class GroupChatDetailController extends GetxController {
  // Services
  final GroupServices _groupServices = GroupServices();
  final LanguageService _languageService = Get.find<LanguageService>();

  final RxList<GroupMessageModel> messages = <GroupMessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGroupDataLoading = false.obs; // Grup verisi için ayrı loading
  final RxBool isMessagesLoading = false.obs; // Mesajlar için ayrı loading
  final RxString currentGroupId = ''.obs;
  final groupData = Rx<GroupDetailModel?>(null);
  final TextEditingController messageController = TextEditingController();
  
  // Group chat için conversation ID mapping
  final RxString currentConversationId = ''.obs;

  // Socket service ile ilgili değişkenler
  late SocketService _socketService;
  late StreamSubscription _groupMessageSubscription;
  late StreamSubscription _pinMessageSubscription; // Pin message subscription eklendi

  bool _isSocketListenerSetup = false; // Multiple subscription guard
  final ScrollController scrollController = ScrollController();

  // PAGINATION: New state variables for lazy loading group messages
  final RxBool isLoadingMoreMessages = false.obs;
  final RxBool hasMoreMessages = true.obs;
  final RxInt currentOffset = 0.obs;
  final int messagesPerPage = 1000; // Increased from 25 to 1000 to remove limit
  final RxBool isFirstLoad = true.obs;
  
  // Track message count for auto-scroll optimization
  int _lastMessageCount = 0;
  
  // Scroll to bottom button visibility
  final RxBool showScrollToBottomButton = false.obs;

  // Grup chat verilerinden çıkarılan belge, bağlantı ve fotoğraf listeleri
  final RxList<DocumentModel> groupDocuments = <DocumentModel>[].obs;
  final RxList<LinkModel> groupLinks = <LinkModel>[].obs;
  final RxList<String> groupPhotos = <String>[].obs;

  // Mesaj gönderme için seçilen dosyalar ve linkler
  final RxList<File> selectedFiles = <File>[].obs;
  final RxBool isSendingMessage = false.obs;

  RxString pollQuestion = ''.obs;
  RxList<String> pollOptions = <String>[].obs;
  RxMap<String, int> pollVotes = <String, int>{}.obs;
  RxString selectedPollOption = ''.obs;
  TextEditingController pollTitleController = TextEditingController();

  // Survey variables
  RxString surveyTitle = ''.obs;
  RxList<String> surveyChoices = <String>[].obs;
  RxBool isMultipleChoice = false.obs;
  TextEditingController surveyTitleController = TextEditingController();

  // Performance optimization: Cache kullanıcı verileri
  final Map<String, Map<String, dynamic>> _userCache = {};
  bool _isInitialLoad = true;

  // URL algılama için regex pattern
  static final RegExp urlRegex = RegExp(
    r'(https?://[^\s]+)|(www\.[^\s]+)|([^\s]+\.[^\s]{2,})',
    caseSensitive: false,
  );

  // Admin kontrolü - Genişletilmiş yetki kontrolü
  bool get isCurrentUserAdmin {
    final group = groupData.value;
    
    if (group == null) {
      debugPrint('🔍 [GroupChatDetailController] Admin kontrolü: Group data null');
      return false;
    }
    
    // 1. Grup kurucusu kontrolü
    final isFounder = group.isFounder;
    debugPrint('🔍 [GroupChatDetailController] Admin kontrolü: isFounder=$isFounder');
    
    // 2. Admin sayısı kontrolü (user_count_with_admin > 0 ise admin var)
    final hasAdminUsers = group.userCountWithAdmin > 0;
    debugPrint('🔍 [GroupChatDetailController] Admin kontrolü: hasAdminUsers=$hasAdminUsers');
    
    // 3. Grup üyesi kontrolü
    final isMember = group.isMember;
    debugPrint('🔍 [GroupChatDetailController] Admin kontrolü: isMember=$isMember');
    
    // Admin yetkisi: Grup kurucusu VEYA admin sayısı > 0 olan grupta üye olmak
    final isAdmin = isFounder || (hasAdminUsers && isMember);
    debugPrint('🔍 [GroupChatDetailController] Admin kontrolü: Final result=$isAdmin');
    
    return isAdmin;
  }

  // Link algılama fonksiyonu
  List<String> extractUrlsFromText(String text) {
    final matches = urlRegex.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  // URL'yi normalize et (http:// ekle)
  String normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  // Mesaj içeriğinde link var mı kontrol et
  bool hasLinksInText(String text) {
    return urlRegex.hasMatch(text);
  }

  // Link olmayan text'i çıkar
  String extractNonLinkText(String text) {
    return text.replaceAll(urlRegex, '').trim();
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔍 Group chat detail controller onInit called');
    
    // Socket servisini initialize et
    _socketService = Get.find<SocketService>();
    _setupSocketListeners();
    
    // PAGINATION: Initialize scroll listener for lazy loading
    _setupPaginationScrollListener();
    
    // Arguments'ı güvenli bir şekilde kontrol et
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['groupId'] != null) {
      currentGroupId.value = arguments['groupId'].toString();
      debugPrint('✅ Current group ID set to: ${currentGroupId.value}');
      
      // Optimize: Sadece burada yükle, initState'te tekrar çağırma
      _loadGroupDataProgressive();
      
      // Group chat'e girdiğinde socket durumunu kontrol et
      onGroupChatEntered();
      
      // İlk yükleme sonrası pin durumlarını kontrol et
      Future.delayed(Duration(milliseconds: 1000), () {
        _updatePinStatusFromAPI();
      });
      
      // Cache'i temizle (Android'de güncel olmayan veri sorunu için)
      GroupServices.clearGroupCache();
    } else {
      debugPrint('❌ No group ID provided in arguments');
      // Custom snackbar kullan ve güvenli navigation
      final languageService = Get.find<LanguageService>();
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("groups.errors.noGroupSelected"),
        type: SnackbarType.error,
        duration: const Duration(seconds: 3),
      );
      
      // Güvenli navigation
      Future.delayed(const Duration(seconds: 1), () {
        if (Get.isRegistered<GroupChatDetailController>()) {
          Get.back();
        }
      });
    }
  }

  /// SCROLL: Setup scroll listener for scroll to bottom button
  void _setupPaginationScrollListener() {
    scrollController.addListener(() {
      // SCROLL TO BOTTOM BUTTON: Show/hide based on scroll position
      if (scrollController.hasClients && messages.isNotEmpty) {
        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.position.pixels;
        final isNearBottom = (maxScroll - currentScroll) < 200; // Show button if user scrolled up more than 200px
        
        showScrollToBottomButton.value = !isNearBottom && maxScroll > 0;
      }
    });
  }



  /// Progressive loading: Önce grup verilerini yükle, sonra mesajları
  Future<void> _loadGroupDataProgressive() async {
    try {
      isGroupDataLoading.value = true;
      
      // STEP 1: Quick message loading (önce sadece mesajları al)
      await fetchGroupDetailsOptimized();
      
      // STEP 2: API'den gelen pin durumlarını kontrol et ve UI'ı güncelle
      _updatePinStatusFromAPI();
      
      // STEP 3: Socket üzerinden güncel pin durumlarını kontrol et
      await _checkPinStatusFromSocket();
      
      isGroupDataLoading.value = false;
      
      // İlk yükleme sonrası scroll
      if (_isInitialLoad) {
        _isInitialLoad = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottomAfterLoad();
        });
      }
      
    } catch (e) {
      debugPrint('❌ Progressive loading error: $e');
      isGroupDataLoading.value = false;
      isMessagesLoading.value = false;
    }
  }

  /// OPTIMIZED: Faster group details fetching
  Future<void> fetchGroupDetailsOptimized() async {
    if (currentGroupId.value.isEmpty) {
      debugPrint('❌ Cannot fetch group details: No group ID provided');
      return;
    }

    try {
      debugPrint('🚀 Fast-fetching group details for group ID: ${currentGroupId.value}');
      
      // OPTIMIZE: Try cache first, then API
      GroupDetailModel? group;
      
      try {
        // Try cached version first
        group = await _groupServices.fetchGroupDetailCached(currentGroupId.value)
            .timeout(const Duration(seconds: 10)); // 3'ten 10'a çıkarıldı
      } catch (e) {
        debugPrint('⚠️ Cache failed, trying direct API: $e');
        // Fallback to direct API call
        group = await _groupServices.fetchGroupDetail(currentGroupId.value)
            .timeout(const Duration(seconds: 15)); // 5'ten 15'e çıkarıldı
      }
      
      groupData.value = group;
      
      // Group chat için conversation_id'yi güncelle
      if (group.conversationId != null) {
        currentConversationId.value = group.conversationId!;
        debugPrint('📌 [GroupChatDetailController] Updated conversation ID from group data: ${group.conversationId}');
      }
      
      // OPTIMIZE: Process messages in background
      Future.microtask(() {
        convertGroupChatsToMessagesOptimized();
      });
      
      debugPrint('✅ Group details loaded successfully (optimized)');
    } catch (e) {
      debugPrint('❌ Error fetching group details: $e');
      
      Get.snackbar(
        _languageService.tr('groupChat.errors.loadFailed'),
        _languageService.tr('groupChat.errors.tryAgain'),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
    }
  }

  /// Socket event dinleyicilerini ayarla
  void _setupSocketListeners() {
    // Multiple subscription guard
    if (_isSocketListenerSetup) {
      debugPrint('⚠️ Group chat socket listeners already setup, skipping...');
      return;
    }
    
    // Chat liste controller'ın group message listener'ını durdur (Artık gerekli değil - sürekli aktif)
    debugPrint('📴 ChatController group message listener artık duraklatılmıyor - sürekli aktif');
    
    // Group mesaj dinleyicisi - user:{user_id} kanalından
    _groupMessageSubscription = _socketService.onGroupMessage.listen((data) {
      _onNewGroupMessage(data);
    });

    // Pin message dinleyicisi - pin/unpin event'leri için
    _pinMessageSubscription = _socketService.onPinMessage.listen((data) {
      _onPinMessageUpdate(data);
    });

    
    _isSocketListenerSetup = true;
    debugPrint('✅ GroupChatDetailController socket listeners setup completed');
  }

  /// Group message listener'ını duraklat
  void pauseGroupMessageListener() {
    try {
      debugPrint('⏸️ PAUSE REQUEST: GroupChatDetailController group message listener pause requested');
      debugPrint('⏸️ Current state: isPaused=${_groupMessageSubscription.isPaused}');
      
      if (!_groupMessageSubscription.isPaused) {
        _groupMessageSubscription.pause();
        debugPrint('⏸️ SUCCESS: GroupChatDetailController group message listener paused');
      } else {
        debugPrint('⏸️ ALREADY PAUSED: GroupChatDetailController group message listener was already paused');
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
      debugPrint('▶️ RESUME REQUEST: GroupChatDetailController group message listener resume requested');
      debugPrint('▶️ Current state: isPaused=${_groupMessageSubscription.isPaused}');
      
      if (_groupMessageSubscription.isPaused) {
        _groupMessageSubscription.resume();
        debugPrint('▶️ SUCCESS: GroupChatDetailController group message listener resumed');
      } else {
        debugPrint('▶️ ALREADY ACTIVE: GroupChatDetailController group message listener was already active');
      }
      
      // Verification  
      debugPrint('▶️ VERIFICATION: isPaused=${_groupMessageSubscription.isPaused}');
      
    } catch (e) {
      debugPrint('❌ RESUME ERROR: Group message listener resume failed: $e');
    }
  }

  /// Yeni grup mesajı geldiğinde işle - OPTIMIZE
  void _onNewGroupMessage(dynamic data) {
    try {
      
      if (data is Map<String, dynamic>) {
        // Socket'ten gelen data yapısı: {message: {group_id: 2, ...}}
        final messageData = data['message'] as Map<String, dynamic>?;
        final incomingGroupId = messageData?['group_id']?.toString();
        
        
        // Sadece bu grup için gelen mesajları işle
        if (incomingGroupId != null && incomingGroupId == currentGroupId.value) {
          
          // Pin durumu kontrolü - eğer mesaj zaten varsa ve pin durumu değiştiyse
          final messageId = messageData?['id']?.toString();
          final isPinned = messageData?['is_pinned'] ?? false;
          
          
          // Pin durumu değişikliği varsa özel işlem yap
          if (messageId != null && messageData?.containsKey('is_pinned') == true) {
            debugPrint('🔍 [GroupChatDetailController] Pin durumu değişikliği tespit edildi, özel işlem yapılıyor');
            
            final existingMessageIndex = messages.indexWhere((msg) => msg.id == messageId);
            debugPrint('🔍 [GroupChatDetailController] Existing message index: $existingMessageIndex');
            
            if (existingMessageIndex != -1) {
              // Mesaj zaten var - pin durumu güncellemesi
              final existingMessage = messages[existingMessageIndex];
              debugPrint('🔍 [GroupChatDetailController] Mevcut mesaj bulundu: ID=${existingMessage.id}, Mevcut Pin=${existingMessage.isPinned}, Yeni Pin=$isPinned');
              
              if (existingMessage.isPinned != isPinned) {
                debugPrint('📌 Pin durumu değişikliği tespit edildi: Message ID=$messageId, isPinned=$isPinned');
                
                // Mesajın pin durumunu güncelle
                messages[existingMessageIndex] = existingMessage.copyWith(isPinned: isPinned);
                
                // PinnedMessagesWidget'ı güncelle
                update();
                
                
                // Pin durumu değişikliği için özel bildirim gönder
                _notifyPinStatusChange(messageId, isPinned);
                
                // Pin/Unpin işlemi için özel log
                if (isPinned) {
                  debugPrint('📌 [GroupChatDetailController] Message $messageId PINNED - PinnedMessagesWidget güncellenmeli');
                } else {
                  debugPrint('📌 [GroupChatDetailController] Message $messageId UNPINNED - PinnedMessagesWidget\'dan kaldırılmalı');
                }
                
                return; // Yeni mesaj ekleme işlemini yapma
              } else {
                debugPrint('🔍 [GroupChatDetailController] Pin durumu değişmedi, normal mesaj işlemi devam ediyor');
              }
            } else {
              debugPrint('🔍 [GroupChatDetailController] Mesaj henüz listede yok, yeni mesaj olarak ekleniyor');
            }
          } else {
            debugPrint('🔍 [GroupChatDetailController] Pin durumu kontrolü yapılmadı - messageId: $messageId, contains is_pinned: ${messageData?.containsKey('is_pinned')}');
          }
          
          // OPTIMIZE: Tüm grup detayını tekrar çekme, sadece yeni mesajı ekle
          _addNewMessageFromSocket(data);
          
          debugPrint('✅ Yeni grup mesajı işlendi');
        } else {
          debugPrint('📡 Gelen grup mesajı bu gruba ait değil. Gelen: $incomingGroupId, Mevcut: ${currentGroupId.value}');
          debugPrint('📡 Data yapısı: $data');
        }
      }
    } catch (e) {
      debugPrint('❌ _onNewGroupMessage error: $e');
    }
  }

  /// Pin durumu değişikliği için özel bildirim gönder
  void _notifyPinStatusChange(String messageId, bool isPinned) {
    try {
      debugPrint('📌 [GroupChatDetailController] Pin durumu değişikliği bildirimi gönderiliyor');
      debugPrint('📌 Message ID: $messageId, Is Pinned: $isPinned');
      
      // PinnedMessagesWidget'ın anlık güncellenmesi için özel event gönder
      final pinUpdateData = {
        'message_id': messageId,
        'is_pinned': isPinned,
        'group_id': currentGroupId.value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Pin event'ini tetikle - bu zaten _onPinMessageUpdate metodunda işlenecek
      _onPinMessageUpdate(pinUpdateData);
      
      debugPrint('📌 [GroupChatDetailController] Pin durumu değişikliği bildirimi gönderildi');
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Pin durumu bildirimi hatası: $e');
    }
  }

  /// Test için manuel pin durumu güncelleme
  void updateMessagePinStatus(String messageId, bool isPinned) {
    try {
      debugPrint('📌 [GroupChatDetailController] Manual pin status update requested');
      debugPrint('📌 Message ID: $messageId, Is Pinned: $isPinned');
      
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        final existingMessage = messages[messageIndex];
        debugPrint('📌 [GroupChatDetailController] Found message at index $messageIndex');
        debugPrint('📌 [GroupChatDetailController] Current pin status: ${existingMessage.isPinned}');
        
        if (existingMessage.isPinned != isPinned) {
          final updatedMessage = existingMessage.copyWith(isPinned: isPinned);
          messages[messageIndex] = updatedMessage;
          debugPrint('📌 [GroupChatDetailController] Message pin status updated manually');
          
          // PinnedMessagesWidget'ı güncelle
          update();
          
          debugPrint('📌 [GroupChatDetailController] Manual pin update completed');
          debugPrint('📌 [GroupChatDetailController] Pinned messages count: ${messages.where((m) => m.isPinned).length}');
        } else {
          debugPrint('📌 [GroupChatDetailController] Pin status already matches, no update needed');
        }
      } else {
        debugPrint('⚠️ [GroupChatDetailController] Message with ID $messageId not found for manual update');
      }
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Manual pin status update error: $e');
    }
  }

  /// Test için socket event'ini manuel olarak işle
  void processSocketEvent(dynamic data) {
    try {
      debugPrint('📌 [GroupChatDetailController] Manual socket event processing requested');
      debugPrint('📌 Event data: $data');
      
      // Socket event'ini manuel olarak işle
      _onNewGroupMessage(data);
      
      debugPrint('📌 [GroupChatDetailController] Manual socket event processing completed');
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Manual socket event processing error: $e');
    }
  }

  /// PinnedMessagesWidget'ı zorla yenile
  void forceRefreshPinnedWidget() {
    try {
      debugPrint('📌 [GroupChatDetailController] Force refresh PinnedMessagesWidget requested');
      
      // Widget'ı zorla yenile
      update();
      
      debugPrint('📌 [GroupChatDetailController] PinnedMessagesWidget force refresh completed');
      debugPrint('📌 [GroupChatDetailController] Current pinned messages count: ${messages.where((m) => m.isPinned).length}');
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Force refresh error: $e');
    }
  }

  /// Debug: Pinlenmiş mesajları listele
  void debugPinnedMessages() {
    try {
      debugPrint('🔍 [GroupChatDetailController] Debug: Pinned messages check');
      debugPrint('🔍 [GroupChatDetailController] Total messages: ${messages.length}');
      
      final pinnedMessages = messages.where((m) => m.isPinned).toList();
      debugPrint('🔍 [GroupChatDetailController] Pinned messages count: ${pinnedMessages.length}');
      
      for (int i = 0; i < pinnedMessages.length; i++) {
        final msg = pinnedMessages[i];
        debugPrint('🔍 [GroupChatDetailController] Pinned message $i: ID=${msg.id}, Content="${msg.content}", Username=${msg.username}');
      }
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Debug error: $e');
    }
  }

  /// Socket'ten gelen yeni mesajı direkt ekle (API çağrısı yapma)
  void _addNewMessageFromSocket(Map<String, dynamic> data) {
    try {
      debugPrint('📡 [GroupChatDetailController] Yeni grup mesajı payload alındı');
      debugPrint('📡 [GroupChatDetailController] Current Group ID: ${currentGroupId.value}');
      debugPrint('📡 [GroupChatDetailController] Processing: $data');
      
      // Socket'ten gelen data yapısı: {message: {user_id: 6, group_id: 2, message: "text", ...}}
      final messageData = data['message'] as Map<String, dynamic>?;
      if (messageData == null) {
        debugPrint('❌ [GroupChatDetailController] Message data is null');
        return;
      }
      
      // Yeni mesajı parse et ve listeye ekle
      final currentUserId = Get.find<ProfileController>().userId.value;
      
      // DUPLICATE CHECK: Aynı ID'li mesaj var mı kontrol et
      final messageId = messageData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final isDuplicate = messages.any((existingMessage) => existingMessage.id == messageId);
      if (isDuplicate) {
        debugPrint('🚫 [GroupChatDetailController] DUPLICATE MESSAGE BLOCKED: ID $messageId already exists');
        return;
      }
      
      // User data'yı al
      final userData = messageData['user'] as Map<String, dynamic>?;
      
      // Message type'ı belirle
      GroupMessageType messageType = GroupMessageType.text;
      String content = messageData['message'] ?? '';
      List<String>? pollOptions;
      bool? isMultipleChoice;
      int? surveyId;
      List<String>? links;
      List<String>? media;
      
      // Survey mesajları için özel işlem
      if (messageData['type'] == 'survey' && messageData['survey'] != null) {
        messageType = GroupMessageType.survey;
        final surveyData = messageData['survey'] as Map<String, dynamic>;
        content = surveyData['title'] ?? '';
        isMultipleChoice = surveyData['multiple_choice'] ?? false;
        surveyId = surveyData['id'];
        
        // Survey seçeneklerini al
        if (surveyData['choices'] != null) {
          final choices = surveyData['choices'] as List<dynamic>;
          pollOptions = choices.map((choice) => (choice['title'] ?? '').toString()).toList();
        }
      } else if (messageData['type'] == 'poll') {
        messageType = GroupMessageType.poll;
        // Poll seçeneklerini al
        if (messageData['poll_options'] != null) {
          pollOptions = List<String>.from(messageData['poll_options']);
        }
      }
      
      // Media ve link bilgilerini al
      if (messageData['media'] != null) {
        final mediaList = messageData['media'] as List<dynamic>;
        media = mediaList.map((m) => m['full_path'] ?? m['path'] ?? '').cast<String>().toList();
      }
      
      if (messageData['group_chat_link'] != null) {
        final linkList = messageData['group_chat_link'] as List<dynamic>;
        links = linkList.map((l) => l['link'] ?? '').cast<String>().toList();
      }
      

      
      final newMessage = GroupMessageModel(
        id: messageId,
        senderId: messageData['user_id']?.toString() ?? '',
        receiverId: currentGroupId.value,
        name: userData?['name'] ?? '',
        surname: userData?['surname'] ?? '',
        username: userData?['username'] ?? '',
        profileImage: userData?['avatar_url'] ?? '',
        content: content,
        messageType: messageType,
        timestamp: DateTime.parse(messageData['created_at'] ?? DateTime.now().toIso8601String()),
        isSentByMe: messageData['user_id']?.toString() == currentUserId,
        pollOptions: pollOptions,
        isMultipleChoice: isMultipleChoice,
        surveyId: surveyId,
        links: links,
        media: media,
      );
      
      messages.add(newMessage);
      debugPrint('✅ [GroupChatDetailController] Yeni grup mesajı eklendi: ID ${newMessage.id}, Content: "${newMessage.content}"');
      debugPrint('✅ [GroupChatDetailController] Toplam grup mesaj sayısı: ${messages.length}');
      
      // Yeni mesaj eklendiğinde en alta git
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottomForNewMessage();
      });
      
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] _addNewMessageFromSocket error: $e');
      // Fallback: Tüm mesajları yeniden yükle
      refreshMessagesOnly();
    }
  }



  /// Group chat socket durumunu kontrol et
  void checkGroupChatSocketConnection() {
    
    // Socket service'den detaylı durum raporu al
    _socketService.checkSocketStatus();
    
  }

  /// Group chat'e girdiğinde socket durumunu kontrol et
  void onGroupChatEntered() {
    debugPrint('🚪 Group chat\'e girildi, socket durumu kontrol ediliyor...');
    checkGroupChatSocketConnection();
    
    // Group chat'e girdiğinde gruba join ol
    if (_socketService.isConnected.value) {
      
      final joinData = {
        'group_id': currentGroupId.value,
      };
      
      
      _socketService.sendMessage('group:join', joinData);
      
      debugPrint('✅ group:join event\'i başarıyla gönderildi!');
    } else {
      debugPrint('❌ Socket bağlantısı yok! group:join gönderilemedi.');
      debugPrint('🔍 Socket durumu: ${_socketService.isConnected.value}');
    }
  }



  /// OPTIMIZE: Background message conversion with pagination support
  Future<void> convertGroupChatsToMessagesOptimized() async {
    if (groupData.value?.groupChats == null) return;
    
    try {
      final groupChats = groupData.value!.groupChats;
      final currentUserId = Get.find<ProfileController>().userId.value;
      
      // DEBUG: Group mesajlarının sayısını yazdır
      debugPrint('📊 Group chats count: ${groupChats.length}');
      
      // PAGINATION: Process all messages without limit
      final messagesToProcess = groupChats;
      
      // Performance: Batch processing
      final processedMessages = <GroupMessageModel>[];
      
      // Cache kullanıcı verilerini tek seferde
      for (final chat in messagesToProcess) {
        final userId = chat.userId.toString();
        if (!_userCache.containsKey(userId)) {
          _userCache[userId] = chat.user;
        }
      }
      
      // OPTIMIZE: Process in smaller batches to prevent UI freeze
      const batchSize = 10;
      for (int i = 0; i < messagesToProcess.length; i += batchSize) {
        final batch = messagesToProcess.skip(i).take(batchSize);
        
        for (final chat in batch) {
          try {
            final userId = chat.userId.toString();
            final user = _userCache[userId]!;
            final isSentByMe = userId == currentUserId;
            
            // FIXED: Safe message type determination
            final messageData = _determineMessageType(chat);
            
            // Media dosyalarını al
            List<String>? mediaUrls;
            if (chat.media.isNotEmpty) {
              mediaUrls = chat.media.map((media) => media.fullPath).toList();
            }
            

            
            final message = GroupMessageModel(
                  id: chat.id.toString(),
                  senderId: userId,
                  receiverId: chat.groupId.toString(),
                  name: user['name'] ?? '',
                  surname: user['surname'] ?? '',
                  username: user['username'] ?? user['name'] ?? '',
                  profileImage: user['avatar_url'] ?? '',
                  content: messageData['content'],
                  messageType: messageData['type'],
                  timestamp: DateTime.parse(chat.createdAt),
                  isSentByMe: isSentByMe,
                  pollOptions: messageData['pollOptions'],
                  additionalText: messageData['additionalText'],
                  links: messageData['links'],
                  media: mediaUrls,
                  isMultipleChoice: messageData['isMultipleChoice'],
                  surveyId: messageData['surveyId'],
                  choiceIds: messageData['choiceIds'],
                  surveyData: messageData['surveyData'],
                  isPinned: chat.isPinned, // Pin durumunu ekle
                );
            
            processedMessages.add(message);
          } catch (e) {
            debugPrint('⚠️ Error processing message ${chat.id}: $e');
            // Skip this message and continue
          }
        }
        
        // Allow UI to update between batches
        if (i + batchSize < messagesToProcess.length) {
          await Future.delayed(Duration(milliseconds: 1));
        }
      }
      
      // FIXED: API'den gelen mesajlar zaten doğru sıralı (en yeni en altta)
      // API sırasını koru, ekstra sıralama yapma
      // processedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      // PAGINATION: Update state based on first load or not
      if (isFirstLoad.value) {
        messages.assignAll(processedMessages);
        
        // Since we're loading all messages, no more messages to load
        hasMoreMessages.value = false;
        
        isFirstLoad.value = false;
        debugPrint('✅ Initial ${processedMessages.length} group messages loaded (proper chronological order)');
        debugPrint('📊 Mesaj sayısı kontrolü: ${messages.length} mesaj yüklendi');
        
        // Pin durumu debug log'ları
        final pinnedCount = messages.where((msg) => msg.isPinned).length;
        debugPrint('📌 Pin durumu kontrolü: $pinnedCount pinlenmiş mesaj bulundu');
        for (int i = 0; i < messages.length; i++) {
          final msg = messages[i];
          if (msg.isPinned) {
            debugPrint('📌 Pinlenmiş mesaj $i: ID=${msg.id}, Content="${msg.content}"');
          }
        }
        
        // Pinlenmiş mesajlar varsa UI'ı güncelle
        if (pinnedCount > 0) {
          update();
          debugPrint('📌 UI güncellendi - pinlenmiş mesajlar gösteriliyor');
        }
      } else {
        messages.assignAll(processedMessages);
        debugPrint('📊 Mesaj sayısı güncellendi: ${messages.length} mesaj');
        
        // Pin durumu debug log'ları
        final pinnedCount = messages.where((msg) => msg.isPinned).length;
        debugPrint('📌 Pin durumu kontrolü: $pinnedCount pinlenmiş mesaj bulundu');
      }
      
      // Extract media in background
      Future.microtask(() {
        extractGroupChatMedia();
      });
      
      debugPrint('✅ Processed ${processedMessages.length} messages successfully');
      
    } catch (e) {
      debugPrint('❌ Error in convertGroupChatsToMessagesOptimized: $e');
    }
  }

  /// Helper function for message type determination - FIXED
  Map<String, dynamic> _determineMessageType(dynamic chat) {
    GroupMessageType messageType = GroupMessageType.text;
    String content = chat.message ?? '';
    List<String>? links;
    List<String>? pollOptions;
                  String? additionalText;
              bool? isMultipleChoice;
              int? surveyId;
              List<int>? choiceIds;
              Map<String, dynamic>? surveyData;
    

    
                  try {
                if (chat.messageType == 'poll') {
                  messageType = GroupMessageType.poll;
                  content = chat.message ?? '';
                  pollOptions = ['Seçenek 1', 'Seçenek 2']; 
                } else if (chat.messageType == 'survey' || chat.surveyId != null || chat.survey != null) {
                  messageType = GroupMessageType.survey;
                  
                  debugPrint('🔍 Survey mesajı tespit edildi');
                  debugPrint('🔍 chat.survey: ${chat.survey}');
                  debugPrint('🔍 chat.message: ${chat.message}');
                  debugPrint('🔍 chat.surveyId: ${chat.surveyId}');
                  
                  // Survey verisi survey objesi içinde geliyor
                  if (chat.survey != null) {
                    content = chat.survey['title'] ?? '';
                    isMultipleChoice = chat.survey['multiple_choice'] ?? false;
                    surveyId = chat.survey['id'];
                    surveyData = chat.survey; // Tüm survey verisini sakla
                    
                    debugPrint('🔍 Survey title: $content');
                    debugPrint('🔍 Survey multiple_choice: $isMultipleChoice');
                    debugPrint('🔍 Survey ID: $surveyId');
                    
                    // Survey seçeneklerini al
                    if (chat.survey['choices'] != null) {
                      final choices = chat.survey['choices'] as List<dynamic>;
                      pollOptions = choices.map((choice) => choice['title'] ?? '').cast<String>().toList();
                      choiceIds = choices.map((choice) => choice['id'] ?? 0).cast<int>().toList();
                      debugPrint('🔍 Survey choices: $pollOptions');
                      debugPrint('🔍 Survey choice IDs: $choiceIds');
                    }
                  } else {
                    // Fallback
                    content = chat.message ?? '';
                    isMultipleChoice = false;
                    surveyId = chat.surveyId;
                    debugPrint('🔍 Fallback - content: $content');
                  }
      } else if (chat.media != null && chat.media.isNotEmpty) {
        final media = chat.media.first;
        if (media.type != null && media.type.toString().startsWith('image/')) {
          // Eğer hem text hem image varsa, textWithLinks tipini kullan (universal widget için)
          if (chat.message != null && chat.message.toString().isNotEmpty) {
            messageType = GroupMessageType.textWithLinks;
            content = chat.message.toString();
          } else {
            messageType = GroupMessageType.image;
            content = media.fullPath ?? '';
          }
        } else {
          messageType = GroupMessageType.document;
          content = media.fullPath ?? '';
        }
      }
      
      // Link kontrolü - media kontrolünden sonra yapılmalı
      if (chat.groupChatLink != null && chat.groupChatLink.isNotEmpty) {
        // FIXED: Safe type casting for links
        final chatLinks = <String>[];
        
        for (var link in chat.groupChatLink) {
          if (link?.link != null) {
            final linkStr = link.link.toString();
            if (linkStr.isNotEmpty) {
              chatLinks.add(linkStr);
            }
          }
        }
        
        if (chat.message != null && chat.message.toString().isNotEmpty) {
          messageType = GroupMessageType.textWithLinks;
          content = chat.message.toString();
          links = chatLinks.isNotEmpty ? chatLinks : null;
        } else if (chatLinks.isNotEmpty) {
          // Eğer sadece link varsa ve media da varsa, textWithLinks kullan
          if (chat.media != null && chat.media.isNotEmpty) {
            messageType = GroupMessageType.textWithLinks;
            content = ''; // Boş text
            links = chatLinks.isNotEmpty ? chatLinks : null;
          } else {
            messageType = GroupMessageType.link;
            content = chatLinks.first;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error determining message type: $e');
      // Fallback to text message
      messageType = GroupMessageType.text;
      content = chat.message?.toString() ?? '';
    }
    
                  return {
                'type': messageType,
                'content': content,
                'links': links,
                'pollOptions': pollOptions,
                'additionalText': additionalText,
                'isMultipleChoice': isMultipleChoice,
                'surveyId': surveyId,
                'choiceIds': choiceIds,
                'surveyData': surveyData,
              };
  }

  /// FIXED: Proper scroll to bottom with timing
  void scrollToBottomAfterLoad() {
    debugPrint('📜 Group Chat - scrollToBottomAfterLoad called, messages: ${messages.length}');
    
    // Allow UI to render first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Multiple delayed attempts for better reliability
      Future.delayed(Duration(milliseconds: 100), () {
        if (scrollController.hasClients && messages.isNotEmpty) {
          scrollToBottom(animated: false);
        }
      });
      
      // Second attempt with longer delay
      Future.delayed(Duration(milliseconds: 300), () {
        if (scrollController.hasClients && messages.isNotEmpty) {
          scrollToBottom(animated: false);
        }
      });
      
      // Final attempt
      Future.delayed(Duration(milliseconds: 600), () {
        if (scrollController.hasClients && messages.isNotEmpty) {
          scrollToBottom(animated: false);
        }
      });
    });
  }

  /// FIXED: Scroll to bottom for new messages
  void scrollToBottomForNewMessage() {
    final currentMessageCount = messages.length;
    debugPrint('📜 Group Chat - scrollToBottomForNewMessage called, messages: $currentMessageCount, last: $_lastMessageCount');
    
    // Only scroll if message count actually increased (new message added)
    if (currentMessageCount <= _lastMessageCount) {
      debugPrint('📜 Group Chat - No new messages, skipping auto-scroll');
      return;
    }
    
    _lastMessageCount = currentMessageCount;
    
    // Check if user is already at bottom (within 100px) before scrolling
    if (scrollController.hasClients) {
      final position = scrollController.position;
      final isNearBottom = position.maxScrollExtent - position.pixels < 100;
      
      if (!isNearBottom) {
        debugPrint('📜 Group Chat - User scrolled away from bottom, not auto-scrolling');
        return;
      }
    }
    
    // Immediate scroll for new messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients && messages.isNotEmpty) {
        debugPrint('📜 Group Chat - Auto-scrolling to bottom for new message');
        scrollToBottom(animated: true);
      }
    });
  }

  /// Test function for manual scroll
  void testScrollToBottom() {
    debugPrint('🧪 === SCROLL TEST ===');
    debugPrint('🧪 Messages count: ${messages.length}');
    debugPrint('🧪 ScrollController hasClients: ${scrollController.hasClients}');
    if (scrollController.hasClients) {
      debugPrint('🧪 Current position: ${scrollController.position.pixels}');
      debugPrint('🧪 Max extent: ${scrollController.position.maxScrollExtent}');
      debugPrint('🧪 Has content dimensions: ${scrollController.position.hasContentDimensions}');
    }
    debugPrint('🧪 Attempting to scroll...');
    scrollToBottom(animated: true);
    debugPrint('🧪 ==================');
  }

  /// Socket ve listener durumunu kontrol et
  void checkSocketConnection() {
    debugPrint('🔍 === GRUP CHAT SOCKET DURUM RAPORU ===');
    debugPrint('🔍 Current Group ID: ${currentGroupId.value}');
    debugPrint('🔍 Socket Service bağlı: ${_socketService.isConnected.value}');
    
    // Socket service'den durum kontrolü yap
    _socketService.checkSocketStatus();
    
    debugPrint('🔍 Grup mesaj subscription aktif: ${!_groupMessageSubscription.isPaused}');
    debugPrint('🔍 ================================');
  }

  void extractGroupChatMedia() {
    if (groupData.value?.groupChats == null) return;
    
    final groupChats = groupData.value!.groupChats;
    
    // Listeleri temizle
    groupDocuments.clear();
    groupLinks.clear();
    groupPhotos.clear();
    
    for (final chat in groupChats) {
      // Belgeler ve fotoğraflar
      for (final media in chat.media) {
        if (media.type.startsWith('image/')) {
          // Fotoğraf
          if (!groupPhotos.contains(media.fullPath)) {
            groupPhotos.add(media.fullPath);
          }
        } else {
          // Belge
          final document = DocumentModel(
            id: media.id.toString(),
            name: media.title,
            sizeMb: double.tryParse(media.fileSize) ?? 0.0,
            humanCreatedAt: media.humanCreatedAt,
            createdAt: DateTime.parse(chat.createdAt),
            url: media.fullPath,
          );
          
          // Aynı belgeyi tekrar eklemeyi önle
          if (!groupDocuments.any((doc) => doc.id == document.id)) {
            groupDocuments.add(document);
          }
        }
      }
      
      // Bağlantılar
      for (final link in chat.groupChatLink) {
        final linkModel = LinkModel(
          url: link.link,
          title: link.linkTitle,
        );
        
        // Aynı bağlantıyı tekrar eklemeyi önle
        if (!groupLinks.any((l) => l.url == linkModel.url)) {
          groupLinks.add(linkModel);
        }
      }
    }
    
    // Belgeleri tarihe göre sırala (en yeni önce)
    groupDocuments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Linkleri tarihe göre sırala (en yeni önce)
    // Link'lerin tarih bilgisi yok, mesaj sırasına göre sırala
    // Bu durumda mesaj sırasına göre sırala (en son eklenen en üstte)
    
    // Fotoğrafları tarihe göre sırala (en yeni önce)
    // Fotoğraflar mesaj sırasına göre zaten sıralı geliyor
    
    debugPrint('📁 Extracted ${groupDocuments.length} documents from group chats (sorted by date)');
    debugPrint('🔗 Extracted ${groupLinks.length} links from group chats');
    debugPrint('📸 Extracted ${groupPhotos.length} photos from group chats');
  }

  Future<void> fetchGroupMessages() async {
    try {
      debugPrint('Fetching messages for group: ${currentGroupId.value}');
      
      // Grup verileri zaten yüklendi, sadece mesajları dönüştür
      if (groupData.value != null) {
        convertGroupChatsToMessagesOptimized();
      }
      
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      Get.snackbar(
        _languageService.tr('groupChat.errors.loadFailed'),
        _languageService.tr('groupChat.errors.messageSendFailed'),
        snackPosition: SnackPosition.BOTTOM
      );
    }
  }

  void openPollBottomSheet() {
    pollQuestion.value = '';
    pollOptions.assignAll(['', '']);
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              TextField(
                style: TextStyle(fontSize: 12),
                controller: pollTitleController,
                decoration: InputDecoration(
                  hintText: _languageService.tr("chat.poll.title"),
                  filled: true,
                  fillColor: const Color(0xfff5f5f5),
                  hintStyle:
                      const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => pollQuestion.value = val,
              ),
              const SizedBox(height: 30),
              Obx(() => Column(
                    children: List.generate(pollOptions.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: _languageService.tr("chat.poll.addOption"),
                                  filled: true,
                                  fillColor: const Color(0xfff5f5f5),
                                  hintStyle: const TextStyle(
                                      color: Color(0xFF9CA3AF), fontSize: 12),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (val) => pollOptions[index] = val,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (pollOptions.length > 2)
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () => pollOptions.removeAt(index),
                              ),
                          ],
                        ),
                      );
                    }),
                  )),
              TextButton.icon(
                onPressed: () => pollOptions.add(''),
                icon: const Icon(
                  Icons.add,
                  color: Color(0xffED7474),
                  size: 15,
                ),
                label: Text(
                  _languageService.tr("chat.poll.addOption"),
                  style: TextStyle(color: Color(0xffED7474), fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),

              /**
               *  backgroundColor: const Color(0xffFFF6F6),
                    foregroundColor: const Color(0xffED7474),
               */
              CustomButton(
                  text: _languageService.tr("chat.poll.send"),
                  height: 45,
                  borderRadius: 15,
                  onPressed: () {
                    final filledOptions =
                        pollOptions.where((e) => e.trim().isNotEmpty).toList();
                    if (pollTitleController.text.trim().isNotEmpty &&
                        filledOptions.length >= 2) {
                      sendPoll(pollTitleController.text, filledOptions);
                      Get.back();
                    }
                  },
                  isLoading: isSendingMessage,
                  backgroundColor: Color(0xffFFF6F6),
                  textColor: Color(0xffED7474)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void votePoll(String option) {
    if (!pollVotes.containsKey(option)) {
      pollVotes[option] = 1;
    } else {
      pollVotes[option] = pollVotes[option]! + 1;
    }
    selectedPollOption.value = option;
  }

  void sendPoll(String question, List<String> options) async {
    if (isSendingMessage.value) return;
    
    isSendingMessage.value = true;
    
    try {
      // Poll mesajını API'ye gönder
      final success = await _groupServices.sendGroupMessage(
        groupId: currentGroupId.value,
        message: question,
        pollOptions: options,
      );
      
      if (success) {
        // Başarılı ise mesajları yeniden yükle
        await refreshMessagesOnly();
        
        // Poll gönderildikten sonra en alta git
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom(animated: true);
        });
      } else {
        Get.snackbar(
          'Hata',
          'Anket gönderilemedi',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Anket gönderme hatası: $e');
      Get.snackbar(
        'Hata',
        'Anket gönderilemedi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  // Survey functions
  void openSurveyBottomSheet() {
    surveyTitle.value = '';
    surveyChoices.assignAll(['', '']);
    isMultipleChoice.value = false;
    surveyTitleController.clear();
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              TextField(
                style: TextStyle(fontSize: 12),
                controller: surveyTitleController,
                decoration: InputDecoration(
                  hintText: _languageService.tr("chat.survey.title"),
                  filled: true,
                  fillColor: const Color(0xfff5f5f5),
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => surveyTitle.value = val,
              ),
              const SizedBox(height: 20),
              Obx(() => Row(
                children: [
                  Checkbox(
                    value: isMultipleChoice.value,
                    onChanged: (value) => isMultipleChoice.value = value ?? false,
                    activeColor: Color(0xffED7474),
                  ),
                  Text(
                    _languageService.tr("chat.survey.multipleChoice"),
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              )),
              const SizedBox(height: 30),
              Obx(() => Column(
                children: List.generate(surveyChoices.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: _languageService.tr("chat.survey.addChoice"),
                              filled: true,
                              fillColor: const Color(0xfff5f5f5),
                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (val) => surveyChoices[index] = val,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (surveyChoices.length > 2)
                          IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () => surveyChoices.removeAt(index),
                          ),
                      ],
                    ),
                  );
                }),
              )),
              TextButton.icon(
                onPressed: () => surveyChoices.add(''),
                icon: const Icon(
                  Icons.add,
                  color: Color(0xffED7474),
                  size: 15,
                ),
                label: Text(
                  _languageService.tr("chat.survey.addChoice"),
                  style: TextStyle(color: Color(0xffED7474), fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: _languageService.tr("chat.survey.send"),
                height: 45,
                borderRadius: 15,
                onPressed: () {
                  final filledChoices = surveyChoices.where((e) => e.trim().isNotEmpty).toList();
                  if (surveyTitleController.text.trim().isNotEmpty && filledChoices.length >= 2) {
                    sendSurvey(surveyTitleController.text, filledChoices);
                    Get.back();
                  }
                },
                isLoading: isSendingMessage,
                backgroundColor: Color(0xffFFF6F6),
                textColor: Color(0xffED7474),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void sendSurvey(String title, List<String> choices) async {
    if (isSendingMessage.value) return;
    
    isSendingMessage.value = true;
    
    try {
      debugPrint('📊 Survey gönderme başlatılıyor...');
      debugPrint('📊 Group ID: ${currentGroupId.value}');
      debugPrint('📊 Title: $title');
      debugPrint('📊 Choices: $choices');
      debugPrint('📊 Multiple Choice: ${isMultipleChoice.value}');
      
      final success = await SurveyService.createSurvey(
        receiverId: int.parse(currentGroupId.value),
        isGroup: true,
        title: title,
        multipleChoice: isMultipleChoice.value,
        choices: choices,
      );
      
      if (success) {
        // Başarılı ise mesajları yeniden yükle
        await refreshMessagesOnly();
        
        // Survey gönderildikten sonra en alta git
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom(animated: true);
        });
        
        Get.snackbar(
          'Başarılı',
          'Anket başarıyla gönderildi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Hata',
          'Anket gönderilemedi',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Survey gönderme hatası: $e');
      Get.snackbar(
        'Hata',
        'Anket gönderilemedi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  void answerSurvey(int surveyId, List<String> selectedChoices) async {
    try {
      // Seçilen choice'ların ID'lerini bul
      List<int> answerIds = [];
      
      // String olarak gelen choice ID'lerini int'e çevir
      for (String choice in selectedChoices) {
        final choiceId = int.tryParse(choice);
        if (choiceId != null) {
          answerIds.add(choiceId);
        }
      }
      
      final success = await SurveyService.answerSurvey(
        surveyId: surveyId,
        answerIds: answerIds,
      );
      
      if (success) {
        // Başarılı ise mesajları yeniden yükle
        await refreshMessagesOnly();
      } else {
        Get.snackbar(
          'Hata',
          'Anket cevabı kaydedilemedi',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Survey cevaplama hatası: $e');
      Get.snackbar(
        'Hata',
        'Anket cevabı kaydedilemedi',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      selectedFiles.add(file);
    }
  }

  void pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        selectedFiles.add(file);
        
        debugPrint("Seçilen dosya: $filePath");
      }
    } catch (e) {
      debugPrint("Belge seçme hatası: $e",wrapWidth: 1024);
    }
  }

  Future<void> sendMessage(String text) async {
    if (isSendingMessage.value) return;
    
    debugPrint('📤 Sending message: "$text"');
    
    if (text.isEmpty && selectedFiles.isEmpty) {
      debugPrint('❌ Nothing to send');
      return;
    }
    
    if (text.isEmpty && selectedFiles.isNotEmpty) {
      debugPrint('📁 Sending only media files');
      await sendMediaOnly();
      return;
    }
    
    // Socket durumunu kontrol et
    debugPrint('🔌 Socket durumu kontrol ediliyor...');
    debugPrint('🔌 Socket bağlı: ${_socketService.isConnected.value}');
    debugPrint('🔌 Socket ID: ${_socketService.socket?.id}');
    debugPrint('🔌 Group Message Subscription aktif: ${!_groupMessageSubscription.isPaused}');
    
    isSendingMessage.value = true;
    
    try {
      bool success;
      
      if (text.isNotEmpty && hasLinksInText(text)) {
        debugPrint('🔗 Links detected in text, processing...');
        
        final urls = extractUrlsFromText(text);
        final nonLinkText = extractNonLinkText(text);
        final normalizedUrls = urls.map((url) => normalizeUrl(url)).toList();
        
        success = await _groupServices.sendGroupMessage(
          groupId: currentGroupId.value,
          message: nonLinkText,
          mediaFiles: selectedFiles.isNotEmpty ? selectedFiles : null,
          links: normalizedUrls,
        );
      } else {
        success = await _groupServices.sendGroupMessage(
          groupId: currentGroupId.value,
          message: text,
          mediaFiles: selectedFiles.isNotEmpty ? selectedFiles : null,
          links: null,
        );
      }
      
      if (success) {
        selectedFiles.clear();
        
        // Socket üzerinden mesaj gelip gelmediğini kontrol et
        debugPrint('✅ Mesaj başarıyla gönderildi, socket üzerinden gelmesi bekleniyor...');
        
        // Socket üzerinden mesaj gelmesi için kısa bir süre bekle
        bool socketMessageReceived = false;
        final originalMessageCount = messages.length;
        
        // 2 saniye boyunca socket mesajını bekle
        for (int i = 0; i < 20; i++) {
          await Future.delayed(Duration(milliseconds: 100));
          if (messages.length > originalMessageCount) {
            debugPrint('✅ Socket üzerinden yeni mesaj geldi!');
            socketMessageReceived = true;
            break;
          }
        }
        
        if (!socketMessageReceived) {
          debugPrint('⚠️ Socket üzerinden mesaj gelmedi, API\'den yeniden yüklenecek...');
        }
        
        // FIXED: Immediate scroll for better UX, then refresh
        scrollToBottomForNewMessage();
        
        // OPTIMIZE: Reduced refresh delay
        Future.delayed(Duration(milliseconds: 300), () async {
          await refreshMessagesOptimized();
          // Ensure we stay at bottom after refresh
          scrollToBottomForNewMessage();
        });
      } else {
        Get.snackbar(
          _languageService.tr('groupChat.errors.messageSendFailed'),
          _languageService.tr('groupChat.errors.tryAgain'),
          snackPosition: SnackPosition.BOTTOM
        );
      }
      
    } catch (e) {
      debugPrint('💥 Message sending error: $e');
      Get.snackbar(
        _languageService.tr('groupChat.errors.messageSendFailed'),
        _languageService.tr('groupChat.errors.tryAgain'),
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  // Sadece media dosyalarını gönder (text olmadan)
  Future<void> sendMediaOnly() async {
    if (isSendingMessage.value) return;
    
    debugPrint('📁 Sending media files only');
    isSendingMessage.value = true;
    
    try {
      final success = await _groupServices.sendGroupMessage(
        groupId: currentGroupId.value,
        message: '', // Boş text
        mediaFiles: selectedFiles,
        links: null,
      );
      
      if (success) {
        selectedFiles.clear();
        
        // FIXED: Same scroll behavior for media
        scrollToBottomForNewMessage();
        
        Future.delayed(Duration(milliseconds: 300), () async {
          await refreshMessagesOptimized();
          scrollToBottomForNewMessage();
        });
      } else {
        Get.snackbar(
          _languageService.tr('groupChat.errors.messageSendFailed'),
          _languageService.tr('groupChat.errors.tryAgain'),
          snackPosition: SnackPosition.BOTTOM
        );
      }
      
    } catch (e) {
      debugPrint('💥 Media sending error: $e');
      Get.snackbar(
        _languageService.tr('groupChat.errors.messageSendFailed'),
        _languageService.tr('groupChat.errors.tryAgain'),
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  void clearSelectedItems() {
    selectedFiles.clear();
  }

  void scrollToBottom({bool animated = true}) {
    try {
      if (scrollController.hasClients && 
          scrollController.position.hasContentDimensions &&
          messages.isNotEmpty) {
        
        final maxScroll = scrollController.position.maxScrollExtent;
        debugPrint('📜 Group Chat - Scrolling to bottom: maxScroll = $maxScroll');
        
        if (animated) {
          scrollController.animateTo(
            maxScroll,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          scrollController.jumpTo(maxScroll);
        }
      } else {
        debugPrint('⚠️ Group Chat - Cannot scroll: hasClients=${scrollController.hasClients}, messages=${messages.length}');
      }
    } catch (e) {
      debugPrint('❌ Group Chat - Scroll error: $e');
    }
  }

  void getToGrupDetailScreen() {
    debugPrint('🔍 Navigating to group detail screen with group ID: ${currentGroupId.value}');
    Get.toNamed("/groupDetailScreen", arguments: {
      'groupId': currentGroupId.value,
    });
  }

  // OPTIMIZE: Faster message refresh
  Future<void> refreshMessagesOptimized() async {
    try {
      debugPrint('🔄 Refreshing messages (optimized)...');
      
      // Reduced timeout for faster response
      final group = await _groupServices.fetchGroupDetail(currentGroupId.value)
          .timeout(const Duration(seconds: 15)); // 5'ten 15'e çıkarıldı
      
      groupData.value = group;
      convertGroupChatsToMessagesOptimized();
      
      // Socket üzerinden pin durumlarını kontrol et
      await _checkPinStatusFromSocket();
      
      debugPrint('✅ Messages refreshed successfully');
    } catch (e) {
      debugPrint('❌ Error refreshing messages: $e');
    }
  }

  // Keep backwards compatibility
  Future<void> refreshMessagesOnly() async {
    await refreshMessagesOptimized();
  }

  /// Pin message update handler - socket'ten gelen pin/unpin event'lerini işle
  void _onPinMessageUpdate(dynamic data) {
    try {
      debugPrint('📌 [GroupChatDetailController] Pin message update received: $data');
      debugPrint('📌 [GroupChatDetailController] Data type: ${data.runtimeType}');
      debugPrint('📌 [GroupChatDetailController] Data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}');
      
      if (data is Map<String, dynamic>) {
        // Pin durumu kontrolü response'u mu kontrol et
        if (data.containsKey('pinned_messages') || data.containsKey('pin_status')) {
          _handlePinStatusResponse(data);
          return;
        }
        
        // Group chat için özel event kontrolü
        if (data.containsKey('group_id')) {
          final groupId = data['group_id']?.toString();
          final messageId = data['message_id']?.toString();
          final isPinned = data['is_pinned'] ?? false;
          
          debugPrint('📌 [GroupChatDetailController] Group chat pin event detected');
          debugPrint('📌 [GroupChatDetailController] Group ID: $groupId, Message ID: $messageId, Is Pinned: $isPinned');
          debugPrint('📌 [GroupChatDetailController] Current Group ID: ${currentGroupId.value}');
          
          // Sadece bu grup için gelen pin event'lerini işle
          if (groupId != null && groupId == currentGroupId.value && messageId != null) {
            _updateMessagePinStatus(messageId, isPinned);
            return;
          } else {
            debugPrint('📌 [GroupChatDetailController] Pin event not for this group. Group ID: $groupId, Current: ${currentGroupId.value}');
            return;
          }
        }
        
        // Yeni pin event yapısı kontrolü (SocketService'den gelen)
        if (data.containsKey('source') && data['source'] == 'group:chat_message') {
          _handleSocketPinUpdate(data);
          return;
        }
        
        // Yeni: group:unpin_message event kontrolü
        if (data.containsKey('source') && data['source'] == 'group:unpin_message') {
          _handleSocketUnpinUpdate(data);
          return;
        }
        
        // Action kontrolü (unpin işlemi için)
        if (data.containsKey('action') && data['action'] == 'unpin') {
          _handleSocketUnpinUpdate(data);
          return;
        }
        
        // Event yapısını kontrol et - message objesi içinde olabilir
        Map<String, dynamic> messageData;
        if (data.containsKey('message')) {
          // message alanının Map olup olmadığını kontrol et
          if (data['message'] is Map<String, dynamic>) {
            messageData = data['message'] as Map<String, dynamic>;
            debugPrint('📌 [GroupChatDetailController] Message data found in nested structure');
          } else {
            // message alanı Map değilse, direkt data'yı kullan
            messageData = data;
            debugPrint('📌 [GroupChatDetailController] Message data found in direct structure (message not a Map)');
          }
        } else {
          messageData = data;
          debugPrint('📌 [GroupChatDetailController] Message data found in direct structure');
        }
        
        final messageId = messageData['id']?.toString();
        final isPinned = messageData['is_pinned'] ?? false;
        final groupId = messageData['group_id']?.toString();
        
        debugPrint('📌 [GroupChatDetailController] Parsed data - Message ID: $messageId, Group ID: $groupId, Is Pinned: $isPinned');
        debugPrint('📌 [GroupChatDetailController] Current Group ID: ${currentGroupId.value}');
        
        // Sadece bu grup için gelen pin event'lerini işle
        if (groupId != null && groupId == currentGroupId.value && messageId != null) {
          _updateMessagePinStatus(messageId, isPinned);
        } else {
          debugPrint('📌 [GroupChatDetailController] Pin event not for this group. Group ID: $groupId, Current: ${currentGroupId.value}');
        }
      }
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Pin message update error: $e');
    }
  }

  /// Socket'ten gelen unpin güncellemelerini işle
  void _handleSocketUnpinUpdate(Map<String, dynamic> data) {
    try {
      debugPrint('📌 [GroupChatDetailController] Socket unpin update handling...');
      
      final messageId = data['message_id']?.toString();
      final groupId = data['group_id']?.toString();
      final isPinned = data['is_pinned'] ?? false;
      final timestamp = data['timestamp'];
      final source = data['source'];
      final action = data['action'];
      
      debugPrint('📌 [GroupChatDetailController] Socket unpin update - Message ID: $messageId, Group ID: $groupId, Is Pinned: $isPinned');
      debugPrint('📌 [GroupChatDetailController] Socket unpin update - Source: $source, Action: $action, Timestamp: $timestamp');
      
      // Sadece bu grup için gelen unpin event'lerini işle
      if (groupId != null && groupId == currentGroupId.value && messageId != null) {
        debugPrint('📌 [GroupChatDetailController] Processing unpin for message $messageId');
        _updateMessagePinStatus(messageId, isPinned);
        
        // Unpin işlemi için özel işlem
        debugPrint('📌 [GroupChatDetailController] Unpin operation detected - Forcing PinnedMessagesWidget refresh');
        Future.delayed(Duration(milliseconds: 200), () {
          update();
          debugPrint('📌 [GroupChatDetailController] PinnedMessagesWidget forced refresh after unpin');
        });
      } else {
        debugPrint('📌 [GroupChatDetailController] Socket unpin event not for this group. Group ID: $groupId, Current: ${currentGroupId.value}');
      }
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Socket unpin update error: $e');
    }
  }

  /// Socket'ten gelen pin güncellemelerini işle
  void _handleSocketPinUpdate(Map<String, dynamic> data) {
    try {
      debugPrint('📌 [GroupChatDetailController] Socket pin update handling...');
      
      final messageId = data['message_id']?.toString();
      final groupId = data['group_id']?.toString();
      final isPinned = data['is_pinned'] ?? false;
      final timestamp = data['timestamp'];
      final source = data['source'];
      
      debugPrint('📌 [GroupChatDetailController] Socket pin update - Message ID: $messageId, Group ID: $groupId, Is Pinned: $isPinned');
      debugPrint('📌 [GroupChatDetailController] Socket pin update - Source: $source, Timestamp: $timestamp');
      
      // Sadece bu grup için gelen pin event'lerini işle
      if (groupId != null && groupId == currentGroupId.value && messageId != null) {
        _updateMessagePinStatus(messageId, isPinned);
      } else {
        debugPrint('📌 [GroupChatDetailController] Socket pin event not for this group. Group ID: $groupId, Current: ${currentGroupId.value}');
      }
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Socket pin update error: $e');
    }
  }

  /// Mesaj pin durumunu güncelle (ortak metod)
  void _updateMessagePinStatus(String messageId, bool isPinned) {
    try {
      debugPrint('📌 [GroupChatDetailController] Updating message pin status...');
      debugPrint('📌 [GroupChatDetailController] Message ID: $messageId, Is Pinned: $isPinned');
      debugPrint('📌 [GroupChatDetailController] Current messages count: ${messages.length}');
      
      // Mesajı bul ve pin durumunu güncelle
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        final existingMessage = messages[messageIndex];
        debugPrint('📌 [GroupChatDetailController] Found message at index $messageIndex');
        debugPrint('📌 [GroupChatDetailController] Current pin status: ${existingMessage.isPinned}');
        debugPrint('📌 [GroupChatDetailController] New pin status: $isPinned');
        
        if (existingMessage.isPinned != isPinned) {
          final updatedMessage = existingMessage.copyWith(isPinned: isPinned);
          messages[messageIndex] = updatedMessage;
          debugPrint('📌 [GroupChatDetailController] Message pin status updated successfully');
          
          // PinnedMessagesWidget'ı güncellemek için update() çağır
          update();
          
          debugPrint('📌 [GroupChatDetailController] PinnedMessagesWidget update() called');
          debugPrint('📌 [GroupChatDetailController] Updated messages count: ${messages.length}');
          debugPrint('📌 [GroupChatDetailController] Pinned messages count: ${messages.where((m) => m.isPinned).length}');
          
          // Pin durumu değişikliği için özel log
          if (isPinned) {
            debugPrint('📌 [GroupChatDetailController] Message $messageId PINNED successfully');
          } else {
            debugPrint('📌 [GroupChatDetailController] Message $messageId UNPINNED successfully');
          }
          
          // PinnedMessagesWidget'ın anlık güncellenmesi için ek bildirim
          _notifyPinnedMessagesUpdate();
          
          // Unpin işlemi için özel işlem
          if (!isPinned) {
            debugPrint('📌 [GroupChatDetailController] UNPIN detected - Forcing PinnedMessagesWidget refresh');
            // Unpin durumunda widget'ı zorla yenile
            Future.delayed(Duration(milliseconds: 100), () {
              update();
              debugPrint('📌 [GroupChatDetailController] PinnedMessagesWidget forced refresh after unpin');
            });
          }
        } else {
          debugPrint('📌 [GroupChatDetailController] Pin status unchanged, no update needed');
        }
      } else {
        debugPrint('⚠️ [GroupChatDetailController] Message with ID $messageId not found in current messages');
        debugPrint('⚠️ [GroupChatDetailController] Available message IDs: ${messages.map((m) => m.id).join(', ')}');
      }
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Update message pin status error: $e');
    }
  }

  /// PinnedMessagesWidget güncellemesi için bildirim gönder
  void _notifyPinnedMessagesUpdate() {
    try {
      debugPrint('📌 [GroupChatDetailController] Notifying PinnedMessagesWidget update...');
      
      // PinnedMessagesWidget'ın anlık güncellenmesi için özel event
      final pinnedUpdateEvent = {
        'type': 'pinned_messages_update',
        'group_id': currentGroupId.value,
        'pinned_count': messages.where((m) => m.isPinned).length,
        'total_messages': messages.length,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      debugPrint('📌 [GroupChatDetailController] Pinned messages update event: $pinnedUpdateEvent');
      
      // Widget'ın güncellenmesi için update() çağır
      update();
      
      debugPrint('📌 [GroupChatDetailController] PinnedMessagesWidget update notification sent');
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Pinned messages update notification error: $e');
    }
  }

  /// Pin durumu response'larını işle
  void _handlePinStatusResponse(Map<String, dynamic> data) {
    try {
      debugPrint('📌 [GroupChatDetailController] Handling pin status response: $data');
      
      // Pinned messages listesi varsa
      if (data.containsKey('pinned_messages')) {
        final pinnedMessages = data['pinned_messages'] as List<dynamic>? ?? [];
        debugPrint('📌 [GroupChatDetailController] Received ${pinnedMessages.length} pinned messages from socket');
        
        // Tüm mesajları önce unpin yap
        for (int i = 0; i < messages.length; i++) {
          if (messages[i].isPinned) {
            messages[i] = messages[i].copyWith(isPinned: false);
          }
        }
        
        // Socket'ten gelen pinlenmiş mesajları pin yap
        for (final pinnedMsg in pinnedMessages) {
          if (pinnedMsg is Map<String, dynamic>) {
            final messageId = pinnedMsg['id']?.toString();
            if (messageId != null) {
              final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
              if (messageIndex != -1) {
                messages[messageIndex] = messages[messageIndex].copyWith(isPinned: true);
                debugPrint('📌 [GroupChatDetailController] Message $messageId pinned from socket response');
              }
            }
          }
        }
        
        // UI'ı güncelle
        update();
        debugPrint('📌 [GroupChatDetailController] Pin status updated from socket response');
      }
      
      // Pin status update varsa
      if (data.containsKey('pin_status')) {
        final pinStatus = data['pin_status'] as Map<String, dynamic>?;
        if (pinStatus != null) {
          final messageId = pinStatus['message_id']?.toString();
          final isPinned = pinStatus['is_pinned'] ?? false;
          
          if (messageId != null) {
            final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
            if (messageIndex != -1) {
              messages[messageIndex] = messages[messageIndex].copyWith(isPinned: isPinned);
              update();
              debugPrint('📌 [GroupChatDetailController] Message $messageId pin status updated: $isPinned');
            }
          }
        }
      }
      
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Pin status response error: $e');
    }
  }

  /// API'den gelen pin durumlarini kontrol et ve UI'i guncelle
  void _updatePinStatusFromAPI() {
    try {
      debugPrint('🔍 [GroupChatDetailController] API\'den gelen pin durumlari kontrol ediliyor...');
      
      final allMessages = messages;
      int pinnedCount = 0;
      
      for (int i = 0; i < allMessages.length; i++) {
        final message = allMessages[i];
        if (message.isPinned) {
          pinnedCount++;
          debugPrint('🔍 [GroupChatDetailController] Pinlenmis mesaj bulundu: ID=${message.id}, Content="${message.content}"');
        }
      }
      
      debugPrint('🔍 [GroupChatDetailController] API\'den gelen toplam pinlenmis mesaj sayisi: $pinnedCount');
      
      // UI'i guncelle
      if (pinnedCount > 0) {
        update();
        debugPrint('🔍 [GroupChatDetailController] UI guncellendi - pinlenmis mesajlar gosteriliyor');
      }
      
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] API pin durumu kontrolu hatasi: $e');
    }
  }

  /// Socket üzerinden pin durumlarını kontrol et
  Future<void> _checkPinStatusFromSocket() async {
    try {
      debugPrint('🔍 [GroupChatDetailController] Socket üzerinden pin durumları kontrol ediliyor...');
      
      // Socket üzerinden pin durumlarını iste
      _socketService.sendMessage('group:get_pinned_messages', {
        'group_id': currentGroupId.value,
      });
      
      debugPrint('🔍 [GroupChatDetailController] Pin durumu isteği gönderildi: group_id=${currentGroupId.value}');
      
      // Kısa bir bekleme süresi (socket response için)
      await Future.delayed(Duration(milliseconds: 500));
      
      debugPrint('🔍 [GroupChatDetailController] Pin durumu kontrolü tamamlandı');
      
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Pin durumu kontrolü hatası: $e');
    }
  }


  @override
  void onClose() {
    // Chat liste controller'ın group message listener'ını tekrar başlat (Artık gerekli değil - sürekli aktif)
    debugPrint('▶️ ChatController group message listener artık başlatılmıyor - sürekli aktif');
    
    // Socket listener guard'ı reset et
    _isSocketListenerSetup = false;
    
    messageController.dispose();
    pollTitleController.dispose();
    scrollController.dispose();
    _groupMessageSubscription.cancel();
    _pinMessageSubscription.cancel(); // Pin message subscription'ı temizle

    _userCache.clear(); // Clear cache
    _lastMessageCount = 0; // Reset message count tracker
    super.onClose();
  }

  /// Pin or unpin a group message
  Future<void> pinMessage(int messageId) async {
    try {
      debugPrint('📌 [GroupChatDetailController] Pin/Unpin işlemi başlatıldı');
      debugPrint('📌 [GroupChatDetailController] Message ID: $messageId');
      debugPrint('📌 [GroupChatDetailController] Group ID: ${currentGroupId.value}');
      
      // Admin kontrolü - API'den gelen verileri kullan
      debugPrint('🔍 [GroupChatDetailController] === ADMIN YETKİ KONTROLÜ ===');
      debugPrint('🔍 [GroupChatDetailController] isFounder: $isCurrentUserAdmin');
      debugPrint('🔍 [GroupChatDetailController] isMember: ${groupData.value?.isMember}');
      debugPrint('🔍 [GroupChatDetailController] User Count With Admin: ${groupData.value?.userCountWithAdmin}');
      debugPrint('🔍 [GroupChatDetailController] User Count Without Admin: ${groupData.value?.userCountWithoutAdmin}');
      debugPrint('🔍 [GroupChatDetailController] === ADMIN YETKİ KONTROLÜ TAMAMLANDI ===');
      
      // Mesaj detaylarını kontrol et
      final targetMessage = messages.firstWhereOrNull((msg) => msg.id == messageId.toString());
      if (targetMessage != null) {
        debugPrint('🔍 [GroupChatDetailController] === MESAJ DETAYLARI ===');
        debugPrint('🔍 [GroupChatDetailController] Message ID: ${targetMessage.id}');
        debugPrint('🔍 [GroupChatDetailController] Message Content: ${targetMessage.content}');
        debugPrint('🔍 [GroupChatDetailController] Current Pin Status: ${targetMessage.isPinned}');
        debugPrint('🔍 [GroupChatDetailController] Message Type: ${targetMessage.messageType}');
        debugPrint('🔍 [GroupChatDetailController] Sender ID: ${targetMessage.senderId}');
        debugPrint('🔍 [GroupChatDetailController] === MESAJ DETAYLARI TAMAMLANDI ===');
      } else {
        debugPrint('❌ [GroupChatDetailController] Target message not found: $messageId');
      }
      
      if (!isCurrentUserAdmin) {
        debugPrint('❌ [GroupChatDetailController] User is not admin, cannot pin/unpin message');
        
        // TEST: Geçici olarak admin kontrolünü devre dışı bırak
        debugPrint('🔧 [GroupChatDetailController] TEST: Admin kontrolü devre dışı bırakıldı, işlem devam ediyor...');
        
        // Get.snackbar(
        //   '❌ Yetki Hatası',
        //   'Sadece grup yöneticileri mesaj sabitleyebilir',
        //   snackPosition: SnackPosition.TOP,
        //   duration: Duration(seconds: 2),
        //   backgroundColor: Colors.red.shade100,
        //   colorText: Colors.red.shade900,
        // );
        // return;
      }
      
      // PinMessageService'i kullan
      final pinMessageService = Get.find<PinMessageService>();
      final success = await pinMessageService.pinGroupMessage(messageId, currentGroupId.value);
      
      if (success) {
        debugPrint('✅ [GroupChatDetailController] Pin/Unpin işlemi başarılı');
        
        // UI güncellemesi socket event'leri ile yapılacak
        // Burada manuel güncelleme yapmaya gerek yok
      } else {
        debugPrint('❌ [GroupChatDetailController] Pin/Unpin işlemi başarısız');
        
        // Hata bildirimi göster
        Get.snackbar(
          '❌ Hata',
          'Pin/Unpin işlemi başarısız oldu',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    } catch (e) {
      debugPrint('❌ [GroupChatDetailController] Pin/Unpin işlemi hatası: $e');
      
      // Hata bildirimi göster
      Get.snackbar(
        '❌ Hata',
        'Pin/Unpin işlemi sırasında hata oluştu: $e',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
}
