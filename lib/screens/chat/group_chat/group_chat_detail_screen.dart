import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/input_fields/group_message_input_field.dart';
import '../../../components/widgets/group_chat_widget/group_document_message_widget.dart';
import '../../../components/widgets/group_chat_widget/group_image_message_widget.dart';
import '../../../components/widgets/group_chat_widget/group_link_messaje_widget.dart';
import '../../../components/widgets/group_chat_widget/group_poll_message_widget.dart';
import '../../../components/widgets/group_chat_widget/group_text_message_widget.dart';
import '../../../components/widgets/group_chat_widget/group_text_with_links_message_widget.dart';
import '../../../components/widgets/tree_point_bottom_sheet.dart';
import '../../../controllers/social/group_chat_detail_controller.dart';
import '../../../models/chat_models/group_message_model.dart';
import '../../../components/widgets/custom_loading_indicator.dart';

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
  void initState() {
    super.initState();
    debugPrint('🚀 GroupChatDetailScreen initialized');
    controller.fetchGroupDetails();
    
    // Mesajlar yüklendikten sonra en alta git
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 500), () {
        controller.scrollToBottom(animated: false);
      });
    });
  }

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
          child: Obx(() {
            final group = controller.groupData.value;
            if (group == null) {
              return Row(
                children: [
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomLoadingIndicator(
                        size: 26,
                        color: Color(0xFFFF7C7C),
                        strokeWidth: 2,
                      ),
                   
                    ],
                  ),
                ],
              );
            }
            return Row(
              children: [
                CircleAvatar(
                    backgroundImage: NetworkImage(group.avatarUrl ??
                        "https://stageapi.edusocial.pl/storage/avatars/a25YweIb75P9UdftcMr1b0Sa1fC75fDKAcTK7ZWf.png")),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name,
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
                        Text(group.userCountWithAdmin.toString(),
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff9ca3ae),
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ],
                ),
              ],
            );
          }),
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
                  padding: EdgeInsets.only(bottom: 120),
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    if (message.messageType == GroupMessageType.text) {
                      return GroupTextMessageWidget(message: message);
                    } else if (message.messageType ==
                        GroupMessageType.document) {
                      return GroupDocumentMessageWidget(message: message);
                    } else if (message.messageType ==
                        GroupMessageType.image) {
                      return GroupImageMessageWidget(message: message);
                    } else if (message.messageType == GroupMessageType.link) {
                      return GroupLinkMessageWidget(message: message);
                    } else if (message.messageType == GroupMessageType.textWithLinks) {
                      return GroupTextWithLinksMessageWidget(message: message);
                    } else if (message.messageType == GroupMessageType.poll) {
                      return GroupPollMessageWidget(
                        message: message,
                        pollVotes: controller.pollVotes,
                        selectedOption: controller.selectedPollOption,
                        onVote: controller.votePoll,
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              }),
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
