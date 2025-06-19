import 'package:edusocial/components/widgets/chat_widget/message_widget_factory.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/input_fields/message_input_field.dart';
import '../../../controllers/social/chat_detail_controller.dart';
import '../../../models/user_chat_detail_model.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  // Controller'ı permanent olarak Get.put ile register ettik
  final ChatDetailController controller =
      Get.put(ChatDetailController(), permanent: true);

  final ProfileController profileController = Get.find<ProfileController>();
  late String name;
    late String username;
  late String avatarUrl;
  late bool isOnline;
  late int chatId;

  @override
  void initState() {
    super.initState();

    chatId = Get.arguments['chatId'];
    name = Get.arguments['name'] ?? 'Bilinmiyor';
    username = Get.arguments['username'] ?? '';
    avatarUrl = Get.arguments['avatarUrl'] ?? '';
    isOnline = Get.arguments['isOnline'] ?? false;

    debugPrint('Chat ID: $chatId');

    controller.fetchConversationMessages(chatId).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.scrollToBottom(animated: false);
      });
    });

    controller.startListeningToNewMessages(chatId);
    
    // Mesajlar yüklendikten sonra en alta git
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 500), () {
        controller.scrollToBottom(animated: false);
      });
    });
  }

  @override
  void dispose() {
    controller.stopListeningToNewMessages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        surfaceTintColor: const Color(0xffffffff),
        title: InkWell(
          onTap: () {
            profileController.getToPeopleProfileScreen(username);
          },
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        (avatarUrl.isNotEmpty && !avatarUrl.endsWith('/0'))
                            ? NetworkImage(avatarUrl)
                            : null,
                    child: (avatarUrl.isEmpty || avatarUrl.endsWith('/0'))
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: isOnline
                            ? const Color(0xff65d384)
                            : const Color(0xffd9d9d9),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff414751)),
                  ),
                  Text(
                    isOnline ? "Çevrimiçi" : "Çevrimdışı",
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff9ca3ae),
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          InkWell(
            onTap: _onUserDetailTap,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_horiz),
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xfffafafa),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                // Mesajlar yüklendiğinde en alta git
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (controller.messages.isNotEmpty) {
                    controller.scrollToBottom(animated: false);
                  }
                });
                
                return ListView.builder(
                  controller: controller.scrollController,
                  itemCount: controller.messages.length,
                  padding: const EdgeInsets.only(bottom: 75),
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return MessageWidgetFactory.buildMessageWidget(message);
                  },
                );
              }),
            ),
            Container(
              decoration: const BoxDecoration(color: Color(0xffffffff)),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16, top: 8, bottom: 20),
                child: buildMessageInputField(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onUserDetailTap() {
    debugPrint('🔍 ChatDetailScreen - _onUserDetailTap çağrıldı');
    debugPrint('  - currentChatId: ${controller.currentChatId}');
    debugPrint('  - userChatDetail: ${controller.userChatDetail.value != null ? 'Var' : 'Null'}');

    if (controller.userChatDetail.value == null) {
      debugPrint('❌ ChatDetailScreen - userChatDetail null');
      Get.snackbar('Hata', 'Kullanıcı bilgileri yüklenemedi!');
      return;
    }

    final userDetail = UserChatDetailModel(
      id: controller.userChatDetail.value?.id ?? '',
      name: name,
      follower: controller.userChatDetail.value?.follower ?? '0',
      following: controller.userChatDetail.value?.following ?? '0',
      imageUrl: avatarUrl,
      memberImageUrls: controller.userChatDetail.value?.memberImageUrls ?? [],
      documents: controller.userChatDetail.value?.documents ?? [],
      links: controller.userChatDetail.value?.links ?? [],
      photoUrls: controller.userChatDetail.value?.photoUrls ?? [],
    );
    
    debugPrint('✅ ChatDetailScreen - UserDetail Model oluşturuldu:');
    debugPrint('  - ID: ${userDetail.id}');
    debugPrint('  - Name: ${userDetail.name}');
    debugPrint('  - Follower: ${userDetail.follower}');
    debugPrint('  - Following: ${userDetail.following}');
    
    Get.toNamed('/user_chat_detail', arguments: {
      'chatId': chatId,
      'userDetail': userDetail,
    });
  }
}
