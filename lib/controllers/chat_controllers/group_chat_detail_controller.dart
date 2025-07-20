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

class GroupChatDetailController extends GetxController {
  final GroupServices _groupServices = GroupServices();
  final LanguageService languageService = Get.find<LanguageService>();
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
  final ScrollController scrollController = ScrollController();

  // PAGINATION: New state variables for lazy loading group messages
  final RxBool isLoadingMoreMessages = false.obs;
  final RxBool hasMoreMessages = true.obs;
  final RxInt currentOffset = 0.obs;
  final int messagesPerPage = 25;
  final RxBool isFirstLoad = true.obs;

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
    } else {
      debugPrint('❌ No group ID provided in arguments');
      Get.snackbar('Error', 'No group selected', snackPosition: SnackPosition.BOTTOM);
      Get.back();
    }
  }

  /// PAGINATION: Setup scroll listener for loading more messages
  void _setupPaginationScrollListener() {
    scrollController.addListener(() {
      // Load more messages when scrolling UP (towards older messages)
      if (scrollController.position.pixels <= 100 && 
          !isLoadingMoreMessages.value && 
          hasMoreMessages.value) {
        debugPrint('📜 Group: User scrolled to top, loading more messages...');
        _loadMoreGroupMessages();
      }
    });
  }

  /// PAGINATION: Load more older group messages
  Future<void> _loadMoreGroupMessages() async {
    if (isLoadingMoreMessages.value || !hasMoreMessages.value || currentGroupId.value.isEmpty) {
      return;
    }

    try {
      isLoadingMoreMessages.value = true;
      
      // Use current message count as offset
      final nextOffset = messages.length;
      debugPrint('📜 Group: Loading more messages. Current: ${messages.length}, Offset: $nextOffset');

      // Fetch older messages using the new pagination service
      final olderMessages = await _groupServices.fetchGroupMessagesWithPagination(
        currentGroupId.value,
        limit: messagesPerPage,
        offset: nextOffset,
      );

      if (olderMessages.isEmpty) {
        hasMoreMessages.value = false;
        debugPrint('📜 Group: No more messages to load');
        return;
      }

      // Convert to GroupMessageModel and check for duplicates
      final currentUserId = Get.find<ProfileController>().userId.value;
      final newMessages = <GroupMessageModel>[];
      
      for (final chatData in olderMessages) {
        try {
          final userId = chatData['user_id']?.toString() ?? '';
          final user = chatData['user'] ?? {};
          
          final messageData = _determineMessageType(chatData);
          
          final message = GroupMessageModel(
            id: chatData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: userId,
            receiverId: currentGroupId.value,
            name: user['name'] ?? '',
            surname: user['surname'] ?? '',
            username: user['username'] ?? user['name'] ?? '',
            profileImage: user['avatar_url'] ?? '',
            content: messageData['content'],
            messageType: messageData['type'],
            timestamp: DateTime.parse(chatData['created_at'] ?? DateTime.now().toIso8601String()),
            isSentByMe: userId == currentUserId,
            pollOptions: messageData['pollOptions'],
            additionalText: messageData['additionalText'],
            links: messageData['links'],
          );
          
          // Check for duplicates
          final isDuplicate = messages.any((existingMsg) => existingMsg.id == message.id);
          if (!isDuplicate) {
            newMessages.add(message);
          } else {
            debugPrint('🚫 Group: Duplicate message blocked: ${message.id}');
          }
        } catch (e) {
          debugPrint('⚠️ Group: Error processing message: $e');
        }
      }

      if (newMessages.isEmpty) {
        hasMoreMessages.value = false;
        debugPrint('📜 Group: All messages were duplicates');
        return;
      }

      // Remember scroll position
      final currentScrollOffset = scrollController.offset;
      final currentMaxScrollExtent = scrollController.position.maxScrollExtent;

      // Add older messages to the beginning
      messages.insertAll(0, newMessages);

      debugPrint('✅ Group: Added ${newMessages.length} older messages. Total: ${messages.length}');

      // Maintain scroll position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          final newMaxScrollExtent = scrollController.position.maxScrollExtent;
          final scrollDifference = newMaxScrollExtent - currentMaxScrollExtent;
          scrollController.jumpTo(currentScrollOffset + scrollDifference);
        }
      });

      // Check if we reached the end
      if (newMessages.length < messagesPerPage) {
        hasMoreMessages.value = false;
        debugPrint('📜 Group: Reached end of messages');
      }

    } catch (e) {
      debugPrint('❌ Group: Error loading more messages: $e');
    } finally {
      isLoadingMoreMessages.value = false;
    }
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
    _groupMessageSubscription = _socketService.onGroupMessage.listen((data) {
      _onNewGroupMessage(data);
    });
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
        }
      }
    } catch (e) {
      debugPrint('❌ _onNewGroupMessage error: $e');
    }
  }

  /// Socket'ten gelen yeni mesajı direkt ekle (API çağrısı yapma)
  void _addNewMessageFromSocket(Map<String, dynamic> data) {
    try {
      // Yeni mesajı parse et ve listeye ekle
      // Bu implementation'ı socket data formatına göre ayarla
      final currentUserId = Get.find<ProfileController>().userId.value;
      
      // Basit implementasyon - gerçek socket data'ya göre ayarlanmalı
      final newMessage = GroupMessageModel(
        id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
      
      // Yeni mesaj eklendiğinde en alta git
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottomForNewMessage();
      });
      
    } catch (e) {
      debugPrint('❌ Error adding new message from socket: $e');
      // Fallback: Tüm mesajları yeniden yükle
      refreshMessagesOnly();
    }
  }

  /// OPTIMIZE: Background message conversion with pagination support
  Future<void> convertGroupChatsToMessagesOptimized() async {
    if (groupData.value?.groupChats == null) return;
    
    try {
      final groupChats = groupData.value!.groupChats;
      final currentUserId = Get.find<ProfileController>().userId.value;
      
      // PAGINATION: Only process latest messages for initial load
      final messagesToProcess = isFirstLoad.value 
        ? groupChats.take(messagesPerPage).toList()
        : groupChats;
      
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
      
      // Sort ve assign
      processedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      // PAGINATION: Update state based on first load or not
      if (isFirstLoad.value) {
        messages.assignAll(processedMessages);
        
        // Check if there are more messages available
        if (groupChats.length > messagesPerPage) {
          hasMoreMessages.value = true;
        } else {
          hasMoreMessages.value = false;
        }
        
        isFirstLoad.value = false;
        debugPrint('✅ Initial ${processedMessages.length} group messages loaded');
      } else {
        messages.assignAll(processedMessages);
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
    // Allow UI to render first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (scrollController.hasClients && messages.isNotEmpty) {
          scrollToBottom(animated: false);
        }
      });
    });
  }

  /// FIXED: Scroll to bottom for new messages
  void scrollToBottomForNewMessage() {
    // Immediate scroll for new messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollToBottom(animated: true);
      }
    });
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
    
    debugPrint('📁 Extracted ${groupDocuments.length} documents from group chats');
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
      Get.snackbar('Error', 'Failed to fetch messages', snackPosition: SnackPosition.BOTTOM);
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
        
        // FIXED: Immediate scroll for better UX, then refresh
        scrollToBottomForNewMessage();
        
        // OPTIMIZE: Reduced refresh delay
        Future.delayed(Duration(milliseconds: 300), () async {
          await refreshMessagesOptimized();
          // Ensure we stay at bottom after refresh
          scrollToBottomForNewMessage();
        });
      } else {
        Get.snackbar('Hata', 'Mesaj gönderilemedi', snackPosition: SnackPosition.BOTTOM);
      }
      
    } catch (e) {
      debugPrint('💥 Message sending error: $e');
      Get.snackbar('Hata', 'Mesaj gönderilemedi', snackPosition: SnackPosition.BOTTOM);
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
        Get.snackbar('Hata', 'Medya gönderilemedi', snackPosition: SnackPosition.BOTTOM);
      }
      
    } catch (e) {
      debugPrint('💥 Media sending error: $e');
      Get.snackbar('Hata', 'Medya gönderilemedi', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSendingMessage.value = false;
    }
  }

  void clearSelectedItems() {
    selectedFiles.clear();
  }

  void scrollToBottom({bool animated = true}) {
    if (scrollController.hasClients) {
      if (animated) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
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
    messageController.dispose();
    pollTitleController.dispose();
    scrollController.dispose();
    _groupMessageSubscription.cancel();
    _userCache.clear(); // Clear cache
    super.onClose();
  }
}
