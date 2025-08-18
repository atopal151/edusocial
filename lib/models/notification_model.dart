



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
    /*debugPrint("🔍 === NOTIFICATION DEBUG ===");
    debugPrint("🔍 Notification type: ${json['type']}");
    debugPrint("🔍 Full notification: ${json.toString()}");
    debugPrint("🔍 User data: ${user.toString()}");
    debugPrint("🔍 Answer data: ${answer.toString()}");
    debugPrint("🔍 is_following: ${user['is_following']} (type: ${user['is_following'].runtimeType})");
    debugPrint("🔍 is_following_pending: ${user['is_following_pending']} (type: ${user['is_following_pending'].runtimeType})");
    debugPrint("🔍 is_self: ${user['is_self']}");
    debugPrint("🔍 answer.status: ${answer['status']}");*/

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
    
        // Takip ile ilgili tüm bildirim tiplerini kontrol et
    if (json['type'] == 'follow-join-request' || 
        json['type'] == 'follow-request' ||
        json['type'] == 'user.folow.request' ||
        json['type'] == 'user.follow.request' ||
        json['type'] == 'user.folow.request.accepted' ||
        json['type'] == 'follow-request-accepted' ||
        json['type'] == 'user.folow.start' ||
        json['type'] == 'follow-start') {
      
      bool userIsFollowing = user['is_following'] ?? false;
      bool userIsFollowingPending = user['is_following_pending'] ?? false;
      
      // Status kontrolü ekle - answer objesi içindeki status'u kontrol et
      String answerStatus = answer['status']?.toString().toLowerCase() ?? '';
      //debugPrint("🔍 [FOLLOW NOTIFICATION] Answer Status: $answerStatus");
      
      // Answer status değerine göre durumu belirle
      if (answerStatus == 'accepted') {
        // Status accepted - buton gösterilmez
        isFollowing = true;
        isFollowingPending = false;
        isAccepted = true;
        isRejected = false;
        //debugPrint("🔍   → RESULT: Answer status accepted - buton gösterilmeyecek");
      } else if (answerStatus == 'rejected') {
        // Status rejected - buton gösterilmez
        isFollowing = false;
        isFollowingPending = false;
        isAccepted = false;
        isRejected = true;
       //debugPrint("🔍   → RESULT: Answer status rejected - buton gösterilmeyecek");
      } else if (answerStatus == 'pending') {
        // Status pending - buton gösterilir
        isFollowing = false;
        isFollowingPending = true;
        isAccepted = false;
        isRejected = false;
        //debugPrint("🔍   → RESULT: Answer status pending - buton gösterilecek");
      } else if (json['type'] == 'user.folow.request.accepted' || 
          json['type'] == 'follow-request-accepted') {
        // Takip isteği onaylanmış bildirimi
        isFollowing = true;
        isFollowingPending = false;
        isAccepted = true;
        isRejected = false;
        //debugPrint("🔍   → RESULT: Takip isteği onaylandı");
      } else if (json['type'] == 'user.folow.start' || 
                 json['type'] == 'follow-start') {
        // Direkt takip başladı bildirimi (açık profil)
        isFollowing = true;
        isFollowingPending = false;
        isAccepted = true;
        isRejected = false;
        //debugPrint("🔍   → RESULT: Direkt takip başladı");
      } else {
        // Takip isteği bildirimi (pending)
        if (userIsFollowing) {
          // Kullanıcı zaten takip ediyor
          isFollowing = true;
          isFollowingPending = false;
          isAccepted = true;
          isRejected = false;
          //debugPrint("🔍   → RESULT: Zaten takip ediyor");
        } else if (userIsFollowingPending) {
          // Takip isteği beklemede
          isFollowing = false;
          isFollowingPending = true;
          isAccepted = false;
          isRejected = false;
          //debugPrint("🔍   → RESULT: Takip isteği beklemede");
        } else {
          // Yeni takip isteği
          isFollowing = false;
          isFollowingPending = true;
          isAccepted = false;
          isRejected = false;
          //debugPrint("🔍   → RESULT: Yeni takip isteği");
        }
      }
    
      //debugPrint("🔍 [FOLLOW NOTIFICATION] Final State:");
      //debugPrint("🔍   - isFollowing: $isFollowing");
      //debugPrint("🔍   - isFollowingPending: $isFollowingPending");
      //debugPrint("🔍   - isAccepted: $isAccepted");
      //debugPrint("🔍   - isRejected: $isRejected");
    } else if (json['type'] == 'group-join-request' || json['type'] == 'group-join') {
      // Grup katılma istekleri için answer.status'a göre belirle
      String answerStatus = answer['status']?.toString().toLowerCase() ?? '';
      //debugPrint("🔍 Group join request answer status: $answerStatus");
      
      // Answer status değerine göre durumu belirle
      if (answerStatus == 'accepted') {
        // Status accepted - buton gösterilmez
        isAccepted = true;
        isRejected = false;
        isFollowing = false;
        isFollowingPending = false;
        //debugPrint("🔍   → RESULT: Answer status accepted - buton gösterilmeyecek");
      } else if (answerStatus == 'rejected') {
        // Status rejected - buton gösterilmez
        isAccepted = false;
        isRejected = true;
        isFollowing = false;
        isFollowingPending = false;
        //debugPrint("🔍   → RESULT: Answer status rejected - buton gösterilmeyecek");
      } else if (answerStatus == 'pending') {
        // Status pending - buton gösterilir
        isAccepted = false;
        isRejected = false;
        isFollowing = false;
        isFollowingPending = false;
        //debugPrint("🔍   → RESULT: Answer status pending - buton gösterilecek");
      } else if (answerStatus == 'approved') {
        isAccepted = true;
        isRejected = false;
        isFollowing = false;
        isFollowingPending = false;
        //debugPrint("🔍   → RESULT: Answer status approved");
      } else if (answerStatus == 'rejected') {
        isAccepted = false;
        isRejected = true;
        isFollowing = false;
        isFollowingPending = false;
        //debugPrint("🔍   → RESULT: Answer status rejected");
      } else if (answerStatus == 'pending') {
        isAccepted = false;
        isRejected = false;
        isFollowing = false;
        isFollowingPending = false;
        //debugPrint("🔍   → RESULT: Answer status pending");
      } else {
        // group-join tipinde answer.status yoksa, grup durumuna göre belirle
        if (json['type'] == 'group-join') {
          String groupStatus = group['status']?.toString().toLowerCase() ?? '';
          //debugPrint("🔍 Group status: $groupStatus");
          
          if (groupStatus == 'approved') {
            isAccepted = true;
            isRejected = false;
            //debugPrint("🔍   → RESULT: Group status approved");
          } else if (groupStatus == 'rejected') {
            isAccepted = false;
            isRejected = true;
            //debugPrint("🔍   → RESULT: Group status rejected");
          } else {
            // pending veya diğer durumlar için varsayılan olarak beklemede
            isAccepted = false;
            isRejected = false;
            //debugPrint("🔍   → RESULT: Group status pending/other");
          }
        } else {
          isAccepted = false;
          isRejected = false;
          //debugPrint("🔍   → RESULT: Default group status");
        }
        isFollowing = false;
        isFollowingPending = false;
      }
    } else {
      // Diğer bildirim tipleri için user.is_following kullan
      isFollowing = user['is_following'] ?? false;
      isFollowingPending = user['is_following_pending'] ?? false;
    }

    //debugPrint("🔍 Final values:");
    //debugPrint("🔍   - isFollowing: $isFollowing");
    //debugPrint("🔍   - isFollowingPending: $isFollowingPending");
    //debugPrint("🔍   - isAccepted: $isAccepted");
    //debugPrint("🔍   - senderUserId: $senderUserId");
    //debugPrint("🔍 === END DEBUG ===");

    // isRead alanını kontrol et
    final rawIsRead = json['is_read'];
    final isReadValue = rawIsRead == true || rawIsRead == 1;
    
    //  debugPrint('🔍 === ISREAD DEBUG ===');
    //debugPrint('🔍 Raw is_read value: $rawIsRead (type: ${rawIsRead.runtimeType})');
    //debugPrint('🔍 Parsed isRead: $isReadValue');
    //debugPrint('🔍 Notification ID: ${json['id']}');
    //debugPrint('🔍 Notification Type: ${json['type']}');
    //debugPrint('🔍 ====================');

    return NotificationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      senderUserId: senderUserId,
      userName: userName,
      profileImageUrl: avatarUrl,
      type: json['type'] ?? 'other',
      message: fullData['text'] ?? '',
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: isReadValue,
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
