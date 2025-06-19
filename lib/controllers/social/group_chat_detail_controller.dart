import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/buttons/custom_button.dart';
import '../../models/chat_models/group_message_model.dart';
import '../../models/group_models/group_detail_model.dart';
import '../../models/group_models/group_chat_model.dart';
import '../../services/group_services/group_service.dart';
import '../profile_controller.dart';

class GroupChatDetailController extends GetxController {
  final GroupServices _groupServices = GroupServices();
  final RxList<GroupMessageModel> messages = <GroupMessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentGroupId = ''.obs;
  final groupData = Rx<GroupDetailModel?>(null);
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  RxString pollQuestion = ''.obs;
  RxList<String> pollOptions = <String>[].obs;
  RxMap<String, int> pollVotes = <String, int>{}.obs;
  RxString selectedPollOption = ''.obs;
  TextEditingController pollTitleController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    debugPrint('Group chat detail arguments: ${Get.arguments}');
    if (Get.arguments != null && Get.arguments['groupId'] != null) {
      currentGroupId.value = Get.arguments['groupId'];
      debugPrint('Current group ID: ${currentGroupId.value}');
      fetchGroupDetails();
      fetchGroupMessages();
    } else {
      debugPrint('❌ No group ID provided in arguments');
      Get.snackbar(
        'Error',
        'No group selected',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Navigate back if no group ID is provided
      Get.back();
    }
  }

  Future<void> fetchGroupDetails() async {
    if (currentGroupId.value.isEmpty) {
      debugPrint('❌ Cannot fetch group details: No group ID provided');
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('🔍 Fetching group details for group ID: ${currentGroupId.value}');
      
      final group = await _groupServices.fetchGroupDetail(currentGroupId.value);
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
    } finally {
      isLoading.value = false;
    }
  }

  void convertGroupChatsToMessages() {
    if (groupData.value?.groupChats == null) return;
    
    final groupChats = groupData.value!.groupChats;
    final currentUserId = Get.find<ProfileController>().userId.value;
    
    for (final chat in groupChats) {
      final user = chat.user;
      final isSentByMe = user['id'].toString() == currentUserId;
      
      GroupMessageType messageType = GroupMessageType.text;
      String content = chat.message;
      
      // Mesaj türünü belirle
      if (chat.media.isNotEmpty) {
        final media = chat.media.first;
        if (media.type.startsWith('image/')) {
          messageType = GroupMessageType.image;
          content = media.fullPath; // Resim URL'si
        } else {
          messageType = GroupMessageType.document;
          content = media.fullPath; // Doküman URL'si
        }
      } else if (chat.groupChatLink.isNotEmpty) {
        messageType = GroupMessageType.link;
        final link = chat.groupChatLink.first;
        content = link.link; // Link URL'si
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
      );
      
      messages.add(message);
    }
    
    // Mesajları tarihe göre sırala
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> fetchGroupMessages() async {
    try {
      isLoading.value = true;
      debugPrint('Fetching messages for group: ${currentGroupId.value}');
      
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch messages',
        snackPosition: SnackPosition.BOTTOM,
      );
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
    messages.add(GroupMessageModel(
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
      messages.add(GroupMessageModel(
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
        debugPrint("Seçilen dosya: $filePath");

        messages.add(GroupMessageModel(
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
      debugPrint("Belge seçme hatası: $e",wrapWidth: 1024);
    }
  }

  void sendMessage(String text) {
    messages.add(GroupMessageModel(
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
    debugPrint('🔍 Navigating to group detail screen with group ID: ${currentGroupId.value}');
    Get.toNamed("/groupDetailScreen", arguments: {
      'groupId': currentGroupId.value,
    });
  }

}
