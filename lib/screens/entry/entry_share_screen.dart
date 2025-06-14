import 'package:edusocial/components/dropdowns/custom_dropdown.dart';
import 'package:edusocial/components/input_fields/costum_textfield.dart';
import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/controllers/entry_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/custom_multiline_textfield.dart';
import '../../models/topic_category_model.dart';
import '../../services/entry_services.dart';

class EntryShareScreen extends StatefulWidget {
  const EntryShareScreen({super.key});

  @override
  State<EntryShareScreen> createState() => _EntryShareScreenState();
}

class _EntryShareScreenState extends State<EntryShareScreen> {
  final EntryController entryController = Get.find<EntryController>();
  final EntryServices entryServices = EntryServices();
  int currentCharCount = 0;
  final RxList<TopicCategoryModel> categoryList = <TopicCategoryModel>[].obs;
  final Rxn<TopicCategoryModel> selectedTopicCategory = Rxn<TopicCategoryModel>();

  @override
  void initState() {
    super.initState();
    entryController.bodyEntryController.addListener(_entryTextListener);
    _fetchTopicCategories();
  }

  void _entryTextListener() {
    if (mounted) {
      setState(() {
        currentCharCount = entryController.bodyEntryController.text.length;
      });
    }
  }

  Future<void> _fetchTopicCategories() async {
    final List<TopicCategoryModel> data = await entryServices.fetchTopicCategories();
    categoryList.assignAll(data);
    if (categoryList.isNotEmpty) {
      final gunceCategory = categoryList.firstWhereOrNull((element) => element.title == "Güncem");
      if (gunceCategory != null) {
        selectedTopicCategory.value = gunceCategory;
      } else {
        selectedTopicCategory.value = categoryList.first;
      }
    }
  }

  @override
  void dispose() {
    entryController.bodyEntryController.removeListener(_entryTextListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                textColor: Color(0xff9CA3AE),
                hintText: "Konu Başlığı",
                controller: entryController.titleEntryController,
                backgroundColor: Color(0xffffffff),
              ),
              SizedBox(
                height: 20,
              ),
              CustomMultilineTextField(
                count: entryController.bodyEntryController.text.length,
                textColor: Color(0xff9CA3AE),
                hintText: "Entry",
                controller: entryController.bodyEntryController,
                backgroundColor: Color(0xffffffff),
              ),
              SizedBox(
                height: 20,
              ),
              Obx(
                () => CustomDropDown(
                  label: "Kategori",
                  items: categoryList.map((e) => e.title).toList(),
                  selectedItem: selectedTopicCategory.value?.title ?? (categoryList.isNotEmpty ? categoryList.first.title : ""),
                  onChanged: (value) {
                    if (value != null) {
                      selectedTopicCategory.value = categoryList.firstWhereOrNull((element) => element.title == value);
                    }
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CustomButton(
                height: 50,
                borderRadius: 15,
                text: "+ Konuyu Aç",
                onPressed: () {
                  entryController.shareEntryPost(
                    topicName: entryController.titleEntryController.text,
                    content: entryController.bodyEntryController.text,
                    topicCategoryId: selectedTopicCategory.value?.id ?? 0,
                  );
                },
                isLoading: entryController.isEntryLoading,
                backgroundColor: Color(0xfffb535c),
                textColor: Color(0xffffffff),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
