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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: GeneralLoadingIndicator(
                    size: 32,
                    color: Color(0xFFFF7743),
                    icon: Icons.notifications,
                    showText: true,
                  ),
                ),
              ],
            ),
          );
        }

        final grouped =
            controller.groupNotificationsByDate(controller.notifications);

        return RefreshIndicator(
          onRefresh: () async {
            debugPrint("🔄 Bildirimler yenileniyor...");
            await controller.fetchNotifications();
            debugPrint("✅ Bildirimler başarıyla yenilendi");
          },
          color: Color(0xFFEF5050),
          backgroundColor: Color(0xfffafafa),
          strokeWidth: 2.0,
          displacement: 40.0,
          child: ListView.builder(
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
          ),
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
    // Takip istekleri için butonlar
    if (notif.type == 'follow-join-request' || notif.type == 'follow-request') {
      debugPrint("🔍 Building button for notification:");
      debugPrint("🔍   - isType: "+notif.type);
      debugPrint("🔍   - isFollowing: "+notif.isFollowing.toString());
      debugPrint("🔍   - isFollowingPending: "+notif.isFollowingPending.toString());
      debugPrint("🔍   - isAccepted: "+notif.isAccepted.toString());
      debugPrint("🔍   - isRejected: "+notif.isRejected.toString());

      if (notif.isAccepted) {
        debugPrint("🔍   - Durum: Onaylandı");
        return SizedBox(
          width: 100,
          child: CustomButton(
            text: "Onaylandı",
            height: 32,
            borderRadius: 15,
            onPressed: () {}, // Tıklanamaz
            isLoading: RxBool(false),
            backgroundColor: Color(0xffffffff),
            textColor: Colors.grey[600]!,
          ),
        );
      }

      if (notif.isRejected) {
        debugPrint("🔍   - Durum: Reddedildi");
        return SizedBox(
          width: 100,
          child: CustomButton(
            text: "Reddedildi",
            height: 32,
            borderRadius: 15,
            onPressed: () {}, // Tıklanamaz
            isLoading: RxBool(false),
            backgroundColor: Color(0xfffb535c),
            textColor: Color(0xfffff6f6),
          ),
        );
      }

      // Her durumda Onayla ve X göster
      debugPrint("🔍   - Durum: Onayla ve X gösteriliyor");
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            child: CustomButton(
              text: "Onayla",
              height: 32,
              borderRadius: 15,
              onPressed: () {
                controller.handleFollowRequest(notif.senderUserId, 'accept');
              },
              isLoading: RxBool(false),
            backgroundColor: Color(0xfffb535c),
            textColor: Color(0xfffff6f6),
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.close,
                color: Colors.grey[600],
                size: 18,
              ),
              onPressed: () {
                controller.handleFollowRequest(notif.senderUserId, 'decline');
              },
            ),
          ),
        ],
      );
    }

    // Grup katılma istekleri için butonlar
    if (notif.type == 'group-join-request' || notif.type == 'group-join') {
      debugPrint("🔍 Building group join request button for notification:");
      debugPrint("🔍   - type: ${notif.type}");
      debugPrint("🔍   - isAccepted: ${notif.isAccepted}");
      debugPrint("🔍   - isRejected: ${notif.isRejected}");
      debugPrint("🔍   - groupId: ${notif.groupId}");
      debugPrint("🔍   - senderUserId: ${notif.senderUserId}");
      debugPrint("🔍   - message: ${notif.message}");

      // groupId null ise buton gösterme
      if (notif.groupId == null) {
        debugPrint("🔍   - groupId is null, not showing button");
        return null;
      }

      // Eğer istek zaten onaylanmışsa
      if (notif.isAccepted) {
        debugPrint(
            "🔍   - Request is already accepted, showing 'Onaylandı' button");
        return SizedBox(
          width: 100,
          child: CustomButton(
            text: "Onaylandı",
            height: 32,
            borderRadius: 15,
            onPressed: () {}, // Tıklanamaz
            isLoading: RxBool(false),
            backgroundColor: Colors.grey[300]!,
            textColor: Colors.grey[600]!,
          ),
        );
      }

      // Eğer istek reddedilmişse
      if (notif.isRejected) {
        debugPrint("🔍   - Request is rejected, showing 'Reddedildi' button");
        return SizedBox(
          width: 100,
          child: CustomButton(
            text: "Reddedildi",
            height: 32,
            borderRadius: 15,
            onPressed: () {}, // Tıklanamaz
            isLoading: RxBool(false),
            backgroundColor: Color(0xffffd6d6),
            textColor: Color(0xfffb535c),
          ),
        );
      }

      debugPrint("🔍   - Request is pending, showing accept/decline buttons");
      // İstek beklemedeyse onaylama/reddetme butonları
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            child: CustomButton(
              text: "Onayla",
              height: 32,
              borderRadius: 15,
              onPressed: () {
                controller.handleGroupJoinRequest(
                  notif.senderUserId,
                  notif.groupId!,
                  'accept',
                );
              },
              isLoading: RxBool(false),
              backgroundColor: const Color(0xFFfff6f6),
              textColor: Color(0xFFed7474),
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.close,
                color: Colors.grey[600],
                size: 18,
              ),
              onPressed: () {
                controller.handleGroupJoinRequest(
                  notif.senderUserId,
                  notif.groupId!,
                  'decline',
                );
              },
            ),
          ),
        ],
      );
    }

    return null;
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
