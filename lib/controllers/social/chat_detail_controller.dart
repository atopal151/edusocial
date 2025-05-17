import 'dart:async';
import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/chat_detail_model.dart';
import '../../models/document_model.dart';
import '../../models/link_model.dart';
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

  TextEditingController pollTitleController = TextEditingController();
  @override
  void onInit() {
    super.onInit();
    simulateIncomingMessages();
    loadMockGroupData();
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
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF),fontSize: 12),
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
                                  hintStyle:
                                      const TextStyle(color: Color(0xFF9CA3AF),fontSize: 12),
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
                icon: const Icon(Icons.add,color: Color(0xffED7474),size: 15,),
                label: const Text('Seçenek Ekle',style: TextStyle(color: Color(0xffED7474),fontSize: 12),),
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
                     final filledOptions = pollOptions
                          .where((e) => e.trim().isNotEmpty)
                          .toList();
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

  void loadMockGroupData() {
    userChatDetail.value = UserChatDetailModel(
        id: "user_001",
        name: "Roger Carscraad",
        imageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
        memberImageUrls: [
          "https://randomuser.me/api/portraits/men/1.jpg",
          "https://randomuser.me/api/portraits/men/2.jpg",
          "https://randomuser.me/api/portraits/men/3.jpg",
          "https://randomuser.me/api/portraits/men/4.jpg",
          "https://randomuser.me/api/portraits/men/5.jpg",
          "https://randomuser.me/api/portraits/men/7.jpg",
          "https://randomuser.me/api/portraits/men/6.jpg",
          "https://randomuser.me/api/portraits/men/2.jpg",
          "https://randomuser.me/api/portraits/men/8.jpg",
          "https://randomuser.me/api/portraits/men/9.jpg",
          "https://randomuser.me/api/portraits/men/10.jpg",
          "https://randomuser.me/api/portraits/men/13.jpg",
        ],
        documents: [
          DocumentModel(
            name: "Edusocial.png",
            sizeMb: 3.72,
            date: DateTime(2025, 1, 27),
            url: "https://randomuser.me/api/portraits/men/4.jpg",
          ),
          DocumentModel(
            name: "Edusocial.png",
            sizeMb: 3.72,
            date: DateTime(2025, 1, 27),
            url: "https://randomuser.me/api/portraits/men/4.jpg",
          ),
          DocumentModel(
            name: "Edusocial.png",
            sizeMb: 3.72,
            date: DateTime(2025, 1, 27),
            url: "https://randomuser.me/api/portraits/men/4.jpg",
          ),
          DocumentModel(
            name: "Edusocial.png",
            sizeMb: 3.72,
            date: DateTime(2025, 1, 27),
            url: "https://randomuser.me/api/portraits/men/4.jpg",
          ),
          DocumentModel(
            name: "Edusocial.png",
            sizeMb: 3.72,
            date: DateTime(2025, 1, 27),
            url: "https://randomuser.me/api/portraits/men/4.jpg",
          ),
          DocumentModel(
            name: "Edusocial.png",
            sizeMb: 3.72,
            date: DateTime(2025, 1, 27),
            url: "https://randomuser.me/api/portraits/men/4.jpg",
          ),
        ],
        links: [
          LinkModel(
            title: "github.com",
            url: "https://github.com/monegonllc",
          ),
          LinkModel(
            title: "github.com",
            url: "https://github.com/monegonllc",
          ),
          LinkModel(
            title: "github.com",
            url: "https://github.com/monegonllc",
          ),
          LinkModel(
            title: "github.com",
            url: "https://github.com/monegonllc",
          ),
          LinkModel(
            title: "github.com",
            url: "https://github.com/monegonllc",
          ),
          LinkModel(
            title: "github.com",
            url: "https://github.com/monegonllc",
          ),
        ],
        photoUrls: [
          "https://randomuser.me/api/portraits/men/1.jpg",
          "https://randomuser.me/api/portraits/men/2.jpg",
          "https://randomuser.me/api/portraits/men/3.jpg",
          "https://randomuser.me/api/portraits/men/4.jpg",
          "https://randomuser.me/api/portraits/men/5.jpg",
          "https://randomuser.me/api/portraits/men/6.jpg",
          "https://randomuser.me/api/portraits/men/7.jpg",
          "https://randomuser.me/api/portraits/men/8.jpg",
          "https://randomuser.me/api/portraits/men/9.jpg",
          "https://randomuser.me/api/portraits/men/10.jpg",
          "https://randomuser.me/api/portraits/men/11.jpg",
          "https://randomuser.me/api/portraits/men/12.jpg",
          "https://randomuser.me/api/portraits/men/13.jpg",
          "https://randomuser.me/api/portraits/men/14.jpg",
        ],
        follower: '500',
        following: '459');
  }

  void sendPoll(String question, List<String> options) {
    messages.add(MessageModel(
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
      messages.add(MessageModel(
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
        debugPrint("Seçilen dosya: $filePath",wrapWidth: 1024);

        messages.add(MessageModel(
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
      debugPrint("Belge seçme hatası: $e",wrapWidth: 1024);
    }
  }

  void sendMessage(String text) {
    messages.add(MessageModel(
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

 void simulateIncomingMessages() {
  Timer.periodic(Duration(seconds: 1), (timer) {
    final now = DateTime.now();
    final randomIndex = now.second % 5; // 5 farklı mesaj tipi

    MessageModel newMessage;

    switch (randomIndex) {
      case 0: // Text mesaj
        newMessage = MessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user123",
          receiverId: "me",
          content: "Nasılsın? Bugün ne yapıyorsun?",
          messageType: MessageType.text,
          timestamp: now,
          isSentByMe: false,
        );
        break;
      case 1: // Image mesaj
        newMessage = MessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user124",
          receiverId: "me",
          content: "https://picsum.photos/200/300", // Sahte resim linki
          messageType: MessageType.image,
          timestamp: now,
          isSentByMe: false,
        );
        break;
      case 2: // Document mesaj
        newMessage = MessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user125",
          receiverId: "me",
          content: "/documents/sample_file.pdf",
          messageType: MessageType.document,
          timestamp: now,
          isSentByMe: false,
        );
        break;
      case 3: // Link mesaj
        newMessage = MessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user126",
          receiverId: "me",
          content: "https://flutter.dev",
          messageType: MessageType.link,
          timestamp: now,
          isSentByMe: false,
        );
        break;
      case 4: // Poll mesaj
        newMessage = MessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user127",
          receiverId: "me",
          content: "En sevdiğin tatil türü hangisi? 🏖️⛷️",
          messageType: MessageType.poll,
          timestamp: now,
          isSentByMe: false,
        );
        break;
      default: // Fallback - Text
        newMessage = MessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user123",
          receiverId: "me",
          content: "Varsayılan mesaj...",
          messageType: MessageType.text,
          timestamp: now,
          isSentByMe: false,
        );
        break;
    }

    messages.add(newMessage);
    scrollToBottom();
  });
}

}
