import 'document_model.dart';
import 'link_model.dart';

class UserChatDetailModel {
  final String id;
  final String name;
  final String follower;
  final String following;
  final String imageUrl;
  final List<String> memberImageUrls;
  final List<DocumentModel> documents;
  final List<LinkModel> links;
  final List<String> photoUrls;

  UserChatDetailModel({
    required this.id,
    required this.name,
    required this.follower,
    required this.following,
    required this.imageUrl,
    required this.memberImageUrls,
    required this.documents,
    required this.links,
    required this.photoUrls,
  });
}
