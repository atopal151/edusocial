import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/components/cards/entry_card.dart';
import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:edusocial/models/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/user_appbar/user_appbar.dart';
import '../../components/sheets/share_options_bottom_sheet.dart';
import '../../controllers/entry_controller.dart';
import '../../models/topic_model.dart';
import '../../models/user_model.dart';
import '../../models/topic_category_model.dart';
import '../../services/entry_services.dart';
import '../entry/entry_detail_screen.dart';
import '../profile/people_profile_screen.dart';
import 'package:edusocial/models/display_entry_item.dart';
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
        body: Obx(
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
                        return item.entry.content.toLowerCase().contains(query) ||
                            (item.topicName?.toLowerCase().contains(query) ?? false) ||
                            (item.categoryTitle?.toLowerCase().contains(query) ?? false);
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
                    ? const Center(child: CircularProgressIndicator())
                    : entryController.displayEntries.isEmpty
                        ? const Center(
                            child: Text(
                              "Gösterilecek entry bulunamadı.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: entryController.displayEntries.length,
                            itemBuilder: (context, index) {
                              final displayItem = entryController.displayEntries[index];
                              final EntryModel entry = displayItem.entry;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: EntryCard(
                                  entry: entry,
                                  topicName: displayItem.topicName,
                                  categoryTitle: displayItem.categoryTitle,
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
                                  onPressed: () {
                                    Get.toNamed(Routes.entryDetail, arguments: {'entry': entry});
                                  },
                                  onPressedProfile: () {
                                    Get.to(() => PeopleProfileScreen(username: entry.user.username));
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
