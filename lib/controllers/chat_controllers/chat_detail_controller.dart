import 'dart:async';
import 'dart:io';
import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/models/chat_models/detail_document_model.dart';
import 'package:edusocial/services/chat_service.dart';
import 'package:edusocial/services/socket_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/chat_models/chat_detail_model.dart';
import '../../models/user_chat_detail_model.dart';
import '../../models/document_model.dart';
import '../../models/link_model.dart';
import 'package:edusocial/services/language_service.dart';

class ChatDetailController extends GetxController {
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

  RxString pollQuestion = ''.obs;
  RxList<String> pollOptions = <String>[].obs;
  RxMap<String, int> pollVotes = <String, int>{}.obs;
  RxString selectedPollOption = ''.obs;

  // Media seçimi için yeni değişkenler
  final RxList<File> selectedFiles = <File>[].obs;
  final RxBool isSendingMessage = false.obs;
  TextEditingController pollTitleController = TextEditingController();

  // Controllers
  final ProfileController profileController = Get.find<ProfileController>();

  late SocketService _socketService;
  late StreamSubscription _privateMessageSubscription;

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
      
      debugPrint('ChatDetailController initialized:');
      debugPrint('  - User ID: ${currentChatId.value}');
      debugPrint('  - Conversation ID: ${currentConversationId.value}');
      debugPrint('  - Name: ${name.value}');
      debugPrint('  - Username: ${username.value}');
      debugPrint('  - Avatar URL: ${avatarUrl.value}');

      if (currentChatId.value != null) {
        fetchConversationMessages();
      }
    }
    
    _initializeScrollController();
    _setupSocketListeners();
  }

  void _initializeScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        // Son mesajlara gelindiğinde yeni mesajları yükle
        _loadMoreMessages();
      }
    });
  }

  void _setupSocketListeners() {
    // Birebir mesaj dinleyicisi - sadece bu chat için
    _privateMessageSubscription = _socketService.onPrivateMessage.listen((data) {
      _onNewPrivateMessage(data);
    });
  }

  void _loadMoreMessages() {
    // Daha fazla mesaj yükleme işlemi
  }

  @override
  void onClose() {
    scrollController.dispose();
    documentsScrollController.dispose();
    linksScrollController.dispose();
    photosScrollController.dispose();
    _privateMessageSubscription.cancel();
    super.onClose();
  }

  void _onNewPrivateMessage(dynamic data) {
    try {
      debugPrint('📡 ChatDetailController - Yeni mesaj geldi: $data');
      
      if (data is Map<String, dynamic>) {
        // Gelen mesajın conversation_id'sini string olarak al
        final incomingConversationId = data['conversation_id']?.toString();
        
        // Sadece bu chat için gelen mesajları işle
        if (incomingConversationId != null && incomingConversationId == currentConversationId.value) {
          final currentUserId = profileController.profile.value?.id;
          if (currentUserId == null) {
            debugPrint('❌ _onNewPrivateMessage: Current user ID is null.');
            return;
          }
          
          final message = MessageModel.fromJson(data, currentUserId: currentUserId);
          messages.add(message);
          
          // Yeni mesaj geldiğinde en alta git
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToBottom(animated: true);
          });
          
          debugPrint('✅ Yeni mesaj chat listesine eklendi');
        } else {
          debugPrint('📨 Gelen mesaj bu sohbete ait değil. Gelen: $incomingConversationId, Mevcut: ${currentConversationId.value}');
        }
      }
    } catch (e) {
      debugPrint('❌ _onNewPrivateMessage error: $e');
    }
  }

  Future<void> fetchConversationMessages() async {
    if (currentChatId.value == null) {
      debugPrint('❌ fetchConversationMessages - currentChatId null, işlem iptal.');
      return;
    }
    try {
      isLoading.value = true;
      
      // Mesajları yükle
      final fetchedMessages = await ChatServices.fetchConversationMessages(currentChatId.value!);
      messages.clear();
      messages.addAll(fetchedMessages);

      // Belge, link ve fotoğrafları topla
      final allDocuments = <DetailDocumentModel>[];
      final allLinks = <LinkModel>[];
      final allPhotos = <String>[];

      for (var message in messages) {
        // Belgeleri topla
        if (message.messageDocument != null && message.messageDocument!.isNotEmpty) {
          debugPrint('📄 Belge bulundu: ${message.messageDocument!.length} adet');
          allDocuments.addAll(message.messageDocument!);
        }

        // Linkleri topla
        if (message.messageLink.isNotEmpty) {
          debugPrint('🔗 Link bulundu: ${message.messageLink.length} adet');
          for (var link in message.messageLink) {
            allLinks.add(LinkModel(
              url: link.link,
              title: link.linkTitle,
            ));
          }
        }

        // Fotoğrafları topla
        if (message.messageMedia.isNotEmpty) {
          debugPrint('📸 Fotoğraf bulundu: ${message.messageMedia.length} adet');
          for (var media in message.messageMedia) {
            allPhotos.add(media.path);
          }
        }
      }

      debugPrint('📊 Toplanan veriler:');
      debugPrint('  - Belgeler: ${allDocuments.length} adet');
      debugPrint('  - Linkler: ${allLinks.length} adet');
      debugPrint('  - Fotoğraflar: ${allPhotos.length} adet');

      // Kullanıcı detaylarını güncelle
      if (messages.isNotEmpty) {
        final sender = messages.first.sender;
        userChatDetail.value = UserChatDetailModel(
          id: sender.id.toString(),
          name: '${sender.name} ${sender.surname}',
          follower: '0',
          following: '0',
          imageUrl: sender.avatarUrl,
          memberImageUrls: const [],
          documents: allDocuments.map((doc) => DocumentModel(
            id: doc.id,
            name: doc.name,
            sizeMb: 0.0,
            humanCreatedAt: doc.date,
            createdAt: DateTime.parse(doc.date),
          )).toList(),
          links: allLinks,
          photoUrls: allPhotos,
        );

        debugPrint('✅ ChatDetailController - userChatDetail güncellendi:');
        debugPrint('  - ID: ${userChatDetail.value?.id}');
        debugPrint('  - Name: ${userChatDetail.value?.name}');
        debugPrint('  - Belgeler: ${userChatDetail.value?.documents.length} adet');
        debugPrint('  - Linkler: ${userChatDetail.value?.links.length} adet');
        debugPrint('  - Fotoğraflar: ${userChatDetail.value?.photoUrls.length} adet');
        
        // Mesajlar yüklendikten sonra en alta git - birden fazla deneme
        _scrollToBottomWithRetry();
      }
    } catch (e) {
      debugPrint('❌ fetchConversationMessages error: $e');
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

  void openPollBottomSheet() {
    pollQuestion.value = '';
    pollOptions.assignAll(['', '']);
    final LanguageService languageService = Get.find<LanguageService>();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              TextField(
                style: const TextStyle(fontSize: 12),
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
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: languageService.tr("chat.poll.option"),
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
                icon: const Icon(Icons.add, color: Color(0xffED7474), size: 15),
                label: Text(
                  languageService.tr("chat.poll.addOption"),
                  style: const TextStyle(color: Color(0xffED7474), fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),
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
                  isLoading: isLoading,
                  backgroundColor: const Color(0xffFFF6F6),
                  textColor: const Color(0xffED7474)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void sendPoll(String question, List<String> options) {
    scrollToBottom();
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

  Future<void> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        selectedFiles.add(file);
        debugPrint("📄 Seçilen dosya: $filePath");
        debugPrint("📁 Toplam seçilen dosya sayısı: ${selectedFiles.length}");
      }
    } catch (e) {
      debugPrint("Belge seçme hatası: $e");
    }
  }

  Future<void> sendMessage(String message) async {
    if (currentChatId.value == null) return;
    if (isSendingMessage.value) return;
    
    // Debug logları ekle
    debugPrint('📤 Sending message:');
    debugPrint('  - Text: "$message"');
    debugPrint('  - Selected files: ${selectedFiles.length}');
    debugPrint('  - File types: ${selectedFiles.map((f) => f.path.split('.').last).toList()}');
    
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
        'Hata',
        'Mesaj gönderilemedi',
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
}
