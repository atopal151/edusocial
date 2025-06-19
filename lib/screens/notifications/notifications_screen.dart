import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:edusocial/controllers/notification_controller.dart';
import 'package:edusocial/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: BackAppBar(
        iconBackgroundColor: const Color(0xffffffff),
        backgroundColor: const Color(0xfffafafa),
        title: "Bildirimler",
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: GeneralLoadingIndicator(
              size: 32,
              color: Color(0xFFFF7743),
              icon: Icons.notifications,
              showText: true,
            ),
          );
        }

        final grouped =
            controller.groupNotificationsByDate(controller.notifications);

        return ListView.builder(
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final group = grouped[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    group.label,
                    style: const TextStyle(
                      fontSize: 13.28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff414751),
                    ),
                  ),
                ),
                ...group.notifications.map((n) => buildNotificationTile(n)),
              ],
            );
          },
        );
      }),
    );
  }

  Widget buildNotificationTile(NotificationModel n) {
    return ListTile(
      tileColor: n.isRead ? Colors.transparent : const Color(0xffEEF3F8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(n.profileImageUrl),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                color: _getIconBgColor(n.type),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(n.type),
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "@${n.userName} ",
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            TextSpan(
              text: "${n.message} ",
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12),
            ),
            TextSpan(
              text: _timeAgo(n.timestamp),
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      trailing: _buildTrailingButton(n),
      onTap: () {
        // İstenirse detay ekranına yönlendirme yapılabilir
      },
    );
  }

  Widget? _buildTrailingButton(NotificationModel notif) {
    // Sadece belirli tiplerdeki bildirimlerde buton göster
    if (notif.type != 'follow-join-request') {
      return null;
    }

    debugPrint("🔍 Building button for notification:");
    debugPrint("🔍   - isFollowing: ${notif.isFollowing}");
    debugPrint("🔍   - isFollowingPending: ${notif.isFollowingPending}");
    debugPrint("🔍   - isAccepted: ${notif.isAccepted}");

    // Eğer kullanıcı zaten takip ediliyorsa
    if (notif.isFollowing) {
      return SizedBox(
        width: 100,
        child: CustomButton(
          text: "Takibi Bırak",
          height: 32,
          borderRadius: 8,
          onPressed: () {
            controller.unfollowUser(notif.senderUserId);
          },
          isLoading: RxBool(false),
          backgroundColor: Colors.grey,
          textColor: Colors.white,
        ),
      );
    }

    // Eğer takip isteği beklemedeyse
    if (notif.isFollowingPending) {
      return SizedBox(
        width: 100,
        child: CustomButton(
          text: "Onay Bekliyor",
          height: 32,
          borderRadius: 8,
          onPressed: () {}, // Tıklanamaz
          isLoading: RxBool(false),
          backgroundColor: Colors.grey,
          textColor: Colors.white,
        ),
      );
    }

    // Kullanıcıyı takip etmiyorsak ve istek beklemede değilse
    return SizedBox(
      width: 100,
      child: CustomButton(
        text: "Takip Et",
        height: 32,
        borderRadius: 8,
        onPressed: () {
          controller.followUser(notif.senderUserId);
        },
        isLoading: RxBool(false),
        backgroundColor: const Color(0xFFEF5050),
        textColor: Colors.white,
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'follow-request':
      case 'follow-join-request':
        return Icons.person_add_alt_1;
      case 'post-like':
        return Icons.favorite;
      case 'post-comment':
        return Icons.mode_comment;
      case 'group-join-request':
        return Icons.group_add;
      case 'group-join':
        return Icons.group;
      case 'create-group-event':
        return Icons.event;
      case 'group_accept':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconBgColor(String type) {
    switch (type) {
      case 'follow-request':
      case 'follow-join-request':
        return const Color(0xFF64B5F6);
      case 'post-like':
        return const Color(0xFFE57373);
      case 'post-comment':
        return const Color(0xFFFFB74D);
      case 'group-join-request':
        return const Color(0xFFFFF176);
      case 'group-join':
        return const Color(0xFF81C784);
      case 'create-group-event':
        return const Color(0xFF9575CD);
      case 'group_accept':
        return const Color(0xFFFFCC80);
      default:
        return const Color(0xFFBDBDBD);
    }
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "az önce";
    if (diff.inMinutes < 60) return "${diff.inMinutes}dk";
    if (diff.inHours < 24) return "${diff.inHours}s";
    if (diff.inDays < 7) return "${diff.inDays}g";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()}h";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()}a";
    return "${(diff.inDays / 365).floor()}y";
  }
}
