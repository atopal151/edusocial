import 'dart:async';
import 'dart:io';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/models/chat_models/detail_document_model.dart';
import 'package:edusocial/services/chat_service.dart';
import 'package:edusocial/services/socket_services.dart';
import 'package:edusocial/services/pin_message_service.dart';
import 'package:edusocial/utils/network_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/chat_models/chat_detail_model.dart';
import '../../models/chat_models/sender_model.dart';
import '../../models/user_chat_detail_model.dart';
import '../../models/document_model.dart';
import '../../models/link_model.dart';
import 'package:edusocial/services/language_service.dart';
import 'package:edusocial/controllers/chat_controllers/chat_controller.dart';

class ChatDetailController extends GetxController {
  final LanguageService languageService = Get.find<LanguageService>();
  final PinMessageService _pinMessageService = Get.find<PinMessageService>();
  final isLoading = false.obs;
  final messages = <MessageModel>[].obs;
  final documents = <String>[].obs;
  final links = <String>[].obs;
  final photoUrls = <String>[].obs;
  final documentModels = <DetailDocumentModel>[].obs;
  final userChatDetail = Rxn<UserChatDetailModel>();
  final scrollController = ScrollController();
  final documentsScrollController = ScrollController();
  final linksScrollController = ScrollController();
  final photosScrollController = ScrollController();
  
  final Rxn<int> currentChatId = Rxn<int>(); // This is the User ID
  final Rxn<String> currentConversationId = Rxn<String>();

  // AppBar için anında gösterilecek veriler
  final RxString name = ''.obs;
  final RxString username = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxBool isOnline = false.obs;
  final RxBool isVerified = false.obs; // Hesap doğrulama durumu

  // Media seçimi için yeni değişkenler
  final RxList<File> selectedFiles = <File>[].obs;
  final RxBool isSendingMessage = false.obs;

  // PAGINATION: New state variables for lazy loading
  final RxBool isLoadingMoreMessages = false.obs;
  final RxBool hasMoreMessages = true.obs;
  final int messagesPerPage = 1000; // Increased from 25 to 1000 to remove limit
  final RxBool isFirstLoad = true.obs;
  
  // Scroll to bottom button visibility
  final RxBool showScrollToBottomButton = false.obs;

  // Controllers
  final ProfileController profileController = Get.find<ProfileController>();

  late SocketService _socketService;
  late StreamSubscription _privateMessageSubscription;
  late StreamSubscription _pinMessageSubscription;
  bool _isSocketListenerSetup = false; // Multiple subscription guard

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
    _socketService = Get.find<SocketService>();
    
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      // Core IDs
      final userId = arguments['userId'] as int?;
      final conversationId = arguments['conversationId'];

      // UI için veriler - match sayfasından da gelebilir
      final nameArg = arguments['name'] as String? ?? arguments['userName'] as String?;
      final usernameArg = arguments['username'] as String?;
      final avatarUrlArg = arguments['avatarUrl'] as String? ?? arguments['userAvatar'] as String?;
      final isOnlineArg = arguments['isOnline'] as bool?;
      final isVerifiedArg = arguments['isVerified'] as bool?;
      
      // conversationId can be int or String, convert to String
      String? conversationIdString;
      if (conversationId != null) {
        conversationIdString = conversationId.toString();
      }

      currentChatId.value = userId;
      currentConversationId.value = conversationIdString;

      // UI verilerini ata
      name.value = nameArg ?? 'Bilinmiyor';
      username.value = usernameArg ?? '';
      avatarUrl.value = avatarUrlArg ?? '';
      isOnline.value = isOnlineArg ?? false;
      isVerified.value = isVerifiedArg ?? false;
      

      if (currentChatId.value != null) {
        fetchConversationMessages();
      }
    }
    
    _initializeScrollController();
    _setupSocketListeners();
    
    // Socket durumunu kontrol et
    checkSocketConnection();
  }

  void _initializeScrollController() {
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

  void _setupSocketListeners() {
    // Multiple subscription guard
    if (_isSocketListenerSetup) {
      debugPrint('⚠️ Socket listeners already setup, skipping...');
      return;
    }
    
    // Chat liste controller'ın private message listener'ını durdur
    try {
      final chatController = Get.find<ChatController>();
      chatController.pausePrivateMessageListener();
      debugPrint('📴 ChatController private message listener duraklatıldı');
    } catch (e) {
      debugPrint('⚠️ ChatController bulunamadı: $e');
    }
    
    // Birebir mesaj dinleyicisi - sadece bu chat için
    _privateMessageSubscription = _socketService.onPrivateMessage.listen((data) {
      _onNewPrivateMessage(data);
    });

    // Pin/Unpin message listener
    _pinMessageSubscription = _socketService.onPinMessage.listen((data) {
      debugPrint('🔔 [ChatDetailController] Pin message event received from socket: $data');
      _onPinMessageUpdate(data);
    });
    
    _isSocketListenerSetup = true;
    debugPrint('✅ ChatDetailController socket listeners setup completed');
  }



  @override
  void onClose() {
    // Chat liste controller'ın private message listener'ını tekrar başlat
    try {
      final chatController = Get.find<ChatController>();
      chatController.resumePrivateMessageListener();
      debugPrint('▶️ ChatController private message listener tekrar başlatıldı');
    } catch (e) {
      debugPrint('⚠️ ChatController resume edilemedi: $e');
    }
    
    // Socket listener guard'ı reset et
    _isSocketListenerSetup = false;
    
    scrollController.dispose();
    documentsScrollController.dispose();
    linksScrollController.dispose();
    photosScrollController.dispose();
    _privateMessageSubscription.cancel();
    _pinMessageSubscription.cancel();
    super.onClose();
  }

  void _onNewPrivateMessage(dynamic data) {
    try {
      
      if (data is Map<String, dynamic>) {
        // Gelen mesajın conversation_id'sini string olarak al
        final incomingConversationId = data['conversation_id']?.toString();
        
        debugPrint('📡 [ChatDetailController] Incoming Conversation ID: $incomingConversationId');
        
        // Sadece bu chat için gelen mesajları işle
        if (incomingConversationId != null && incomingConversationId == currentConversationId.value) {
          final currentUserId = profileController.profile.value?.id;
          if (currentUserId == null) {
            debugPrint('❌ [ChatDetailController] Current user ID is null.');
            return;
          }
          
          final message = MessageModel.fromJson(data, currentUserId: currentUserId);
          
          // DUPLICATE CHECK: Aynı ID'li mesaj var mı kontrol et
          final isDuplicate = messages.any((existingMessage) => existingMessage.id == message.id);
          if (isDuplicate) {
            debugPrint('🚫 [ChatDetailController] DUPLICATE MESSAGE BLOCKED: ID ${message.id} already exists');
            return;
          }
          
          messages.add(message);
          debugPrint('✅ [ChatDetailController] Yeni mesaj eklendi: ID ${message.id}, Content: "${message.message}"');
          debugPrint('✅ [ChatDetailController] Toplam mesaj sayısı: ${messages.length}');
          
          // Yeni mesaj geldiğinde en alta git
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToBottom(animated: true);
          });
          
        } else {
          debugPrint('📨 [ChatDetailController] Gelen mesaj bu sohbete ait değil. Gelen: $incomingConversationId, Mevcut: ${currentConversationId.value}');
        }
      }
    } catch (e) {
      debugPrint('❌ [ChatDetailController] _onNewPrivateMessage error: $e');
    }
  }

  void _onPinMessageUpdate(dynamic data) {
    try {
      
      if (data is Map<String, dynamic>) {
        // Try different possible field names for message ID
        final messageId = data['message_id'] ?? data['id'] ?? data['messageId'];
        final isPinned = data['is_pinned'] ?? data['pinned'] ?? data['isPinned'] ?? false;
        final conversationId = data['conversation_id']?.toString() ?? data['conversationId']?.toString();
        
        
        // Check if this pin update is for the current conversation
        if (conversationId != null && conversationId == currentConversationId.value) {
          // Find the message in the current conversation and update its pin status
          final messageIndex = messages.indexWhere((msg) => msg.id.toString() == messageId.toString());
          
          if (messageIndex != -1) {
            // Update the message's pin status
            final updatedMessage = messages[messageIndex].copyWith(isPinned: isPinned);
            messages[messageIndex] = updatedMessage;
            
            debugPrint('✅ [ChatDetailController] Message pin status updated: ID $messageId, Pinned: $isPinned');
            debugPrint('✅ [ChatDetailController] Messages list length: ${messages.length}');
            debugPrint('✅ [ChatDetailController] Updated message at index: $messageIndex');
            
            // Force UI update by refreshing the messages list
            messages.refresh();
            
            // Also trigger controller update
            update();
            
            // Force GetBuilder to rebuild
            Get.find<ChatDetailController>().update();
            
            debugPrint('✅ [ChatDetailController] UI update triggered');
          } else {
            debugPrint('⚠️ [ChatDetailController] Message not found in current conversation: ID $messageId');
            debugPrint('⚠️ [ChatDetailController] Available message IDs: ${messages.map((m) => m.id).toList()}');
          }
        } else {
          debugPrint('📨 [ChatDetailController] Pin update is not for current conversation. Gelen: $conversationId, Mevcut: ${currentConversationId.value}');
        }
      } else {
        debugPrint('❌ [ChatDetailController] Data is not a Map: ${data.runtimeType}');
      }
    } catch (e) {
      debugPrint('❌ [ChatDetailController] _onPinMessageUpdate error: $e');
      debugPrint('❌ [ChatDetailController] Error stack trace: ${e.toString()}');
    }
  }

  Future<void> fetchConversationMessages() async {
    if (currentChatId.value == null) {
      debugPrint('❌ fetchConversationMessages - currentChatId null, işlem iptal.');
      return;
    }
    
    try {
      isLoading.value = true;
      
      // PAGINATION: Reset pagination state for first load
      if (isFirstLoad.value) {
        hasMoreMessages.value = true;
        messages.clear();
      }
      
      // OPTIMIZE: Load messages without limit
      final fetchedMessages = await ChatServices.fetchConversationMessages(
        currentChatId.value!,
        limit: messagesPerPage,
        offset: 0,
      ).timeout(const Duration(seconds: 10)); // Reduced timeout
      
      if (fetchedMessages.isEmpty) {
        debugPrint('⚠️ Mesaj listesi boş - kullanıcı verisi oluşturulamadı');
        userChatDetail.value = null;
        hasMoreMessages.value = false;
        return;
      }

      // PAGINATION: Add messages and update state
      if (isFirstLoad.value) {
        messages.clear();
        
        // FIXED: API returns messages in DESC order (newest first), 
        // and we want to display them in DESC order (newest at bottom)
        // So we don't need to reverse them anymore
        messages.addAll(fetchedMessages);
        
        // Since we're loading all messages, no more messages to load
        hasMoreMessages.value = false;
        
        isFirstLoad.value = false;
        debugPrint('✅ Initial ${fetchedMessages.length} messages loaded (newest at bottom)');
      } else {
        messages.addAll(fetchedMessages);
      }

      // Performans optimizasyonu: Map kullanarak belge, link ve fotoğrafları topla
      final allDocuments = <DetailDocumentModel>[];
      final allLinks = <LinkModel>[];
      final allPhotos = <String>[];

      // Paralel işlem için mesajları parçalara böl
      for (var message in messages) {
        // Belgeleri topla
        if (message.messageDocument != null && message.messageDocument!.isNotEmpty) {
          allDocuments.addAll(message.messageDocument!);
        }

        // Linkleri topla
        if (message.messageLink.isNotEmpty) {
          allLinks.addAll(message.messageLink.map((link) => LinkModel(
            url: link.link.isNotEmpty ? link.link : 'https://example.com',
            title: link.linkTitle.isNotEmpty ? link.linkTitle : 'Link',
          )));
        }

        // Fotoğrafları topla
        if (message.messageMedia.isNotEmpty) {
          allPhotos.addAll(message.messageMedia.map((media) => media.path));
        }
      }

      // Duplicates'i filtrele
      final uniquePhotos = allPhotos.toSet().toList();
      final uniqueLinks = <LinkModel>[];
      final seenUrls = <String>{};
      
      for (var link in allLinks) {
        if (!seenUrls.contains(link.url)) {
          seenUrls.add(link.url);
          uniqueLinks.add(link);
        }
      }

      // Belgeleri tarihe göre sırala (en yeni en üstte)
      allDocuments.sort((a, b) {
        final dateA = DateTime.tryParse(a.date) ?? DateTime.now();
        final dateB = DateTime.tryParse(b.date) ?? DateTime.now();
        return dateB.compareTo(dateA); // En yeni en üstte
      });

      // Linkleri tarihe göre sırala (en yeni en üstte)
      uniqueLinks.sort((a, b) {
        // Link'lerin tarih bilgisi yok, mesaj tarihine göre sırala
        // Bu durumda mesaj sırasına göre sırala (en son eklenen en üstte)
        return 0; // Şimdilik sıralama yapmıyoruz, mesaj sırasına göre kalıyor
      });

      // Fotoğrafları tarihe göre sırala (en yeni en üstte)
      // Fotoğraflar mesaj sırasına göre zaten sıralı geliyor


      // Kullanıcı detaylarını güncelle - doğru sender bilgilerini al
      final currentUserId = profileController.profile.value?.id;
      
      
      // Conversation'dan karşı tarafı bul
      SenderModel? targetSender;
      int? targetUserId;
      
      // Conversation bilgilerinden karşı tarafı belirle
      if (messages.isNotEmpty) {
        final conversation = messages.first.conversation;
        debugPrint('  - Conversation userOne: ${conversation.userOne}, userTwo: ${conversation.userTwo}');
        
        // Current user ID'si ile conversation'daki userOne ve userTwo'yu karşılaştır
        if (conversation.userOne == currentUserId) {
          targetUserId = conversation.userTwo;
          debugPrint('  ✅ Target user ID: ${conversation.userTwo} (userTwo)');
        } else if (conversation.userTwo == currentUserId) {
          targetUserId = conversation.userOne;
          debugPrint('  ✅ Target user ID: ${conversation.userOne} (userOne)');
        } else {
          // Fallback: currentChatId.value'yu kullan
          targetUserId = currentChatId.value;
          debugPrint('  ⚠️ Fallback target user ID: ${currentChatId.value}');
        }
      }
      
      // Mesajları tara ve target user ID'sine sahip sender'ı bul
      for (var message in messages) {
        debugPrint('  - Message Sender ID: ${message.sender.id}, isMe: ${message.isMe}');
        
        // Target user ID'sine sahip sender'ı ara
        if (message.sender.id == targetUserId) {
          targetSender = message.sender;
          debugPrint('  ✅ Target sender bulundu: ${targetSender.name} ${targetSender.surname}');
          break;
        }
      }
      
      // Hala bulunamadıysa, oturum açan kullanıcının mesajı olmayan ilk mesajı al
      if (targetSender == null) {
        debugPrint('  ⚠️ Target sender bulunamadı, oturum açan kullanıcının olmadığı mesajı arıyor...');
        
        for (var message in messages) {
          if (message.sender.id != currentUserId) {
            targetSender = message.sender;
            debugPrint('  ✅ Target sender bulundu (fallback): ${targetSender.name} ${targetSender.surname}');
            break;
          }
        }
      }
      
      // Son fallback: currentChatId.value'yu kullanarak API'den kullanıcı bilgilerini al
      if (targetSender == null) {
        debugPrint('  ⚠️ Final fallback: currentChatId.value kullanılarak kullanıcı bilgileri alınacak');
        // Bu durumda UI'dan gelen bilgileri kullan (onInit'te atanan)
        targetSender = SenderModel(
          id: currentChatId.value ?? 0,
          accountType: 'public', // Default değer
          name: name.value.split(' ').first,
          surname: name.value.split(' ').length > 1 ? name.value.split(' ').skip(1).join(' ') : '',
          username: username.value,
          avatarUrl: avatarUrl.value,
        );
      }
      
      final userName = '${targetSender.name} ${targetSender.surname}'.trim();
      
      
      // Null check ve fallback values
      userChatDetail.value = UserChatDetailModel(
        id: targetSender.id.toString(),
        name: userName.isNotEmpty ? userName : 'Bilinmeyen Kullanıcı',
        follower: '0',
        following: '0',
        imageUrl: targetSender.avatarUrl.isNotEmpty ? targetSender.avatarUrl : '',
        memberImageUrls: const [],
        documents: allDocuments.map((doc) => DocumentModel(
          id: doc.id,
          name: doc.name.isNotEmpty ? doc.name : 'Belge',
          sizeMb: 0.0,
          humanCreatedAt: doc.date,
          createdAt: DateTime.tryParse(doc.date) ?? DateTime.now(),
        )).toList(),
        links: uniqueLinks,
        photoUrls: uniquePhotos,
      );

      
      // Mesajlar yüklendikten sonra en alta git
      _scrollToBottomWithRetry();
      
    } catch (e) {
      debugPrint('❌ fetchConversationMessages error: $e');
      // Hata durumunda userChatDetail'i null yap
      userChatDetail.value = null;
      
      // IMPROVED: Better error handling with NetworkHelper
      String errorMessage = NetworkHelper.getNetworkErrorMessage(e);
      
      // Check if we should show retry button
      bool showRetryButton = NetworkHelper.isRetryableError(e);
      
              // Hata mesajı göster
        Get.snackbar(
          languageService.tr("common.messages.connectionErrorMessage"),
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
          duration: const Duration(seconds: 4),
          mainButton: showRetryButton ? TextButton(
            onPressed: () {
              Get.back(); // Snackbar'ı kapat
              fetchConversationMessages(); // Tekrar dene
            },
            child: Text(
              languageService.tr("common.messages.tryAgainButton"),
              style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold),
            ),
          ) : null,
        );
    } finally {
      isLoading.value = false;
    }
  }

  void scrollToBottom({bool animated = true}) {
    if (scrollController.hasClients) {
      try {
        final maxScroll = scrollController.position.maxScrollExtent;
        debugPrint('📜 User Chat - Scrolling to bottom: maxScroll = $maxScroll');
        
        if (animated) {
          scrollController.animateTo(
            maxScroll,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          scrollController.jumpTo(maxScroll);
        }
      } catch (e) {
        debugPrint('❌ User Chat - Scroll error: $e');
      }
    } else {
      debugPrint('⚠️ User Chat - ScrollController has no clients yet');
    }
  }

  void _scrollToBottomWithRetry() {
    // İlk deneme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom(animated: false);
      
      // İkinci deneme - biraz gecikmeyle
      Future.delayed(Duration(milliseconds: 300), () {
        scrollToBottom(animated: false);
      });
      
      // Üçüncü deneme - daha uzun gecikmeyle
      Future.delayed(Duration(milliseconds: 800), () {
        scrollToBottom(animated: false);
      });
    });
  }



  void pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      selectedFiles.add(file);
      debugPrint("📸 Seçilen resim: ${pickedFile.path}");
      debugPrint("📁 Toplam seçilen dosya sayısı: ${selectedFiles.length}");
    }
  }



  Future<void> sendMessage(String message) async {
    if (currentChatId.value == null) return;
    if (isSendingMessage.value) return;
    
    
    // Eğer hiçbir şey seçilmemişse gönderme
    if (message.isEmpty && selectedFiles.isEmpty) {
      debugPrint('❌ Nothing to send');
      return;
    }
    
    isSendingMessage.value = true;
    
    try {
      // Text içinde link var mı kontrol et
      if (message.isNotEmpty && hasLinksInText(message)) {
        debugPrint('🔗 Links detected in text, processing...');
        
        final urls = extractUrlsFromText(message);
        final nonLinkText = extractNonLinkText(message);
        
        debugPrint('  - Detected URLs: $urls');
        debugPrint('  - Non-link text: "$nonLinkText"');
        
        // Linkleri normalize et
        final normalizedUrls = urls.map((url) => normalizeUrl(url)).toList();
        
        // Text alanında sadece link olmayan kısmı gönder, linkleri ayrı parametrede gönder
        debugPrint('  - Sending message with separated text and links');
        
        await ChatServices.sendMessage(
          currentChatId.value!,
          nonLinkText.isEmpty ? ' ' : nonLinkText, // Boş string yerine space gönder
          conversationId: currentConversationId.value,
          mediaFiles: selectedFiles.isNotEmpty ? selectedFiles : null,
          links: normalizedUrls, // Linkleri ayrı parametrede gönder
        );
      } else {
        // Normal text mesajı gönder (link yok)
        debugPrint('📝 Sending normal text message');
        
        await ChatServices.sendMessage(
          currentChatId.value!,
          message,
          conversationId: currentConversationId.value,
          mediaFiles: selectedFiles.isNotEmpty ? selectedFiles : null,
        );
      }
      
      // Başarılı ise seçilen dosyaları temizle
      selectedFiles.clear();
      
      // Mesaj gönderildikten sonra mesajları yeniden yükle
      await fetchConversationMessages();
      
      // Mesaj gönderildikten sonra en alta git
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom(animated: true);
      });
      
    } catch (e) {
      debugPrint("🛑 Mesaj gönderilemedi: $e");
      Get.snackbar(
        languageService.tr("common.error"),
        languageService.tr("common.messages.messageSendFailed"),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  // Sadece media dosyalarını gönder (text olmadan)
  Future<void> sendMediaOnly() async {
    if (currentChatId.value == null) return;
    if (isSendingMessage.value) return;
    
    debugPrint('📁 Sending media files only');
    isSendingMessage.value = true;
    
    try {
      await ChatServices.sendMessage(
        currentChatId.value!,
        '', // Boş text
        conversationId: currentConversationId.value,
        mediaFiles: selectedFiles,
      );
      
      debugPrint('✅ Media files sent successfully');
      selectedFiles.clear();
      
      // Mesajları yeniden yükle
      await fetchConversationMessages();
      
      // Medya gönderildikten sonra en alta git
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom(animated: true);
      });
      
    } catch (e) {
      debugPrint('💥 Media sending error: $e');
      Get.snackbar(
        'Hata',
        'Dosyalar gönderilemedi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  void clearSelectedItems() {
    selectedFiles.clear();
  }

  void checkSocketConnection() {
    
    // Socket service'den detaylı durum raporu al
    _socketService.checkSocketStatus();
    
  }

  /// Pin or unpin a message
  Future<void> pinMessage(int messageId) async {
    try {
      final success = await _pinMessageService.pinMessage(messageId);
      
      if (success) {
        // Update the message in the list
        final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
        if (messageIndex != -1) {
          final message = messages[messageIndex];
          final updatedMessage = message.copyWith(isPinned: !message.isPinned);
          messages[messageIndex] = updatedMessage;
          
          // Update UI
          update();
          
          // Success - no snackbar needed
        }
      } else {
        Get.snackbar(
          languageService.tr('messages.pinError'),
          languageService.tr('messages.tryAgain'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Pin message error: $e');
      Get.snackbar(
        languageService.tr('messages.pinError'),
        languageService.tr('messages.tryAgain'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
