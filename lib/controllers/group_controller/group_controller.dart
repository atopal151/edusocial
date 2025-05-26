// group_controller.dart
import 'dart:io';

import 'package:edusocial/models/group_models/group_detail_model.dart';
import 'package:edusocial/models/group_models/grup_suggestion_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/document_model.dart';
import '../../models/event_model.dart';
import '../../models/group_models/group_model.dart';
import '../../models/link_model.dart';
import '../../services/group_services/group_service.dart';

class GroupController extends GetxController {
  var userGroups = <GroupModel>[].obs;
  var allGroups = <GroupModel>[].obs;
  var suggestionGroups = <GroupSuggestionModel>[].obs;
  var isLoading = false.obs;
  var isGroupLoading = false.obs;
  var selectedCategory = "Kimya".obs;
  var groupDetail = Rxn<GroupDetailModel>();
  var filteredGroups = <GroupModel>[].obs;

  var categories = ["Kimya", "Fizik", "Teknoloji", "Eğitim"].obs;

  Rx<File?> coverImageFile = Rx<File?>(null);
  Rx<File?> profileImageFile = Rx<File?>(null);
  var selectedRequest = false.obs;
  RxList<String> categoryGroup = <String>[].obs;
  final TextEditingController nameGroupController = TextEditingController();
  final TextEditingController descriptionGroupController =
      TextEditingController();

  final GroupServices _groupServices = GroupServices();

  @override
  void onInit() {
    super.onInit();
    fetchUserGroups();
    fetchAllGroups();
    fetchSuggestionGroups();

    categoryGroup.value = ["Genel", "Felsefe", "Spor", "Tarih"]; // örnek
    //loadMockGroupData(); // backend yerine simule veri
    ever(selectedCategory, (_) => updateFilteredGroups());
  }

void joinSuggestionGroup(String id) {
  final index = suggestionGroups.indexWhere((group) => group.id == id);
  if (index != -1) {
    Get.snackbar("Katıldın", "${suggestionGroups[index].groupName} grubuna katıldın");
  }
}

  void getCreateGroup() {
    Get.toNamed("/createGroup");
  }

  void createGroup() {
    Get.snackbar("Grup Oluşturma", "Grup Oluşturuldu");
  }

  void toggleNotification(bool value) {
    selectedRequest.value = value;
  }


  void fetchUserGroups() async {
    isLoading.value = true;
    userGroups.value = await _groupServices.fetchUserGroups();
    isLoading.value = false;
  }

  void fetchSuggestionGroups() async {
    isLoading.value = true;
    suggestionGroups.value = await _groupServices.fetchSuggestionGroups();
    isLoading.value = false;
  }

  void fetchAllGroups() async {
    isLoading.value = true;
    allGroups.value = await _groupServices.fetchAllGroups();
    updateFilteredGroups(); // ✅ burada tetikleniyor
    isLoading.value = false;
  }

  void getGrupDetail() {
    Get.toNamed("/group_detail_screen");
  }

  void getToGroupChatDetail() {
    Get.toNamed("/group_chat_detail");
  }

  void updateFilteredGroups() {
    filteredGroups.value = allGroups
        .where((group) => group.groupAreaId == selectedCategory.value)
        .toList();
  }

  void joinGroup(String id) {
    final index = allGroups.indexWhere((group) => group.id == id);
    if (index != -1) {
      allGroups[index] = allGroups[index].copyWith(isJoined: true);
      Get.snackbar(
          "Katılım Başarılı", "${allGroups[index].name} grubuna katıldınız");
    }
  }
}
