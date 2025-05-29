import 'entry_model.dart'; // mevcut EntryModel
import 'topic_model.dart'; // aşağıda vereceğim
class TopicWithEntryModel {
  final TopicModel topic;
  final List<EntryModel> entries;

  TopicWithEntryModel({
    required this.topic,
    required this.entries,
  });

  factory TopicWithEntryModel.fromJson(Map<String, dynamic> json) {
    return TopicWithEntryModel(
      topic: TopicModel.fromJson(json["topic"]),
      entries: (json["entrys"] as List<dynamic>)
          .map((e) => EntryModel.fromJson(e))
          .toList(),
    );
  }
}
