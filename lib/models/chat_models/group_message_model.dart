enum GroupMessageType { text, image, link, poll, document, textWithLinks, survey }

class GroupMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final GroupMessageType messageType;
  final DateTime timestamp;
  final bool isSentByMe;
  final bool isVerified;
  final List<String>? pollOptions;
  final String? additionalText;
  final String name;
  final String surname;
  final String username;
  final String profileImage;
  final List<String>? links;
  final List<String>? media; // Media dosyaları için
  final bool? isMultipleChoice;
  final int? surveyId;
  final List<int>? choiceIds;
  final Map<String, dynamic>? surveyData;
  final bool isPinned; // Pin durumu için field ekle
  /// Yanıtlanan mesajın ID'si (reply)
  final String? replyId;
  /// Yanıtlanan mesajın metni (API'dan dönerse)
  final String? replyMessageText;
  /// Yanıtlanan mesajın gönderen adı
  final String? replyMessageSenderName;
  /// Yanıtlanan mesaj görsel içeriyor mu — önizlemede "Fotoğraf" göstermek için
  final bool replyHasImageMedia;
  /// Yanıtlanan mesaj link içeriyor mu — önizlemede "Link" göstermek için
  final bool replyHasLinkMedia;

  GroupMessageModel({
    required this.id,
    required this.senderId,
    required this.name,
    required this.surname,
    required this.username,
    required this.profileImage,
    required this.receiverId,
    required this.content,
    required this.messageType,
    required this.timestamp,
    required this.isSentByMe,
    this.isVerified = false,
    this.pollOptions,
    this.additionalText,
    this.links,
    this.media,
    this.isMultipleChoice,
    this.surveyId,
    this.choiceIds,
    this.surveyData,
    this.isPinned = false,
    this.replyId,
    this.replyMessageText,
    this.replyMessageSenderName,
    this.replyHasImageMedia = false,
    this.replyHasLinkMedia = false,
  });

  // Create a copy with updated pin status
  GroupMessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    GroupMessageType? messageType,
    DateTime? timestamp,
    bool? isSentByMe,
    bool? isVerified,
    List<String>? pollOptions,
    String? additionalText,
    String? name,
    String? surname,
    String? username,
    String? profileImage,
    List<String>? links,
    List<String>? media,
    bool? isMultipleChoice,
    int? surveyId,
    List<int>? choiceIds,
    Map<String, dynamic>? surveyData,
    bool? isPinned,
    String? replyId,
    String? replyMessageText,
    String? replyMessageSenderName,
    bool? replyHasImageMedia,
    bool? replyHasLinkMedia,
  }) {
    return GroupMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      isVerified: isVerified ?? this.isVerified,
      pollOptions: pollOptions ?? this.pollOptions,
      additionalText: additionalText ?? this.additionalText,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      links: links ?? this.links,
      media: media ?? this.media,
      isMultipleChoice: isMultipleChoice ?? this.isMultipleChoice,
      surveyId: surveyId ?? this.surveyId,
      choiceIds: choiceIds ?? this.choiceIds,
      surveyData: surveyData ?? this.surveyData,
      isPinned: isPinned ?? this.isPinned,
      replyId: replyId ?? this.replyId,
      replyMessageText: replyMessageText ?? this.replyMessageText,
      replyMessageSenderName: replyMessageSenderName ?? this.replyMessageSenderName,
      replyHasImageMedia: replyHasImageMedia ?? this.replyHasImageMedia,
      replyHasLinkMedia: replyHasLinkMedia ?? this.replyHasLinkMedia,
    );
  }

  /// Yanıt önizlemesi için metin (metin, görsel, link, belge)
  String get replyPreviewDisplayText {
    final text = (content).trim();
    if (text.isNotEmpty) {
      return text.length > 40 ? '${text.substring(0, 40)}...' : text;
    }
    if (messageType == GroupMessageType.image || (media?.isNotEmpty ?? false)) return '📷 Photo';
    if (messageType == GroupMessageType.link || (links?.isNotEmpty ?? false)) return '🔗 Link';
    if (messageType == GroupMessageType.document) return '📎 Document';
    return 'Media';
  }

  /// Yanıt önizlemesinde gösterilecek görsel URL (varsa)
  String? get replyPreviewImageUrl {
    if (media != null && media!.isNotEmpty) return media!.first;
    return null;
  }

  // Factory constructor to create GroupMessageModel from JSON
  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    // Determine message type
    GroupMessageType messageType = GroupMessageType.text;
    if (json['type'] == 'poll') {
      messageType = GroupMessageType.poll;
    } else if (json['type'] == 'survey') {
      messageType = GroupMessageType.survey;
    } else if (json['media'] != null && (json['media'] as List).isNotEmpty) {
      if (json['content']?.toString().isNotEmpty == true) {
        messageType = GroupMessageType.textWithLinks;
      } else {
        messageType = GroupMessageType.image;
      }
    } else if (json['links'] != null && (json['links'] as List).isNotEmpty) {
      messageType = GroupMessageType.link;
    } else if (json['document'] != null) {
      messageType = GroupMessageType.document;
    }

    // Parse timestamp
    final timestamp = json['created_at'] != null 
        ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
        : DateTime.now();

    // Parse poll options
    List<String>? pollOptions;
    if (json['poll_options'] != null) {
      pollOptions = List<String>.from(json['poll_options']);
    }

    // Parse links
    List<String>? links;
    if (json['links'] != null) {
      links = List<String>.from(json['links']);
    }

    // Parse media
    List<String>? media;
    if (json['media'] != null) {
      media = List<String>.from(json['media']);
    }

    // Parse survey data
    Map<String, dynamic>? surveyData;
    if (json['survey'] != null) {
      surveyData = Map<String, dynamic>.from(json['survey']);
    }

    // Parse isPinned status
    final bool isPinned = json['is_pinned'] == true;

    // Reply (yanıt) bilgisi
    final replyId = json['reply_id'] != null ? json['reply_id'].toString() : null;
    String? replyMessageText;
    String? replyMessageSenderName;
    bool replyHasImageMedia = false;
    bool replyHasLinkMedia = false;
    final replyMessage = json['reply_message'] ?? json['reply'];
    if (replyMessage is Map<String, dynamic>) {
      replyMessageText = replyMessage['content']?.toString() ?? replyMessage['message']?.toString();
      final replySender = replyMessage['sender'];
      if (replySender is Map<String, dynamic>) {
        replyMessageSenderName = replySender['name']?.toString();
      }
      final replyMedia = replyMessage['media'] as List<dynamic>?;
      if (replyMedia != null && replyMedia.isNotEmpty) {
        replyHasImageMedia = true;
      }
      final replyLinks = replyMessage['links'] as List<dynamic>? ?? replyMessage['group_chat_link'] as List<dynamic>? ?? replyMessage['message_link'] as List<dynamic>?;
      if (replyLinks != null && replyLinks.isNotEmpty) {
        replyHasLinkMedia = true;
      }
    }

    // Sender bilgisi (doğrulama için)
    final Map<String, dynamic>? sender =
        json['sender'] != null ? Map<String, dynamic>.from(json['sender']) : null;

    return GroupMessageModel(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['group_id']?.toString() ?? '',
      content: json['content'] ?? json['message'] ?? '',
      messageType: messageType,
      timestamp: timestamp,
      isSentByMe: json['is_sent_by_me'] == true || json['is_me'] == true,
      isVerified: _computeIsVerified(sender ?? json),
      pollOptions: pollOptions,
      additionalText: json['additional_text'],
      name: json['sender']?['name'] ?? json['name'] ?? '',
      surname: json['sender']?['surname'] ?? json['surname'] ?? '',
      username: json['sender']?['username'] ?? json['username'] ?? '',
      profileImage: json['sender']?['avatar_url'] ?? json['profile_image'] ?? '',
      links: links,
      media: media,
      isMultipleChoice: json['is_multiple_choice'],
      surveyId: json['survey_id'],
      choiceIds: json['choice_ids'] != null ? List<int>.from(json['choice_ids']) : null,
      surveyData: surveyData,
      isPinned: isPinned,
      replyId: replyId,
      replyMessageText: replyMessageText,
      replyMessageSenderName: replyMessageSenderName,
      replyHasImageMedia: replyHasImageMedia,
      replyHasLinkMedia: replyHasLinkMedia,
    );
  }

  // Değişken tipte gelebilen doğrulama alanlarını güvenle bool'a çevirir
  static bool _computeIsVerified(Map<String, dynamic> source) {
    bool? pick(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value == 1;
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true' || lower == '1') return true;
        if (lower == 'false' || lower == '0') return false;
      }
      return null;
    }

    final candidates = [
      pick(source['is_verified']),
      pick(source['verified']),
      pick(source['account_verified']),
      pick(source['document_verified']),
      pick(source['identity_verified']),
    ];

    final status = source['verification_status']?.toString().toLowerCase();
    final level = source['verification_level']?.toString().toLowerCase();
    final type = source['verification_type']?.toString().toLowerCase();
    final stringVerified =
        status == 'verified' || level == 'verified' || type == 'verified';

    for (final val in candidates) {
      if (val != null) return val;
    }
    return stringVerified;
  }
}
