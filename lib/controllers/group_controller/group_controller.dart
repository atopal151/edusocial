// group_controller.dart
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:edusocial/models/group_models/group_detail_model.dart';
import 'package:edusocial/models/group_models/grup_suggestion_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/group_models/group_model.dart';
import '../../services/group_services/group_service.dart';

class GroupController extends GetxController {
  var userGroups = <GroupModel>[].obs;
  var allGroups = <GroupModel>[].obs;
  var suggestionGroups = <GroupSuggestionModel>[].obs;

  var isLoading = false.obs;
  var isGroupLoading = false.obs;

  var selectedCategory = "All".obs;
  final Rx<GroupDetailModel?> groupDetail = Rx<GroupDetailModel?>(null);
  var filteredGroups = <GroupModel>[].obs;

  var categories = ['All'].obs;

  Map<String, String> categoryMap = {}; // id => name

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
    // fetchUserGroups(); // Login sırasında manuel olarak çağrılacak
    // fetchAllGroups(); // Login sırasında manuel olarak çağrılacak
    // fetchSuggestionGroups(); // Login sırasında manuel olarak çağrılacak
    // fetchGroupAreas(); // Login sırasında manuel olarak çağrılacak
    categoryGroup.value = [];

    ever(selectedCategory, (_) => updateFilteredGroups());
  }

//-------------------------------fetch-------------------------------
  Future<void> fetchUserGroups() async {
    isLoading.value = true;
    userGroups.value = await _groupServices.fetchUserGroups();
    isLoading.value = false;
  }

  void fetchSuggestionGroups() async {
    debugPrint("🔄 GroupController.fetchSuggestionGroups() çağrıldı");
    isLoading.value = true;
    try {
      final groups = await _groupServices.fetchSuggestionGroups();
      suggestionGroups.value = groups;
      debugPrint("✅ Önerilen gruplar başarıyla yüklendi: ${groups.length} grup");
    } catch (e) {
      debugPrint("❌ Önerilen gruplar yüklenirken hata: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchAllGroups() async {
    isLoading.value = true;
    allGroups.value = await _groupServices.fetchAllGroups();
    updateFilteredGroups(); // ✅ burada tetikleniyor
    isLoading.value = false;
  }

  void fetchGroupAreas() async {
    final areas = await _groupServices.fetchGroupAreas();

    for (var area in areas) {
      final id = area['id'].toString();
      final name = area['name'].toString();

      categoryMap[id] = name;

      if (!categories.contains(name)) {
        categories.add(name);
      }
    }
  }
//--------------------------------------------------------------



  void requestToJoinGroup(String groupId) async {
    isGroupLoading.value = true;

    final success = await _groupServices.sendJoinRequest(groupId);

    if (success) {
      final index = allGroups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        allGroups[index] = allGroups[index].copyWith(isJoined: true);
      }

      Get.snackbar("İstek Gönderildi", "Gruba katılma isteğiniz gönderildi.");
    } else {
      Get.snackbar("Hata", "İstek gönderilemedi. Lütfen tekrar deneyin.");
    }

    isGroupLoading.value = false;
  }

  void joinGroup(String id) async {
    final success = await _groupServices.sendJoinRequest(id);

    if (success) {
      final index = allGroups.indexWhere((group) => group.id == id);
      if (index != -1) {
        allGroups[index] = allGroups[index].copyWith(isJoined: true);
        Get.snackbar("Katılım Başarılı",
            "${allGroups[index].name} grubuna katılım isteği gönderildi");
      }
    } else {
      Get.snackbar("Katılım Hatası", "Gruba katılma isteği gönderilemedi",
          backgroundColor: Colors.red.shade100);
    }
  }

  void getCreateGroup() {
    Get.toNamed("/createGroup");
  }

  void toggleNotification(bool value) {
    selectedRequest.value = value;
  }

  void getGrupDetail() {
    Get.toNamed("/group_detail_screen");
  }

  void getToGroupChatDetail(String groupId) {
    Get.toNamed("/group_chat_detail", arguments: {
      'groupId': groupId,
    });
  }

  void updateFilteredGroups() {
    if (selectedCategory.value == "All" || selectedCategory.value.isEmpty) {
      filteredGroups.value = allGroups;
    } else {
      // Kategori adına göre filtreleme → ID'yi bul, sonra filtrele
      final selectedId = categoryMap.entries
          .firstWhereOrNull((entry) => entry.value == selectedCategory.value)
          ?.key;

      filteredGroups.value = allGroups
          .where((group) => group.groupAreaId.toString() == selectedId)
          .toList();
    }
  }

  Future<void> fetchGroupDetail(String groupId) async {
    try {
      final group = await _groupServices.fetchGroupDetail(groupId);
      groupDetail.value = group as GroupDetailModel?;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load group details',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
