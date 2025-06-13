import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/components/cards/entry_card.dart';
import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:edusocial/models/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/user_appbar/user_appbar.dart';
import '../../components/widgets/share_bottom_sheet.dart';
import '../../controllers/entry_controller.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final EntryController entryController = Get.find();
  final TextEditingController entrySearchController = TextEditingController();
  final RxList<EntryModel> filteredEntries = <EntryModel>[].obs;

  @override
  void initState() {
    super.initState();

    // İlk açılışta veri çek
    entryController.fetchEntriesForSelectedCategory();
    // İlk veri yüklendiğinde listeyi eşitle
    ever(entryController.entryList, (_) {
      filteredEntries.assignAll(entryController.entryList);
    });
  }

  @override
  void dispose() {
    filteredEntries.clear();
    entrySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: UserAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Arama Alanı
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
            child: SearchTextField(
              label: "Entry ara",
              controller: entrySearchController,
              onChanged: (value) {
                final query = value.toLowerCase();
                filteredEntries.assignAll(
                  entryController.entryList.where((entry) {
                    return entry.content.toLowerCase().contains(query) ||
                        entry.content.toLowerCase().contains(query);
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

          // 📚 Kategori Seçimi
          SizedBox(
            height: 35,
            child: Obx(() {
              final categories = entryController.categoryEntry;
              final selected = entryController.selectedCategory.value;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selected;

                  return GestureDetector(
                    onTap: () {
                      entryController.selectedCategory.value = category;
                      entryController.fetchEntriesForSelectedCategory();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xfffb535c)
                            : Color(0xffefefef),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color:
                                isSelected ? Colors.white : Color(0xff414751),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // 📄 Entry Listesi
          Expanded(
            child: Obx(() {
              final topic = entryController.currentTopic.value;
              final topicName = topic?.name;
              final categoryTitle = topic?.category.title;
              return ListView.separated(
                itemCount: filteredEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = filteredEntries[index];
                  return EntryCard(
                    entry: entry,
                    topicName: topicName,
                    categoryTitle: categoryTitle,
                    onPressedProfile: () {
                      Get.toNamed("/peopleProfile");
                    },
                    onPressed: () {
                      Get.toNamed("/entryDetail", arguments: entry);
                    },
                    onUpvote: () => entryController.voteEntry(entry.id, "up"),
                    onDownvote: () => entryController.voteEntry(entry.id, "down"),
                    onShare: () {
                      final String shareText = entry.content;
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        builder: (_) => ShareOptionsBottomSheet(postText: shareText),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
