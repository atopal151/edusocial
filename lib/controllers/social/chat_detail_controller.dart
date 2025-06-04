import 'dart:async';
import 'dart:io';
import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/models/chat_models/conversation_model.dart';
import 'package:edusocial/models/chat_models/sender_model.dart';
import 'package:edusocial/services/chat_service.dart';
import 'package:edusocial/services/socket_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/chat_models/chat_detail_model.dart';
import '../../models/user_chat_detail_model.dart';

class ChatDetailController extends GetxController {
  RxList<MessageModel> messages = <MessageModel>[].obs;
  final ScrollController scrollController = ScrollController();

  var userChatDetail = Rxn<UserChatDetailModel>();
  var isLoading = false.obs;
  RxString pollQuestion = ''.obs;
  RxList<String> pollOptions = <String>[].obs;
  RxMap<String, int> pollVotes = <String, int>{}.obs;
  RxString selectedPollOption = ''.obs;

  Rx<File?> selectedImage = Rx<File?>(null);
  TextEditingController pollTitleController = TextEditingController();

  late int currentChatId;
  final ProfileController profileController = Get.find<ProfileController>();
  final SocketService socketService = Get.find<SocketService>();

@override
void onInit() {
  super.onInit();

    // Socket Listener'ı sadece 1 kez ekliyoruz
   /* socketService.onPrivateMessage((data) {
      onNewPrivateMessage(data);
    });*/
}


  @override
  void onClose() {
    stopListeningToNewMessages();
    super.onClose();
  }

  void onNewPrivateMessage(dynamic data) {
    final conversationId = data['conversation_id'];
    if (conversationId == currentChatId) {
      messages.add(MessageModel.fromJson(data));
      messages.refresh();
      scrollToBottom();
    }
  }


  void startListeningToNewMessages(int chatId) {
    currentChatId = chatId;
  }

  void stopListeningToNewMessages() {
   // socketService.removeAllListeners();
  }

 void fetchConversationMessages(int chatId) async {
    try {
      isLoading.value = true;
      final fetchedMessages = await ChatServices.fetchConversationMessages(chatId);
      messages.assignAll(fetchedMessages);
      messages.refresh();
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    } catch (e, stackTrace) {
      debugPrint("🛑 Mesajlar getirilemedi: $e");
      debugPrint(stackTrace.toString());
    } finally {
      isLoading.value = false;
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
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
  void sendMessage(String text) async {
    try {
      isLoading.value = true;
      List<File> mediaFilesToSend = [];
      if (selectedImage.value != null) {
        mediaFilesToSend.add(selectedImage.value!);
      }

      await ChatServices.sendMessage(
        currentChatId,
        text,
        mediaFiles: mediaFilesToSend.isNotEmpty ? mediaFilesToSend : null,
      );

      messages.add(MessageModel(
        id: 0,
        conversationId: currentChatId,
        senderId: 0,
        message: text,
        isRead: true,
        isMe: true,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        sender: SenderModel.empty(),
        conversation: ConversationModel.empty(),
        messageMedia: [],
        messageLink: [],
        senderAvatarUrl: '',
      ));

      messages.refresh();
      selectedImage.value = null;
      scrollToBottom();
    } catch (e) {
      debugPrint("🛑 Mesaj gönderilemedi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
