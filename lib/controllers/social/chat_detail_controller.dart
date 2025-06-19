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
  int? currentChatId;

  RxString pollQuestion = ''.obs;
  RxList<String> pollOptions = <String>[].obs;
  RxMap<String, int> pollVotes = <String, int>{}.obs;
  RxString selectedPollOption = ''.obs;

  // Media seçimi için yeni değişkenler
  final RxList<File> selectedFiles = <File>[].obs;
  final RxBool isSendingMessage = false.obs;
  TextEditingController pollTitleController = TextEditingController();

  final ProfileController profileController = Get.find<ProfileController>();
  final SocketService socketService = Get.find<SocketService>();

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
    _initializeScrollController();
    _setupSocketListeners();
    _loadInitialData();
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
    final socketService = Get.find<SocketService>();
    socketService.onNewPrivateMessage(_onNewPrivateMessage);
  }

  void _loadInitialData() {
    if (currentChatId != null) {
      fetchConversationMessages(currentChatId!);
    }
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
    super.onClose();
  }

  Future<void> loadUserChatDetail(int chatId) async {
    try {
      debugPrint('🔍 ChatDetailController - loadUserChatDetail başladı');
      debugPrint('  - chatId: $chatId');
      
      isLoading.value = true;
      currentChatId = chatId;

      // Mesajları yükle
      final fetchedMessages = await ChatServices.fetchConversationMessages(chatId);
      messages.clear();
      messages.addAll(fetchedMessages);

      // İlk mesajdan kullanıcı bilgilerini yükle
      if (messages.isNotEmpty) {
        final sender = messages.first.sender;
        
        debugPrint('✅ ChatDetailController - Sender bilgileri:');
        debugPrint('  - ID: ${sender.id}');
        debugPrint('  - Name: ${sender.name}');
        debugPrint('  - Surname: ${sender.surname}');
        
        // Kullanıcı detaylarını getir
        final userDetails = await ChatServices.fetchUserDetails(sender.id);
        
        // Belge, link ve fotoğrafları topla
        final allDocuments = <DetailDocumentModel>[];
        final allLinks = <LinkModel>[];
        final allPhotos = <String>[];

        for (var message in messages) {
          // Belgeleri topla
          if (message.messageDocument != null) {
            allDocuments.addAll(message.messageDocument!);
          }

          // Linkleri topla
          for (var link in message.messageLink) {
            allLinks.add(LinkModel(
              url: link.link,
              title: link.linkTitle,
            ));
          }

          // Fotoğrafları topla
          for (var media in message.messageMedia) {
            allPhotos.add(media.path);
          }
        }

        // Kullanıcı detaylarını güncelle
        userChatDetail.value = UserChatDetailModel(
          id: userDetails.id,
          name: userDetails.name,
          follower: userDetails.follower,
          following: userDetails.following,
          imageUrl: userDetails.imageUrl,
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
        debugPrint('  - Follower: ${userChatDetail.value?.follower}');
        debugPrint('  - Following: ${userChatDetail.value?.following}');
        debugPrint('  - Documents Count: ${userChatDetail.value?.documents.length}');
        debugPrint('  - Links Count: ${userChatDetail.value?.links.length}');
        debugPrint('  - PhotoUrls Count: ${userChatDetail.value?.photoUrls.length}');
      } else {
        debugPrint('❌ ChatDetailController - Mesaj veya gönderen bulunamadı');
      }

      userChatDetail.refresh();
    } catch (e) {
      debugPrint('❌ ChatDetailController - Hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _onNewPrivateMessage(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        final message = MessageModel.fromJson(data);
        if (message.conversationId == currentChatId) {
          messages.add(message);
          // Yeni mesaj geldiğinde kullanıcı bilgilerini güncelle
          final sender = message.sender;
          userChatDetail.value = UserChatDetailModel(
            id: sender.id.toString(),
            name: '${sender.name} ${sender.surname}',
            follower: '0', // API'den gelmiyor
            following: '0', // API'den gelmiyor
            imageUrl: sender.avatarUrl,
            memberImageUrls: const [],
            documents: message.messageDocument?.map((doc) => DocumentModel(
              id: doc.id,
              name: doc.name,
              sizeMb: 0.0,
              humanCreatedAt: doc.date,
              createdAt: DateTime.parse(doc.date),
            )).toList() ?? [],
            links: const [],
            photoUrls: const [],
          );
        }
      }
    } catch (e) {
      debugPrint('❌ _onNewPrivateMessage error: $e');
    }
  }

  void startListeningToNewMessages(int chatId) {
    currentChatId = chatId;
  }

  void stopListeningToNewMessages() {
    // socketService.removeAllListeners();
  }

  Future<void> fetchConversationMessages(int chatId) async {
    try {
      isLoading.value = true;
      currentChatId = chatId;
      
      // Mesajları yükle
      final fetchedMessages = await ChatServices.fetchConversationMessages(chatId);
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
                  hintText: "Anket Başlığı",
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
                                  hintText: "+ Seçenek Ekle",
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
                label: const Text(
                  'Seçenek Ekle',
                  style: TextStyle(color: Color(0xffED7474), fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                  text: "Gönder",
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
    if (currentChatId == null) return;
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
          currentChatId!,
          nonLinkText, // Sadece link olmayan text
          mediaFiles: selectedFiles.isNotEmpty ? selectedFiles : null,
          links: normalizedUrls, // Linkleri ayrı parametrede gönder
        );
      } else {
        // Normal text mesajı gönder (link yok)
        debugPrint('📝 Sending normal text message');
        
        await ChatServices.sendMessage(
          currentChatId!,
          message,
          mediaFiles: selectedFiles.isNotEmpty ? selectedFiles : null,
        );
      }
      
      // Başarılı ise seçilen dosyaları temizle
      selectedFiles.clear();
      
      // Mesaj gönderildikten sonra mesajları yeniden yükle
      await fetchConversationMessages(currentChatId!);
      
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
    if (currentChatId == null) return;
    if (isSendingMessage.value) return;
    
    debugPrint('📁 Sending media files only');
    isSendingMessage.value = true;
    
    try {
      await ChatServices.sendMessage(
        currentChatId!,
        '', // Boş text
        mediaFiles: selectedFiles,
      );
      
      debugPrint('✅ Media files sent successfully');
      selectedFiles.clear();
      
      // Mesajları yeniden yükle
      await fetchConversationMessages(currentChatId!);
      
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
