import 'package:edusocial/models/document_model.dart';
import 'package:edusocial/models/event_model.dart';
import 'package:edusocial/models/link_model.dart';
import 'group_chat_model.dart';

class GroupDetailModel {
  final String id;
  final String name;
  final String description;
  final String status;
  final bool isPrivate;
  final String? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userCountWithAdmin;
  final int userCountWithoutAdmin;
  final int messageCount;
  final bool isFounder;
  final bool isMember;
  final bool isPending;
  final String? avatarUrl;
  final String? bannerUrl;
  final String humanCreatedAt;
  final String? conversationId; // Group chat için conversation ID
  final List<DocumentModel> documents;
  final List<LinkModel> links;
  final List<String> photoUrls;
  final List<EventModel> events;
  final List<GroupChatModel> groupChats;
  final List<EventModel> groupEvents;
  final List<Map<String, dynamic>> users;

  GroupDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.isPrivate,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.userCountWithAdmin,
    required this.userCountWithoutAdmin,
    required this.messageCount,
    required this.isFounder,
    required this.isMember,
    required this.isPending,
    this.avatarUrl,
    this.bannerUrl,
    required this.humanCreatedAt,
    this.conversationId,
    required this.documents,
    required this.links,
    required this.photoUrls,
    required this.events,
    required this.groupChats,
    required this.groupEvents,
    required this.users,
  });

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) {
    // API yanıtı data.group içinde geliyor
    final group = json['group'] as Map<String, dynamic>? ?? json;
    
    return GroupDetailModel(
      id: group['id'].toString(),
      name: group['name'] ?? '',
      description: group['description'] ?? '',
      status: group['status'] ?? '',
      isPrivate: group['is_private'] ?? false,
      deletedAt: group['deleted_at'],
      createdAt: DateTime.parse(group['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(group['updated_at'] ?? DateTime.now().toIso8601String()),
      userCountWithAdmin: group['user_count_with_admin'] ?? 0,
      userCountWithoutAdmin: group['user_count_without_admin'] ?? 0,
      messageCount: group['message_count'] ?? 0,
      isFounder: group['is_founder'] ?? false,
      isMember: group['is_member'] ?? false,
      isPending: group['is_pending'] ?? false,
      avatarUrl: group['avatar_url'],
      bannerUrl: group['banner_url'],
      humanCreatedAt: group['human_created_at'] ?? '',
      conversationId: group['conversation_id']?.toString(),
      documents: (group['documents'] as List<dynamic>?)
              ?.map((doc) => DocumentModel.fromJson(doc))
              .toList() ??
          [],
      links: (group['links'] as List<dynamic>?)
              ?.map((link) => LinkModel.fromJson(link))
              .toList() ??
          [],
      photoUrls: (group['photo_urls'] as List<dynamic>?)
              ?.map((url) => url.toString())
              .toList() ??
          [],
      events: (group['events'] as List<dynamic>?)
              ?.map((event) => EventModel.fromJson(event))
              .toList() ??
          [],
      groupChats: (group['group_chats'] as List<dynamic>?)
              ?.map((chat) => GroupChatModel.fromJson(chat))
              .toList() ??
          [],
      groupEvents: (group['group_events'] as List<dynamic>?)
              ?.map((event) => EventModel.fromJson(event))
              .toList() ??
          [],
      users: (group['users'] as List<dynamic>?)
              ?.map((user) => user as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}
