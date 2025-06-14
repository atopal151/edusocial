import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/entry_model.dart';
import '../controllers/entry_controller.dart';
import '../components/sheets/share_options_bottom_sheet.dart';

class DisplayEntryItem extends StatelessWidget {
  final EntryModel entry;
  final VoidCallback onRefresh;

  const DisplayEntryItem({
    Key? key,
    required this.entry,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entryController = Get.find<EntryController>();

    return Container(
      color: const Color(0xfffafafa),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic ve Kategori Bilgisi
              if (entry.topic != null) ...[
                Text(
                  entry.topic!.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (entry.topic!.category != null)
                  Text(
                    entry.topic!.category!.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 8),
              ],

              // Entry İçeriği
              Text(
                entry.content,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),

              // Alt Bilgiler
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kullanıcı Bilgisi
                  GestureDetector(
                    onTap: () => Get.toNamed("/peopleProfile"),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: entry.user.avatarUrl.isNotEmpty
                              ? NetworkImage(entry.user.avatarUrl)
                              : null,
                          child: entry.user.avatarUrl.isEmpty
                              ? const Icon(Icons.person, size: 20)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tarih
                  Text(
                    entry.human_created_at,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Aksiyon Butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Upvote
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () => entryController.voteEntry(entry.id, "up"),
                  ),
                  // Downvote
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: () => entryController.voteEntry(entry.id, "down"),
                  ),
                  // Paylaş
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        builder: (_) => ShareOptionsBottomSheet(postText: entry.content),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 