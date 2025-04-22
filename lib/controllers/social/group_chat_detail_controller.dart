import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/buttons/custom_button.dart';
import '../../models/chat_detail_model.dart';

class GroupChatDetailController extends GetxController {
  RxList<MessageModel> groupmessages = <MessageModel>[].obs;
  final ScrollController scrollController = ScrollController();

  RxString pollQuestion = ''.obs;
  RxList<String> pollOptions = <String>[].obs;
  RxMap<String, int> pollVotes = <String, int>{}.obs;
  RxString selectedPollOption = ''.obs;
  var isLoading = false.obs;
  TextEditingController pollTitleController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    simulateIncomingMessages();
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
                                style: TextStyle(fontSize: 12),
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
                icon: const Icon(
                  Icons.add,
                  color: Color(0xffED7474),
                  size: 15,
                ),
                label: const Text(
                  'Seçenek Ekle',
                  style: TextStyle(color: Color(0xffED7474), fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),

              /**
               *  backgroundColor: const Color(0xffFFF6F6),
                    foregroundColor: const Color(0xffED7474),
               */
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

  void sendPoll(String question, List<String> options) {
    groupmessages.add(MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: "me",
      receiverId: "user123",
      content: question,
      messageType: MessageType.poll,
      timestamp: DateTime.now(),
      isSentByMe: true,
      pollOptions: options,
    ));
    scrollToBottom();
  }

  void pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      groupmessages.add(MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: "me",
        receiverId: "user123",
        content: pickedFile.path,
        messageType: MessageType.image,
        timestamp: DateTime.now(),
        isSentByMe: true,
      ));
      scrollToBottom();
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
        print("Seçilen dosya: $filePath");

        groupmessages.add(MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: "me",
          receiverId: "user123",
          content: filePath,
          messageType: MessageType.document,
          timestamp: DateTime.now(),
          isSentByMe: true,
        ));

        scrollToBottom();
      }
    } catch (e) {
      print("Belge seçme hatası: $e");
    }
  }

  void sendMessage(String text) {
    groupmessages.add(MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: "me",
      receiverId: "user123",
      content: text,
      messageType: MessageType.text,
      timestamp: DateTime.now(),
      isSentByMe: true,
    ));
    scrollToBottom();
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void getToGrupDetailScreen() {
    Get.toNamed("/groupDetailScreen");
  }

  void simulateIncomingMessages() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      groupmessages.add(MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: "user123",
        receiverId: "me",
        content: "Bu otomatik gelen bir mesajdır.",
        messageType: MessageType.text,
        timestamp: DateTime.now(),
        isSentByMe: false,
      ));
      scrollToBottom();
    });
  }
}
