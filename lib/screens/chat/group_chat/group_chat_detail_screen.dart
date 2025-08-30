import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../components/input_fields/group_message_input_field.dart';
import '../../../components/widgets/group_chat_widget/group_document_message_widget.dart';
import '../../../components/widgets/group_chat_widget/group_universal_message_widget.dart';
import '../../../components/widgets/group_chat_widget/group_poll_message_widget.dart';
import '../../../components/widgets/group_chat_widget/group_survey_message_widget.dart';
import '../../../components/widgets/tree_point_bottom_sheet.dart';
import '../../../components/widgets/chat_widget/date_separator_widget.dart';
import '../../../components/widgets/pinned_messages_widget.dart';
import '../../../controllers/chat_controllers/group_chat_detail_controller.dart';
import '../../../models/chat_models/group_message_model.dart';
import '../../../services/language_service.dart';

class GroupChatDetailScreen extends StatefulWidget {
  const GroupChatDetailScreen({super.key});

  @override
  GroupChatDetailScreenState createState() => GroupChatDetailScreenState();
}

class GroupChatDetailScreenState extends State<GroupChatDetailScreen> {
  late GroupChatDetailController controller;

  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 GroupChatDetailScreen initialized');
    controller = Get.find<GroupChatDetailController>();
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
            final isLoading = controller.isGroupDataLoading.value;
            
            if (isLoading || group == null) {
              // OPTIMIZE: Skeleton loading for app bar
              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            
            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  child: group.avatarUrl != null && group.avatarUrl!.isNotEmpty
                      ? ClipOval(
                          // OPTIMIZE: Network image with RepaintBoundary for better performance
                          child: RepaintBoundary(
                            child: Image.network(
                              group.avatarUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
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
        child: Stack(
          children: [
            Column(
              children: [
                // Pinlenen mesajları göster
                PinnedMessagesWidget(
                  isGroupChat: true,
                ),
                Expanded(
                  child: Obx(() {
                    final isGroupLoading = controller.isGroupDataLoading.value;
                    final group = controller.groupData.value;
                    final messages = controller.messages;

                    // FIXED: Simple centered loading instead of skeleton
                    if (isGroupLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFef5050),
                          strokeWidth: 3.0,
                        ),
                      );
                    }

                    // Grup verisi yok ama loading bitmişse hata
                    if (group == null) {
                      return _buildErrorState();
                    }

                    // Mesajlar boşsa
                    if (messages.isEmpty) {
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
                              languageService.tr("groupChatDetail.emptyState.title"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff414751),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              languageService.tr("groupChatDetail.emptyState.subtitle"),
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff9ca3ae),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // OPTIMIZE: Improved ListView with better performance
                    return OptimizedMessageListView(
                      controller: controller,
                      messages: messages,
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
            // Scroll to bottom button
            _buildScrollToBottomButton(),
          ],
        ),
      ),
    );
  }



  /// Error state widget
  Widget _buildErrorState() {
    final LanguageService languageService = Get.find<LanguageService>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            languageService.tr("groupChatDetail.errors.groupDataLoadFailed"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            languageService.tr("groupChatDetail.errors.pleaseRetry"),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              controller.fetchGroupDetailsOptimized();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF7C7C),
              foregroundColor: Colors.white,
            ),
            child: Text(languageService.tr("common.buttons.retry")),
          ),
        ],
      ),
    );
  }

  /// Build scroll to bottom button
  Widget _buildScrollToBottomButton() {
    return Obx(() {
      if (!controller.showScrollToBottomButton.value) {
        return const SizedBox.shrink();
      }
      
      return Positioned(
        bottom: 90, // Above message input field
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              controller.scrollToBottom();
            },
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.circular(28),
               
                border: Border.all(
                  color: Color(0xfff5f6f7),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xffef5050),
                size: 28,
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// OPTIMIZE: Message ListView with better performance
class OptimizedMessageListView extends StatelessWidget {
  final GroupChatDetailController controller;
  final RxList<GroupMessageModel> messages;

  const OptimizedMessageListView({
    super.key,
    required this.controller,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messageList = messages.toList();
      
      if (messageList.isEmpty) {
        return Center(
          child: Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        );
      }

      // OPTIMIZED: Auto-scroll only when needed - let controller handle it
      if (messageList.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.scrollToBottomForNewMessage();
        });
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
        itemCount: messageList.length,
        // OPTIMIZE: Caching for better scroll performance
        cacheExtent: 1000,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final messageIndex = index;
          
          if (messageIndex < 0 || messageIndex >= messageList.length) {
            return const SizedBox.shrink();
          }
          
          final message = messageList[messageIndex];
          
          // OPTIMIZE: RepaintBoundary for each message
          return RepaintBoundary(
            child: Column(
              children: [
                // Date separator (if needed)
                if (_shouldShowDateSeparator(messageList, messageIndex))
                  DateSeparatorWidget(
                    date: message.timestamp,
                  ),
                
                // Message widget based on type
                _buildMessageWidget(message),
              ],
            ),
          );
        },
      );
    });
  }

  bool _shouldShowDateSeparator(List<GroupMessageModel> messages, int index) {
    if (index == 0) return true;
    
    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];
    
    final currentDate = DateTime(
      currentMessage.timestamp.year,
      currentMessage.timestamp.month,
      currentMessage.timestamp.day,
    );
    
    final previousDate = DateTime(
      previousMessage.timestamp.year,
      previousMessage.timestamp.month,
      previousMessage.timestamp.day,
    );
    
    return currentDate.isAfter(previousDate);
  }

  Widget _buildMessageWidget(GroupMessageModel message) {
    switch (message.messageType) {
      case GroupMessageType.document:
        return GroupDocumentMessageWidget(message: message, controller: controller);
      case GroupMessageType.poll:
        return GroupPollMessageWidget(message: message, controller: controller);
      case GroupMessageType.survey:
        return GroupSurveyMessageWidget(message: message, controller: controller);
      case GroupMessageType.image:
      case GroupMessageType.link:
      case GroupMessageType.textWithLinks:
      case GroupMessageType.text:
      return GroupUniversalMessageWidget(message: message, controller: controller);
    }
  }
}

// Helper class for list items
class MessageListItem {
  final bool isDateSeparator;
  final DateTime? date;
  final GroupMessageModel? message;

  MessageListItem.dateSeparator(this.date) 
    : isDateSeparator = true, 
      message = null;

  MessageListItem.message(this.message) 
    : isDateSeparator = false, 
      date = null;
}
