import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:edusocial/utils/date_format.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../components/user_appbar/user_appbar.dart';
import '../../../controllers/chat_controllers/chat_controller.dart';
import '../../../controllers/group_controller/group_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../services/language_service.dart';
import '../../../components/widgets/verification_badge.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ChatController chatController = Get.find<ChatController>();
  final GroupController groupController = Get.find<GroupController>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Uygulama ön plana geldiğinde chat verilerini yenile ve unread count'u kontrol et
      _refreshChatData();
      
      // Socket'ten güncel unread count'u da kontrol et
      Future.delayed(Duration(seconds: 1), () {
        chatController.checkSocketCount();
      });
    }
  }


  /// Chat verilerini yenile
  Future<void> _refreshChatData() async {
    debugPrint("🔄 Chat verileri yenileniyor...");
    try {
      await Future.wait([
        chatController.refreshChatListAndUnreadCounts(),
        groupController.fetchUserGroups(),
      ]);
      debugPrint("✅ Chat verileri başarıyla yenilendi");
      
      // Socket count'u da kontrol et
      chatController.checkSocketCount();
    } catch (e) {
      debugPrint("❌ Chat verileri yenileme hatası: $e");
    }
  }

  /// Avatar widget'ı oluştur - URL varsa resim, yoksa person icon
  Widget _buildAvatarWidget(String? avatarUrl) {
    final fixedUrl = AppConstants.fixAvatarUrl(avatarUrl);
    
    // Eğer default avatar URL'i ise direkt person icon göster
    if (fixedUrl.contains('pravatar.cc')) {
      return Icon(
        Icons.person,
        color: Color(0xff9ca3ae),
      );
    }
    
    return ClipOval(
      child: Image.network(
        fixedUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("❌ Avatar yükleme hatası: $error");
          return Icon(
            Icons.person,
            color: Color(0xff9ca3ae),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Icon(
            Icons.person,
            color: Color(0xff9ca3ae),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();

    return Scaffold(
      appBar: UserAppBar(),
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchTextField(
              label: languageService.tr("chat.chatList.searchPlaceholder"),
              controller: chatController.isClosed ? null : chatController.searchController,
              onChanged: (value) {
                // Hem people hem de groups için arama yap
                if (!chatController.isClosed) {
                  chatController.filterChatList(value);
                }
                if (!groupController.isClosed) {
                  groupController.filterUserGroups(value);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          if (chatController.onlineFriends.isNotEmpty)

            /// **Online Arkadaşlar Alanı**
            Container(
              color: Color(0xffffffff),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      languageService.tr("chat.chatList.onlineFriends"),
                      style: GoogleFonts.inter(
                          fontSize: 13.28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff272727)),
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
                              padding:
                                  const EdgeInsets.only(left: 10, right: 1),
                              child: GestureDetector(
                                onTap: () {
                                  chatController.getChatDetailPage(
                                    userId: friend.id,
                                    name: friend.name,
                                    avatarUrl: friend.profileImage,
                                    isOnline: friend.isOnline,
                                    username: friend.username,
                                  );
                                },
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Color(0xfffafafa),
                                          radius: 28,
                                          child: _buildAvatarWidget(friend.profileImage),
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
                                                  color: Color(0xffffffff),
                                                  width: 2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('@${friend.username}',
                                          style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: Color(0xff272727),
                                              fontWeight: FontWeight.w400)),
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
            padding: const EdgeInsets.symmetric(horizontal: 80),
            color: Color(0xffffffff),
            child: Center(
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                indicatorColor: const Color(0xffef5050),
                indicatorWeight: 1,
                dividerColor: Colors.transparent,
                labelColor: const Color(0xffef5050),
                unselectedLabelColor: Color(0xff9ca3ae),
                labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xff272727),
                ),
                tabs: [
                  // Kişisel Mesajlar Tab'ı (API'den gelen unread count ile)
                  Obx(() {
                    final profileController = Get.find<ProfileController>();
                    final unreadCount = profileController.unreadMessagesTotalCount.value;
                    final peopleText = languageService.tr("chat.chatList.tabs.people");
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              peopleText,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xffef5050),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  // Grup Mesajları Tab'ı (ChatController'dan gelen groupUnreadCount ile)
                  Obx(() {
                    final unreadCount = chatController.groupUnreadCount;
                    final groupsText = languageService.tr("chat.chatList.tabs.groups");
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              groupsText,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xffef5050),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
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
        await _refreshChatData();
      },
      color: Color(0xFFef5050),
      backgroundColor: Color(0xfffafafa),
      elevation: 0,
      strokeWidth: 2.0,
      displacement: 40.0,
      child: Obx(() => ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: chatController.filteredChatList.length,
            itemBuilder: (context, index) {
              final chat = chatController.filteredChatList[index];
              return GestureDetector(
                onTap: () {
                  debugPrint(
                      'tıklanan user id:${chat.id}, conversation id:${chat.conversationId}');
                  chatController.getChatDetailPage(
                    userId: chat.id,
                    conversationId: chat.conversationId,
                    name: chat.name,
                    avatarUrl: chat.avatar,
                    isOnline: chat.isOnline,
                    username: chat.username,
                    isVerified: chat.isVerified,
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Color(0xfffafafa),
                              child: _buildAvatarWidget(chat.avatar),
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
                                  border: Border.all(
                                      color: Color(0xffffffff), width: 2),
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '@${chat.username}',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: Color(0xff414751)),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  VerificationBadge(
                                    isVerified: chat.isVerified ?? false,
                                    size: 14.0,
                                  ),
                                ],
                              ),
                              Text(
                                chat.lastMessage?.message ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Color(0xff9ca3ae),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              formatSimpleDateClock(
                                  chat.lastMessage?.createdAt ?? ''),
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Color(0xff9ca3ae),
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            // Kırmızı nokta sadece hasUnreadMessages=true olan chat'ler için göster
                            chat.hasUnreadMessages 
                                ? Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Color(0xffff565f),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  )
                                : SizedBox(
                                    width: 8,
                                    height: 8,
                                    // Boş container (görünmez)
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
        await _refreshChatData();
      },
      color: Color(0xFFef5050),
      backgroundColor: Color(0xfffafafa),
      elevation: 0,
      strokeWidth: 2.0,
      displacement: 40.0,
                child: Obx(() => ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: chatController.groupChatList.length,
            itemBuilder: (context, index) {
              final group = chatController.groupChatList[index];
              
              // DEBUG: Print individual group data when building
              //debugPrint('🏗️ Building group item ${index + 1}: ${group.name} (ID: ${group.id})');
              
              return GestureDetector(
                onTap: () {
                  chatController.getGroupChatPage(group.groupId.toString());
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
                          backgroundColor: Color(0xfffafafa),
                          child: _buildAvatarWidget(group.groupImage),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      group.groupName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ),
                                  if (group.isAdmin)
                                    Container(
                                      margin: EdgeInsets.only(left: 4),
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Color(0xffEF5050),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.admin_panel_settings,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
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
                            // Kırmızı nokta sadece hasUnreadMessages=true olan gruplar için göster
                            group.hasUnreadMessages 
                                ? Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Color(0xffff565f),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  )
                                : SizedBox(
                                    width: 8,
                                    height: 8,
                                    // Boş container (görünmez)
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
