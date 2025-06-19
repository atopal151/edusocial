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
    switch (notif.type) {
      case 'group-join-request':
      case 'follow-join-request':
        final isJoined = RxBool(false);
        
        // Tip ve message içeriğine göre işlem belirleme
        bool isFollowRequest = notif.type == 'follow-join-request' || 
                              (notif.type == 'group-join-request' && 
                               notif.message.contains('follow request') && 
                               notif.groupId == null);
        
        bool isGroupRequest = notif.type == 'group-join-request' && 
                             notif.message.contains('join') && 
                             notif.groupId != null;
        
        debugPrint('🔍 Bildirim analizi:');
        debugPrint('   Tip: ${notif.type}');
        debugPrint('   Message: ${notif.message}');
        debugPrint('   GroupId: ${notif.groupId}');
        debugPrint('   IsFollowRequest: $isFollowRequest');
        debugPrint('   IsGroupRequest: $isGroupRequest');
        
        return Obx(() => isJoined.value 
          ? SizedBox(
              width: 100,
              child: CustomButton(
                text: "Onaylandı",
                height: 32,
                borderRadius: 8,
                onPressed: () {},
                isLoading: RxBool(false),
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                icon: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  child: CustomButton(
                    text: "Onayla",
                    height: 32,
                    borderRadius: 8,
                    onPressed: () async {
                      isJoined.value = true;
                      try {
                        if (isGroupRequest) {
                          debugPrint('🚀 Grup katılma isteği onaylanıyor...');
                          await controller.handleGroupJoinRequest(notif.userId, notif.groupId!, "accept");
                          debugPrint('✅ Grup katılma isteği onaylandı.');
                        } else if (isFollowRequest) {
                          debugPrint('👤 Takip isteği onaylanıyor...');
                          await controller.handleFollowRequest(notif.userId, "accept");
                          debugPrint('✅ Takip isteği onaylandı.');
                        } else {
                          debugPrint('⚠️ Bilinmeyen istek tipi, işlem yapılmıyor.');
                          isJoined.value = false;
                        }
                      } catch (e) {
                        debugPrint('❌ İstek onaylanamadı: $e');
                        // API hatası durumunda kullanıcıya bilgi ver
                        if (e.toString().contains('not found')) {
                          Get.snackbar(
                            "Bilgi",
                            "Bu istek zaten işlenmiş.",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                            duration: Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            "Hata",
                            "İşlem gerçekleştirilemedi.",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: Duration(seconds: 2),
                          );
                        }
                        isJoined.value = false;
                      }
                    },
                    isLoading: RxBool(false),
                    backgroundColor: const Color(0xFFFF5050),
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    isJoined.value = true;
                    try {
                      if (isGroupRequest) {
                        debugPrint('🚀 Grup katılma isteği reddediliyor...');
                        await controller.handleGroupJoinRequest(notif.userId, notif.groupId!, "decline");
                        debugPrint('✅ Grup katılma isteği reddedildi.');
                      } else if (isFollowRequest) {
                        debugPrint('👤 Takip isteği reddediliyor...');
                        await controller.handleFollowRequest(notif.userId, "decline");
                        debugPrint('✅ Takip isteği reddedildi.');
                      } else {
                        debugPrint('⚠️ Bilinmeyen istek tipi, işlem yapılmıyor.');
                        isJoined.value = false;
                      }
                    } catch (e) {
                      debugPrint('❌ İstek reddedilemedi: $e');
                      // API hatası durumunda kullanıcıya bilgi ver
                      if (e.toString().contains('not found')) {
                        Get.snackbar(
                          "Bilgi",
                          "Bu istek zaten işlenmiş.",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                          duration: Duration(seconds: 2),
                        );
                      } else {
                        Get.snackbar(
                          "Hata",
                          "İşlem gerçekleştirilemedi.",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          duration: Duration(seconds: 2),
                        );
                      }
                      isJoined.value = false;
                    }
                  },
                  icon: Icon(Icons.close, color: Colors.white, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(32, 32),
                  ),
                ),
              ],
            ));

      case 'follow-request':
        final isFollowing = RxBool(false);
        
        // Follow-request tipindeki bildirimler genellikle "started following you" mesajı içerir
        bool isStartedFollowing = notif.message.contains('started following you');
        
        debugPrint('🔍 Follow-request analizi:');
        debugPrint('   Message: ${notif.message}');
        debugPrint('   IsStartedFollowing: $isStartedFollowing');
        
        return Obx(() => isFollowing.value
          ? SizedBox(
              width: 100,
              child: CustomButton(
                text: isStartedFollowing ? "Takip Edildi" : "Onaylandı",
                height: 32,
                borderRadius: 8,
                onPressed: () {},
                isLoading: RxBool(false),
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                icon: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  child: CustomButton(
                    text: isStartedFollowing ? "Takip Et" : "Onayla",
                    height: 32,
                    borderRadius: 8,
                    onPressed: () async {
                      isFollowing.value = true;
                      try {
                        if (isStartedFollowing) {
                          debugPrint('👤 Kullanıcı takip ediliyor...');
                          await controller.handleFollowRequest(notif.userId, "accept");
                          debugPrint('✅ Kullanıcı takip edildi.');
                        } else {
                          debugPrint('👤 Takip isteği onaylanıyor...');
                          await controller.handleFollowRequest(notif.userId, "accept");
                          debugPrint('✅ Takip isteği onaylandı.');
                        }
                      } catch (e) {
                        debugPrint('❌ Takip işlemi başarısız: $e');
                        // API hatası durumunda kullanıcıya bilgi ver
                        if (e.toString().contains('not found')) {
                          Get.snackbar(
                            "Bilgi",
                            "Bu istek zaten işlenmiş.",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                            duration: Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            "Hata",
                            "İşlem gerçekleştirilemedi.",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: Duration(seconds: 2),
                          );
                        }
                        isFollowing.value = false;
                      }
                    },
                    isLoading: RxBool(false),
                    backgroundColor: const Color(0xFFFF5050),
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    isFollowing.value = true;
                    try {
                      debugPrint('👤 Takip isteği reddediliyor...');
                      await controller.handleFollowRequest(notif.userId, "decline");
                      debugPrint('✅ Takip isteği reddedildi.');
                    } catch (e) {
                      debugPrint('❌ Takip reddedilemedi: $e');
                      // API hatası durumunda kullanıcıya bilgi ver
                      if (e.toString().contains('not found')) {
                        Get.snackbar(
                          "Bilgi",
                          "Bu istek zaten işlenmiş.",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                          duration: Duration(seconds: 2),
                        );
                      } else {
                        Get.snackbar(
                          "Hata",
                          "İşlem gerçekleştirilemedi.",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          duration: Duration(seconds: 2),
                        );
                      }
                      isFollowing.value = false;
                    }
                  },
                  icon: Icon(Icons.close, color: Colors.white, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(32, 32),
                  ),
                ),
              ],
            ));

      case 'create-group-event':
        final isEventApproved = RxBool(false);
        
        // Message içeriğinden grup adını çıkar
        String? groupName;
        if (notif.message.contains('in the') && notif.message.contains('group')) {
          final parts = notif.message.split('in the ');
          if (parts.length > 1) {
            groupName = parts[1].split(' group')[0];
          }
        }
        
        return Obx(() => isEventApproved.value
          ? SizedBox(
              width: 100,
              child: CustomButton(
                text: "Onaylandı",
                height: 32,
                borderRadius: 8,
                onPressed: () {},
                isLoading: RxBool(false),
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                icon: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            )
          : groupName != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60,
                    child: CustomButton(
                      text: "Onayla",
                      height: 32,
                      borderRadius: 8,
                      onPressed: () async {
                        debugPrint('Etkinlik oluşturma isteği onaylanıyor...');
                        isEventApproved.value = true;
                        try {
                          // Bu durumda groupId ve eventId null olduğu için
                          // sadece bildirim olarak işaretleyelim
                          debugPrint('Etkinlik oluşturma isteği onaylandı (bildirim olarak).');
                        } catch (e) {
                          debugPrint('Etkinlik oluşturma isteği onaylanamadı: $e');
                          isEventApproved.value = false;
                        }
                      },
                      isLoading: RxBool(false),
                      backgroundColor: const Color(0xFFFF5050),
                      textColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      debugPrint('Etkinlik oluşturma isteği reddediliyor...');
                      isEventApproved.value = true;
                      try {
                        // Bu durumda groupId ve eventId null olduğu için
                        // sadece bildirim olarak işaretleyelim
                        debugPrint('Etkinlik oluşturma isteği reddedildi (bildirim olarak).');
                      } catch (e) {
                        debugPrint('Etkinlik oluşturma isteği reddedilemedi: $e');
                        isEventApproved.value = false;
                      }
                    },
                    icon: Icon(Icons.close, color: Colors.white, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(32, 32),
                    ),
                  ),
                ],
              )
            : SizedBox.shrink() // Grup adı çıkarılamazsa buton gösterme
            );

      default:
        return null;
    }
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
