import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/components/cards/entry_card.dart';
import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:edusocial/models/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../components/user_appbar/user_appbar.dart';
import '../../controllers/entry_controller.dart';
import '../../services/language_service.dart';
import '../profile/people_profile_screen.dart';
import 'package:edusocial/routes/app_routes.dart';

// Yeni sınıf: Entry ve ilişkili görüntüleme verilerini tutar
class DisplayEntryItem {
  final EntryModel entry;
  final String? topicName;
  final String? categoryTitle;

  DisplayEntryItem({required this.entry, this.topicName, this.categoryTitle});
}

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => EntryScreenState();
}

class EntryScreenState extends State<EntryScreen> {
  final EntryController entryController = Get.put(EntryController());

  @override
  void initState() {
    super.initState();
    entryController.fetchAndPrepareEntries();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xfffafafa),
        appBar: UserAppBar(),
        body: Obx(
          () => entryController.isEntryLoading.value
              ? Center(
                  child: GeneralLoadingIndicator(
                    size: 48,
                    color: const Color(0xFFEF5050),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    debugPrint("🔄 Entry verileri yenileniyor...");
                    await entryController.fetchAndPrepareEntries();
                    debugPrint("✅ Entry verileri başarıyla yenilendi");
                  },
                  color: Color(0xFFef5050),
                  backgroundColor: Color(0xfffafafa),
                  elevation: 0,
                  strokeWidth: 2.0,
                  displacement: 120.0,
                  edgeOffset: 10.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔍 Arama Alanı
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
                        child: SearchTextField(
                          label: languageService.tr("entry.entryScreen.searchPlaceholder"),
                          controller: entryController.entrySearchController,
                          onChanged: (value) {
                            // IMPROVED: Kategori + arama filtresini birlikte kullan
                            entryController.applySearchFilterToDisplayList();
                          },
                        ),
                      ),

                      const SizedBox(height: 10),
                        // ➕ Yeni Konu Butonu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomButton(
                          height: 45,
                          borderRadius: 15,
                          text: languageService.tr("entry.entryScreen.newTopicButton"),
                          onPressed: () => entryController.shareEntry(),
                          isLoading: RxBool(false), // Loading durumunu kaldır
                          backgroundColor: const Color(0xfffb535c),
                          textColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 📂 CATEGORY SELECTION: Horizontal category list
                      Container(
                        height: 45,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Obx(() {
                          // Loading state
                          if (entryController.categories.isEmpty) {
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xfffb535c)),
                                ),
                              ),
                            );
                          }
                          
                          // "Tümü" seçeneği + kategoriler
                          final allCategories = ['Tümü'] + entryController.categories.map((cat) => cat.title).toList();
                          
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: allCategories.length,
                            itemBuilder: (context, index) {
                              final categoryName = allCategories[index];
                              final isSelected = entryController.selectedCategory.value == categoryName;
                              
                              // Kategori için entry sayısını hesapla
                              int entryCount;
                              if (categoryName == 'Tümü') {
                                entryCount = entryController.allDisplayEntries.length;
                              } else {
                                entryCount = entryController.allDisplayEntries
                                    .where((item) => item.categoryTitle == categoryName)
                                    .length;
                              }
                              
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () => entryController.selectCategory(categoryName),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xfffb535c) : const Color(0xffffffff),
                                      borderRadius: BorderRadius.circular(16),
                                     
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          categoryName,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected ? Colors.white : const Color(0xff666666),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xfff0f0f0),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            entryCount.toString(),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected ? Colors.white : const Color(0xff888888),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),

                      const SizedBox(height: 10),

                      // 📊 CATEGORY INFO: Selected category and count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Obx(() {
                          final selectedCat = entryController.selectedCategory.value;
                          final entryCount = entryController.displayEntries.length;
                          final totalEntries = entryController.allDisplayEntries.length;
                          
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedCat == 'Tümü' 
                                  ? languageService.tr("entry.entryScreen.allCategories")
                                  : selectedCat,
                                style: GoogleFonts.inter(
                                  fontSize: 13.78,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff272727),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xfff5f5f5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  selectedCat == 'Tümü' 
                                    ? '$totalEntries ${languageService.tr("entry.entryScreen.entries")}'
                                    : '$entryCount ${languageService.tr("entry.entryScreen.entries")}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff666666),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),

                      const SizedBox(height: 10),

                    

                      // 📄 Entry Listesi
                      Expanded(
                        child: entryController.displayEntries.isEmpty
                            ? Center(
                                child: Text(
                                  languageService.tr("entry.entryScreen.noEntriesFound"),
                                  style:
                                      GoogleFonts.inter(color: Color(0xff9ca3ae)),
                                ),
                              )
                            : ListView.builder(
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: entryController.displayEntries.length,
                                itemBuilder: (context, index) {
                                  final displayItem =
                                      entryController.displayEntries[index];
                                  final EntryModel entry = displayItem.entry;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: EntryCard(
                                      entry: entry,
                                      topicName: displayItem.topicName,
                                      categoryTitle: displayItem.categoryTitle,
                                      onUpvote: () => entryController.voteEntry(
                                          entry.id, "up"),
                                      onDownvote: () => entryController.voteEntry(
                                          entry.id, "down"),
                                      onShare: () {
                                        // Konu bilgilerini al
                                        final topicName = displayItem.topicName ??
                                            languageService.tr("entry.entryDetail.topicNotFound");
                                        final categoryTitle =
                                            displayItem.categoryTitle ??
                                                languageService.tr("entry.entryDetail.categoryNotFound");

                                        final String shareText = """
📝 **$topicName** (#${entry.id})

🏷️ **${languageService.tr("entry.entryDetail.shareText.category")}:** $categoryTitle
👤 **${languageService.tr("entry.entryDetail.shareText.author")}:** ${entry.user.name}

💬 **${languageService.tr("entry.entryDetail.shareText.entryContent")}:**
${entry.content}

📱 **${languageService.tr("entry.entryDetail.shareText.downloadApp")}:**
🔗 ${languageService.tr("entry.entryDetail.shareText.openApp")}: edusocial://app
📲 App Store: https://apps.apple.com/app/edusocial/id123456789
📱 Play Store: https://play.google.com/store/apps/details?id=com.edusocial.app

#EduSocial #Eğitim #$categoryTitle
""";
                                        Share.share(shareText);
                                      },
                                      onPressed: () {
                                        Get.toNamed(Routes.entryDetail,
                                            arguments: {'entry': entry});
                                      },
                                      onPressedProfile: () {
                                        Get.to(() => PeopleProfileScreen(
                                            username: entry.user.username));
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                      // RefreshIndicator için minimum yükseklik
                      SizedBox(height: 50),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
