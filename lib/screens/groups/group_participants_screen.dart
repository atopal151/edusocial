import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/group_controller/group_controller.dart';
import '../../controllers/chat_controllers/chat_controller.dart';
import '../../services/language_service.dart';
import '../../components/widgets/verification_badge.dart';

class GroupParticipantsScreen extends StatefulWidget {
  const GroupParticipantsScreen({super.key});

  @override
  State<GroupParticipantsScreen> createState() =>
      _GroupParticipantsScreenState();
}

class _GroupParticipantsScreenState extends State<GroupParticipantsScreen> {
  final GroupController groupController = Get.find<GroupController>();
  final ChatController chatController = Get.find<ChatController>();

  void _sendMessageToUser(Map<String, dynamic> user) {
    final userId = user['id'];
    final name = user['name'] ?? '';
    final surname = user['surname'] ?? '';
    final username = user['username'] ?? '';
    final avatarUrl = user['avatar_url'] ?? '';

    chatController.getChatDetailPage(
      userId: userId,
      name: '$name $surname',
      username: username,
      avatarUrl: avatarUrl,
      isOnline: user['is_online'] ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        title: languageService.tr("groups.groupParticipants.title"),
        backgroundColor: Color(0xfffafafa),
        iconBackgroundColor: Color(0xffffffff),
      ),
      body: Obx(() {
        final group = groupController.groupDetail.value;
        if (group == null) {
          return Center(child: CircularProgressIndicator());
        }

        if (group.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Color(0xff9ca3ae),
                ),
                SizedBox(height: 16),
                Text(
                  languageService.tr("groups.groupParticipants.noParticipants"),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff9ca3ae),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: group.users.length,
          itemBuilder: (context, index) {
            final user = group.users[index];
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () {
                  Get.to(() => PeopleProfileScreen(
                        username: user['username'] ?? '',
                      ));
                },
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xffffffff),
                  backgroundImage: NetworkImage(user["avatar_url"] ?? ''),
                  child: (user["avatar_url"] == null ||
                          user["avatar_url"].toString().isEmpty)
                      ? Icon(Icons.person, color: Color(0xff9ca3ae))
                      : null,
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '${user["name"] ?? ''} ${user["surname"] ?? ''}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff414751),
                        ),
                      ),
                    ),
                    SizedBox(width: 2),
                    VerificationBadge(
                      isVerified: user['is_verified'] ?? false,
                      size: 14.0,
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${user["username"] ?? ''}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff9ca3ae),
                      ),
                    ),

                 
                  ],
                ),
                trailing: InkWell(
                  onTap: () => _sendMessageToUser(user),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xfff0f1f3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      languageService.tr("groups.groupParticipants.sendMessage"),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff414751),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
