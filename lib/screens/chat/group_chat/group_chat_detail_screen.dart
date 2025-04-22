import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/input_fields/group_message_input_field.dart';
import '../../../components/widgets/document_message_widget.dart';
import '../../../components/widgets/image_message_widget.dart';
import '../../../components/widgets/link_messaje_widget.dart';
import '../../../components/widgets/poll_message_widget.dart';
import '../../../components/widgets/text_message_widget.dart';
import '../../../components/widgets/tree_point_bottom_sheet.dart';
import '../../../controllers/social/group_chat_detail_controller.dart';
import '../../../models/chat_detail_model.dart';

class GroupChatDetailScreen extends StatefulWidget {
  const GroupChatDetailScreen({super.key});

  @override
  State<GroupChatDetailScreen> createState() => _GroupChatDetailScreenState();
}

class _GroupChatDetailScreenState extends State<GroupChatDetailScreen> {
  final GroupChatDetailController controller =
      Get.put(GroupChatDetailController());

  TextEditingController messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffffffff),
        surfaceTintColor: Color(0xffffffff),
        title: InkWell(
          onTap: () {
            controller.getToGrupDetailScreen();
          },
          child: Row(
            children: [
              CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://randomuser.me/api/portraits/men/7.jpg")),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Murata Hayranlar Grubu",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff414751))),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.red,
                        size: 15,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Text("223",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff9ca3ae),
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                backgroundColor: Colors.white,
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                builder: (context) => const TreePointBottomSheet(),
              );
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
                    itemCount: controller.groupmessages.length,
                    padding: EdgeInsets.only(bottom: 75),
                    itemBuilder: (context, index) {
                      final message = controller.groupmessages[index];
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
                      } else {
                        return Container();
                      }
                    },
                  )),
            ),
            Container(
              decoration: BoxDecoration(color: Color(0xffffffff)),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 12.0, right: 12, top: 8, bottom: 20),
                child: buildGroupMessageInputField(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
