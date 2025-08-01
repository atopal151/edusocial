import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/onesignal_service.dart';
import '../../services/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final OneSignalService _oneSignalService = Get.find<OneSignalService>();
  final LanguageService _languageService = Get.find<LanguageService>();
  
  // Bildirim türleri için state'ler
  bool _notificationPermission = false;
  bool _postNotifications = true;
  bool _messageNotifications = true;
  bool _groupNotifications = true;
  bool _eventNotifications = true;
  bool _followNotifications = true;
  bool _systemNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    debugPrint('📱 Bildirim ayarları yükleniyor...');
    final prefs = await SharedPreferences.getInstance();
    final settings = await _oneSignalService.getNotificationSettings();
    final hasPermission = await _oneSignalService.hasNotificationPermission();
    
    debugPrint('📱 Mevcut ayarlar:');
    debugPrint('   - Bildirim İzni: $hasPermission');
    debugPrint('   - Post Bildirimleri: ${settings['post_notifications'] ?? true}');
    debugPrint('   - Mesaj Bildirimleri: ${settings['message_notifications'] ?? true}');
    debugPrint('   - Grup Bildirimleri: ${settings['group_notifications'] ?? true}');
    debugPrint('   - Etkinlik Bildirimleri: ${settings['event_notifications'] ?? true}');
    debugPrint('   - Takip Bildirimleri: ${settings['follow_notifications'] ?? true}');
    debugPrint('   - Sistem Bildirimleri: ${settings['system_notifications'] ?? true}');
    
    setState(() {
      _notificationPermission = hasPermission;
      _postNotifications = settings['post_notifications'] ?? true;
      _messageNotifications = settings['message_notifications'] ?? true;
      _groupNotifications = settings['group_notifications'] ?? true;
      _eventNotifications = settings['event_notifications'] ?? true;
      _followNotifications = settings['follow_notifications'] ?? true;
      _systemNotifications = settings['system_notifications'] ?? true;
    });
    
    debugPrint('✅ Bildirim ayarları yüklendi');
  }

  Future<void> _saveNotificationSettings() async {
    debugPrint('💾 Bildirim ayarları kaydediliyor...');
    debugPrint('💾 Yeni ayarlar:');
    debugPrint('   - Bildirim İzni: $_notificationPermission');
    debugPrint('   - Post Bildirimleri: $_postNotifications');
    debugPrint('   - Mesaj Bildirimleri: $_messageNotifications');
    debugPrint('   - Grup Bildirimleri: $_groupNotifications');
    debugPrint('   - Etkinlik Bildirimleri: $_eventNotifications');
    debugPrint('   - Takip Bildirimleri: $_followNotifications');
    debugPrint('   - Sistem Bildirimleri: $_systemNotifications');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_permission', _notificationPermission);
    
    // OneSignal servisini kullanarak ayarları kaydet
    await _oneSignalService.updateNotificationSettings(
      postNotifications: _postNotifications,
      messageNotifications: _messageNotifications,
      groupNotifications: _groupNotifications,
      eventNotifications: _eventNotifications,
      followNotifications: _followNotifications,
      systemNotifications: _systemNotifications,
    );
    
    debugPrint('✅ Bildirim ayarları kaydedildi');
  }

  Future<void> _requestNotificationPermission() async {
    debugPrint('🔐 Bildirim izni isteniyor...');
    try {
      debugPrint('🔐 OneSignal\'dan izin isteniyor...');
      await _oneSignalService.requestNotificationPermission();
      debugPrint('🔐 İzin durumu kontrol ediliyor...');
      final hasPermission = await _oneSignalService.hasNotificationPermission();
      debugPrint('🔐 İzin durumu: $hasPermission');
      
      setState(() {
        _notificationPermission = hasPermission;
      });
      debugPrint('🔐 State güncellendi: $_notificationPermission');
      
      if (hasPermission) {
        debugPrint('✅ Bildirim izni verildi, başarı mesajı gösteriliyor');
        Get.snackbar(
          _languageService.tr('notificationSettings.messages.permissionGranted'),
          _languageService.tr('notificationSettings.messages.permissionGrantedDesc'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        debugPrint('❌ Bildirim izni reddedildi, hata mesajı gösteriliyor');
        Get.snackbar(
          _languageService.tr('notificationSettings.messages.permissionDenied'),
          _languageService.tr('notificationSettings.messages.permissionDeniedDesc'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF5050),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      debugPrint('✅ Bildirim izni işlemi tamamlandı');
    } catch (e) {
      debugPrint('❌ Bildirim izni istenirken hata: $e');
      Get.snackbar(
        'Hata',
        'Bildirim izni istenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF5050),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: BackAppBar(
        title: _languageService.tr('notificationSettings.title'),
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
              _sectionTitle(_languageService.tr('notificationSettings.permissions.title')),
              const SizedBox(height: 10),
              _buildSwitchTile(
                _languageService.tr('notificationSettings.permissions.notificationPermission'),
                _notificationPermission,
                (value) async {
                  debugPrint('🔄 Ana Bildirim İzni Switch: $value');
                  if (value) {
                    debugPrint('🔐 Bildirim izni isteniyor...');
                    await _requestNotificationPermission();
                    debugPrint('✅ Bildirim izni işlemi tamamlandı');
                  } else {
                    debugPrint('🔐 Bildirim izni kapatma dialog\'u gösteriliyor...');
                    // Bildirim iznini kapatmak için dialog göster
                    _showDisablePermissionDialog();
                    debugPrint('✅ Bildirim izni kapatma dialog\'u gösterildi');
                  }
                },
              ),
              const SizedBox(height: 30),
              _sectionTitle(_languageService.tr('notificationSettings.types.title')),
              const SizedBox(height: 10),
              _buildSwitchTile(
                _languageService.tr('notificationSettings.types.postNotifications'),
                _postNotifications,
                (value) {
                  debugPrint('🔄 Post Bildirimleri Switch: $value');
                  if (!_notificationPermission) {
                    debugPrint('❌ Bildirim izni yok, dialog gösteriliyor');
                    _showPermissionRequiredDialog();
                    return;
                  }
                  debugPrint('✅ Post bildirimleri ${value ? 'açılıyor' : 'kapatılıyor'}');
                  setState(() {
                    _postNotifications = value;
                  });
                  debugPrint('💾 Post bildirimleri ayarları kaydediliyor...');
                  _saveNotificationSettings();
                  debugPrint('✅ Post bildirimleri ayarları kaydedildi');
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                _languageService.tr('notificationSettings.types.messageNotifications'),
                _messageNotifications,
                (value) {
                  debugPrint('🔄 Mesaj Bildirimleri Switch: $value');
                  if (!_notificationPermission) {
                    debugPrint('❌ Bildirim izni yok, dialog gösteriliyor');
                    _showPermissionRequiredDialog();
                    return;
                  }
                  debugPrint('✅ Mesaj bildirimleri ${value ? 'açılıyor' : 'kapatılıyor'}');
                  setState(() {
                    _messageNotifications = value;
                  });
                  debugPrint('💾 Mesaj bildirimleri ayarları kaydediliyor...');
                  _saveNotificationSettings();
                  debugPrint('✅ Mesaj bildirimleri ayarları kaydedildi');
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                _languageService.tr('notificationSettings.types.groupNotifications'),
                _groupNotifications,
                (value) {
                  debugPrint('🔄 Grup Bildirimleri Switch: $value');
                  if (!_notificationPermission) {
                    debugPrint('❌ Bildirim izni yok, dialog gösteriliyor');
                    _showPermissionRequiredDialog();
                    return;
                  }
                  debugPrint('✅ Grup bildirimleri ${value ? 'açılıyor' : 'kapatılıyor'}');
                  setState(() {
                    _groupNotifications = value;
                  });
                  debugPrint('💾 Grup bildirimleri ayarları kaydediliyor...');
                  _saveNotificationSettings();
                  debugPrint('✅ Grup bildirimleri ayarları kaydedildi');
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                _languageService.tr('notificationSettings.types.eventNotifications'),
                _eventNotifications,
                (value) {
                  debugPrint('🔄 Etkinlik Bildirimleri Switch: $value');
                  if (!_notificationPermission) {
                    debugPrint('❌ Bildirim izni yok, dialog gösteriliyor');
                    _showPermissionRequiredDialog();
                    return;
                  }
                  debugPrint('✅ Etkinlik bildirimleri ${value ? 'açılıyor' : 'kapatılıyor'}');
                  setState(() {
                    _eventNotifications = value;
                  });
                  debugPrint('💾 Etkinlik bildirimleri ayarları kaydediliyor...');
                  _saveNotificationSettings();
                  debugPrint('✅ Etkinlik bildirimleri ayarları kaydedildi');
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                _languageService.tr('notificationSettings.types.followNotifications'),
                _followNotifications,
                (value) {
                  debugPrint('🔄 Takip Bildirimleri Switch: $value');
                  if (!_notificationPermission) {
                    debugPrint('❌ Bildirim izni yok, dialog gösteriliyor');
                    _showPermissionRequiredDialog();
                    return;
                  }
                  debugPrint('✅ Takip bildirimleri ${value ? 'açılıyor' : 'kapatılıyor'}');
                  setState(() {
                    _followNotifications = value;
                  });
                  debugPrint('💾 Takip bildirimleri ayarları kaydediliyor...');
                  _saveNotificationSettings();
                  debugPrint('✅ Takip bildirimleri ayarları kaydedildi');
                },
              ),
              const SizedBox(height: 20),
              _buildSwitchTile(
                _languageService.tr('notificationSettings.types.systemNotifications'),
                _systemNotifications,
                (value) {
                  debugPrint('🔄 Sistem Bildirimleri Switch: $value');
                  if (!_notificationPermission) {
                    debugPrint('❌ Bildirim izni yok, dialog gösteriliyor');
                    _showPermissionRequiredDialog();
                    return;
                  }
                  debugPrint('✅ Sistem bildirimleri ${value ? 'açılıyor' : 'kapatılıyor'}');
                  setState(() {
                    _systemNotifications = value;
                  });
                  debugPrint('💾 Sistem bildirimleri ayarları kaydediliyor...');
                  _saveNotificationSettings();
                  debugPrint('✅ Sistem bildirimleri ayarları kaydedildi');
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showPermissionRequiredDialog() {
    debugPrint('📱 İzin gerekli dialog\'u gösteriliyor...');
    Get.dialog(
      AlertDialog(
        title: Text(
          _languageService.tr('notificationSettings.dialogs.permissionRequired.title'),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xff414751),
          ),
        ),
        content: Text(
          _languageService.tr('notificationSettings.dialogs.permissionRequired.message'),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xff6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('❌ İzin dialog\'u iptal edildi');
              Get.back();
            },
            child: Text(
              _languageService.tr('common.cancel'),
              style: GoogleFonts.inter(
                color: const Color(0xff6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              debugPrint('✅ İzin dialog\'unda "İzin Ver" butonuna tıklandı');
              Get.back();
              await _requestNotificationPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5050),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _languageService.tr('notificationSettings.dialogs.permissionRequired.grant'),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    debugPrint('✅ İzin gerekli dialog\'u gösterildi');
  }

  void _showDisablePermissionDialog() {
    debugPrint('📱 İzin kapatma dialog\'u gösteriliyor...');
    Get.dialog(
      AlertDialog(
        title: Text(
          _languageService.tr('notificationSettings.dialogs.disablePermission.title'),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xff414751),
          ),
        ),
        content: Text(
          _languageService.tr('notificationSettings.dialogs.disablePermission.message'),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xff6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('❌ İzin kapatma dialog\'u iptal edildi');
              Get.back();
            },
            child: Text(
              _languageService.tr('common.cancel'),
              style: GoogleFonts.inter(
                color: const Color(0xff6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              debugPrint('✅ İzin kapatma dialog\'unda "Ayarları Aç" butonuna tıklandı');
              Get.back();
              // Cihaz ayarlarına yönlendir
              await _openDeviceSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _languageService.tr('notificationSettings.dialogs.disablePermission.openSettings'),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    debugPrint('✅ İzin kapatma dialog\'u gösterildi');
  }

  Future<void> _openDeviceSettings() async {
    debugPrint('⚙️ Cihaz ayarları açılıyor...');
    try {
      // Cihaz ayarlarına yönlendir
      debugPrint('⚙️ AppSettings.openAppSettings() çağrılıyor...');
      await AppSettings.openAppSettings();
      debugPrint('✅ Cihaz ayarları açıldı');
      
      // Kullanıcıya bilgi ver
      debugPrint('📱 Kullanıcıya bilgi mesajı gösteriliyor...');
      Get.snackbar(
        _languageService.tr('notificationSettings.messages.settingsRedirect'),
        _languageService.tr('notificationSettings.messages.settingsRedirectDesc'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF9800),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      debugPrint('✅ Bilgi mesajı gösterildi');
    } catch (e) {
      debugPrint('❌ Cihaz ayarları açılırken hata: $e');
      Get.snackbar(
        'Hata',
        'Ayarlar açılamadı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF5050),
        colorText: Colors.white,
      );
    }
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
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 11.28,
                color: const Color(0xff9ca3ae),
              ),
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
} 