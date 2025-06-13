// entry_detail_screen.dart
import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/controllers/entry_detail_controller.dart';
import 'package:edusocial/controllers/entry_controller.dart';
import 'package:edusocial/models/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/cards/entry_comment_card.dart';
import '../../components/sheets/share_options_bottom_sheet.dart';

class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({super.key});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  final EntryDetailController entryDetailController =
      Get.find<EntryDetailController>();
  final EntryController entryController = Get.find<EntryController>();
  final EntryModel entry = Get.arguments as EntryModel;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    entryDetailController.setSelectedEntry(entry);
    entryDetailController.fetchEntryComments();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("--- EntryDetailScreen Debug Start ---");
    debugPrint("Entry from arguments - Topic Name: ${entry.topic?.name}");
    debugPrint("Entry from arguments - Category Title: ${entry.topic?.category?.title}");
    debugPrint("Entry from arguments - Content: ${entry.content}");
    debugPrint("Controller currentTopic - Topic Name: ${entryController.currentTopic.value?.name}");
    debugPrint("Controller currentTopic - Category Title: ${entryController.currentTopic.value?.category?.title}");
    debugPrint("--- EntryDetailScreen Debug End ---");

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: BackAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ana Entry ve Detayları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Okul İlişkileri Butonu (Kategori)
                GestureDetector(
                  onTap: () {
                    // Butona tıklanınca yapılacak işlemi buraya ekleyin
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      entryController.currentTopic.value?.category?.title ?? "Kategori Yok",
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xff272727)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Entry İçeriği
                Text(
                  entry.content,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff414751)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Yorumlar Listesi
          Expanded(
            child: Obx(() {
              if (entryDetailController.entryComments.isEmpty) {
                return Center(
                  child: Text(
                    "Henüz yorum yapılmamış",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xff9ca3ae),
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: entryDetailController.entryComments.length,
                itemBuilder: (context, index) {
                  final comment = entryDetailController.entryComments[index];
                  return EntryCommentCard(
                    entry: comment,
                    onDownvote: () => entryController.voteEntry(comment.id, "down"),
                    onUpvote: () => entryController.voteEntry(comment.id, "up"),
                    onShare: () {
                      final String shareText = comment.content;
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        builder: (_) => ShareOptionsBottomSheet(postText: shareText),
                      );
                    },
                    onPressed: () {},
                  );
                },
              );
            }),
          ),

          // Entry Paylaşım kısmı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "Entry paylaşın",
                        hintStyle: GoogleFonts.inter(
                            color: const Color(0xff9ca3ae), fontSize: 13.28),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                        fillColor: const Color(0xfffafafa),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF7743),
                            Color(0xFFEF5050)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'images/icons/send_icon.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (commentController.text.isNotEmpty) {
                        entryController.sendEntryToTopic(
                          entry.topic?.id ?? 0,
                          commentController.text,
                        ).then((_) {
                          entryDetailController.fetchEntryComments();
                          commentController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
