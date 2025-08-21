import 'package:edusocial/components/user_appbar/back_appbar.dart';
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
import 'package:edusocial/components/print_full_text.dart';
import 'package:flutter/foundation.dart';

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
      
      // Yeni bildirim geldiğinde kayan bildirim göster
      _handleNewNotification(data);
      
      // Yeni bildirim geldiğinde API'den verileri yeniden çek
      // Loading state'i göstermek için önce loading'i true yap
      controller.isLoading.value = true;
      controller.fetchNotifications();
      
      // Badge sayısı otomatik güncellenir
    });
    
    debugPrint('✅ NotificationScreen: Socket dinleyicileri aktif');
    debugPrint('✅ NotificationScreen: User notification stream aktif: ${!_userNotificationSubscription.isPaused}');
  }

  /// Yeni bildirimi işle ve kayan bildirim göster
  void _handleNewNotification(dynamic data) {
    try {
      printFullText('📱 =======================================');
      printFullText('📱 YENİ BİLDİRİM İŞLENİYOR!');
      printFullText('📱 Data: $data');
      printFullText('📱 Data Type: ${data.runtimeType}');
      
      if (data is Map) {
        printFullText('📱 Data Keys: ${data.keys.toList()}');
        
        // Detaylı alan analizi
        printFullText('📱 === DETAYLI ALAN ANALİZİ ===');
        
        // Ana alanlar
        if (data.containsKey('id')) {
          printFullText('📱 ID: ${data['id']} (Type: ${data['id'].runtimeType})');
        }
        
        if (data.containsKey('type')) {
          printFullText('📱 Type: ${data['type']} (Type: ${data['type'].runtimeType})');
        }
        
        if (data.containsKey('user_id')) {
          printFullText('📱 User ID: ${data['user_id']} (Type: ${data['user_id'].runtimeType})');
        }
        
        if (data.containsKey('sender_id')) {
          printFullText('📱 Sender ID: ${data['sender_id']} (Type: ${data['sender_id'].runtimeType})');
        }
        
        if (data.containsKey('message')) {
          printFullText('📱 Message: ${data['message']} (Type: ${data['message'].runtimeType})');
        }
        
        if (data.containsKey('text')) {
          printFullText('📱 Text: ${data['text']} (Type: ${data['text'].runtimeType})');
        }
        
        if (data.containsKey('created_at')) {
          printFullText('📱 Created At: ${data['created_at']} (Type: ${data['created_at'].runtimeType})');
        }
        
        if (data.containsKey('updated_at')) {
          printFullText('📱 Updated At: ${data['updated_at']} (Type: ${data['updated_at'].runtimeType})');
        }
        
        if (data.containsKey('is_read')) {
          printFullText('📱 Is Read: ${data['is_read']} (Type: ${data['is_read'].runtimeType})');
        }
        
        if (data.containsKey('group_id')) {
          printFullText('📱 Group ID: ${data['group_id']} (Type: ${data['group_id'].runtimeType})');
        }
        
        if (data.containsKey('event_id')) {
          printFullText('📱 Event ID: ${data['event_id']} (Type: ${data['event_id'].runtimeType})');
        }
        
        if (data.containsKey('conversation_id')) {
          printFullText('📱 Conversation ID: ${data['conversation_id']} (Type: ${data['conversation_id'].runtimeType})');
        }
        
        // Nested objects
        if (data.containsKey('notification_data')) {
          printFullText('📱 === NOTIFICATION_DATA OBJECT ===');
          final notificationData = data['notification_data'];
          if (notificationData is Map) {
            printFullText('📱 Notification Data Keys: ${notificationData.keys.toList()}');
            
            for (String key in notificationData.keys) {
              printFullText('📱   ${key}: ${notificationData[key]} (Type: ${notificationData[key].runtimeType})');
            }
          } else {
            printFullText('📱 Notification Data: $notificationData (Type: ${notificationData.runtimeType})');
          }
        }
        
        if (data.containsKey('user')) {
          printFullText('📱 === USER OBJECT ===');
          final user = data['user'];
          if (user is Map) {
            printFullText('📱 User Keys: ${user.keys.toList()}');
            
            for (String key in user.keys) {
              printFullText('📱   ${key}: ${user[key]} (Type: ${user[key].runtimeType})');
            }
          } else {
            printFullText('📱 User: $user (Type: ${user.runtimeType})');
          }
        }
        
        if (data.containsKey('group')) {
          printFullText('📱 === GROUP OBJECT ===');
          final group = data['group'];
          if (group is Map) {
            printFullText('📱 Group Keys: ${group.keys.toList()}');
            
            for (String key in group.keys) {
              printFullText('📱   ${key}: ${group[key]} (Type: ${group[key].runtimeType})');
            }
          } else {
            printFullText('📱 Group: $group (Type: ${group.runtimeType})');
          }
        }
        
        if (data.containsKey('data')) {
          printFullText('📱 === DATA OBJECT ===');
          final dataObj = data['data'];
          if (dataObj is Map) {
            printFullText('📱 Data Keys: ${dataObj.keys.toList()}');
            
            for (String key in dataObj.keys) {
              printFullText('📱   ${key}: ${dataObj[key]} (Type: ${dataObj[key].runtimeType})');
            }
          } else {
            printFullText('📱 Data: $dataObj (Type: ${dataObj.runtimeType})');
          }
        }
        
        if (data.containsKey('answer')) {
          printFullText('📱 === ANSWER OBJECT ===');
          final answer = data['answer'];
          if (answer is Map) {
            printFullText('📱 Answer Keys: ${answer.keys.toList()}');
            
            for (String key in answer.keys) {
              printFullText('📱   ${key}: ${answer[key]} (Type: ${answer[key].runtimeType})');
            }
          } else {
            printFullText('📱 Answer: $answer (Type: ${answer.runtimeType})');
          }
        }
        
        if (data.containsKey('notification_full_data')) {
          printFullText('📱 === NOTIFICATION_FULL_DATA OBJECT ===');
          final fullData = data['notification_full_data'];
          if (fullData is Map) {
            printFullText('📱 Full Data Keys: ${fullData.keys.toList()}');
            
            for (String key in fullData.keys) {
              printFullText('📱   ${key}: ${fullData[key]} (Type: ${fullData[key].runtimeType})');
            }
          } else {
            printFullText('📱 Full Data: $fullData (Type: ${fullData.runtimeType})');
          }
        }
        
        // Diğer olası alanlar
        final otherKeys = data.keys.where((key) => !['id', 'type', 'user_id', 'sender_id', 'message', 'text', 'created_at', 'updated_at', 'is_read', 'group_id', 'event_id', 'conversation_id', 'notification_data', 'user', 'group', 'data', 'answer', 'notification_full_data'].contains(key)).toList();
        
        if (otherKeys.isNotEmpty) {
          printFullText('📱 === DİĞER ALANLAR ===');
          for (String key in otherKeys) {
            printFullText('📱   ${key}: ${data[key]} (Type: ${data[key].runtimeType})');
          }
        }
        
        printFullText('📱 === ALAN ANALİZİ TAMAMLANDI ===');
      } else {
        printFullText('📱 Data is not a Map, it is: ${data.runtimeType}');
      }
      
      // Yeni bildirim geldiğinde API'den verileri yeniden çek
      // Loading state'i göstermek için önce loading'i true yap
      controller.isLoading.value = true;
      controller.fetchNotifications();
      
      // Badge sayısı otomatik güncellenir
      printFullText('📱 =======================================');
    } catch (e) {
      printFullText('❌ Bildirim işleme hatası: $e');
    }
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
    // Her bildirim satırı için is_read değerini debug et
    debugPrint('📱 === NOTIFICATION TILE DEBUG ===');
    debugPrint('📱 Notification ID: ${n.id}');
    debugPrint('📱 Notification Type: ${n.type}');
    debugPrint('📱 isRead: ${n.isRead}');
    debugPrint('📱 Message: ${n.message}');
    debugPrint('📱 ==============================');
    
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
              text: " ${_timeAgo(n.timestamp)}",
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
    final LanguageService languageService = Get.find<LanguageService>();
    
    //debugPrint("🔍 ===============================");
    //debugPrint("🔍 Building button for notification:");
    //debugPrint("🔍   - type: ${notif.type}");
    //debugPrint("🔍   - message: '${notif.message}'");
    //debugPrint("🔍   - isFollowing: ${notif.isFollowing.toString()}");
    //debugPrint("🔍   - isFollowingPending: ${notif.isFollowingPending.toString()}");
    //debugPrint("🔍   - isAccepted: ${notif.isAccepted.toString()}");
    //debugPrint("🔍   - isRejected: ${notif.isRejected.toString()}");

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
      //debugPrint("🔍   - SONUÇ: System bildirimi '${notif.message}' - buton gösterilmiyor");
      //debugPrint("🔍 ===============================");
      return null;
    }
    
        // Takip başladı bildirimi (sadece bilgi amaçlı)
    if (notif.type == 'follow-request') {
      //debugPrint("🔍 Takip başladı bildirimi (bilgi amaçlı):");
      //debugPrint("🔍   - type: ${notif.type}");
      //debugPrint("🔍   - message: ${notif.message}");
      //debugPrint("🔍   - SONUÇ: Takip başlamış - buton gösterilmiyor");
      //debugPrint("🔍 ===============================");
      return null; // Takip başlamış, buton gösterme
    }

    // Takip istekleri için butonlar (sadece follow-join-request)
    if (notif.type == 'follow-join-request') {
      //debugPrint("🔍   - Takip isteği kontrolü yapılıyor...");

      // Onaylanmış takip istekleri - buton gösterme
      if (notif.isAccepted && notif.isFollowing) {
        //debugPrint("🔍   - SONUÇ: Zaten onaylanmış ve takip ediyor - buton gösterilmiyor");
        //debugPrint("🔍 ===============================");
        return null;
      }

      // Reddedilmiş takip istekleri - buton gösterme
      if (notif.isRejected) {
        //debugPrint("🔍   - SONUÇ: Zaten reddedilmiş - buton gösterilmiyor");
        //debugPrint("🔍 ===============================");
        return null;
      }

      // Sadece bekleyen takip istekleri için buton göster (gizli profil)
      if (!notif.isAccepted && !notif.isRejected) {
        //debugPrint("🔍   - SONUÇ: Takip İsteği Beklemede (Onayla/Reddet butonları gösteriliyor)");
        //debugPrint("🔍 ===============================");
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
      //    debugPrint("🔍   - SONUÇ: Beklenmeyen takip isteği durumu - buton gösterilmiyor");
      //debugPrint("🔍 ===============================");
      return null;
    }

        // Grup katılım bildirimi (sadece bilgi amaçlı)
    if (notif.type == 'group-join') {
      //debugPrint("🔍 Grup katılım bildirimi (bilgi amaçlı):");
      //debugPrint("🔍   - type: ${notif.type}");
      //debugPrint("🔍   - message: ${notif.message}");
      //debugPrint("🔍   - SONUÇ: Grup katılımı gerçekleşmiş - buton gösterilmiyor");
      //debugPrint("🔍 ===============================");
      return null; // Katılım gerçekleşmiş, buton gösterme
    }

    // Grup katılma istekleri için butonlar (sadece group-join-request)
    if (notif.type == 'group-join-request') {
      //debugPrint("🔍 Building group join request button for notification:");
      //debugPrint("🔍   - type: ${notif.type}");
      //debugPrint("🔍   - isAccepted: ${notif.isAccepted}");
      //debugPrint("🔍   - isRejected: ${notif.isRejected}");
      //debugPrint("🔍   - groupId: ${notif.groupId}");
      //debugPrint("🔍   - senderUserId: ${notif.senderUserId}");
      //debugPrint("🔍   - message: ${notif.message}");

      // groupId null ise buton gösterme
      if (notif.groupId == null) {
        //debugPrint("🔍   - SONUÇ: groupId null - buton gösterilmiyor");
        //debugPrint("🔍 ===============================");
        return null;
      }

      // Eğer istek zaten onaylanmışsa veya reddedilmişse - buton gösterme
      if (notif.isAccepted) {
        //debugPrint("🔍   - SONUÇ: Grup isteği zaten onaylandı - buton gösterilmiyor");
        //debugPrint("🔍 ===============================");
        return null;
      }

      if (notif.isRejected) {
        //debugPrint("🔍   - SONUÇ: Grup isteği zaten reddedildi - buton gösterilmiyor");
        //debugPrint("🔍 ===============================");
        return null;
      }

      // Sadece bekleyen istekler için buton göster
      //  debugPrint("🔍   - SONUÇ: Grup isteği beklemede - Onayla/Reddet butonları gösteriliyor");
      //debugPrint("🔍 ===============================");
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

    //debugPrint("🔍   - SONUÇ: Bilinmeyen bildirim tipi '${notif.type}' - buton gösterilmiyor");
    //debugPrint("🔍 ===============================");
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
  
  /// Test method for notification logging - can be called manually for testing
  void _testNotificationLogging() {
    printFullText('🧪 === TEST NOTIFICATION LOGGING ===');
    
    // Simulate a sample notification data structure
    final testData = {
      'id': '12345',
      'type': 'follow-request',
      'user_id': '67890',
      'sender_id': '11111',
      'message': 'Test notification message',
      'text': 'Test notification text',
      'created_at': '2024-01-01T12:00:00Z',
      'updated_at': '2024-01-01T12:00:00Z',
      'is_read': false,
      'group_id': 'group123',
      'event_id': 'event456',
      'conversation_id': 'conv789',
      'notification_data': {
        'id': '12345',
        'type': 'follow-request',
        'text': 'Test notification data text',
        'user_id': '67890',
        'created_at': '2024-01-01T12:00:00Z',
      },
      'user': {
        'id': '11111',
        'username': 'testuser',
        'name': 'Test',
        'surname': 'User',
        'avatar_url': 'https://example.com/avatar.jpg',
        'is_following': false,
        'is_following_pending': true,
        'is_self': false,
      },
      'group': {
        'id': 'group123',
        'name': 'Test Group',
        'status': 'pending',
      },
      'data': {
        'data': {
          'user_id': '11111',
          'group_id': 'group123',
        }
      },
      'answer': {
        'status': 'pending',
        'created_at': '2024-01-01T12:00:00Z',
      },
      'notification_full_data': {
        'text': 'Test full data text',
        'user_id': '67890',
        'group_id': 'group123',
        'event_id': 'event456',
        'group_name': 'Test Group',
      },
      'extra_field': 'extra_value',
    };
    
    // Call the notification handler with test data
    _handleNewNotification(testData);
    
    printFullText('🧪 === TEST COMPLETED ===');
  }
}
