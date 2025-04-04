import 'package:edusocial/components/dropdowns/custom_dropdown.dart';
import 'package:edusocial/components/input_fields/costum_textfield.dart';
import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/controllers/entry_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/custom_multiline_textfield.dart';

class EntryShareScreen extends StatefulWidget {
  const EntryShareScreen({super.key});

  @override
  State<EntryShareScreen> createState() => _EntryShareScreenState();
}

class _EntryShareScreenState extends State<EntryShareScreen> {
  final EntryController entryController = Get.find<EntryController>();
  int currentCharCount = 0;

  @override
  void initState() {
    super.initState();
    entryController.bodyEntryController.addListener(() {
      setState(() {
        currentCharCount = entryController.bodyEntryController.text.length;
      });
    });
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
                  items: entryController.categoryEntry,
                  selectedItem: entryController.categoryEntry.isNotEmpty
                      ? (entryController.categoryEntry.contains(
                                  entryController.selectedCategory.value) &&
                              entryController.selectedCategory.value.isNotEmpty
                          ? entryController.selectedCategory.value
                          : entryController.categoryEntry.first)
                      : "",
                  onChanged: (value) {
                    if (value != null) {
                      entryController.selectedCategory.value = value;
                    }
                  },
                ),
              ),
              SizedBox(height: 20,),
              CustomButton(
                  text: "Paylaş",
                  onPressed: () {
                    entryController.shareEntryPost();
                  },
                  isLoading: entryController.isEntryLoading,
                  backgroundColor: Color(0xfffb535c),
                  textColor: Color(0xffffffff),
                  icon: Icons.share),
            ],
          ),
        ),
      ),
    );
  }
}
