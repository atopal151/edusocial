import 'package:edusocial/models/entry_model.dart';
import 'package:edusocial/models/topic_model.dart';

class TopicEntryResponse {
  final TopicModel topic;
  final List<EntryModel> entries;

  TopicEntryResponse({
    required this.topic,
    required this.entries,
  });

  factory TopicEntryResponse.fromJson(Map<String, dynamic> json) {
    final topicJson = json['topic'];
    final entryList = json['entrys'];

    return TopicEntryResponse(
      topic: TopicModel.fromJson(topicJson),
      entries: entryList != null
          ? (entryList as List).map((e) => EntryModel.fromJson(e)).toList()
          : [],
    );
  }
}
