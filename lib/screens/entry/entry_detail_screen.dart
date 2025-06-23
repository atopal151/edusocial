// entry_detail_screen.dart
import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/controllers/entry_controller.dart';
import 'package:edusocial/controllers/entry_detail_controller.dart';
import 'package:edusocial/models/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/cards/entry_comment_card.dart';

class EntryDetailScreen extends StatefulWidget {
  final EntryModel entry;
  const EntryDetailScreen({super.key, required this.entry});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  final EntryDetailController entryDetailController =
      Get.find<EntryDetailController>();
  final EntryController entryController = Get.find<EntryController>();
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Eğer entry'nin bir topic'i varsa, onu ayarla.
    if (widget.entry.topic != null) {
      entryDetailController.setCurrentTopic(widget.entry.topic!);
    } else {
      // Eğer topic hala null ise, bu bir veri eksikliğidir.
      // Bu durumda EntryDetailController'da null bir topic ile devam edilebilir
      // veya hata mesajı gösterilebilir.
      debugPrint("⚠️ EntryDetailScreen: Topic bilgisi bulunamadı!");
      entryDetailController
          .setCurrentTopic(null); // veya varsayılan bir TopicModel
    }

    entryDetailController.fetchEntryComments();
  }

  @override
  void dispose() {
    debugPrint(
        "⚠️ EntryDetailScreen dispose: Widget yok ediliyor ve yorumlar temizleniyor.");
    entryDetailController.entryComments
        .clear(); // Yorum listesini doğrudan burada temizle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("--- EntryDetailScreen Debug Start ---");
    // debugPrint("Topic from arguments - Topic Name: ${topic.name}");
    // debugPrint("Topic from arguments - Category Title: ${topic.category?.title}");
    // debugPrint("--- EntryDetailScreen Debug End ---");

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: BackAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ana Topic ve Detayları
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori Butonu
                GestureDetector(
                  onTap: () {
                    // Butona tıklanınca yapılacak işlemi buraya ekleyin
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      widget.entry.topic?.category?.title ?? "Kategori Yok",
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xff272727)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Topic Başlığı
                Text(
                  widget.entry.topic?.name ?? "Konu Bilgisi Yok",
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff414751)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Yorumlar Listesi (Entry'ler)
          Expanded(
            child: Obx(() {
              if (entryDetailController.entryComments.isEmpty) {
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Color(0xff9ca3ae),
                  color: Color(0xfffafafa),
                ));
              }
              return ListView.builder(
                itemCount: entryDetailController.entryComments.length,
                itemBuilder: (context, index) {
                  final comment = entryDetailController.entryComments[index];
                  return EntryCommentCard(
                    entry: comment,
                    onDownvote: () =>
                        entryController.voteEntry(comment.id, "down"),
                    onUpvote: () => entryController.voteEntry(comment.id, "up"),
                    onShare: () {
                      // Konunun ilk entry'sini bul
                      String firstEntryContent = "";
                      if (entryDetailController.entryComments.isNotEmpty) {
                        firstEntryContent =
                            entryDetailController.entryComments.first.content;
                      }

                      // Konu bilgilerini al
                      final topic = widget.entry.topic;
                      final categoryTitle =
                          topic?.category?.title ?? "Kategori Yok";
                      final topicName = topic?.name ?? "Konu Bilgisi Yok";
                      final entryCount =
                          entryDetailController.entryComments.length;

                      final String shareText = """
📝 **$topicName** (#${comment.id})

🏷️ **Kategori:** $categoryTitle
📊 **Entry Sayısı:** $entryCount

💬 **Bu Entry:**
${comment.content}

📖 **Konu Hakkında:**
$firstEntryContent

📱 **EduSocial Uygulamasını İndir:**
🔗 Uygulamayı Aç: edusocial://app
📲 App Store: https://apps.apple.com/app/edusocial/id123456789
📱 Play Store: https://play.google.com/store/apps/details?id=com.edusocial.app

#EduSocial #Eğitim #$categoryTitle
""";
                      Share.share(shareText);
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
                        hintText: "Bu konuya entry paylaşın",
                        hintStyle: GoogleFonts.inter(
                            color: const Color(0xff9ca3ae), fontSize: 13.28),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                        fillColor: const Color(0xfffafafa),
                        filled: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
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
                          colors: [Color(0xFFFF7743), Color(0xFFEF5050)],
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
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (commentController.text.isNotEmpty) {
                        entryController
                            .sendEntryToTopic(
                          widget.entry.topic?.id ?? 0,
                          commentController.text,
                        )
                            .then((_) {
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
