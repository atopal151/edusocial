import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/onesignal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final OneSignalService _oneSignalService = Get.find<OneSignalService>();
  
  // Bildirim türleri için state'ler
  bool _notificationPermission = false;
  bool _postNotifications = true;
  bool _messageNotifications = true;
  bool _groupNotifications = true;
  bool _eventNotifications = true;
  bool _followNotifications = true;
  bool _userNotifications = true;
  bool _commentNotifications = true;
  bool _likeNotifications = true;
  bool _postMentionNotifications = true;
  bool _commentMentionNotifications = true;
  bool _systemNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = await _oneSignalService.getNotificationSettings();
    
    setState(() {
      _notificationPermission = prefs.getBool('notification_permission') ?? false;
      _postNotifications = settings['post_notifications'] ?? true;
      _messageNotifications = settings['message_notifications'] ?? true;
      _groupNotifications = settings['group_notifications'] ?? true;
      _eventNotifications = settings['event_notifications'] ?? true;
      _followNotifications = settings['follow_notifications'] ?? true;
      _userNotifications = settings['user_notifications'] ?? true;
      _commentNotifications = settings['comment_notifications'] ?? true;
      _likeNotifications = settings['like_notifications'] ?? true;
      _postMentionNotifications = settings['post_mention_notifications'] ?? true;
      _commentMentionNotifications = settings['comment_mention_notifications'] ?? true;
      _systemNotifications = settings['system_notifications'] ?? true;
    });
  }

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_permission', _notificationPermission);
    
    // OneSignal servisini kullanarak ayarları kaydet
    await _oneSignalService.updateNotificationSettings(
      postNotifications: _postNotifications,
      messageNotifications: _messageNotifications,
      groupNotifications: _groupNotifications,
      eventNotifications: _eventNotifications,
      followNotifications: _followNotifications,
      userNotifications: _userNotifications,
      commentNotifications: _commentNotifications,
      likeNotifications: _likeNotifications,
      postMentionNotifications: _postMentionNotifications,
      commentMentionNotifications: _commentMentionNotifications,
      systemNotifications: _systemNotifications,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: BackAppBar(
        title: 'Bildirim Ayarları',
        iconBackgroundColor: Color(0xffffffff),
      ),
      backgroundColor: const Color(0xffFAFAFA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildNotificationStatusCard(),
              const SizedBox(height: 20),
              _sectionTitle('Bildirim İzinleri'),
              const SizedBox(height: 10),
              _buildSwitchTile(
                'Bildirim İzni',
                _notificationPermission,
                (value) async {
                  setState(() {
                    _notificationPermission = value;
                  });
                  if (value) {
                    await _oneSignalService.requestNotificationPermission();
                  }
                  await _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 30),
              _sectionTitle('Bildirim Türleri'),
              const SizedBox(height: 10),
              _buildSwitchTile(
                'Post Bildirimleri',
                _postNotifications,
                (value) {
                  setState(() {
                    _postNotifications = value;
                  });
                  _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                'Mesaj Bildirimleri',
                _messageNotifications,
                (value) {
                  setState(() {
                    _messageNotifications = value;
                  });
                  _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                'Grup Bildirimleri',
                _groupNotifications,
                (value) {
                  setState(() {
                    _groupNotifications = value;
                  });
                  _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                'Etkinlik Bildirimleri',
                _eventNotifications,
                (value) {
                  setState(() {
                    _eventNotifications = value;
                  });
                  _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                'Takip Bildirimleri',
                _followNotifications,
                (value) {
                  setState(() {
                    _followNotifications = value;
                  });
                  _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                'Kullanıcı Bildirimleri',
                _userNotifications,
                (value) {
                  setState(() {
                    _userNotifications = value;
                  });
                  _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                'Yorum Bildirimleri',
                _commentNotifications,
                (value) {
                  setState(() {
                    _commentNotifications = value;
                  });
                  _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                'Beğeni Bildirimleri',
                _likeNotifications,
                (value) {
                  setState(() {
                    _likeNotifications = value;
                  });
                  _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                'Post Etiketleme Bildirimleri',
                _postMentionNotifications,
                (value) {
                  setState(() {
                    _postMentionNotifications = value;
                  });
                  _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                'Yorum Etiketleme Bildirimleri',
                _commentMentionNotifications,
                (value) {
                  setState(() {
                    _commentMentionNotifications = value;
                  });
                  _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                'Sistem Bildirimleri',
                _systemNotifications,
                (value) {
                  setState(() {
                    _systemNotifications = value;
                  });
                  _saveNotificationSettings();
                },
              ),
              const SizedBox(height: 30),
              _sectionTitle('Test İşlemleri'),
              const SizedBox(height: 10),
              _buildTestButton(
                'Platform Test Bildirimi',
                () {
                  _oneSignalService.sendPlatformAwareTestNotification();
                },
              ),
              const SizedBox(height: 8),
              _buildTestButton(
                'OneSignal Test Bildirimi',
                () {
                  _oneSignalService.sendOneSignalTestNotification();
                },
              ),
              const SizedBox(height: 8),
              _buildTestButton(
                'Local Test Bildirimi',
                () {
                  _oneSignalService.sendLocalTestNotification();
                },
              ),
              const SizedBox(height: 8),
              _buildTestButton(
                'Basit Test Bildirimi',
                () {
                  _oneSignalService.sendSimpleTestNotification();
                },
              ),
              const SizedBox(height: 8),
              _buildTestButton(
                'Konfigürasyon Kontrol Et',
                () {
                  _oneSignalService.checkOneSignalConfiguration();
                },
              ),
              const SizedBox(height: 8),
              _buildTestButton(
                'Player ID Göster',
                () async {
                  final playerId = await _oneSignalService.getPlayerId();
                  if (playerId != null) {
                    Get.snackbar(
                      'Player ID',
                      playerId,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 5),
                      backgroundColor: const Color(0xFFEF5050),
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      'Hata',
                      'Player ID alınamadı',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
       
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bildirim Durumu',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xff414751),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<String?>(
            future: _oneSignalService.getPlayerId(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData && snapshot.data != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF5050).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Cihaz ID: ${snapshot.data!.substring(0, 8)}...',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFEF5050),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bildirim Servisi Aktif',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bildirim Servisi Bağlantısı Yok',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13.28,
              color: const Color(0xff9ca3ae),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: value
                      ? const Color(0xFFEF5050)
                      : const Color(0xFFD3D3D3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 13.28,
        color: const Color(0xff414751),
      ),
    );
  }

  Widget _buildTestButton(String title, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF5050),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
} 