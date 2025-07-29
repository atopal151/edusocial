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
import '../profile_controller.dart';
import 'chat_controller.dart'; // Added import for ChatController

class GroupChatDetailController extends GetxController {
  final LanguageService languageService = Get.find<LanguageService>();
  final GroupServices _groupServices = GroupServices();
  final RxList<GroupMessageModel> messages = <GroupMessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGroupDataLoading = false.obs; // Grup verisi için ayrı loading
  final RxBool isMessagesLoading = false.obs; // Mesajlar için ayrı loading
  final RxString currentGroupId = ''.obs;
  final groupData = Rx<GroupDetailModel?>(null);
  final TextEditingController messageController = TextEditingController();

  // Socket service ile ilgili değişkenler
  late SocketService _socketService;
  late StreamSubscription _groupMessageSubscription;
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

  // Performance optimization: Cache kullanıcı verileri
  final Map<String, Map<String, dynamic>> _userCache = {};
  bool _isInitialLoad = true;

  // URL algılama için regex pattern
  static final RegExp urlRegex = RegExp(
    r'(https?://[^\s]+)|(www\.[^\s]+)|([^\s]+\.[^\s]{2,})',
    caseSensitive: false,
  );

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
    
    if (Get.arguments != null && Get.arguments['groupId'] != null) {
      currentGroupId.value = Get.arguments['groupId'];
      debugPrint('✅ Current group ID set to: ${currentGroupId.value}');
      
      // Optimize: Sadece burada yükle, initState'te tekrar çağırma
      _loadGroupDataProgressive();
      
      // Group chat'e girdiğinde socket durumunu kontrol et
      onGroupChatEntered();
      
      // Cache'i temizle (Android'de güncel olmayan veri sorunu için)
      GroupServices.clearGroupCache();
    } else {
      debugPrint('❌ No group ID provided in arguments');
      Get.snackbar('Error', 'No group selected', snackPosition: SnackPosition.BOTTOM);
      Get.back();
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
            .timeout(const Duration(seconds: 3)); // Even shorter timeout for cache
      } catch (e) {
        debugPrint('⚠️ Cache failed, trying direct API: $e');
        // Fallback to direct API call
        group = await _groupServices.fetchGroupDetail(currentGroupId.value)
            .timeout(const Duration(seconds: 5));
      }
      
      if (group != null) {
        groupData.value = group;
        
        // OPTIMIZE: Process messages in background
        Future.microtask(() {
          convertGroupChatsToMessagesOptimized();
        });
        
        debugPrint('✅ Group details loaded successfully (optimized)');
      }
      
    } catch (e) {
      debugPrint('❌ Error fetching group details: $e');
      
      Get.snackbar(
        'Bağlantı Hatası',
        'Grup verileri yüklenemedi. Lütfen tekrar deneyin.',
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
    
    // Chat liste controller'ın group message listener'ını durdur
    try {
      final chatController = Get.find<ChatController>();
      chatController.pauseGroupMessageListener();
      debugPrint('📴 ChatController group message listener duraklatıldı');
    } catch (e) {
      debugPrint('⚠️ ChatController bulunamadı: $e');
    }
    
    // Group mesaj dinleyicisi - user:{user_id} kanalından
    _groupMessageSubscription = _socketService.onGroupMessage.listen((data) {
      _onNewGroupMessage(data);
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
      debugPrint('📡 GroupChatDetailController - Yeni grup mesajı geldi: $data');
      
      if (data is Map<String, dynamic>) {
        final incomingGroupId = data['group_id']?.toString();
        
        // Sadece bu grup için gelen mesajları işle
        if (incomingGroupId != null && incomingGroupId == currentGroupId.value) {
          debugPrint('✅ Yeni grup mesajı bu gruba ait, mesaj listesine ekleniyor');
          
          // OPTIMIZE: Tüm grup detayını tekrar çekme, sadece yeni mesajı ekle
          _addNewMessageFromSocket(data);
          
          debugPrint('✅ Yeni grup mesajı işlendi');
        } else {
          debugPrint('📡 Gelen grup mesajı bu gruba ait değil. Gelen: $incomingGroupId, Mevcut: ${currentGroupId.value}');
        }
      }
    } catch (e) {
      debugPrint('❌ _onNewGroupMessage error: $e');
    }
  }

  /// Socket'ten gelen yeni mesajı direkt ekle (API çağrısı yapma)
  void _addNewMessageFromSocket(Map<String, dynamic> data) {
    try {
      debugPrint('📡 [GroupChatDetailController] Yeni grup mesajı payload alındı');
      debugPrint('📡 [GroupChatDetailController] Current Group ID: ${currentGroupId.value}');
      debugPrint('📡 [GroupChatDetailController] Processing: $data');
      
      // Yeni mesajı parse et ve listeye ekle
      final currentUserId = Get.find<ProfileController>().userId.value;
      
      // DUPLICATE CHECK: Aynı ID'li mesaj var mı kontrol et
      final messageId = data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final isDuplicate = messages.any((existingMessage) => existingMessage.id == messageId);
      if (isDuplicate) {
        debugPrint('🚫 [GroupChatDetailController] DUPLICATE MESSAGE BLOCKED: ID $messageId already exists');
        return;
      }
      
      // Basit implementasyon - gerçek socket data'ya göre ayarlanmalı
      final newMessage = GroupMessageModel(
        id: messageId,
        senderId: data['user_id']?.toString() ?? '',
        receiverId: currentGroupId.value,
        name: data['user']?['name'] ?? '',
        surname: data['user']?['surname'] ?? '',
        username: data['user']?['username'] ?? '',
        profileImage: data['user']?['avatar_url'] ?? '',
        content: data['message'] ?? '',
        messageType: GroupMessageType.text, // Socket data'ya göre ayarla
        timestamp: DateTime.now(),
        isSentByMe: data['user_id']?.toString() == currentUserId,
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
    debugPrint('📡 === GROUP CHAT SOCKET DURUM RAPORU ===');
    debugPrint('📡 Socket Bağlantı Durumu: ${_socketService.isConnected.value}');
    debugPrint('📡 Aktif Group ID: ${currentGroupId.value}');
    debugPrint('📡 Group Message Subscription Aktif: ${!_groupMessageSubscription.isPaused}');
    debugPrint('📡 Socket ID: ${_socketService.socket?.id}');
    debugPrint('📡 Socket Connected: ${_socketService.socket?.connected}');
    
    // Socket service'den detaylı durum raporu al
    _socketService.checkSocketStatus();
    
    debugPrint('📡 =======================================');
  }

  /// Group chat'e girdiğinde socket durumunu kontrol et
  void onGroupChatEntered() {
    debugPrint('🚪 Group chat\'e girildi, socket durumu kontrol ediliyor...');
    checkGroupChatSocketConnection();
    
    // Group chat'e girdiğinde socket'e join ol
    if (_socketService.isConnected.value) {
      debugPrint('🔌 Group chat için socket kanalına join olunuyor...');
      _socketService.sendMessage('join', {
        'channel': 'group:${currentGroupId.value}',
        'group_id': currentGroupId.value,
        'user_id': Get.find<ProfileController>().userId.value,
      });
      
      // Test için manuel socket event gönder
      _testSocketEvent();
    }
  }

  /// Test için manuel socket event gönder
  void _testSocketEvent() {
    debugPrint('🧪 Test socket event gönderiliyor...');
    _socketService.sendTestEvent('user:group_message', {
      'group_id': currentGroupId.value,
      'user_id': Get.find<ProfileController>().userId.value,
      'message': 'Test mesajı - ${DateTime.now()}',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// OPTIMIZE: Background message conversion with pagination support
  Future<void> convertGroupChatsToMessagesOptimized() async {
    if (groupData.value?.groupChats == null) return;
    
    try {
      final groupChats = groupData.value!.groupChats;
      final currentUserId = Get.find<ProfileController>().userId.value;
      
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
      // Sadece timestamp'e göre sırala (en eski en üstte, en yeni en altta)
      processedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      // PAGINATION: Update state based on first load or not
      if (isFirstLoad.value) {
        messages.assignAll(processedMessages);
        
        // Since we're loading all messages, no more messages to load
        hasMoreMessages.value = false;
        
        isFirstLoad.value = false;
        debugPrint('✅ Initial ${processedMessages.length} group messages loaded (proper chronological order)');
      debugPrint('📊 Mesaj sayısı kontrolü: ${messages.length} mesaj yüklendi');
      } else {
        messages.assignAll(processedMessages);
        debugPrint('📊 Mesaj sayısı güncellendi: ${messages.length} mesaj');
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
    
    try {
      if (chat.messageType == 'poll') {
        messageType = GroupMessageType.poll;
        content = chat.message ?? '';
        pollOptions = ['Seçenek 1', 'Seçenek 2']; // TODO: Backend'den parse et
      } else if (chat.media != null && chat.media.isNotEmpty) {
        final media = chat.media.first;
        if (media.type != null && media.type.toString().startsWith('image/')) {
          messageType = GroupMessageType.image;
          content = media.fullPath ?? '';
        } else {
          messageType = GroupMessageType.document;
          content = media.fullPath ?? '';
        }
      } else if (chat.groupChatLink != null && chat.groupChatLink.isNotEmpty) {
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
          messageType = GroupMessageType.link;
          content = chatLinks.first;
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
      Get.snackbar(languageService.tr("common.error"), languageService.tr("common.messages.messageSendFailed"), snackPosition: SnackPosition.BOTTOM);
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
                  hintText: languageService.tr("chat.poll.title"),
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
                                  hintText: languageService.tr("chat.poll.addOption"),
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
                  languageService.tr("chat.poll.addOption"),
                  style: TextStyle(color: Color(0xffED7474), fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),

              /**
               *  backgroundColor: const Color(0xffFFF6F6),
                    foregroundColor: const Color(0xffED7474),
               */
              CustomButton(
                  text: languageService.tr("chat.poll.send"),
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
        Get.snackbar(languageService.tr("common.error"), languageService.tr("common.messages.messageSendFailed"), snackPosition: SnackPosition.BOTTOM);
      }
      
    } catch (e) {
      debugPrint('💥 Message sending error: $e');
      Get.snackbar(languageService.tr("common.error"), languageService.tr("common.messages.messageSendFailed"), snackPosition: SnackPosition.BOTTOM);
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
        Get.snackbar(languageService.tr("common.error"), languageService.tr("common.messages.mediaSendFailed"), snackPosition: SnackPosition.BOTTOM);
      }
      
    } catch (e) {
      debugPrint('💥 Media sending error: $e');
      Get.snackbar(languageService.tr("common.error"), languageService.tr("common.messages.mediaSendFailed"), snackPosition: SnackPosition.BOTTOM);
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
          .timeout(const Duration(seconds: 5));
      
      groupData.value = group;
      convertGroupChatsToMessagesOptimized();
      
      debugPrint('✅ Messages refreshed successfully');
    } catch (e) {
      debugPrint('❌ Error refreshing messages: $e');
    }
  }

  // Keep backwards compatibility
  Future<void> refreshMessagesOnly() async {
    await refreshMessagesOptimized();
  }

  @override
  void onClose() {
    // Chat liste controller'ın group message listener'ını tekrar başlat
    try {
      final chatController = Get.find<ChatController>();
      chatController.resumeGroupMessageListener();
      debugPrint('▶️ ChatController group message listener tekrar başlatıldı');
    } catch (e) {
      debugPrint('⚠️ ChatController resume edilemedi: $e');
    }
    
    // Socket listener guard'ı reset et
    _isSocketListenerSetup = false;
    
    messageController.dispose();
    pollTitleController.dispose();
    scrollController.dispose();
    _groupMessageSubscription.cancel();
    _userCache.clear(); // Clear cache
    _lastMessageCount = 0; // Reset message count tracker
    super.onClose();
  }
}
