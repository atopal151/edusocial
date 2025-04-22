import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/input_fields/message_input_field.dart';
import '../../../components/widgets/document_message_widget.dart';
import '../../../components/widgets/image_message_widget.dart';
import '../../../components/widgets/link_messaje_widget.dart';
import '../../../components/widgets/poll_message_widget.dart';
import '../../../components/widgets/text_message_widget.dart';
import '../../../controllers/social/chat_detail_controller.dart';
import '../../../models/chat_detail_model.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatDetailController controller = Get.put(ChatDetailController());

  TextEditingController messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffffffff),
        surfaceTintColor: Color(0xffffffff),
        title: InkWell(
          onTap: () {
            Get.toNamed("/peopleProfile");
          },
          child: Row(
            children: [
              CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://randomuser.me/api/portraits/men/1.jpg")),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Roger Carscraad",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff414751))),
                  Text("Çevrimiçi",
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff9ca3ae),
                          fontWeight: FontWeight.w400)),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.more_horiz),
            ),
          ),
        ],
      ),
      body: Container(
        color: Color(0xfffafafa),
        child: Column(
          children: [
            Expanded(
              child: Obx(() => ListView.builder(
                    controller: controller.scrollController,
                    itemCount: controller.messages.length,
                    padding: EdgeInsets.only(bottom: 75),
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      if (message.messageType == MessageType.text) {
                        return TextMessageWidget(message: message);
                      } else if (message.messageType == MessageType.document) {
                        return DocumentMessageWidget(message: message);
                      } else if (message.messageType == MessageType.image) {
                        return ImageMessageWidget(message: message);
                      } else if (message.messageType == MessageType.link) {
                        return LinkMessageWidget(message: message);
                      } else if (message.messageType == MessageType.poll) {
                        return PollMessageWidget(
                          message: message,
                          pollVotes: controller.pollVotes,
                          selectedOption: controller.selectedPollOption,
                          onVote: controller.votePoll,
                        );
                      }

                      /*
                      else if (message.messageType == MessageType.poll) {
                        return PollMessageWidget(message: message);
                      } */

                      else {
                        return Container();
                      }
                    },
                  )),
            ),
            Container(
              decoration: BoxDecoration(color: Color(0xffffffff)),
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
