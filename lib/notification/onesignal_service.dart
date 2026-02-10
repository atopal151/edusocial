import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:get_storage/get_storage.dart';

import '../services/api_service.dart';
import 'notification_handler.dart';
import 'notification_renderer.dart';
import 'notification_settings.dart';

class OneSignalService extends GetxService {
  static const String _appId = "a26f3c4c-771d-4b68-85d6-a33c1ef1766f";

  late final NotificationSettings _settings;
  late final NotificationHandler _handler;
  String? _loggedInExternalId;
  String? _lastSubscriptionId;

  @override
  void onInit() {
    super.onInit();
    _settings = NotificationSettings();
    _handler = NotificationHandler(
      settings: _settings,
      renderer: NotificationRenderer(),
    );
    _initializeOneSignal();
  }

  Future<void> _initializeOneSignal() async {
    try {
      // Platform kontrolü
      final platform = Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Unknown');
      debugPrint('🚀 OneSignal initializing on platform: $platform');
      
      OneSignal.initialize(_appId);
      debugPrint('✅ OneSignal initialized with App ID: $_appId');

      await _requestPermissionIfNeeded(force: true);
      _logSubscriptionState();
      _logPushToken();
      
      // iOS için özel kontrol
      if (Platform.isIOS) {
        debugPrint('📱 iOS platform detected - checking push notification setup');
        final hasPermission = await hasNotificationPermission();
        debugPrint('📱 iOS notification permission: $hasPermission');
      }

      // Foreground notification handler (uygulama açıkken)
      OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
        debugPrint('📱 [Foreground] Notification received: ${event.notification.title}');
        event.preventDefault();
        await _handler.handleForeground(event.notification);
      });

      // Permission observer (izin durumu değiştiğinde)
      OneSignal.Notifications.addPermissionObserver((hasPermission) {
        debugPrint('🔔 Notification permission changed: $hasPermission');
      });

      // Notification click handler
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('👆 Notification clicked: ${event.notification.title}');
        _handler.handleClick(event.notification);
      });

      OneSignal.User.pushSubscription.addObserver((state) {
        final current = state.current;
        final currentId = current.id;
        final currentToken = current.token;
        final currentOptedIn = current.optedIn;
        
        debugPrint('OneSignal subscription changed: id=$currentId, token=$currentToken, optedIn=$currentOptedIn');
        
        // Subscription ID değişti mi kontrol et
        final subscriptionIdChanged = currentId != null && 
                                     currentId != _lastSubscriptionId && 
                                     _lastSubscriptionId != null;
        
        if (subscriptionIdChanged) {
          debugPrint('🔄 Subscription ID changed: $_lastSubscriptionId -> $currentId');
        }
        
        // Subscription ready olduğunda ve external ID varsa login yap
        // Subscription ID değiştiğinde external ID ile tekrar bağlanmak kritik
        if (currentId != null && _loggedInExternalId != null && _loggedInExternalId!.isNotEmpty) {
          if (subscriptionIdChanged) {
            debugPrint('🔄 Re-login with externalUserId=$_loggedInExternalId (subscription ID changed)');
          } else {
            debugPrint('🔄 Ensuring login with externalUserId=$_loggedInExternalId');
          }
          loginUser(_loggedInExternalId!);
        }
        
        // Subscription ID hazır olduğunda ve değiştiğinde Player ID'yi backend'e gönder
        if (currentId != null && currentId.isNotEmpty) {
          if (subscriptionIdChanged || _lastSubscriptionId == null) {
            debugPrint('📤 Player ID backend\'e gönderiliyor (subscription ready/changed): $currentId');
            _sendPlayerIdToBackend();
          }
        }
        
        // Subscription ID'yi güncelle
        _lastSubscriptionId = currentId;
        
        _logPushToken();
      });
    } catch (e) {
      debugPrint('OneSignal init error: $e');
    }
  }

  Future<void> loginUser(String externalUserId) async {
    try {
      if (externalUserId.isNotEmpty) {
        // Her zaman login yap (OneSignal SDK gereksiz çağrıları optimize eder)
        // Subscription ID değiştiğinde external ID ile tekrar bağlanmak için önemli
        await OneSignal.login(externalUserId);
        _loggedInExternalId = externalUserId;
        debugPrint('✅ OneSignal login with externalUserId=$externalUserId');
        _logSubscriptionState();
        _logPushToken();
        
        // Player ID'yi backend'e gönder
        await _sendPlayerIdToBackend();
      }
    } catch (e) {
      debugPrint('❌ OneSignal login error: $e');
    }
  }

  /// Player ID'yi backend'e gönder
  Future<void> _sendPlayerIdToBackend() async {
    try {
      final playerId = OneSignal.User.pushSubscription.id;
      if (playerId == null || playerId.isEmpty) {
        debugPrint('⚠️ Player ID henüz hazır değil, backend\'e gönderilemedi');
        return;
      }

      final token = GetStorage().read('token');
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ Token bulunamadı, Player ID backend\'e gönderilemedi');
        return;
      }

      // Platform bilgisini al
      final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');
      
      // Device name (opsiyonel)
      final deviceName = '${platform}_device';

      debugPrint('📤 Player ID backend\'e gönderiliyor: $playerId');
      debugPrint('📤 Platform: $platform');
      debugPrint('📤 Device Name: $deviceName');

      try {
        final apiService = Get.find<ApiService>();
        final response = await apiService.post(
          '/set-user-device',
          {
            'player_id': playerId,
            'device_name': deviceName,
            'platform': platform,
          },
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('✅ Player ID backend\'e başarıyla gönderildi: $playerId');
        } else {
          debugPrint('⚠️ Player ID backend\'e gönderilemedi. Status: ${response.statusCode}');
          debugPrint('⚠️ Response: ${response.data}');
        }
      } catch (e) {
        debugPrint('❌ Player ID backend\'e gönderilirken hata: $e');
      }
    } catch (e) {
      debugPrint('❌ Player ID backend\'e gönderme hatası: $e');
    }
  }

  Future<void> requestNotificationPermission() async {
    await _requestPermissionIfNeeded(force: true);
  }

  Future<bool> hasNotificationPermission() async {
    try {
      return OneSignal.Notifications.permission;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, bool>> getNotificationSettings() {
    return _settings.getPreferences();
  }

  Future<void> updateNotificationSettings({
    required bool postNotifications,
    required bool messageNotifications,
    required bool groupNotifications,
    required bool eventNotifications,
    required bool followNotifications,
    required bool systemNotifications,
  }) {
    return _settings.updatePreferences(
      postNotifications: postNotifications,
      messageNotifications: messageNotifications,
      groupNotifications: groupNotifications,
      eventNotifications: eventNotifications,
      followNotifications: followNotifications,
      systemNotifications: systemNotifications,
    );
  }

  Future<void> muteGroup(String groupId) => _settings.muteGroup(groupId);
  Future<void> unmuteGroup(String groupId) => _settings.unmuteGroup(groupId);
  Future<bool> isGroupMuted(String groupId) => _settings.isGroupMuted(groupId);

  Future<void> mutePrivateChat(String conversationId) =>
      _settings.mutePrivateChat(conversationId);
  Future<void> unmutePrivateChat(String conversationId) =>
      _settings.unmutePrivateChat(conversationId);
  Future<bool> isPrivateChatMuted(String conversationId) =>
      _settings.isPrivateChatMuted(conversationId);

  Future<void> sendLocalNotification(
    String title,
    String message,
    Map<String, dynamic>? data,
  ) async {
    final type = data?['type']?.toString() ?? 'notification';
    await _handler.handleLocal(type, title, message, data ?? <String, dynamic>{});
  }

  Future<void> _requestPermissionIfNeeded({bool force = false}) async {
    try {
      if (!force && await hasNotificationPermission()) {
        debugPrint('✅ Notification permission already granted');
        return;
      }
      
      final platform = Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Unknown');
      debugPrint('🔔 Requesting notification permission on $platform...');
      
      final granted = await OneSignal.Notifications.requestPermission(true);
      debugPrint('🔔 OneSignal permission result: $granted');
      
      if (!granted) {
        debugPrint('⚠️ OneSignal permission denied by user');
      } else {
        debugPrint('✅ OneSignal permission granted successfully');
      }
    } catch (e) {
      debugPrint('❌ OneSignal permission error: $e');
    }
  }

  void _logSubscriptionState() {
    try {
      final sub = OneSignal.User.pushSubscription;
      final platform = Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Unknown');
      debugPrint(
        '📊 [$platform] OneSignal subscription state: id=${sub.id}, token=${sub.token}, optedIn=${sub.optedIn}',
      );
      
      if (Platform.isIOS && sub.id == null) {
        debugPrint('⚠️ [iOS] Subscription ID is null - this is normal on simulator, use real device for testing');
      }
    } catch (e) {
      debugPrint('❌ OneSignal subscription log error: $e');
    }
  }

  void _logPushToken() {
    try {
      final token = OneSignal.User.pushSubscription.token;
      final platform = Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Unknown');
      
      if (token != null && token.isNotEmpty) {
        debugPrint('🔑 [$platform] OneSignal push token: $token');
      } else {
        debugPrint('⚠️ [$platform] OneSignal push token is null or empty');
        if (Platform.isIOS) {
          debugPrint('⚠️ [iOS] Push token is null - this is normal on simulator, use real device for testing');
        }
      }
    } catch (e) {
      debugPrint('❌ OneSignal token log error: $e');
    }
  }
}

