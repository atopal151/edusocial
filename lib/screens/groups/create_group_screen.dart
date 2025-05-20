import 'dart:io';

import 'package:edusocial/components/buttons/custom_button.dart';
import 'package:edusocial/controllers/group_controller/create_group_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/dropdowns/custom_dropdown.dart';
import '../../components/input_fields/costum_textfield.dart';
import '../../components/input_fields/custom_multiline_textfield.dart';
import '../../components/user_appbar/back_appbar.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final CreateGroupController createGroupController =
      Get.put(CreateGroupController());

  int currentCharCount = 0;

  @override
  void initState() {
    super.initState();
    createGroupController.loadGroupAreas();
    createGroupController.descriptionGroupController.addListener(() {
      setState(() {
        currentCharCount =
            createGroupController.descriptionGroupController.text.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        iconBackgroundColor: Color(0xffffffff),
        title: "Yeni Grup Oluştur",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(
                () => Column(
                  children: [
                    SizedBox(
                      height: 160, // 120 kapak + 60 profil yüksekliği
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Kapak Fotoğrafı
                          IgnorePointer(
                            // Tıklamayı engellemesin
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius: BorderRadius.circular(20),
                                image: createGroupController
                                            .coverImageFile.value !=
                                        null
                                    ? DecorationImage(
                                        image: FileImage(
                                          createGroupController
                                              .coverImageFile.value!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),
                          ),

                          // 2. Profil Fotoğrafı
                          Positioned(
                            bottom: 0, // -40 yerine artık görünür alandayız
                            left: MediaQuery.of(context).size.width / 2 - 60,
                            child: GestureDetector(
                              onTap: () async {
                                final pickedFile = await ImagePicker()
                                    .pickImage(source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  createGroupController.profileImageFile.value =
                                      File(pickedFile.path);
                                }
                              },
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 44,
                                    backgroundColor: Color(0xfffafafa),
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white,
                                      backgroundImage: createGroupController
                                                  .profileImageFile.value !=
                                              null
                                          ? FileImage(createGroupController
                                              .profileImageFile.value!)
                                          : const NetworkImage(
                                              "https://randomuser.me/api/portraits/women/2.jpg",
                                            ) as ImageProvider,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Color(0xfffb535c),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.edit,
                                        size: 16, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),

                          // 3. Kapak Fotoğrafı Edit
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () async {
                                final pickedFile = await ImagePicker()
                                    .pickImage(source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  createGroupController.coverImageFile.value =
                                      File(pickedFile.path);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Color(0xfffb535c),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.edit,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Grup Fotoğrafı",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff414751),
                      ),
                    ),
                  ],
                ),
              ),
              CustomTextField(
                textColor: Color(0xff414751),
                hintText: "Grup Adı",
                controller: createGroupController.nameGroupController,
                backgroundColor: Color(0xffffffff),
              ),
              SizedBox(height: 20),
              CustomMultilineTextField(
                count: createGroupController
                    .descriptionGroupController.text.length,
                textColor: Color(0xff414751),
                hintText: "Grup Açıklaması",
                controller: createGroupController.descriptionGroupController,
                backgroundColor: Color(0xffffffff),
              ),
              SizedBox(height: 20),
              Obx(() => CustomDropDown(
                    color: Color(0xff414751),
                    label: "Grup Alanı",
                    items: createGroupController.groupAreas
                        .map((e) => e.name)
                        .toList(),
                    selectedItem:
                        createGroupController.selectedGroupArea.value?.name ??
                            "",
                    onChanged: (value) {
                      final selected = createGroupController.groupAreas
                          .firstWhereOrNull((e) => e.name == value);
                      if (selected != null) {
                        createGroupController.selectedGroupArea.value =
                            selected;
                      }
                    },
                  )),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Gruba girmek için katılım isteği\ngöndermek gereksin.",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xff414751)),
                  ),
                  Obx(() => Switch(
                        value: createGroupController.isPrivate.value,
                        activeColor: Color(0xFFEF5050),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white,
                        inactiveThumbColor: Color(0xFFD0D4DB),
                        trackOutlineColor:
                            WidgetStateProperty.all(Colors.white),
                        onChanged: createGroupController.togglePrivacy,
                      )),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "İptal",
                      height: 40,
                      borderRadius: 15,
                      onPressed: () => Get.back(),
                      isLoading: createGroupController.isLoading,
                      backgroundColor: Color(0xffffffff),
                      textColor: Color(0xff414751),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: "Grup Oluştur",
                      height: 40,
                      borderRadius: 15,
                      onPressed: () => createGroupController.createGroup(),
                      isLoading: createGroupController.isLoading,
                      backgroundColor: Color(0xfffb535c),
                      textColor: Color(0xffffffff),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
