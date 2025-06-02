import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/input_fields/message_input_field.dart';
import '../../../components/widgets/chat_widget/text_message_widget.dart';
import '../../../controllers/social/chat_detail_controller.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatDetailController controller = Get.put(ChatDetailController());
  TextEditingController messageController = TextEditingController();

  late String name;
  late String avatarUrl;
  late bool isOnline;

  @override
  void initState() {
    super.initState();

    final chatId = Get.arguments['chatId'];
    controller.fetchConversationMessages(chatId);

    // AppBar bilgileri:
    name = Get.arguments['name'] ?? 'Bilinmiyor';
    avatarUrl = Get.arguments['avatarUrl'] ?? '';
    isOnline = Get.arguments['isOnline'] ?? false;

    debugPrint('Chat ID: $chatId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        surfaceTintColor: const Color(0xffffffff),
        title: InkWell(
          onTap: () {
            Get.toNamed("/peopleProfile");
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
            onTap: () {
              Get.toNamed("/user_chat_detail");
            },
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
              child: Obx(() => ListView.builder(
                    controller: controller.scrollController,
                    itemCount: controller.messages.length,
                    padding: const EdgeInsets.only(bottom: 75),
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return TextMessageWidget(message: message);
                    },
                  )),
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
}
