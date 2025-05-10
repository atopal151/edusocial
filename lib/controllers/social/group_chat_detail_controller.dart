import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/buttons/custom_button.dart';
import '../../models/group_models/group_message_model.dart';

class GroupChatDetailController extends GetxController {
  RxList<GroupMessageModel> groupmessages = <GroupMessageModel>[].obs;
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
    groupmessages.add(GroupMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: "me",
      receiverId: "user123",
      content: question,name: "Ali",
    surname: "Yılmaz",
    profileImage: "https://randomuser.me/api/portraits/men/1.jpg",
      messageType: GroupMessageType.poll,
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
      groupmessages.add(GroupMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: "me",
        receiverId: "user123",name: "Ali",
    surname: "Yılmaz",
    profileImage: "https://randomuser.me/api/portraits/men/1.jpg",
        content: pickedFile.path,
        messageType: GroupMessageType.image,
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

        groupmessages.add(GroupMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: "me",
          receiverId: "user123",
          content: filePath,name: "Ali",
    surname: "Yılmaz",
    profileImage: "https://randomuser.me/api/portraits/men/1.jpg",
          messageType: GroupMessageType.document,
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
    groupmessages.add(GroupMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: "me",
      receiverId: "user123",
      content: text,
      name: "Ali",
    surname: "Yılmaz",
    profileImage: "https://randomuser.me/api/portraits/men/1.jpg",
      messageType: GroupMessageType.text,
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
  Timer.periodic(Duration(seconds: 1), (timer) {
    final now = DateTime.now();
    final randomIndex = now.second % 5; // 5 tip var, saniyeye göre değişsin

    GroupMessageModel newMessage;

    switch (randomIndex) {
      case 0: // Text mesaj
        newMessage = GroupMessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user123",
          receiverId: "me",
          name: "Ayşe",
          surname: "Demir",
          profileImage: "https://randomuser.me/api/portraits/women/10.jpg",
          content: "Selam! Ne yapıyorsun?",
          messageType: GroupMessageType.text,
          timestamp: now,
          isSentByMe: false,
        );
        break;
      case 1: // Image mesaj
        newMessage = GroupMessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user124",
          receiverId: "me",
          name: "Mehmet",
          surname: "Kaya",
          profileImage: "https://randomuser.me/api/portraits/men/15.jpg",
          content: "https://picsum.photos/200/300", // Simülasyon görseli
          messageType: GroupMessageType.image,
          timestamp: now,
          isSentByMe: false,
        );
        break;
      case 2: // Document mesaj
        newMessage = GroupMessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user125",
          receiverId: "me",
          name: "Fatma",
          surname: "Koç",
          profileImage: "https://randomuser.me/api/portraits/women/20.jpg",
          content: "/documents/example_doc.pdf", // Sahte dosya yolu
          messageType: GroupMessageType.document,
          timestamp: now,
          isSentByMe: false,
        );
        break;
      case 3: // Link mesaj
        newMessage = GroupMessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user126",
          receiverId: "me",
          name: "Ahmet",
          surname: "Şahin",
          profileImage: "https://randomuser.me/api/portraits/men/25.jpg",
          content: "https://flutter.dev",
          messageType: GroupMessageType.link,
          timestamp: now,
          isSentByMe: false,
        );
        break;
      case 4: // Poll mesaj
        newMessage = GroupMessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user127",
          receiverId: "me",
          name: "Elif",
          surname: "Yıldız",
          profileImage: "https://randomuser.me/api/portraits/women/30.jpg",
          content: "En sevdiğin mevsim hangisi?",
          messageType: GroupMessageType.poll,
          timestamp: now,
          isSentByMe: false,
          pollOptions: ["Yaz", "Kış", "İlkbahar", "Sonbahar"],
        );
        break;
      default: // Fallback - Text
        newMessage = GroupMessageModel(
          id: now.millisecondsSinceEpoch.toString(),
          senderId: "user123",
          receiverId: "me",
          name: "Ayşe",
          surname: "Demir",
          profileImage: "https://randomuser.me/api/portraits/women/10.jpg",
          content: "Default mesaj.",
          messageType: GroupMessageType.text,
          timestamp: now,
          isSentByMe: false,
        );
        break;
    }

    groupmessages.add(newMessage);
    scrollToBottom();
  });
}

}
