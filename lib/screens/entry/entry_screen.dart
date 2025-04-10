import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/components/cards/entry_card.dart';
import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:edusocial/models/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/user_appbar/user_appbar.dart';
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

    filteredEntries.assignAll(entryController.entryList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: UserAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
            child: SearchTextField(
              label: "Entry ara",
              controller: entrySearchController,
              onChanged: (value) {
                filteredEntries.value = entryController.entryList
                    .where((entry) =>
                        entry.entryTitle
                            .toLowerCase()
                            .contains(value.toLowerCase()) ||
                        entry.entryDescription
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                    .toList();
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: CustomButton(

                        height: 50,
                        borderRadius: 15,
                text: "Yeni Konu Aç",
                onPressed: () {
                  entryController.shareEntry();
                },
                isLoading: entryController.isEntryLoading,
                backgroundColor: Color(0xfffb535c),
                textColor: Color(0xffffffff),
                icon: Icons.add),
          ),
          SizedBox(
            height: 10,
          ),
          Obx(() {
            return Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // entryController'dan verileri yeniden çek
                  entryController.fetchEntries();

                  // filtreleme varsa güncelle
                  filteredEntries.assignAll(entryController.entryList
                      .where((entry) =>
                          entry.entryTitle.toLowerCase().contains(
                              entrySearchController.text.toLowerCase()) ||
                          entry.entryDescription.toLowerCase().contains(
                              entrySearchController.text.toLowerCase()))
                      .toList());
                },
                child: ListView.separated(
                  itemCount: filteredEntries.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = filteredEntries[index];
                    return EntryCard(
                      onPressedProfile: () {
                        Get.toNamed("/peopleProfile");
                      },
                      onPressed: () {
                        Get.toNamed("/entryDetail", arguments: entry);
                      },
                      entry: entry,
                      onUpvote: () => entryController.upvoteEntry(index),
                      onDownvote: () => entryController.downvoteEntry(index),
                      onShare: () {},
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
