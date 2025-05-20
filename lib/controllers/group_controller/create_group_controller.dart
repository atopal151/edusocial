import 'dart:io';

import 'package:edusocial/models/group_models/group_area_model.dart';
import 'package:edusocial/services/group_services/create_group_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateGroupController extends GetxController {
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
  
  debugPrint("📥 Fetched Group Areas: ${fetchedAreas.map((e) => e.toJson())}");

  groupAreas.assignAll(fetchedAreas);
  if (fetchedAreas.isNotEmpty) {
    selectedGroupArea.value = fetchedAreas.first;
    debugPrint("✅ İlk Seçilen Grup Alanı: ${selectedGroupArea.value!.name}");
  } else {
    debugPrint("❗ Grup alanı listesi boş geldi.");
  }
}

  Future<void> createGroup() async {
  final name = nameGroupController.text.trim();
  final desc = descriptionGroupController.text.trim();
  final area = selectedGroupArea.value;

  if (name.isEmpty || desc.isEmpty || area == null) {
    Get.snackbar("Eksik Bilgi", "Lütfen tüm alanları doldurun");
    return;
  }

  isLoading.value = true;

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
    Get.snackbar("Başarılı", "Grup başarıyla oluşturuldu");
  } else {
    Get.snackbar("Hata", "Grup oluşturulamadı");
  }
}

}
