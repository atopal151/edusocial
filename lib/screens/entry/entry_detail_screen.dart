// entry_detail_screen.dart
import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:edusocial/controllers/entry_controller.dart';
import 'package:edusocial/controllers/entry_detail_controller.dart';
import 'package:edusocial/controllers/topics_controller.dart';
import 'package:edusocial/models/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:edusocial/services/language_service.dart';

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
  final LanguageService languageService = Get.find<LanguageService>();

  // TopicsController'ı bul (eğer varsa)
  TopicsController? _topicsController;

  @override
  void initState() {
    super.initState();

    // TopicsController'ı bul (eğer varsa)
    try {
      _topicsController = Get.find<TopicsController>();
      debugPrint("🔄 EntryDetailScreen initState: TopicsController bulundu");
    } catch (e) {
      debugPrint("⚠️ TopicsController bulunamadı: $e");
    }

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

    // Widget tree kilitliyken observable güncellemelerini engelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Yorum listesini temizle
      entryDetailController.entryComments.clear();

      // TopicsController loading state'ini sıfırla
      if (_topicsController != null) {
        _topicsController!.resetTopicLoadingState();
        debugPrint(
            "🔄 EntryDetailScreen dispose: TopicsController loading state sıfırlandı");
      }
    });

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
                      widget.entry.topic?.category?.title ??
                          languageService.tr("entryDetail.noCategory"),
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xff272727)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Topic Başlığı
                Text(
                  widget.entry.topic?.name ??
                      languageService.tr("entryDetail.noTopicInfo"),
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff414751)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // İlk entry + yorumlar tek listede, birlikte kayar
          Expanded(
            child: Obx(() {
              if (entryDetailController.isCommentsLoading.value) {
                return Center(
                    child: GeneralLoadingIndicator(
                  size: 32,
                  showIcon: false,
                ));
              }

              final main =
                  entryDetailController.mainEntry.value ?? widget.entry;
              final topic = main.topic ?? widget.entry.topic;
              final categoryTitle = topic?.category?.title ??
                  languageService.tr("entryDetail.noCategory");
              final topicName = topic?.name ?? "Konu Bilgisi Yok";
              final comments = entryDetailController.entryComments;
              final totalCount = 1 + comments.length;

              return RefreshIndicator(
                color: Color(0xFFef5050),
                backgroundColor: Color(0xfffafafa),
                elevation: 0,
                onRefresh: () async {
                  await entryDetailController.fetchEntryComments();
                },
                child: ListView.builder(
                  itemCount: totalCount,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return EntryCommentCard(
                        entry: main,
                        onDownvote: () =>
                            entryController.voteEntry(main.id, "down"),
                        onUpvote: () =>
                            entryController.voteEntry(main.id, "up"),
                        onShare: () {
                          final String shareText = """
📝 **$topicName** (#${main.id})

🏷️ $categoryTitle

💬 **Entry:**
${main.content}

📲 App Store: https://apps.apple.com/app/edusocial/id123456789
📱 Play Store: https://play.google.com/store/apps/details?id=com.edusocial.app

""";
                          Share.share(shareText);
                        },
                        onPressed: () {},
                      );
                    }

                    final comment = comments[index - 1];
                    return EntryCommentCard(
                      entry: comment,
                      onDownvote: () =>
                          entryController.voteEntry(comment.id, "down"),
                      onUpvote: () =>
                          entryController.voteEntry(comment.id, "up"),
                      onShare: () {
                        String firstEntryContent = "";
                        if (comments.isNotEmpty) {
                          firstEntryContent = comments.first.content;
                        }
                        final t = widget.entry.topic;
                        final catTitle = t?.category?.title ??
                            languageService.tr("entryDetail.noCategory");
                        final tName = t?.name ?? "Konu Bilgisi Yok";
                        final entryCount = comments.length;
                        final String shareText = """
📝 **$tName** (#${comment.id})

🏷️ **Kategori:** $catTitle
📊 **Entry Sayısı:** $entryCount

💬 **Bu Entry:**
${comment.content}

📖 **Konu Hakkında:**
$firstEntryContent

📱 **EduSocial Uygulamasını İndir:**
🔗 Uygulamayı Aç: edusocial://app
📲 App Store: https://apps.apple.com/app/edusocial/id123456789
📱 Play Store: https://play.google.com/store/apps/details?id=com.edusocial.app

#EduSocial #Eğitim #$catTitle
""";
                        Share.share(shareText);
                      },
                      onPressed: () {},
                    );
                  },
                ),
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
                        hintText: languageService
                            .tr("entry.entryDetail.commentPlaceholder"),
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
                  Obx(() => IconButton(
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
                            child: entryController.isSendingEntry.value
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : SvgPicture.asset(
                                    'images/icons/send_icon.svg',
                                    width: 18,
                                    height: 18,
                                    colorFilter: const ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  ),
                          ),
                        ),
                        onPressed: entryController.isSendingEntry.value
                            ? null
                            : () {
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
                      )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
