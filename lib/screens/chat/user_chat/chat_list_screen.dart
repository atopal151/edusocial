import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/user_appbar/user_appbar.dart';
import '../../../controllers/social/chat_controller.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  final ChatController chatController = Get.put(ChatController());

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
                          return GestureDetector(
                            onTap: () {
                              chatController.getChatDetailPage();
                            },
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
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
    return Obx(() => ListView.builder(
          itemCount: chatController.filteredChatList.length,
          itemBuilder: (context, index) {
            final chat = chatController.filteredChatList[index];
            return GestureDetector(
              onTap: () {
                chatController.getChatDetailPage();
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
                            backgroundImage:
                                NetworkImage(chat.sender.profileImage),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: chat.sender.isOnline
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
                              chat.sender.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              chat.lastMessage,
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
                            chat.lastMessageTime,
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
        ));
  }

  /// 👥 Grup Mesajları Listesi
  Widget _buildGroupMessages() {
    return Obx(() => ListView.builder(
          itemCount: chatController.filteredGroupChatList.length,
          itemBuilder: (context, index) {
            final group = chatController.filteredGroupChatList[index];
            return GestureDetector(
              onTap: () {
                chatController.getGroupChatPage();
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
                        backgroundImage: NetworkImage(group.groupImage),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.groupName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              group.lastMessage,
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
                            group.lastMessageTime,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          if (group.unreadCount > 0)
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Text(
                                group.unreadCount.toString(),
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
        ));
  }
}



/*import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/user_appbar/user_appbar.dart';
import '../../../controllers/social/chat_controller.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin{
  final ChatController chatController = Get.put(ChatController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserAppBar(),
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: SearchTextField(
                label: "Kişi ara",
                controller: chatController.searchController,
                onChanged: chatController.filterChatList,
              )),
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
                const SizedBox(height: 20),
                Obx(() => SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: chatController.onlineFriends.length,
                        itemBuilder: (context, index) {
                          final friend = chatController.onlineFriends[index];
                          return GestureDetector(
                            onTap: () {
                              chatController.getChatDetailPage();
                            },
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
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
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(friend.name,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xff414751))),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// **Mesajlar Alanı**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              "Mesajlar",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),

          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: chatController.filteredChatList.length,
                  itemBuilder: (context, index) {
                    final chat = chatController.filteredChatList[index];
                    return GestureDetector(
                      onTap: () {
                        chatController.getChatDetailPage();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
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
                                    backgroundImage:
                                        NetworkImage(chat.sender.profileImage),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: chat.sender.isOnline
                                            ? Color(0xff65d384)
                                            : Color(0xffd9d9d9),
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color: Colors.white, width: 2),
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
                                      chat.sender.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      chat.lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    chat.lastMessageTime,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
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
          ),
        ],
      ),
    );
  }
}
*/