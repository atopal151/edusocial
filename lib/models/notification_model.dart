




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
  final Map<String, dynamic>? postData;
  final String? postId;

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
    this.postData,
    this.postId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final fullData = json['notification_full_data'] ?? {};
    final user = fullData['user'] ?? {};
    final group = fullData['group'] ?? {};
    final data = json['data'] ?? {};
    final eventData = data['data'] ?? {};
    final answer = fullData['answer'] ?? {};
 

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
      
      // Answer status değerine göre durumu belirle
      if (answerStatus == 'accepted') {
        // Status accepted - buton gösterilmez
        isFollowing = true;
        isFollowingPending = false;
        isAccepted = true;
        isRejected = false; 
      } else if (answerStatus == 'rejected') {
        // Status rejected - buton gösterilmez
        isFollowing = false;
        isFollowingPending = false;
        isAccepted = false;
        isRejected = true; 
      } else if (answerStatus == 'pending') {
        // Status pending - buton gösterilir
        isFollowing = false;
        isFollowingPending = true;
        isAccepted = false;
        isRejected = false; 
      } else if (json['type'] == 'user.folow.request.accepted' || 
          json['type'] == 'follow-request-accepted') {
        // Takip isteği onaylanmış bildirimi
        isFollowing = true;
        isFollowingPending = false;
        isAccepted = true;
        isRejected = false; 
      } else if (json['type'] == 'user.folow.start' || 
                 json['type'] == 'follow-start') {
        // Direkt takip başladı bildirimi (açık profil)
        isFollowing = true;
        isFollowingPending = false;
        isAccepted = true;
        isRejected = false; 
      } else {
        // Takip isteği bildirimi (pending)
        if (userIsFollowing) {
          // Kullanıcı zaten takip ediyor
          isFollowing = true;
          isFollowingPending = false;
          isAccepted = true;
          isRejected = false; 
        } else if (userIsFollowingPending) {
          // Takip isteği beklemede
          isFollowing = false;
          isFollowingPending = true;
          isAccepted = false;
          isRejected = false; 
        } else {
          // Yeni takip isteği
          isFollowing = false;
          isFollowingPending = true;
          isAccepted = false;
          isRejected = false; 
        }
      }
     
    } else if (json['type'] == 'group-join-request' || json['type'] == 'group-join') {
      // Grup katılma istekleri için answer.status'a göre belirle
      String answerStatus = answer['status']?.toString().toLowerCase() ?? ''; 
      
      // Answer status değerine göre durumu belirle
      if (answerStatus == 'accepted') {
        // Status accepted - buton gösterilmez
        isAccepted = true;
        isRejected = false;
        isFollowing = false;
        isFollowingPending = false; 
      } else if (answerStatus == 'rejected') {
        // Status rejected - buton gösterilmez
        isAccepted = false;
        isRejected = true;
        isFollowing = false;
        isFollowingPending = false; 
      } else if (answerStatus == 'pending') {
        // Status pending - buton gösterilir
        isAccepted = false;
        isRejected = false;
        isFollowing = false;
        isFollowingPending = false; 
      } else if (answerStatus == 'approved') {
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


    // isRead alanını kontrol et
    final rawIsRead = json['is_read'];
    final isReadValue = rawIsRead == true || rawIsRead == 1;
    
    // Post bilgilerini al
    final post = fullData['post'] ?? {};
    Map<String, dynamic>? postDataMap;
    String? postIdValue;
    if (post.isNotEmpty && post is Map) {
      postDataMap = Map<String, dynamic>.from(post);
      // Post ID'sini al
      if (post['id'] != null) {
        postIdValue = post['id'].toString();
      }
    }
    
    // Eğer post ID postData'da yoksa, eventData'dan al
    if (postIdValue == null && eventData['post_id'] != null) {
      postIdValue = eventData['post_id'].toString();
    }

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
      postData: postDataMap,
      postId: postIdValue,
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
      'postData': postData,
      'postId': postId,
    };
  }
}
