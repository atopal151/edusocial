import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../components/input_fields/group_message_input_field.dart';
import '../../../components/widgets/group_chat_widget/group_document_message_widget.dart';
import '../../../components/widgets/group_chat_widget/group_image_message_widget.dart';
import '../../../components/widgets/group_chat_widget/group_link_messaje_widget.dart';
import '../../../components/widgets/group_chat_widget/group_poll_message_widget.dart';
import '../../../components/widgets/group_chat_widget/group_text_message_widget.dart';
import '../../../components/widgets/group_chat_widget/group_text_with_links_message_widget.dart';
import '../../../components/widgets/tree_point_bottom_sheet.dart';
import '../../../controllers/chat_controllers/group_chat_detail_controller.dart';
import '../../../models/chat_models/group_message_model.dart';
import '../../../components/widgets/custom_loading_indicator.dart';
import '../../../services/language_service.dart';

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
    final LanguageService languageService = Get.find<LanguageService>();

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
              return Center();
            }
            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  child: group.avatarUrl != null && group.avatarUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            group.avatarUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Network image yüklenemezse SVG göster
                              return SvgPicture.asset(
                                "images/icons/group_icon.svg",
                                colorFilter: const ColorFilter.mode(
                                  Color(0xff9ca3ae),
                                  BlendMode.srcIn,
                                ),
                                width: 24,
                                height: 24,
                              );
                            },
                          ),
                        )
                      : SvgPicture.asset(
                          "images/icons/group_icon.svg",
                          colorFilter: const ColorFilter.mode(
                            Color(0xff9ca3ae),
                            BlendMode.srcIn,
                          ),
                          width: 24,
                          height: 24,
                        ),
                ),
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
                          color: Color(0xffef5050),
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
                builder: (context) =>  TreePointBottomSheet(),
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
                final isMessagesLoading = controller.isMessagesLoading.value;
                final isGroupLoading = controller.isGroupDataLoading.value;
                final group = controller.groupData.value;

                // Mesajlar yüklendiğinde en alta git
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (controller.messages.isNotEmpty) {
                    controller.scrollToBottom(animated: false);
                  }
                });

                // Grup verisi veya mesajlar yükleniyorsa loading göster
                if (isGroupLoading || isMessagesLoading || group == null) {
                  return Center(
                    child: CustomLoadingIndicator(
                      size: 40,
                      color: Color(0xFFFF7C7C),
                      strokeWidth: 3,
                    ),
                  );
                }

                // Mesajlar boşsa
                if (controller.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: 40,
                            color: Color(0xff9ca3ae),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          languageService.tr("groupChat.noMessages"),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff414751),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          languageService.tr("groupChat.sendFirstMessage"),
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff9ca3ae),
                          ),
                        ),
                      ],
                    ),
                  );
                }

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
                    } else if (message.messageType == GroupMessageType.image) {
                      return GroupImageMessageWidget(message: message);
                    } else if (message.messageType == GroupMessageType.link) {
                      return GroupLinkMessageWidget(message: message);
                    } else if (message.messageType ==
                        GroupMessageType.textWithLinks) {
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
