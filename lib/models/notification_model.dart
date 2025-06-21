import 'package:flutter/foundation.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String senderUserId;
  final String userName;
  final String profileImageUrl;
  final String type;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? groupId;
  final String? eventId;
  final String? groupName;
  final bool isAccepted;
  final bool isFollowing;
  final bool isFollowingPending;
  final bool isRejected;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.senderUserId,
    required this.userName,
    required this.profileImageUrl,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.groupId,
    this.eventId,
    this.groupName,
    this.isAccepted = false,
    this.isFollowing = false,
    this.isFollowingPending = false,
    this.isRejected = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final fullData = json['notification_full_data'] ?? {};
    final user = fullData['user'] ?? {};
    final group = fullData['group'] ?? {};
    final data = json['data'] ?? {};
    final eventData = data['data'] ?? {};
    final answer = fullData['answer'] ?? {};

    // Debug için API yanıtını logla
    //debugPrint("🔍 === NOTIFICATION DEBUG ===");
    //debugPrint("🔍 Notification type: ${json['type']}");
    //debugPrint("🔍 Full notification: ${json.toString()}");
    //debugPrint("🔍 User data: ${user.toString()}");
    //debugPrint("🔍 Answer data: ${answer.toString()}");
    //debugPrint("🔍 is_following: ${user['is_following']} (type: ${user['is_following'].runtimeType})");
    //debugPrint("🔍 is_following_pending: ${user['is_following_pending']} (type: ${user['is_following_pending'].runtimeType})");
    //debugPrint("🔍 is_self: ${user['is_self']}");
    //debugPrint("🔍 answer.status: ${answer['status']}");

    // Kullanıcı adını belirle
    String userName = 'Kullanıcı';
    if (user['username'] != null && user['username'].toString().isNotEmpty) {
      userName = user['username'];
    } else if (user['name'] != null && user['surname'] != null) {
      userName = '${user['name']} ${user['surname']}';
    }

    // Avatar URL'ini belirle
    String avatarUrl = '';
    if (user['avatar_url'] != null && user['avatar_url'].toString().isNotEmpty) {
      avatarUrl = user['avatar_url'];
    } else if (user['avatar'] != null && user['avatar'].toString().isNotEmpty) {
      avatarUrl = 'https://stageapi.edusocial.pl/storage/${user['avatar']}';
    }

    // Grup ID'sini belirle
    String? groupId;
    if (group['id'] != null) {
      groupId = group['id'].toString();
    } else if (fullData['group_id'] != null) {
      groupId = fullData['group_id'].toString();
    }

    // Grup adını belirle
    String? groupName;
    if (group['name'] != null) {
      groupName = group['name'];
    } else if (fullData['group_name'] != null) {
      groupName = fullData['group_name'];
    }

    // Event ID'sini belirle
    String? eventId;
    if (fullData['event_id'] != null) {
      eventId = fullData['event_id'].toString();
    }

    // İsteği gönderen kullanıcının ID'sini belirle
    String senderUserId = '';
    if (eventData['user_id'] != null) {
      senderUserId = eventData['user_id'].toString();
    } else if (user['id'] != null) {
      senderUserId = user['id'].toString();
    }

    // Takip durumlarını belirle - answer.status'a göre
    bool isFollowing = false;
    bool isFollowingPending = false;
    bool isAccepted = false;
    bool isRejected = false;
    
    if (json['type'] == 'follow-join-request' || json['type'] == 'follow-request') {
      String answerStatus = answer['status']?.toString().toLowerCase() ?? '';
      bool userIsFollowing = user['is_following'] ?? false;
      bool userIsFollowingPending = user['is_following_pending'] ?? false;
      String text = fullData['text']?.toString() ?? '';
      
      //debugPrint("🔍 Answer status: $answerStatus");
      //debugPrint("🔍 User is_following: $userIsFollowing");
      //debugPrint("🔍 User is_following_pending: $userIsFollowingPending");
      //debugPrint("🔍 Text: $text");
      
      // Mantık: Eğer user.is_following true ise, kullanıcıyı takip ediyoruz
      // Eğer user.is_following_pending true ise, takip isteği beklemede
      // Eğer ikisi de false ise, takip etmiyoruz
      
      if (userIsFollowing) {
        isFollowing = true;
        isFollowingPending = false;
        isAccepted = true;
      } else if (userIsFollowingPending) {
        isFollowing = false;
        isFollowingPending = true;
        isAccepted = false;
      } else {
        isFollowing = false;
        isFollowingPending = false;
        isAccepted = false;
      }
    } else if (json['type'] == 'group-join-request' || json['type'] == 'group-join') {
      // Grup katılma istekleri için answer.status'a göre belirle
      String answerStatus = answer['status']?.toString().toLowerCase() ?? '';
      debugPrint("🔍 Group join request answer status: $answerStatus");
      
      if (answerStatus == 'approved') {
        isAccepted = true;
        isRejected = false;
        isFollowing = false;
        isFollowingPending = false;
      } else if (answerStatus == 'rejected') {
        isAccepted = false;
        isRejected = true;
        isFollowing = false;
        isFollowingPending = false;
      } else if (answerStatus == 'pending') {
        isAccepted = false;
        isRejected = false;
        isFollowing = false;
        isFollowingPending = false;
      } else {
        // group-join tipinde answer.status yoksa, grup durumuna göre belirle
        if (json['type'] == 'group-join') {
          String groupStatus = group['status']?.toString().toLowerCase() ?? '';
          debugPrint("🔍 Group status: $groupStatus");
          
          if (groupStatus == 'approved') {
            isAccepted = true;
            isRejected = false;
          } else if (groupStatus == 'rejected') {
            isAccepted = false;
            isRejected = true;
          } else {
            // pending veya diğer durumlar için varsayılan olarak beklemede
            isAccepted = false;
            isRejected = false;
          }
        } else {
          isAccepted = false;
          isRejected = false;
        }
        isFollowing = false;
        isFollowingPending = false;
      }
    } else {
      // Diğer bildirim tipleri için user.is_following kullan
      isFollowing = user['is_following'] ?? false;
      isFollowingPending = user['is_following_pending'] ?? false;
    }
    
    bool isSelf = user['is_self'] ?? false;

    //debugPrint("🔍 Final values:");
    //debugPrint("🔍   - isFollowing: $isFollowing");
    //debugPrint("🔍   - isFollowingPending: $isFollowingPending");
    //debugPrint("🔍   - isAccepted: $isAccepted");
    //debugPrint("🔍   - isSelf: $isSelf");
    //debugPrint("🔍   - senderUserId: $senderUserId");
    //debugPrint("🔍 === END DEBUG ===");

    return NotificationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      senderUserId: senderUserId,
      userName: userName,
      profileImageUrl: avatarUrl,
      type: json['type'] ?? 'other',
      message: fullData['text'] ?? '',
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      groupId: groupId,
      eventId: eventId,
      groupName: groupName,
      isAccepted: isAccepted,
      isFollowing: isFollowing,
      isFollowingPending: isFollowingPending,
      isRejected: isRejected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'senderUserId': senderUserId,
      'userName': userName,
      'profileImageUrl': profileImageUrl,
      'type': type,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'groupId': groupId,
      'eventId': eventId,
      'groupName': groupName,
      'isAccepted': isAccepted,
      'isFollowing': isFollowing,
      'isFollowingPending': isFollowingPending,
      'isRejected': isRejected,
    };
  }
}
