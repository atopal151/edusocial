import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../controllers/notification_controller.dart';

Widget buildNotificationTile(NotificationModel n) {
  final NotificationController controller = Get.find();
  
  debugPrint('🔔 Bildirim tipi: ${n.type}');
  return ListTile(
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
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          TextSpan(
            text: "${n.message} ",
            style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12),
          ),
          TextSpan(
            text: _timeAgo(
              n.timestamp,
            ),
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
          )
        ],
      ),
    ),
    tileColor: n.isRead ? Colors.transparent : const Color(0xffEEF3F8),
    trailing: _buildFollowRequestAction(n, controller),
  );
}

Widget _buildFollowRequestAction(NotificationModel n, NotificationController controller) {
  debugPrint('🔔 [Button] Bildirim tipi: ${n.type}');
  debugPrint('🔍   - isFollowing: ${n.isFollowing}');
  debugPrint('🔍   - isFollowingPending: ${n.isFollowingPending}');
  debugPrint('🔍   - isAccepted: ${n.isAccepted}');
  debugPrint('🔍   - isRejected: ${n.isRejected}');
  if (n.type == 'follow-request' || n.type == 'follow-join-request') {
    if (n.isAccepted) {
      debugPrint('🔍   - Durum: Onaylandı');
      return Text(
        'Onaylandı',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (n.isRejected) {
      debugPrint('🔍   - Durum: Reddedildi');
      return Text(
        'Reddedildi',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      debugPrint('🔍   - Durum: Onayla ve X gösteriliyor');
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              controller.handleFollowRequest(n.senderUserId, 'accept');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff4CAF50),
              minimumSize: Size(60, 32),
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text('Onayla', style: TextStyle(fontSize: 12)),
          ),
          SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () {
              controller.handleFollowRequest(n.senderUserId, 'decline');
            },
            tooltip: 'Reddet',
          ),
        ],
      );
    }
  }
  return SizedBox.shrink();
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
      return Color(0xFF64B5F6); // mavi - daha koyu pastel ton

    case 'post-like':
      return Color(0xFFE57373); // kırmızımsı pembe - belirgin

    case 'post-comment':
      return Color(0xFFFFB74D); // turuncu - sıcak ve net

    case 'group-join-request':
      return Color(0xFFFFF176); // sarı - doygun

    case 'group-join':
      return Color(0xFF81C784); // yeşil - dengeli pastel yeşil

    case 'create-group-event':
      return Color(0xFF9575CD); // mor - parlak ton

    case 'group_accept':
      return Color(0xFFFFCC80); // açık kahverengi/turuncu - yumuşak

    default:
      return Color(0xFFBDBDBD); // nötr gri - daha koyu
  }
}

String _timeAgo(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) return "az önce";
  if (diff.inMinutes < 60) return "${diff.inMinutes}dk";
  if (diff.inHours < 24) return "${diff.inHours}s";
  if (diff.inDays < 7) return "${diff.inDays}g";
  if (diff.inDays < 30) return "${(diff.inDays / 7).floor()}h"; // hafta
  if (diff.inDays < 365) return "${(diff.inDays / 30).floor()}a"; // ay
  return "${(diff.inDays / 365).floor()}y"; // yıl
}
