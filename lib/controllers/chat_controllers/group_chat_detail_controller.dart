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
  final ScrollController scrollController = ScrollController();

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
    debugPrint('🔍 Get.arguments: ${Get.arguments}');
    debugPrint('🔍 Get.arguments type: ${Get.arguments.runtimeType}');
    
    if (Get.arguments != null && Get.arguments['groupId'] != null) {
      currentGroupId.value = Get.arguments['groupId'];
      debugPrint('✅ Current group ID set to: ${currentGroupId.value}');
      
      // Progressive loading: Önce grup verilerini yükle
      _loadGroupDataProgressive();
    } else {
      debugPrint('❌ No group ID provided in arguments');
      debugPrint('❌ Get.arguments is null: ${Get.arguments == null}');
      if (Get.arguments != null) {
        debugPrint('❌ Get.arguments keys: ${Get.arguments.keys}');
      }
      Get.snackbar(
        'Error',
        'No group selected',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Navigate back if no group ID is provided
      Get.back();
    }
  }

  /// Progressive loading: Önce grup verilerini yükle, sonra mesajları
  Future<void> _loadGroupDataProgressive() async {
    try {
      // 1. Grup verilerini yükle
      isGroupDataLoading.value = true;
      await fetchGroupDetails();
      isGroupDataLoading.value = false;
      
      // 2. Mesajları ayrı olarak yükle (UI zaten görünür durumda)
      isMessagesLoading.value = true;
      await fetchGroupMessages();
      isMessagesLoading.value = false;
      
    } catch (e) {
      debugPrint('❌ Progressive loading error: $e');
      isGroupDataLoading.value = false;
      isMessagesLoading.value = false;
    }
  }

  Future<void> fetchGroupDetails() async {
    if (currentGroupId.value.isEmpty) {
      debugPrint('❌ Cannot fetch group details: No group ID provided');
      return;
    }

    try {
      debugPrint('🔍 Fetching group details for group ID: ${currentGroupId.value}');
      
      final group = await _groupServices.fetchGroupDetail(currentGroupId.value)
          .timeout(const Duration(seconds: 10)); // 10 saniye timeout
      
      groupData.value = group;
      
      // Group chats verilerini mesajlara dönüştür
      convertGroupChatsToMessages();
      
      debugPrint('✅ Group details loaded successfully');
    } catch (e) {
      debugPrint('❌ Error fetching group details: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch group details',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void convertGroupChatsToMessages() {
    if (groupData.value?.groupChats == null) return;
    
    // Mevcut mesajları temizle
    messages.clear();
    
    final groupChats = groupData.value!.groupChats;
    final currentUserId = Get.find<ProfileController>().userId.value;
    
    // Performans için önceden hesaplanmış değerler
    final processedMessages = <GroupMessageModel>[];
    
    for (final chat in groupChats) {
      final user = chat.user;
      final isSentByMe = user['id'].toString() == currentUserId;
      
      GroupMessageType messageType = GroupMessageType.text;
      String content = chat.message;
      List<String>? links;
      
      // Mesaj türünü belirle - optimize edilmiş
      if (chat.media.isNotEmpty) {
        final media = chat.media.first;
        if (media.type.startsWith('image/')) {
          messageType = GroupMessageType.image;
          content = media.fullPath;
        } else {
          messageType = GroupMessageType.document;
          content = media.fullPath;
        }
      } else if (chat.groupChatLink.isNotEmpty) {
        final chatLinks = chat.groupChatLink.map((link) => link.link).toList();
        
        if (chat.message.isNotEmpty) {
          messageType = GroupMessageType.textWithLinks;
          content = chat.message;
          links = chatLinks;
        } else {
          messageType = GroupMessageType.link;
          content = chatLinks.first;
        }
      }
      
      final message = GroupMessageModel(
        id: chat.id.toString(),
        senderId: chat.userId.toString(),
        receiverId: chat.groupId.toString(),
        name: user['name'] ?? '',
        surname: user['surname'] ?? '',
        profileImage: user['avatar_url'] ?? '',
        content: content,
        messageType: messageType,
        timestamp: DateTime.parse(chat.createdAt),
        isSentByMe: isSentByMe,
        additionalText: chat.messageType == 'poll' ? chat.message : null,
        links: links,
      );
      
      processedMessages.add(message);
    }
    
    // Mesajları tarihe göre sırala
    processedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Toplu olarak ekle
    messages.assignAll(processedMessages);
    
    // Grup chat verilerinden belge, bağlantı ve fotoğraf verilerini çıkar
    extractGroupChatMedia();
    
    // Mesajlar yüklendikten sonra en alta git
    _scrollToBottomWithRetry();
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
        convertGroupChatsToMessages();
      }
      
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch messages',
        snackPosition: SnackPosition.BOTTOM,
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
    
    // Debug log ekle
    debugPrint('📤 Sending message:');
    debugPrint('  - Text: "$text"');
    debugPrint('  - Selected files: ${selectedFiles.length}');
    
    // Eğer hiçbir şey seçilmemişse gönderme
    if (text.isEmpty && selectedFiles.isEmpty) {
      debugPrint('❌ Nothing to send');
      return;
    }
    
    // Eğer sadece dosya seçilmişse ve text yoksa, dosyaları gönder
    if (text.isEmpty && selectedFiles.isNotEmpty) {
      debugPrint('📁 Sending only media files');
      await sendMediaOnly();
      return;
    }
    
    isSendingMessage.value = true;
    
    try {
      // Text içinde link var mı kontrol et
      if (text.isNotEmpty && hasLinksInText(text)) {
        debugPrint('🔗 Links detected in text, processing...');
        
        final urls = extractUrlsFromText(text);
        final nonLinkText = extractNonLinkText(text);
        
        debugPrint('  - Detected URLs: $urls');
        debugPrint('  - Non-link text: "$nonLinkText"');
        
        // Linkleri normalize et
        final normalizedUrls = urls.map((url) => normalizeUrl(url)).toList();
        
        // Text ve linkleri birlikte gönder (user chat gibi)
        debugPrint('  - Sending message with text and links together');
        
        final success = await _groupServices.sendGroupMessage(
          groupId: currentGroupId.value,
          message: nonLinkText, // Link olmayan text
          mediaFiles: selectedFiles.isNotEmpty ? selectedFiles : null,
          links: normalizedUrls, // Linkleri ayrı parametrede gönder
        );
        
        if (!success) {
          debugPrint('❌ Failed to send message with links');
          Get.snackbar(
            'Hata',
            'Mesaj gönderilemedi',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        // Normal text mesajı gönder (link yok)
        debugPrint('📝 Sending normal text message');
        
        final success = await _groupServices.sendGroupMessage(
          groupId: currentGroupId.value,
          message: text, // Boş string olsa bile gönder
          mediaFiles: selectedFiles.isNotEmpty ? selectedFiles : null,
          links: null,
        );
        
        if (!success) {
          debugPrint('❌ Failed to send message');
          Get.snackbar(
            'Hata',
            'Mesaj gönderilemedi',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
      
      // Başarılı ise seçilen dosyaları temizle
      selectedFiles.clear();
      
      // Mesajları hızlıca yeniden yükle
      await refreshMessagesOnly();
      
      // Mesaj gönderildikten sonra en alta git
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom(animated: true);
      });
      
    } catch (e) {
      debugPrint('💥 Message sending error: $e');
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
        debugPrint('✅ Media files sent successfully');
        selectedFiles.clear();
        await refreshMessagesOnly();
        
        // Medya gönderildikten sonra en alta git
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom(animated: true);
        });
      } else {
        debugPrint('❌ Failed to send media files');
        Get.snackbar(
          'Hata',
          'Dosyalar gönderilemedi',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
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

  // Hızlı mesaj güncelleme (sadece mesajları yeniden yükle)
  Future<void> refreshMessagesOnly() async {
    try {
      debugPrint('🔄 Refreshing messages only...');
      
      // Sadece grup detaylarını yeniden yükle (mesajlar dahil)
      final group = await _groupServices.fetchGroupDetail(currentGroupId.value);
      groupData.value = group;
      
      // Group chats verilerini mesajlara dönüştür
      convertGroupChatsToMessages();
      
      debugPrint('✅ Messages refreshed successfully');
    } catch (e) {
      debugPrint('❌ Error refreshing messages: $e');
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    pollTitleController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
