
import 'sender_model.dart';
import 'conversation_model.dart';
import 'message_media_model.dart';
import 'message_link_model.dart';
import 'detail_document_model.dart';

class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String message;
  final bool isRead;
  final bool isMe;
  final String createdAt;
  final String updatedAt;
  final SenderModel sender;
  final ConversationModel conversation;
  final List<MessageMediaModel> messageMedia;
  final List<MessageLinkModel> messageLink;
  final List<DetailDocumentModel>? messageDocument;
  final String? senderAvatarUrl;
  final bool isPinned;
  /// Yanıtlanan mesajın ID'si (reply)
  final int? replyId;
  /// Yanıtlanan mesajın metni (API'dan dönerse gösterim için)
  final String? replyMessageText;
  /// Yanıtlanan mesajın gönderen adı (API'dan dönerse gösterim için)
  final String? replyMessageSenderName;
  /// Yanıtlanan mesaj görsel (fotoğraf) içeriyor mu — önizlemede "Fotoğraf" göstermek için
  final bool replyHasImageMedia;
  /// Yanıtlanan mesaj link içeriyor mu — önizlemede "Link" göstermek için
  final bool replyHasLinkMedia;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.isRead,
    required this.isMe,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
    required this.conversation,
    required this.messageMedia,
    required this.messageLink,
    this.messageDocument,
    this.senderAvatarUrl,
    this.isPinned = false,
    this.replyId,
    this.replyMessageText,
    this.replyMessageSenderName,
    this.replyHasImageMedia = false,
    this.replyHasLinkMedia = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, {int? currentUserId}) {
    final senderJson = json['sender'];
    final senderId = json['sender_id'] is int
        ? json['sender_id']
        : int.tryParse(json['sender_id'].toString()) ?? 0;
        
    bool isMeFlag = json['is_me'] == true || (json['is_me'] is int && json['is_me'] == 1);
    if (currentUserId != null) {
      isMeFlag = senderId == currentUserId;
    }

    // DEBUG: Okundu alanını kontrol et
    final rawIsRead = json['is_read'];
    final isReadValue = rawIsRead == true || (rawIsRead is int && rawIsRead == 1);

    // Check if message is pinned
    final isPinned = json['is_pinned'] == true || (json['is_pinned'] is int && json['is_pinned'] == 1);

    // Reply (yanıt) bilgisi
    final replyId = json['reply_id'] != null ? int.tryParse(json['reply_id'].toString()) : null;
    String? replyMessageText;
    String? replyMessageSenderName;
    bool replyHasImageMedia = false;
    bool replyHasLinkMedia = false;
    final replyMessage = json['reply_message'] ?? json['reply'];
    if (replyMessage is Map<String, dynamic>) {
      replyMessageText = replyMessage['message']?.toString();
      final replySender = replyMessage['sender'];
      if (replySender is Map<String, dynamic>) {
        replyMessageSenderName = replySender['name']?.toString();
      }
      // Yanıtlanan mesaj görsel içeriyorsa önizlemede "Fotoğraf" göstereceğiz
      final replyMedia = replyMessage['message_media'] as List<dynamic>?;
      if (replyMedia != null && replyMedia.isNotEmpty) {
        replyHasImageMedia = replyMedia.any((m) {
          final type = m is Map ? (m['type'] as String?) : null;
          return type != null && type.startsWith('image/');
        });
      }
      // Yanıtlanan mesaj link içeriyorsa önizlemede "Link" göstereceğiz
      final replyLink = replyMessage['message_link'] as List<dynamic>?;
      if (replyLink != null && replyLink.isNotEmpty) {
        replyHasLinkMedia = true;
      }
    }

    return MessageModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      conversationId: json['conversation_id'] is int
          ? json['conversation_id']
          : int.tryParse(json['conversation_id'].toString()) ?? 0,
      senderId: senderId,
      message: json['message'] ?? '',
      isRead: isReadValue,
      isMe: isMeFlag,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      sender: json['sender'] != null
          ? SenderModel.fromJson(json['sender'])
          : SenderModel.empty(),
      conversation: json['conversation'] != null
          ? ConversationModel.fromJson(json['conversation'])
          : ConversationModel.empty(),
      messageMedia: (json['message_media'] as List<dynamic>?)
              ?.map((e) => MessageMediaModel.fromJson(e))
              .toList() ??
          [],
      messageLink: (json['message_link'] as List<dynamic>?)
              ?.map((e) => MessageLinkModel.fromJson(e))
              .toList() ??
          [],
      messageDocument: (json['message_document'] as List<dynamic>?)
              ?.map((e) => DetailDocumentModel.fromJson(e))
              .toList(),
      senderAvatarUrl: senderJson != null
          ? senderJson['avatar_url'] ?? ""
          : "",
      isPinned: isPinned,
      replyId: replyId,
      replyMessageText: replyMessageText,
      replyMessageSenderName: replyMessageSenderName,
      replyHasImageMedia: replyHasImageMedia,
      replyHasLinkMedia: replyHasLinkMedia,
    );
  }

  /// Yanıt önizlemesi için metin — her mesaj tipi için (metin, görsel, link, belge)
  String get replyPreviewDisplayText {
    final text = message.trim();
    if (text.isNotEmpty) {
      return text.length > 40 ? '${text.substring(0, 40)}...' : text;
    }
    if (messageMedia.any((m) => m.isImage)) return '📷 Photo';
    if (messageLink.isNotEmpty) return '🔗 Link';
    if ((messageDocument?.isNotEmpty ?? false) || messageMedia.any((m) => m.isDocument)) {
      return '📎 Document';
    }
    return 'Media';
  }

  /// Yanıt önizlemesinde gösterilecek görsel URL (varsa)
  String? get replyPreviewImageUrl {
    final imageList = messageMedia.where((m) => m.isImage).toList();
    if (imageList.isEmpty) return null;
    return imageList.first.fullPath;
  }

  /// Yanıtlanan mesaj görsel içeriyor mu (önizlemede thumbnail göstermek için)
  bool get hasReplyPreviewImage => replyPreviewImageUrl != null;

  // Create a copy with updated pin status
  MessageModel copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    String? message,
    bool? isRead,
    bool? isMe,
    String? createdAt,
    String? updatedAt,
    SenderModel? sender,
    ConversationModel? conversation,
    List<MessageMediaModel>? messageMedia,
    List<MessageLinkModel>? messageLink,
    List<DetailDocumentModel>? messageDocument,
    String? senderAvatarUrl,
    bool? isPinned,
    int? replyId,
    String? replyMessageText,
    String? replyMessageSenderName,
    bool? replyHasImageMedia,
    bool? replyHasLinkMedia,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      isMe: isMe ?? this.isMe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
      conversation: conversation ?? this.conversation,
      messageMedia: messageMedia ?? this.messageMedia,
      messageLink: messageLink ?? this.messageLink,
      messageDocument: messageDocument ?? this.messageDocument,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      isPinned: isPinned ?? this.isPinned,
      replyId: replyId ?? this.replyId,
      replyMessageText: replyMessageText ?? this.replyMessageText,
      replyMessageSenderName: replyMessageSenderName ?? this.replyMessageSenderName,
      replyHasImageMedia: replyHasImageMedia ?? this.replyHasImageMedia,
      replyHasLinkMedia: replyHasLinkMedia ?? this.replyHasLinkMedia,
    );
  }
}
