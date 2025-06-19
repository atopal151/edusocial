import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../models/group_models/group_search_model.dart';
import '../models/user_search_model.dart';
import '../services/search_services.dart'; // Yeni ekledik ✅
import '../services/group_services/group_service.dart';

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

  final GroupServices _groupServices = GroupServices();

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

      debugPrint('🔍 Search results loaded:');
      debugPrint('🔍 Users: ${allUsers.length}');
      debugPrint('🔍 Groups: ${allGroups.length}');
      debugPrint('🔍 Events: ${allEvents.length}');
      
      // Debug group membership status
      for (var group in allGroups) {
        debugPrint('🔍 Group: ${group.name} - isMember: ${group.isMember} - isPending: ${group.isPending}');
      }

      debugPrint('allgroup: $allGroups');

      debugPrint('alluser: $allUsers');

      debugPrint('allevent: $allEvents');
    } catch (e) {
      debugPrint("❗ Arama hatası: $e",wrapWidth: 1024);
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

  // Grup katılma işlevi
  Future<void> joinGroup(int groupId) async {
    try {
      final success = await _groupServices.sendJoinRequest(groupId.toString());
      
      if (success) {
        // Başarılı ise grup listesini güncelle
        final groupIndex = allGroups.indexWhere((group) => group.id == groupId);
        if (groupIndex != -1) {
          // Grubun durumunu güncelle
          final updatedGroup = GroupSearchModel(
            id: allGroups[groupIndex].id,
            userId: allGroups[groupIndex].userId,
            groupAreaId: allGroups[groupIndex].groupAreaId,
            name: allGroups[groupIndex].name,
            description: allGroups[groupIndex].description,
            status: allGroups[groupIndex].status,
            isPrivate: allGroups[groupIndex].isPrivate,
            createdAt: allGroups[groupIndex].createdAt,
            updatedAt: allGroups[groupIndex].updatedAt,
            userCountWithAdmin: allGroups[groupIndex].userCountWithAdmin,
            userCountWithoutAdmin: allGroups[groupIndex].userCountWithoutAdmin,
            messageCount: allGroups[groupIndex].messageCount,
            isFounder: allGroups[groupIndex].isFounder,
            isMember: allGroups[groupIndex].isMember,
            isPending: true, // Bekleyen durumuna çevir
            avatarUrl: allGroups[groupIndex].avatarUrl,
            bannerUrl: allGroups[groupIndex].bannerUrl,
            humanCreatedAt: allGroups[groupIndex].humanCreatedAt,
          );
          
          allGroups[groupIndex] = updatedGroup;
          allGroups.refresh();
          
          // Filtered listeyi de güncelle
          final filteredIndex = filteredGroups.indexWhere((group) => group.id == groupId);
          if (filteredIndex != -1) {
            filteredGroups[filteredIndex] = updatedGroup;
            filteredGroups.refresh();
          }
        }
        
        Get.snackbar(
          "Başarılı", 
          "Gruba katılma isteğiniz gönderildi.",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      } else {
        Get.snackbar(
          "Hata", 
          "Gruba katılma isteği gönderilemedi. Lütfen tekrar deneyin.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Hata", 
        "Bir hata oluştu: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
}
