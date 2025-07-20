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
import '../../../components/widgets/chat_widget/date_separator_widget.dart';
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

  // OPTIMIZE: Cache için message items listesi
  List<Widget> _cachedMessageItems = [];
  List<GroupMessageModel> _lastProcessedMessages = [];

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 GroupChatDetailScreen initialized');
    
    // OPTIMIZE: Controller'da zaten çağrılıyor, burada tekrar çağırma
    // controller.fetchGroupDetails(); // Bu satırı kaldır
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
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final isMessagesLoading = controller.isMessagesLoading.value;
                final isGroupLoading = controller.isGroupDataLoading.value;
                final group = controller.groupData.value;
                final messages = controller.messages;

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
      ),
    );
  }
}

// OPTIMIZE: Separate optimized ListView widget
class OptimizedMessageListView extends StatefulWidget {
  final GroupChatDetailController controller;
  final List<GroupMessageModel> messages;

  const OptimizedMessageListView({
    Key? key,
    required this.controller,
    required this.messages,
  }) : super(key: key);

  @override
  State<OptimizedMessageListView> createState() => _OptimizedMessageListViewState();
}

class _OptimizedMessageListViewState extends State<OptimizedMessageListView> {
  List<MessageListItem> _cachedItems = [];
  List<GroupMessageModel> _lastProcessedMessages = [];

  @override
  Widget build(BuildContext context) {
    // OPTIMIZE: Only rebuild cache if messages changed
    if (!_areMessagesEqual(widget.messages, _lastProcessedMessages)) {
      _rebuildCache();
      _lastProcessedMessages = List.from(widget.messages);
      
      // Auto scroll to bottom when messages change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.controller.scrollController.hasClients && widget.messages.isNotEmpty) {
          widget.controller.scrollController.jumpTo(
            widget.controller.scrollController.position.maxScrollExtent,
          );
        }
      });
    }

    return ListView.builder(
      controller: widget.controller.scrollController,
      itemCount: _cachedItems.length,
      padding: EdgeInsets.only(bottom: 120),
      // OPTIMIZE: Use cacheExtent for better performance
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        final item = _cachedItems[index];
        
        if (item.isDateSeparator) {
          return DateSeparatorWidget(date: item.date!);
        } else {
          return _buildMessageWidget(item.message!);
        }
      },
    );
  }

  // OPTIMIZE: Pre-calculate list items with date separators
  void _rebuildCache() {
    _cachedItems.clear();
    
    if (widget.messages.isEmpty) return;
    
    DateTime? lastDate;
    
    for (var message in widget.messages) {
      final messageDate = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );
      
      // Add date separator if date changed
      if (lastDate == null || messageDate != lastDate) {
        _cachedItems.add(MessageListItem.dateSeparator(messageDate));
        lastDate = messageDate;
      }
      
      // Add message item
      _cachedItems.add(MessageListItem.message(message));
    }
  }

  bool _areMessagesEqual(List<GroupMessageModel> a, List<GroupMessageModel> b) {
    if (a.length != b.length) return false;
    
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    
    return true;
  }

  // OPTIMIZE: Cached message widget builder
  Widget _buildMessageWidget(GroupMessageModel message) {
    switch (message.messageType) {
      case GroupMessageType.text:
        return GroupTextMessageWidget(message: message);
      case GroupMessageType.document:
        return GroupDocumentMessageWidget(message: message);
      case GroupMessageType.image:
        return GroupImageMessageWidget(message: message);
      case GroupMessageType.link:
        return GroupLinkMessageWidget(message: message);
      case GroupMessageType.textWithLinks:
        return GroupTextWithLinksMessageWidget(message: message);
      case GroupMessageType.poll:
        return GroupPollMessageWidget(
          message: message,
          pollVotes: widget.controller.pollVotes,
          selectedOption: widget.controller.selectedPollOption,
          onVote: widget.controller.votePoll,
        );
      default:
        return Container();
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
