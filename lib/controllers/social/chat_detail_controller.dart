import 'dart:async';
import 'dart:io';
import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/models/chat_models/conversation_model.dart';
import 'package:edusocial/models/chat_models/sender_model.dart';
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
  int? currentChatId;

  RxString pollQuestion = ''.obs;
  RxList<String> pollOptions = <String>[].obs;
  RxMap<String, int> pollVotes = <String, int>{}.obs;
  RxString selectedPollOption = ''.obs;

  Rx<File?> selectedImage = Rx<File?>(null);
  TextEditingController pollTitleController = TextEditingController();

  final ProfileController profileController = Get.find<ProfileController>();
  final SocketService socketService = Get.find<SocketService>();

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
        // Son sayfaya gelindiğinde yeni mesajları yükle
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

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadUserChatDetail(int chatId) async {
    try {
      debugPrint('🔍 ChatDetailController - loadUserChatDetail başladı');
      debugPrint('  - chatId: $chatId');
      
      isLoading.value = true;
      currentChatId = chatId;

      // Örnek veri - gerçek uygulamada API'den gelecek
      userChatDetail.value = UserChatDetailModel(
        id: chatId.toString(),
        name: "Kullanıcı Adı",
        follower: "0",
        following: "0",
        imageUrl: "https://via.placeholder.com/150",
        memberImageUrls: const [],
        documents: const [],
        links: const [],
        photoUrls: const [],
      );

      debugPrint('✅ ChatDetailController - userChatDetail yüklendi:');
      debugPrint('  - ID: ${userChatDetail.value?.id}');
      debugPrint('  - Name: ${userChatDetail.value?.name}');
      debugPrint('  - Follower: ${userChatDetail.value?.follower}');
      debugPrint('  - Following: ${userChatDetail.value?.following}');

      // Mesajları yükle
      await fetchConversationMessages(chatId);

      // Belge, link ve fotoğrafları userChatDetail'e ekle
      if (userChatDetail.value != null) {
        userChatDetail.value = UserChatDetailModel(
          id: userChatDetail.value!.id,
          name: userChatDetail.value!.name,
          follower: userChatDetail.value!.follower,
          following: userChatDetail.value!.following,
          imageUrl: userChatDetail.value!.imageUrl,
          memberImageUrls: userChatDetail.value!.memberImageUrls,
          documents: documentModels.map((doc) => DocumentModel(
            name: doc.name,
            url: doc.url,
            sizeMb: 0.0,
            date: DateTime.now(),
          )).toList(),
          links: links.map((link) => LinkModel(
            url: link,
            title: "Link",
          )).toList(),
          photoUrls: photoUrls,
        );
        
        debugPrint('✅ ChatDetailController - userChatDetail güncellendi:');
        debugPrint('  - Documents Count: ${userChatDetail.value?.documents.length}');
        debugPrint('  - Links Count: ${userChatDetail.value?.links.length}');
        debugPrint('  - PhotoUrls Count: ${userChatDetail.value?.photoUrls.length}');
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
          if (message.sender != null) {
            final sender = message.sender!;
            userChatDetail.value = UserChatDetailModel(
              id: sender.id.toString(),
              name: '${sender.name} ${sender.surname}',
              follower: '0', // API'den gelmiyor
              following: '0', // API'den gelmiyor
              imageUrl: sender.avatarUrl,
              memberImageUrls: const [],
              documents: const [],
              links: const [],
              photoUrls: const [],
            );
          }
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
      
      final fetchedMessages = await ChatServices.fetchConversationMessages(chatId);
      messages.clear();
      messages.addAll(fetchedMessages);

      // İlk mesajdan kullanıcı bilgilerini yükle
      if (messages.isNotEmpty && messages.first.sender != null) {
        final sender = messages.first.sender!;
        userChatDetail.value = UserChatDetailModel(
          id: sender.id.toString(),
          name: '${sender.name} ${sender.surname}',
          follower: '0', // API'den gelmiyor
          following: '0', // API'den gelmiyor
          imageUrl: sender.avatarUrl,
          memberImageUrls: const [],
          documents: const [],
          links: const [],
          photoUrls: const [],
        );
      }
    } catch (e) {
      debugPrint('❌ fetchConversationMessages error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void scrollToBottom({bool animated = true}) {
    if (scrollController.hasClients) {
      final position = scrollController.position.maxScrollExtent + 100;
      if (animated) {
        scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 1),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(position);
      }
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
      selectedImage.value = File(pickedFile.path);
      debugPrint("📸 Seçilen resim: ${pickedFile.path}");
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
        debugPrint("Seçilen dosya: $filePath");
        scrollToBottom();
      }
    } catch (e) {
      debugPrint("Belge seçme hatası: $e");
    }
  }

  Future<void> sendMessage(String message) async {
    if (currentChatId == null) return;
    
    try {
      await ChatServices.sendMessage(
        currentChatId!,
        message,
      );
      // Mesaj gönderildikten sonra mesajları yeniden yükle
      await fetchConversationMessages(currentChatId!);
    } catch (e) {
      debugPrint("🛑 Mesaj gönderilemedi: $e");
    }
  }
}
