import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  static const Duration _cooldown = Duration(seconds: 10);

  final Map<String, DateTime> _lastShown = {};

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Map<String, bool>> getPreferences() async {
    final prefs = await _prefs;
    return {
      'post_notifications': prefs.getBool('post_notifications') ?? true,
      'message_notifications': prefs.getBool('message_notifications') ?? true,
      'group_notifications': prefs.getBool('group_notifications') ?? true,
      'event_notifications': prefs.getBool('event_notifications') ?? true,
      'follow_notifications': prefs.getBool('follow_notifications') ?? true,
      'system_notifications': prefs.getBool('system_notifications') ?? true,
    };
  }

  Future<void> updatePreferences({
    required bool postNotifications,
    required bool messageNotifications,
    required bool groupNotifications,
    required bool eventNotifications,
    required bool followNotifications,
    required bool systemNotifications,
  }) async {
    final prefs = await _prefs;
    await prefs.setBool('post_notifications', postNotifications);
    await prefs.setBool('message_notifications', messageNotifications);
    await prefs.setBool('group_notifications', groupNotifications);
    await prefs.setBool('event_notifications', eventNotifications);
    await prefs.setBool('follow_notifications', followNotifications);
    await prefs.setBool('system_notifications', systemNotifications);
  }

  Future<bool> shouldShow(String type, Map<String, dynamic>? data) async {
    final prefs = await _prefs;

    switch (type) {
      case 'message':
        if (!(prefs.getBool('message_notifications') ?? true)) return false;
        final conversationId = data?['conversation_id']?.toString();
        if (conversationId != null &&
            (prefs.getBool('private_chat_muted_$conversationId') ?? false)) {
          return false;
        }
        return true;
      case 'group':
      case 'group_message':
        if (!(prefs.getBool('group_notifications') ?? true)) return false;
        final groupId = data?['group_id']?.toString();
        if (groupId != null &&
            (prefs.getBool('group_muted_$groupId') ?? false)) {
          return false;
        }
        return true;
      case 'post-like':
      case 'post-comment':
        return prefs.getBool('post_notifications') ?? true;
      case 'follow-request':
        return prefs.getBool('follow_notifications') ?? true;
      default:
        return prefs.getBool('system_notifications') ?? true;
    }
  }

  String buildCooldownKey(String type, Map<String, dynamic>? data) {
    final id = data?['id']?.toString() ??
        data?['conversation_id']?.toString() ??
        data?['group_id']?.toString() ??
        '';
    return '$type-$id';
  }

  bool canShow(String key) {
    final now = DateTime.now();
    final last = _lastShown[key];
    if (last != null && now.difference(last) < _cooldown) {
      return false;
    }
    _lastShown[key] = now;
    return true;
  }

  Future<void> muteGroup(String groupId) async {
    final prefs = await _prefs;
    await prefs.setBool('group_muted_$groupId', true);
  }

  Future<void> unmuteGroup(String groupId) async {
    final prefs = await _prefs;
    await prefs.setBool('group_muted_$groupId', false);
  }

  Future<bool> isGroupMuted(String groupId) async {
    final prefs = await _prefs;
    return prefs.getBool('group_muted_$groupId') ?? false;
  }

  Future<void> mutePrivateChat(String conversationId) async {
    final prefs = await _prefs;
    await prefs.setBool('private_chat_muted_$conversationId', true);
  }

  Future<void> unmutePrivateChat(String conversationId) async {
    final prefs = await _prefs;
    await prefs.setBool('private_chat_muted_$conversationId', false);
  }

  Future<bool> isPrivateChatMuted(String conversationId) async {
    final prefs = await _prefs;
    return prefs.getBool('private_chat_muted_$conversationId') ?? false;
  }
}

