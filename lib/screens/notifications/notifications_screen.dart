import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/components/buttons/notification_action_button.dart';
import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:edusocial/controllers/notification_controller.dart';
import 'package:edusocial/models/notification_model.dart';
import 'package:edusocial/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/language_service.dart';
import 'dart:async';
import 'package:edusocial/controllers/profile_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.find();
  late SocketService _socketService;
  late StreamSubscription _userNotificationSubscription;

  @override
  void initState() {
    super.initState();
    _socketService = Get.find<SocketService>();
    _setupSocketListener();
    
    // Socket bağlantısı kurulduktan sonra user kanalına join ol
    Future.delayed(Duration(seconds: 2), () {
      _joinUserChannel();
    });
    
    // Sayfa açıldığında bildirimleri çek
    controller.fetchNotifications();
  }

  @override
  void dispose() {
    _userNotificationSubscription.cancel();
    
    // User kanalından ayrıl
    _leaveUserChannel();
    
    super.dispose();
  }

  /// Socket event dinleyicisini ayarla
  void _setupSocketListener() {
    debugPrint('🔔 NotificationScreen: Socket dinleyicisi ayarlanıyor...');
    
    // User notification dinleyicisi (user:{user_id} kanalı)
    _userNotificationSubscription = _socketService.onUserNotification.listen((data) {
      debugPrint('👤 NotificationScreen: User notification geldi: $data');
      debugPrint('👤 NotificationScreen: Data type: ${data.runtimeType}');
      
      // Yeni bildirim geldiğinde API'den verileri yeniden çek
      // Loading state'i göstermek için önce loading'i true yap
      controller.isLoading.value = true;
      controller.fetchNotifications();
      
      // Badge sayısı otomatik güncellenir
      // Snackbar kaldırıldı - sadece badge güncellenir
    });
    
    debugPrint('✅ NotificationScreen: Socket dinleyicileri aktif');
    debugPrint('✅ NotificationScreen: User notification stream aktif: ${!_userNotificationSubscription.isPaused}');
  }



  /// User kanalına join ol
  void _joinUserChannel() {
    try {
      final profileController = Get.find<ProfileController>();
      final userId = profileController.userId.value;
      
      if (userId.isNotEmpty) {
        debugPrint('👤 NotificationScreen: User kanalına join olunuyor: user:$userId');
        _socketService.joinUserChannel(userId);
        
        // Tüm bildirim kanallarına da join ol
        _socketService.joinAllNotificationChannels(userId);
      } else {
        debugPrint('⚠️ NotificationScreen: User ID boş, kanala join olunamıyor');
      }
    } catch (e) {
      debugPrint('❌ NotificationScreen: User kanalına join olma hatası: $e');
    }
  }

  /// User kanalından ayrıl
  void _leaveUserChannel() {
    try {
      final profileController = Get.find<ProfileController>();
      final userId = profileController.userId.value;
      
      if (userId.isNotEmpty) {
        debugPrint('👤 NotificationScreen: User kanalından ayrılıyor: user:$userId');
        _socketService.leaveUserChannel(userId);
      }
    } catch (e) {
      debugPrint('❌ NotificationScreen: User kanalından ayrılma hatası: $e');
    }
  }

  /// Socket durumunu kontrol et
  void _checkSocketConnection() {
    debugPrint('🔍 === NOTIFICATION SCREEN SOCKET DURUMU ===');
    debugPrint('🔍 Socket bağlı: ${_socketService.isConnected.value}');
    debugPrint('🔍 User notification subscription aktif: ${!_userNotificationSubscription.isPaused}');
    debugPrint('🔍 Socket ID: ${_socketService.socket?.id}');
    debugPrint('🔍 Socket connected: ${_socketService.socket?.connected}');
    
    // Socket service'den detaylı durum raporu al
    _socketService.checkSocketStatus();
    
    debugPrint('🔍 === SOCKET DURUM RAPORU ===');
    debugPrint('🔍 Socket nesnesi: ${_socketService.socket != null ? "✅ Var" : "❌ Yok"}');
    debugPrint('🔍 Bağlantı durumu: ${_socketService.socket?.connected == true ? "✅ Bağlı" : "❌ Bağlı Değil"}');
    debugPrint('🔍 Socket ID: ${_socketService.socket?.id}');
    debugPrint('🔍 isConnected observable: ${_socketService.isConnected.value}');
    debugPrint('🔍 Dinlenen event\'ler:');
    debugPrint('  - conversation:new_message');
    debugPrint('  - group_conversation:new_message');
    debugPrint('  - conversation:un_read_message_count');
    debugPrint('  - notification:new');
    debugPrint('  - user:notification');
    debugPrint('  - user:*');
    debugPrint('  - private:notification');
    debugPrint('  - user:message');
    debugPrint('  - direct:notification');
    debugPrint('  - personal:notification');
    debugPrint('  - post:comment');
    debugPrint('  - comment:new');
    debugPrint('  - post:activity');
    debugPrint('  - timeline:notification');
    debugPrint('  - follow:notification');
    debugPrint('  - like:notification');
    debugPrint('  - group:notification');
    debugPrint('  - event:notification');
    debugPrint('  - activity:notification');
    debugPrint('  - realtime:notification');
    debugPrint('  - * (wildcard)');
    debugPrint('  - onAny (tüm event\'ler)');
    debugPrint('🔍 ===========================');
    debugPrint('🔍 ===========================================');
  }

  /// Test event gönder
  void _sendTestEvent() {
    debugPrint('🧪 Test event gönderiliyor...');
    
    // Tüm notification tiplerini test et
    final testEvents = [
      'notification:event',
      'comment:event',
      'like:event',
      'follow:event',
      'post:event',
      'group:join_request',
      'group:join_accepted',
      'group:join_declined',
      'follow:request',
      'follow:accepted',
      'follow:declined',
      'event:invitation',
      'event:reminder',
      'post:mention',
      'comment:mention',
      'system:notification',
      'notification:new',
      'user:notification',
      'post:comment',
      'comment:new',
      'like:notification',
      'follow:notification',
      'test:notification',
    ];
    
    for (String eventName in testEvents) {
      _socketService.sendTestEvent(eventName, {
        'type': 'test',
        'message': 'Test notification for $eventName',
        'user_id': 6,
        'timestamp': DateTime.now().toIso8601String(),
        'conversation_id': 'test_123', // Private chat'teki gibi
        'notification_type': eventName.replaceAll(':', '_'),
      });
    }
    
    Get.snackbar(
      'Test',
      'Tüm notification tipleri test edildi',
      duration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar:BackAppBar(
        title: languageService.tr("notifications.title"),
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
          color: Color(0xFFef5050),
          backgroundColor: Color(0xfffafafa),
          elevation: 0,
          strokeWidth: 2.0,
          displacement: 40.0,
          child: Column(
            children: [
              // Socket bağlantı durumu göstergesi
              Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _socketService.isConnected.value ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _socketService.isConnected.value ? Icons.wifi : Icons.wifi_off,
                      color: _socketService.isConnected.value ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _socketService.isConnected.value ? 'Socket Bağlı - Gerçek Zamanlı Güncelleme Aktif' : 'Socket Bağlı Değil - Gerçek Zamanlı Güncelleme Devre Dışı',
                      style: TextStyle(
                        fontSize: 12,
                        color: _socketService.isConnected.value ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
              // Bildirim listesi
              Expanded(
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
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildNotificationTile(NotificationModel n) {
    final LanguageService languageService = Get.find<LanguageService>();
    
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
        // Bildirimi okundu olarak işaretle
        if (!n.isRead) {
          controller.markAsRead(n.id);
        }
        // İstenirse detay ekranına yönlendirme yapılabilir
      },
    );
  }

  Widget? _buildTrailingButton(NotificationModel notif) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    debugPrint("🔍 ===============================");
    debugPrint("🔍 Building button for notification:");
    debugPrint("🔍   - type: ${notif.type}");
    debugPrint("🔍   - message: '${notif.message}'");
    debugPrint("🔍   - isFollowing: ${notif.isFollowing.toString()}");
    debugPrint("🔍   - isFollowingPending: ${notif.isFollowingPending.toString()}");
    debugPrint("🔍   - isAccepted: ${notif.isAccepted.toString()}");
    debugPrint("🔍   - isRejected: ${notif.isRejected.toString()}");

    // System bildirimleri (buton gösterilmez)
    List<String> systemMessages = [
      'user.folow.request.accepted',
      'user.folow.request.declined',
      'user.folow.start', 
      'user.follow.start',
      'user.liked.post',
      'user.commented.post',
      'follow-request-accepted',
      'follow-request-declined',
      'follow-start'
    ];
    
    if (systemMessages.contains(notif.message)) {
      debugPrint("🔍   - SONUÇ: System bildirimi '${notif.message}' - buton gösterilmiyor");
      debugPrint("🔍 ===============================");
      return null;
    }
    
        // Takip başladı bildirimi (sadece bilgi amaçlı)
    if (notif.type == 'follow-request') {
      debugPrint("🔍 Takip başladı bildirimi (bilgi amaçlı):");
      debugPrint("🔍   - type: ${notif.type}");
      debugPrint("🔍   - message: ${notif.message}");
      debugPrint("🔍   - SONUÇ: Takip başlamış - buton gösterilmiyor");
      debugPrint("🔍 ===============================");
      return null; // Takip başlamış, buton gösterme
    }

    // Takip istekleri için butonlar (sadece follow-join-request)
    if (notif.type == 'follow-join-request') {
      debugPrint("🔍   - Takip isteği kontrolü yapılıyor...");

      // Onaylanmış takip istekleri - buton gösterme
      if (notif.isAccepted && notif.isFollowing) {
        debugPrint("🔍   - SONUÇ: Zaten onaylanmış ve takip ediyor - buton gösterilmiyor");
        debugPrint("🔍 ===============================");
        return null;
      }

      // Reddedilmiş takip istekleri - buton gösterme
      if (notif.isRejected) {
        debugPrint("🔍   - SONUÇ: Zaten reddedilmiş - buton gösterilmiyor");
        debugPrint("🔍 ===============================");
        return null;
      }

      // Sadece bekleyen takip istekleri için buton göster (gizli profil)
      if (!notif.isAccepted && !notif.isRejected) {
        debugPrint("🔍   - SONUÇ: Takip İsteği Beklemede (Onayla/Reddet butonları gösteriliyor)");
        debugPrint("🔍 ===============================");
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NotificationActionButtonStyles.accept(
              text: languageService.tr("notifications.actions.accept"),
              onPressed: () {
                controller.handleFollowRequest(notif.senderUserId, 'accept');
              },
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

      // Varsayılan durum
      debugPrint("🔍   - SONUÇ: Beklenmeyen takip isteği durumu - buton gösterilmiyor");
      debugPrint("🔍 ===============================");
      return null;
    }

        // Grup katılım bildirimi (sadece bilgi amaçlı)
    if (notif.type == 'group-join') {
      debugPrint("🔍 Grup katılım bildirimi (bilgi amaçlı):");
      debugPrint("🔍   - type: ${notif.type}");
      debugPrint("🔍   - message: ${notif.message}");
      debugPrint("🔍   - SONUÇ: Grup katılımı gerçekleşmiş - buton gösterilmiyor");
      debugPrint("🔍 ===============================");
      return null; // Katılım gerçekleşmiş, buton gösterme
    }

    // Grup katılma istekleri için butonlar (sadece group-join-request)
    if (notif.type == 'group-join-request') {
      debugPrint("🔍 Building group join request button for notification:");
      debugPrint("🔍   - type: ${notif.type}");
      debugPrint("🔍   - isAccepted: ${notif.isAccepted}");
      debugPrint("🔍   - isRejected: ${notif.isRejected}");
      debugPrint("🔍   - groupId: ${notif.groupId}");
      debugPrint("🔍   - senderUserId: ${notif.senderUserId}");
      debugPrint("🔍   - message: ${notif.message}");

      // groupId null ise buton gösterme
      if (notif.groupId == null) {
        debugPrint("🔍   - SONUÇ: groupId null - buton gösterilmiyor");
        debugPrint("🔍 ===============================");
        return null;
      }

      // Eğer istek zaten onaylanmışsa veya reddedilmişse - buton gösterme
      if (notif.isAccepted) {
        debugPrint("🔍   - SONUÇ: Grup isteği zaten onaylandı - buton gösterilmiyor");
        debugPrint("🔍 ===============================");
        return null;
      }

      if (notif.isRejected) {
        debugPrint("🔍   - SONUÇ: Grup isteği zaten reddedildi - buton gösterilmiyor");
        debugPrint("🔍 ===============================");
        return null;
      }

      // Sadece bekleyen istekler için buton göster
      debugPrint("🔍   - SONUÇ: Grup isteği beklemede - Onayla/Reddet butonları gösteriliyor");
      debugPrint("🔍 ===============================");
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NotificationActionButtonStyles.accept(
            text: languageService.tr("notifications.actions.accept"),
            onPressed: () {
              controller.handleGroupJoinRequest(
                notif.senderUserId,
                notif.groupId!,
                'accept',
              );
            },
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

    debugPrint("🔍   - SONUÇ: Bilinmeyen bildirim tipi '${notif.type}' - buton gösterilmiyor");
    debugPrint("🔍 ===============================");
    return null;
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'follow-request':
      case 'follow-join-request':
      case 'user.folow.request':
      case 'user.follow.request':
        return Icons.person_add_alt_1;
      case 'user.folow.request.accepted':
      case 'follow-request-accepted':
      case 'user.folow.start':
      case 'follow-start':
        return Icons.person_add;
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
      case 'user.folow.request':
      case 'user.follow.request':
        return const Color(0xFF64B5F6);
      case 'user.folow.request.accepted':
      case 'follow-request-accepted':
      case 'user.folow.start':
      case 'follow-start':
        return const Color(0xFF4CAF50); // Yeşil - onaylandı/başladı
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
    final LanguageService languageService = Get.find<LanguageService>();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return languageService.tr("notifications.timeAgo.justNow");
    if (diff.inMinutes < 60) return "${diff.inMinutes}${languageService.tr("notifications.timeAgo.minutesAgo")}";
    if (diff.inHours < 24) return "${diff.inHours}${languageService.tr("notifications.timeAgo.hoursAgo")}";
    if (diff.inDays < 7) return "${diff.inDays}${languageService.tr("notifications.timeAgo.daysAgo")}";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()}${languageService.tr("notifications.timeAgo.weeksAgo")}";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()}${languageService.tr("notifications.timeAgo.monthsAgo")}";
    return "${(diff.inDays / 365).floor()}${languageService.tr("notifications.timeAgo.yearsAgo")}";
  }
}
