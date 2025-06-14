import 'package:edusocial/models/entry_model.dart';

// Entry ve ilişkili görüntüleme verilerini tutar
class DisplayEntryItem {
  final EntryModel entry;
  final String? topicName;
  final String? categoryTitle;

  DisplayEntryItem({required this.entry, this.topicName, this.categoryTitle});

  DisplayEntryItem copyWith({
    EntryModel? entry,
    String? topicName,
    String? categoryTitle,
  }) {
    return DisplayEntryItem(
      entry: entry ?? this.entry,
      topicName: topicName ?? this.topicName,
      categoryTitle: categoryTitle ?? this.categoryTitle,
    );
  }
} 