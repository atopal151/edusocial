import 'dart:io';

import 'package:edusocial/models/group_models/group_area_model.dart';
import 'package:edusocial/services/group_services/create_group_service.dart';
import 'package:edusocial/services/language_service.dart';
import 'package:edusocial/components/snackbars/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateGroupController extends GetxController {
  final LanguageService languageService = Get.find<LanguageService>();
  final TextEditingController nameGroupController = TextEditingController();
  final TextEditingController descriptionGroupController =
      TextEditingController();

  Rx<File?> coverImageFile = Rx<File?>(null);
  Rx<File?> profileImageFile = Rx<File?>(null);

  RxBool isLoading = false.obs;
  RxBool isPrivate = false.obs;

  RxList<GroupAreaModel> groupAreas = <GroupAreaModel>[].obs;
  Rx<GroupAreaModel?> selectedGroupArea = Rx<GroupAreaModel?>(null);

  final CreateGroupService _service = CreateGroupService();

  void togglePrivacy(bool value) {
    isPrivate.value = value;
  }

 Future<void> loadGroupAreas() async {
  final fetchedAreas = await _service.fetchGroupAreas();
  
  //debugPrint("📥 Fetched Group Areas: ${fetchedAreas.map((e) => e.toJson())}");

  groupAreas.assignAll(fetchedAreas);
  if (fetchedAreas.isNotEmpty) {
    selectedGroupArea.value = fetchedAreas.first;
    //debugPrint("✅ İlk Seçilen Grup Alanı: ${selectedGroupArea.value!.name}");
  } else {
    debugPrint("❗ Grup alanı listesi boş geldi.");
  }
}

Future<void> createGroup() async {
  final name = nameGroupController.text.trim();
  final desc = descriptionGroupController.text.trim();
  final area = selectedGroupArea.value;

  if (name.isEmpty || desc.isEmpty || area == null) {
    CustomSnackbar.show(
      title: languageService.tr("common.messages.missingInfo"),
      message: languageService.tr("common.messages.fillAllFields"),
      type: SnackbarType.warning,
      duration: const Duration(seconds: 4),
    );
    return;
  }

  isLoading.value = true;

  try {
    final success = await _service.createGroup(
      name: name,
      description: desc,
      groupAreaId: area.id,
      isPrivate: isPrivate.value,
      avatar: profileImageFile.value,
      banner: coverImageFile.value,
    );

    isLoading.value = false;

    if (success) {
      Get.back();
      CustomSnackbar.show(
        title: languageService.tr("common.success"),
        message: languageService.tr("common.messages.groupCreatedSuccessfully"),
        type: SnackbarType.success,
        duration: const Duration(seconds: 3),
      );
    } else {
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("common.messages.groupCreationFailed"),
        type: SnackbarType.error,
        duration: const Duration(seconds: 4),
      );
    }
  } catch (e, stack) {
    isLoading.value = false;
    debugPrint("❌ Grup oluşturulurken hata oluştu: $e");
    debugPrint("📛 Stack Trace:\n$stack");
    CustomSnackbar.show(
      title: languageService.tr("common.error"),
      message: "${languageService.tr("common.messages.groupCreationFailed")}: $e",
      type: SnackbarType.error,
      duration: const Duration(seconds: 5),
    );
  }
}


}
