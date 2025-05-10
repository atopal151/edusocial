import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../models/group_models/group_search_model.dart';
import '../models/user_search_model.dart';
import '../services/search_services.dart'; // Yeni ekledik ✅

class SearchTextController extends GetxController {
  var searchTextController = TextEditingController();
  var searchQuery = "".obs;
  var selectedTab = 0.obs;
  var isSeLoading = false.obs;

  var allUsers = <UserSearchModel>[].obs;
  var allGroups = <GroupSearchModel>[].obs;
  var allEvents = <EventModel>[].obs;

  var filteredUsers = <UserSearchModel>[].obs;
  var filteredGroups = <GroupSearchModel>[].obs;
  var filteredEvents = <EventModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Uygulama açılırken boş arama yapmayacağız, kullanıcı yazdıkça fetch olacak
  }

  // Kullanıcı her arama yaptığında çağrılacak
  Future<void> fetchSearchResults(String query) async {
    searchQuery.value = query.trim();

    if (searchQuery.value.isEmpty) {
      clearResults();
      return;
    }

    isSeLoading.value = true;

    try {
      final response = await SearchServices.searchAll(query);

      // Gelen verileri ayırıyoruz
      allUsers.assignAll(response.users);
      allGroups.assignAll(response.groups);
      allEvents.assignAll(response.events);

      // Aynı zamanda filtered verileri de güncelliyoruz
      filteredUsers.assignAll(response.users);
      filteredGroups.assignAll(response.groups);
      filteredEvents.assignAll(response.events);
    } catch (e) {
      print("❗ Arama hatası: $e");
      clearResults();
    } finally {
      isSeLoading.value = false;
    }
  }

  void clearResults() {
    allUsers.clear();
    allGroups.clear();
    allEvents.clear();
    filteredUsers.clear();
    filteredGroups.clear();
    filteredEvents.clear();
  }

  // Eğer filtreli arama yapmak istersek (ekstra filtrelemeler için kullanılabilir)
  void filterResults(String query) {
    searchQuery.value = query.toLowerCase();
    filteredUsers.value = allUsers
        .where((user) => user.name.toLowerCase().contains(searchQuery.value))
        .toList();

    filteredGroups.value = allGroups
        .where((group) =>
            group.name.toLowerCase().contains(searchQuery.value) ||
            group.description.toLowerCase().contains(searchQuery.value))
        .toList();

    filteredEvents.value = allEvents
        .where((event) =>
            event.title.toLowerCase().contains(searchQuery.value) ||
            event.description.toLowerCase().contains(searchQuery.value))
        .toList();
  }
}
