import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../routes/app_routes.dart';
import '../screens/profile/people_profile_screen.dart';
import '../services/people_profile_services.dart';
import 'notification_renderer.dart';
import 'notification_settings.dart';

class NotificationHandler {
  NotificationHandler({
    required NotificationSettings settings,
    required NotificationRenderer renderer,
  })  : _settings = settings,
        _renderer = renderer;

  final NotificationSettings _settings;
  final NotificationRenderer _renderer;

  Future<void> handleForeground(OSNotification notification) async {
    final data = notification.additionalData ?? <String, dynamic>{};
    final type = _resolveType(data);

    if (!await _settings.shouldShow(type, data)) return;

    final cooldownKey = _settings.buildCooldownKey(type, data);
    if (!_settings.canShow(cooldownKey)) return;

    final title = notification.title ?? 'Notification';
    final message = notification.body ?? '';

    await _render(type, title, message, data);
  }

  Future<void> handleLocal(
    String type,
    String title,
    String message,
    Map<String, dynamic> data,
  ) async {
    if (!await _settings.shouldShow(type, data)) return;

    final cooldownKey = _settings.buildCooldownKey(type, data);
    if (!_settings.canShow(cooldownKey)) return;

    await _render(type, title, message, data);
  }

  void handleClick(OSNotification notification) {
    final data = notification.additionalData ?? <String, dynamic>{};
    debugPrint('🔔 [NotificationHandler] Notification clicked - Data: $data');
    debugPrint('🔔 [NotificationHandler] Notification type: ${_resolveType(data)}');
    _route(data); // async metod ama await etmeden çağırıyoruz
  }

  String _resolveType(Map<String, dynamic> data) {
    String raw = data['type']?.toString() ?? '';
    if (raw.isEmpty && data['data'] != null && data['data'] is Map) {
      raw = data['data']['type']?.toString() ?? '';
    }
    if (raw.isEmpty) {
      final nested = data['notification_data'];
      if (nested is Map && nested['type'] != null) {
        raw = nested['type'].toString();
      }
    }
    if (raw.isNotEmpty) {
      // OneSignal / backend bazen "new_message", "new_group_message" gönderir
      if (raw == 'new_message' || raw == 'message' || raw == 'text') {
        debugPrint('🔍 [NotificationHandler] Type resolved: message');
        return 'message';
      }
      if (raw == 'new_group_message' || raw == 'group_message' || raw == 'group') {
        debugPrint('🔍 [NotificationHandler] Type resolved: group_message');
        return 'group_message';
      }
      debugPrint('🔍 [NotificationHandler] Type resolved (direct): $raw');
      return raw;
    }
    debugPrint('⚠️ [NotificationHandler] Type not found, using default: notification');
    return 'notification';
  }

  /// Recursive olarak post_id'yi bulur
  dynamic _extractPostId(dynamic data, {int depth = 0}) {
    if (depth > 5) return null; // Sonsuz döngüyü önle
    
    if (data == null) return null;
    
    // Eğer Map ise
    if (data is Map) {
      // Direkt post_id veya id kontrolü
      if (data.containsKey('post_id')) {
        return data['post_id'];
      }
      if (data.containsKey('id') && depth == 0) {
        // İlk seviyede id varsa ama post-like/post-comment tipindeyse post_id olabilir
        return data['id'];
      }
      
      // Nested data içinde ara
      if (data.containsKey('data')) {
        final nestedId = _extractPostId(data['data'], depth: depth + 1);
        if (nestedId != null) return nestedId;
      }
      
      // notification_data içinde ara
      if (data.containsKey('notification_data')) {
        final notificationId = _extractPostId(data['notification_data'], depth: depth + 1);
        if (notificationId != null) return notificationId;
      }
      
      // Tüm key'leri kontrol et (deep search)
      for (var value in data.values) {
        final foundId = _extractPostId(value, depth: depth + 1);
        if (foundId != null) return foundId;
      }
    }
    
    // Eğer List ise her elemanı kontrol et
    if (data is List) {
      for (var item in data) {
        final foundId = _extractPostId(item, depth: depth + 1);
        if (foundId != null) return foundId;
      }
    }
    
    return null;
  }

  Future<void> _render(
    String type,
    String title,
    String message,
    Map<String, dynamic> data,
  ) async {
    final avatar = data['avatar']?.toString() ??
        data['sender_avatar']?.toString() ??
        data['group_avatar']?.toString() ??
        '';

    switch (type) {
      case 'message':
        await _renderer.showMessage(
          title: title,
          message: message,
          avatar: avatar,
        );
        break;
      case 'group':
      case 'group_message':
        await _renderer.showGroupMessage(
          title: title,
          message: message,
          avatar: avatar,
        );
        break;
      case 'post-like':
        await _renderer.showPostLike(
          title: title,
          message: message,
          avatar: avatar,
        );
        break;
      case 'post-comment':
        await _renderer.showPostComment(
          title: title,
          message: message,
          avatar: avatar,
        );
        break;
      case 'follow-request':
        await _renderer.showFollowRequest(
          title: title,
          message: message,
          avatar: avatar,
        );
        break;
      default:
        await _renderer.showGeneric(
          title: title,
          message: message,
          avatar: avatar,
        );
    }
  }

  /// Mesaj bildirimi için conversation_id çıkarır (data, data.data, notification_data)
  dynamic _extractConversationId(Map<String, dynamic> data) {
    final id = data['conversation_id'] ?? data['conversationId'];
    if (id != null) return id;
    if (data['data'] is Map) {
      final d = data['data'] as Map;
      final n = d['notification_data'];
      if (n is Map) {
        final cid = n['conversation_id'] ?? n['conversationId'];
        if (cid != null) return cid;
      }
      return d['conversation_id'] ?? d['conversationId'];
    }
    if (data['notification_data'] is Map) {
      final n = data['notification_data'] as Map;
      final full = n['notification_full_data'];
      if (full is Map) {
        final cid = full['conversation_id'] ?? full['conversationId'];
        if (cid != null) return cid;
      }
      return n['conversation_id'] ?? n['conversationId'];
    }
    return null;
  }

  /// Grup mesajı bildirimi için group_id çıkarır (data, data.data, notification_data)
  dynamic _extractGroupId(Map<String, dynamic> data) {
    final id = data['group_id'] ?? data['groupId'];
    if (id != null) return id;
    if (data['data'] is Map) {
      final d = data['data'] as Map;
      final n = d['notification_data'];
      if (n is Map) {
        final gid = n['group_id'] ?? n['groupId'];
        if (gid != null) return gid;
      }
      final gid = d['group_id'] ?? d['groupId'];
      if (gid != null) return gid;
    }
    if (data['notification_data'] is Map) {
      final n = data['notification_data'] as Map;
      final full = n['notification_full_data'];
      if (full is Map) {
        final gid = full['group_id'] ?? full['groupId'];
        if (gid != null) return gid;
      }
      return n['group_id'] ?? n['groupId'];
    }
    return null;
  }

  /// Mesaj bildirimi için sender_id (gönderen kullanıcı id) çıkarır
  dynamic _extractSenderId(Map<String, dynamic> data) {
    final id = data['sender_id'] ?? data['senderId'];
    if (id != null) return id;
    final sender = _extractSenderMap(data);
    if (sender != null) return sender['id'];
    if (data['data'] is Map) {
      final d = data['data'] as Map;
      return d['sender_id'] ?? d['senderId'];
    }
    if (data['notification_data'] is Map) {
      final n = data['notification_data'] as Map;
      return n['sender_id'] ?? n['senderId'];
    }
    return null;
  }

  /// Mesaj bildirimi için sender objesini çıkarır (name, username, avatar_url, is_online, is_verified)
  Map<String, dynamic>? _extractSenderMap(Map<String, dynamic> data) {
    if (data['sender'] is Map) return data['sender'] as Map<String, dynamic>;
    if (data['data'] is Map) {
      final d = data['data'] as Map;
      if (d['sender'] is Map) return d['sender'] as Map<String, dynamic>;
    }
    if (data['notification_data'] is Map) {
      final n = data['notification_data'] as Map;
      if (n['sender'] is Map) return n['sender'] as Map<String, dynamic>;
      final full = n['notification_full_data'];
      if (full is Map && full['user'] is Map) return full['user'] as Map<String, dynamic>;
    }
    return null;
  }

  /// Sender adı: name + surname veya name
  String? _extractSenderName(Map<String, dynamic>? sender, Map<String, dynamic> data) {
    if (sender != null) {
      final name = sender['name']?.toString();
      final surname = sender['surname']?.toString();
      if (name != null && surname != null) return '$name $surname'.trim();
      if (name != null) return name;
    }
    final n = data['sender_name'] ?? data['senderName'];
    if (n != null) return n.toString();
    return null;
  }

  Future<void> _route(Map<String, dynamic> data) async {
    final type = _resolveType(data);

    switch (type) {
      case 'message':
      case 'text':
        // Mesaj bildirimi: sohbet listesine (chat tab) git, sonra ilgili sohbet detayına aç
        final conversationId = _extractConversationId(data);
        final senderId = _extractSenderId(data);
        final sender = _extractSenderMap(data);
        final name = _extractSenderName(sender, data);
        final username = (sender?['username'] ?? data['sender_username'])?.toString() ?? '';
        final avatarUrl = (sender?['avatar_url'] ?? sender?['avatar'])?.toString() ?? '';
        final isOnline = (sender?['is_online'] ?? data['sender_is_online']) == true;
        final isVerified = (sender?['is_verified'] ?? data['sender_is_verified']) == true;

        if (conversationId != null && senderId != null) {
          debugPrint('🔔 [NotificationHandler] Mesaj bildirimi - conversation_id: $conversationId, sender_id: $senderId');
          // Önce ana ekrana git ve chat sekmesini seç (geri basınca sohbet listesine dönülsün)
          Get.offAllNamed(Routes.main, arguments: {'selectedIndex': 3});
          Future.delayed(const Duration(milliseconds: 150), () {
            Get.toNamed(Routes.chatDetail, arguments: {
              'userId': senderId is int ? senderId : int.tryParse(senderId.toString()),
              'conversationId': conversationId,
              'name': name ?? 'Bilinmeyen',
              'username': username,
              'avatarUrl': avatarUrl,
              'isOnline': isOnline,
              'isVerified': isVerified,
            });
          });
        } else {
          debugPrint('❌ [NotificationHandler] Mesaj bildirimi - conversation_id veya sender_id eksik');
          Get.offAllNamed(Routes.main, arguments: {'selectedIndex': 3});
        }
        break;
      case 'group':
      case 'group_message':
        final groupId = _extractGroupId(data) ?? data['group_id'] ?? data['id'];
        if (groupId != null) {
          debugPrint('🔔 [NotificationHandler] Grup mesajı bildirimi - group_id: $groupId');
          Get.offAllNamed(Routes.main, arguments: {'selectedIndex': 3});
          Future.delayed(const Duration(milliseconds: 150), () {
            Get.toNamed(Routes.groupChatDetail, arguments: {'groupId': groupId});
          });
        } else {
          debugPrint('❌ [NotificationHandler] Grup mesajı - group_id eksik');
          Get.offAllNamed(Routes.main, arguments: {'selectedIndex': 3});
        }
        break;
      case 'post-like':
      case 'post-comment':
        // Post ID'yi farklı yerlerden kontrol et
        // Önce direkt kontrol et
        var postId = data['post_id'] ?? data['id'];
        
        // data.data.post_id kontrolü (OneSignal formatı)
        if (postId == null && data['data'] != null) {
          final data1 = data['data'];
          if (data1 is Map) {
            postId = data1['post_id'] ?? data1['id'];
            
            // data.data.data.post_id kontrolü (daha nested)
            if (postId == null && data1['data'] != null) {
              final data2 = data1['data'];
              if (data2 is Map) {
                postId = data2['post_id'] ?? data2['id'];
              }
            }
          }
        }
        
        // Recursive fallback
        if (postId == null) {
          postId = _extractPostId(data);
        }
        
        if (postId != null) {
          debugPrint('🔔 [NotificationHandler] Post bildirimi tıklandı - Post ID: $postId');
          Get.toNamed('/post_detail', arguments: {'post_id': postId.toString()});
        } else {
          debugPrint('❌ [NotificationHandler] Post ID bulunamadı - Data: $data');
          // Post ID bulunamazsa ana sayfaya yönlendir
          Get.toNamed('/home');
        }
        break;
      case 'follow-request':
      case 'follow-request-accepted':
      case 'user.folow.start':
      case 'follow-start':
      case 'follow-join-request':
        // Username'i bul ve profil sayfasına yönlendir
        debugPrint('🔔 [NotificationHandler] Takip bildirimi işleniyor - Type: $type');
        debugPrint('🔔 [NotificationHandler] Data yapısı: $data');
        
        // Önce username'i direkt bulmaya çalış (basit kontrol)
        String? username = _extractUsernameSimple(data);
        debugPrint('🔔 [NotificationHandler] Basit username kontrolü sonucu: $username');
        
        // Username bulunamazsa user_id'den çek
        if (username == null || username.isEmpty) {
          final userId = _extractUserId(data);
          if (userId != null) {
            debugPrint('🔔 [NotificationHandler] Username bulunamadı, user_id\'den çekiliyor: $userId');
            try {
              final userProfile = await PeopleProfileService.fetchUserById(userId);
              if (userProfile != null && userProfile.username.isNotEmpty) {
                username = userProfile.username;
                debugPrint('✅ [NotificationHandler] Username user_id\'den çekildi: $username');
              }
            } catch (e) {
              debugPrint('❌ [NotificationHandler] User_id\'den username çekilemedi: $e');
            }
          }
        }
        
        if (username != null && username.isNotEmpty) {
          debugPrint('✅ [NotificationHandler] Takip isteği bildirimi - Username: $username');
          try {
            Get.to(() => PeopleProfileScreen(username: username!));
            debugPrint('✅ [NotificationHandler] PeopleProfileScreen açıldı');
          } catch (e) {
            debugPrint('❌ [NotificationHandler] PeopleProfileScreen açılırken hata: $e');
            Get.toNamed('/home');
          }
        } else {
          debugPrint('❌ [NotificationHandler] Username bulunamadı - Data: $data');
          debugPrint('❌ [NotificationHandler] Data keys: ${data.keys.toList()}');
          Get.toNamed('/home');
        }
        break;
      default:
        // type "notification" veya bilinmeyen: payload'dan mesaj/grup mesajı olup olmadığını tahmin et
        final groupId = _extractGroupId(data);
        final conversationId = _extractConversationId(data);
        final senderId = _extractSenderId(data);
        if (groupId != null) {
          debugPrint('🔔 [NotificationHandler] Varsayılan - grup mesajı olarak yönlendiriliyor: $groupId');
          Get.offAllNamed(Routes.main, arguments: {'selectedIndex': 3});
          Future.delayed(const Duration(milliseconds: 150), () {
            Get.toNamed(Routes.groupChatDetail, arguments: {'groupId': groupId});
          });
        } else if (conversationId != null && senderId != null) {
          final sender = _extractSenderMap(data);
          final name = _extractSenderName(sender, data);
          final username = (sender?['username'] ?? data['sender_username'])?.toString() ?? '';
          final avatarUrl = (sender?['avatar_url'] ?? sender?['avatar'])?.toString() ?? '';
          final isOnline = (sender?['is_online'] ?? data['sender_is_online']) == true;
          final isVerified = (sender?['is_verified'] ?? data['sender_is_verified']) == true;
          debugPrint('🔔 [NotificationHandler] Varsayılan - özel mesaj olarak yönlendiriliyor');
          Get.offAllNamed(Routes.main, arguments: {'selectedIndex': 3});
          Future.delayed(const Duration(milliseconds: 150), () {
            Get.toNamed(Routes.chatDetail, arguments: {
              'userId': senderId is int ? senderId : int.tryParse(senderId.toString()),
              'conversationId': conversationId,
              'name': name ?? 'Bilinmeyen',
              'username': username,
              'avatarUrl': avatarUrl,
              'isOnline': isOnline,
              'isVerified': isVerified,
            });
          });
        } else {
          Get.toNamed('/home');
        }
    }
  }

  /// Recursive olarak username'i bulur
  String? _extractUsername(dynamic data, {int depth = 0}) {
    if (depth > 5) {
      debugPrint('⚠️ [NotificationHandler] _extractUsername: Max depth reached');
      return null; // Sonsuz döngüyü önle
    }
    
    if (data == null) return null;
    
    // Eğer Map ise
    if (data is Map) {
      // Direkt username kontrolü
      if (data.containsKey('username')) {
        final username = data['username']?.toString();
        if (username != null && username.isNotEmpty) {
          debugPrint('✅ [NotificationHandler] Username bulundu (direct): $username');
          return username;
        }
      }
      
      // user objesi içinde username kontrolü
      if (data.containsKey('user')) {
        final user = data['user'];
        if (user is Map) {
          final username = user['username']?.toString();
          if (username != null && username.isNotEmpty) {
            debugPrint('✅ [NotificationHandler] Username bulundu (user): $username');
            return username;
          }
        }
      }
      
      // notification_full_data içinde user kontrolü
      if (data.containsKey('notification_full_data')) {
        final fullData = data['notification_full_data'];
        if (fullData is Map) {
          final user = fullData['user'];
          if (user is Map) {
            final username = user['username']?.toString();
            if (username != null && username.isNotEmpty) {
              debugPrint('✅ [NotificationHandler] Username bulundu (notification_full_data.user): $username');
              return username;
            }
          }
        }
      }
      
      // Nested data içinde ara
      if (data.containsKey('data')) {
        final nestedUsername = _extractUsername(data['data'], depth: depth + 1);
        if (nestedUsername != null) {
          debugPrint('✅ [NotificationHandler] Username bulundu (nested data): $nestedUsername');
          return nestedUsername;
        }
      }
      
      // notification_data içinde ara
      if (data.containsKey('notification_data')) {
        final notificationUsername = _extractUsername(data['notification_data'], depth: depth + 1);
        if (notificationUsername != null) {
          debugPrint('✅ [NotificationHandler] Username bulundu (notification_data): $notificationUsername');
          return notificationUsername;
        }
      }
      
      // Tüm key'leri kontrol et (deep search)
      for (var entry in data.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        // Sadece ilgili key'leri kontrol et (performans için)
        if (key.contains('user') || key.contains('data') || key.contains('notification')) {
          final foundUsername = _extractUsername(value, depth: depth + 1);
          if (foundUsername != null) {
            debugPrint('✅ [NotificationHandler] Username bulundu (deep search, key: $key): $foundUsername');
            return foundUsername;
          }
        }
      }
    }
    
    // Eğer List ise her elemanı kontrol et
    if (data is List) {
      for (var item in data) {
        final foundUsername = _extractUsername(item, depth: depth + 1);
        if (foundUsername != null) return foundUsername;
      }
    }
    
    return null;
  }

  /// Basit username çıkarma (recursive değil, sadece direkt yolları kontrol eder)
  String? _extractUsernameSimple(Map<String, dynamic> data) {
    // Direkt username kontrolü
    if (data.containsKey('username')) {
      final username = data['username']?.toString();
      if (username != null && username.isNotEmpty) {
        return username;
      }
    }
    
    // data.data.notification_data.user_id kontrolü (OneSignal formatı)
    if (data.containsKey('data')) {
      final data1 = data['data'];
      if (data1 is Map) {
        // data.data.notification_data kontrolü
        if (data1.containsKey('notification_data')) {
          final notificationData = data1['notification_data'];
          if (notificationData is Map) {
            // notification_data.user kontrolü
            if (notificationData.containsKey('user')) {
              final user = notificationData['user'];
              if (user is Map && user.containsKey('username')) {
                final username = user['username']?.toString();
                if (username != null && username.isNotEmpty) {
                  return username;
                }
              }
            }
            // notification_data.notification_full_data.user kontrolü
            if (notificationData.containsKey('notification_full_data')) {
              final fullData = notificationData['notification_full_data'];
              if (fullData is Map && fullData.containsKey('user')) {
                final user = fullData['user'];
                if (user is Map && user.containsKey('username')) {
                  final username = user['username']?.toString();
                  if (username != null && username.isNotEmpty) {
                    return username;
                  }
                }
              }
            }
          }
        }
        
        // data.data.data.notification_data kontrolü (daha nested)
        if (data1.containsKey('data')) {
          final data2 = data1['data'];
          if (data2 is Map && data2.containsKey('notification_data')) {
            final notificationData = data2['notification_data'];
            if (notificationData is Map) {
              if (notificationData.containsKey('user')) {
                final user = notificationData['user'];
                if (user is Map && user.containsKey('username')) {
                  final username = user['username']?.toString();
                  if (username != null && username.isNotEmpty) {
                    return username;
                  }
                }
              }
            }
          }
        }
      }
    }
    
    // notification_data kontrolü
    if (data.containsKey('notification_data')) {
      final notificationData = data['notification_data'];
      if (notificationData is Map) {
        if (notificationData.containsKey('user')) {
          final user = notificationData['user'];
          if (user is Map && user.containsKey('username')) {
            final username = user['username']?.toString();
            if (username != null && username.isNotEmpty) {
              return username;
            }
          }
        }
      }
    }
    
    return null;
  }

  /// User ID'yi çıkarır (takip isteği gönderen kişinin ID'si)
  /// ÖNEMLİ: receiver_id değil, gönderen kişinin user_id'si alınmalı
  int? _extractUserId(Map<String, dynamic> data) {
    debugPrint('🔍 [NotificationHandler] _extractUserId başlatıldı');
    
    // Öncelik sırası:
    // 1. data.data.notification_data.user_id (OneSignal formatı - gönderen kişi)
    if (data.containsKey('data')) {
      final data1 = data['data'];
      if (data1 is Map) {
        // data.data.notification_data.user_id kontrolü
        if (data1.containsKey('notification_data')) {
          final notificationData = data1['notification_data'];
          if (notificationData is Map && notificationData.containsKey('user_id')) {
            final userId = notificationData['user_id'];
            if (userId != null) {
              final id = int.tryParse(userId.toString());
              debugPrint('✅ [NotificationHandler] User ID bulundu (data.data.notification_data.user_id): $id');
              return id;
            }
          }
        }
        
        // data.data.data.notification_data.user_id kontrolü (daha nested)
        if (data1.containsKey('data')) {
          final data2 = data1['data'];
          if (data2 is Map) {
            // data.data.data.notification_data.user_id kontrolü
            if (data2.containsKey('notification_data')) {
              final notificationData = data2['notification_data'];
              if (notificationData is Map && notificationData.containsKey('user_id')) {
                final userId = notificationData['user_id'];
                if (userId != null) {
                  final id = int.tryParse(userId.toString());
                  debugPrint('✅ [NotificationHandler] User ID bulundu (data.data.data.notification_data.user_id): $id');
                  return id;
                }
              }
            }
            
            // data.data.data.user_id kontrolü - BU YANLIŞ OLABİLİR (receiver olabilir)
            // Bu kontrolü atlıyoruz çünkü bu receiver_id olabilir
          }
        }
      }
    }
    
    // notification_data.user_id kontrolü
    if (data.containsKey('notification_data')) {
      final notificationData = data['notification_data'];
      if (notificationData is Map && notificationData.containsKey('user_id')) {
        final userId = notificationData['user_id'];
        if (userId != null) {
          final id = int.tryParse(userId.toString());
          debugPrint('✅ [NotificationHandler] User ID bulundu (notification_data.user_id): $id');
          return id;
        }
      }
    }
    
    // Direkt user_id kontrolü - BU YANLIŞ OLABİLİR (receiver olabilir)
    // Bu kontrolü atlıyoruz çünkü bu receiver_id olabilir
    
    debugPrint('❌ [NotificationHandler] User ID bulunamadı');
    return null;
  }
}

