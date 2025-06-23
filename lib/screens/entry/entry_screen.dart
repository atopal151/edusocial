import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/components/cards/entry_card.dart';
import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:edusocial/models/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../components/user_appbar/user_appbar.dart';
import '../../components/sheets/share_options_bottom_sheet.dart';
import '../../controllers/entry_controller.dart';
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xfffafafa),
        appBar: UserAppBar(),
        body: RefreshIndicator(
          
          onRefresh: () async {
            debugPrint("🔄 Entry verileri yenileniyor...");
            await entryController.fetchAndPrepareEntries();
            debugPrint("✅ Entry verileri başarıyla yenilendi");
          },
          color: Color(0xFFEF5050),
          backgroundColor: Color(0xfffafafa),
          strokeWidth: 2.0,
          displacement: 120.0,
          edgeOffset: 10.0,
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Arama Alanı
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
                  child: SearchTextField(
                    label: "Entry ara",
                    controller: entryController.entrySearchController,
                    onChanged: (value) {
                      final query = value.toLowerCase();
                      entryController.displayEntries.assignAll(
                        entryController.allDisplayEntries.where((item) {
                          return item.entry.content
                                  .toLowerCase()
                                  .contains(query) ||
                              (item.topicName?.toLowerCase().contains(query) ??
                                  false) ||
                              (item.categoryTitle
                                      ?.toLowerCase()
                                      .contains(query) ??
                                  false);
                        }).toList(),
                      );
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
                    text: "+ Yeni Konu Aç",
                    onPressed: () => entryController.shareEntry(),
                    isLoading: entryController.isEntryLoading,
                    backgroundColor: const Color(0xfffb535c),
                    textColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                // 📄 Entry Listesi
                Expanded(
                  child: entryController.isEntryLoading.value
                      ? Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: GeneralLoadingIndicator(
                              size: 32,
                              showIcon: false,
                            ),
                          ),
                        )
                      : entryController.displayEntries.isEmpty
                          ? const Center(
                              child: Text(
                                "Gösterilecek entry bulunamadı.",
                                style: TextStyle(color: Colors.grey),
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
                                      final topicName = displayItem.topicName ?? "Konu Bilgisi Yok";
                                      final categoryTitle = displayItem.categoryTitle ?? "Kategori Yok";
                                      
                                      final String shareText = """
📝 **$topicName** (#${entry.id})

🏷️ **Kategori:** $categoryTitle
👤 **Yazar:** ${entry.user.name}

💬 **Entry İçeriği:**
${entry.content}

📱 **EduSocial Uygulamasını İndir:**
🔗 Uygulamayı Aç: edusocial://app
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
