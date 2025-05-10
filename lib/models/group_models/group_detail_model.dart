import '../document_model.dart';
import '../event_model.dart';
import '../link_model.dart';

class GroupDetailModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> memberImageUrls;
  final int memberCount;
  final DateTime createdAt;
  final List<DocumentModel> documents;
  final List<LinkModel> links;
  final List<String> photoUrls;
  final List<EventModel> events;
  final String coverImageUrl;

  GroupDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.memberImageUrls,
    required this.memberCount,
    required this.createdAt,
    required this.documents,
    required this.links,
    required this.photoUrls,
    required this.events,
    required this.coverImageUrl,
  });
}
