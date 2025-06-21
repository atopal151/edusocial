import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/user_appbar/user_appbar.dart';
import '../../../controllers/social/chat_controller.dart';
import '../../../controllers/group_controller/group_controller.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  final ChatController chatController = Get.find<ChatController>();
  final GroupController groupController = Get.find<GroupController>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserAppBar(),
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchTextField(
              label: "Ara",
              controller: chatController.searchController,
              onChanged: chatController.filterChatList,
            ),
          ),
          const SizedBox(height: 10),

          /// **Online Arkadaşlar Alanı**
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text(
                    "Online Arkadaşlar",
                    style: TextStyle(
                        fontSize: 13.28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff414751)),
                  ),
                ),
                const SizedBox(height: 5),
                Obx(() => SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: chatController.onlineFriends.length,
                        itemBuilder: (context, index) {
                          final friend = chatController.onlineFriends[index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 10, right: 1),
                            child: GestureDetector(
                              onTap: () {
                                //debugPrint('tıklanan chat id:${friend.id}');
                                chatController.getChatDetailPage(
                                  friend.id,
                                  name: friend.name,
                                  avatarUrl: friend.profileImage,
                                  isOnline: friend.isOnline, username: friend.username,
                                );
                              },
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color(0xffffffff),
                                        radius: 28,
                                        backgroundImage:
                                            NetworkImage(friend.profileImage),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            color: friend.isOnline
                                                ? Color(0xff65d384)
                                                : Color(0xffd9d9d9),
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(friend.name,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xff414751))),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )),
              ],
            ),
          ),

          /// ✅ TabBar (Kişisel & Grup)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 90),
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xffef5050),
              indicatorWeight: 1,
              dividerColor: Colors.transparent,
              labelColor: const Color(0xffef5050),
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: "Kişisel"),
                Tab(text: "Gruplar"),
              ],
            ),
          ),

          /// ✅ TabBarView (Mesaj Listeleri)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPrivateMessages(),
                _buildGroupMessages(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 👥 Kişisel Mesajlar Listesi
  Widget _buildPrivateMessages() {
    return RefreshIndicator(
      onRefresh: () async {
        debugPrint("🔄 Kişisel mesajlar yenileniyor...");
        await chatController.fetchChatList();
        debugPrint("✅ Kişisel mesajlar başarıyla yenilendi");
      },
      color: Color(0xFFEF5050),
      backgroundColor: Color(0xfffafafa),
      strokeWidth: 2.0,
      displacement: 10.0,
      child: Obx(() => ListView.builder(
            itemCount: chatController.filteredChatList.length,
            itemBuilder: (context, index) {
              final chat = chatController.filteredChatList[index];
              return GestureDetector(
                onTap: () {
                  debugPrint('tıklanan chat id:${chat.id}');
                  chatController.getChatDetailPage(
                    chat.id,
                    name: chat.name,
                    avatarUrl: chat.avatar,
                    isOnline: chat.isOnline, username: chat.username,
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(chat.avatar),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: chat.isOnline
                                      ? const Color(0xff65d384)
                                      : const Color(0xffd9d9d9),
                                  borderRadius: BorderRadius.circular(50),
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              Text(
                                chat.lastMessage?.message ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              formatSimpleDateClock(
                                  chat.lastMessage?.createdAt ?? ''),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            if (chat.unreadCount > 0)
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text(
                                  chat.unreadCount.toString(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }

  /// 👥 Grup Mesajları Listesi
  Widget _buildGroupMessages() {
    return RefreshIndicator(
      onRefresh: () async {
        debugPrint("🔄 Grup mesajları yenileniyor...");
        await groupController.fetchUserGroups();
        debugPrint("✅ Grup mesajları başarıyla yenilendi");
      },
      color: Color(0xFFEF5050),
      backgroundColor: Color(0xfffafafa),
      strokeWidth: 2.0,
      displacement: 40.0,
      child: Obx(() => ListView.builder(
            itemCount: groupController.userGroups.length,
            itemBuilder: (context, index) {
              final group = groupController.userGroups[index];
              return GestureDetector(
                onTap: () {
                  chatController.getGroupChatPage(group.id);
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(group.avatarUrl),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              Text(
                                group.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              group.humanCreatedAt,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            if (group.messageCount > 0)
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Text(
                                  group.messageCount.toString(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}
