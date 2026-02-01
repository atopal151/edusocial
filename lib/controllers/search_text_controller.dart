import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../models/group_models/group_search_model.dart';
import '../models/user_search_model.dart';
import '../services/search_services.dart'; // Yeni ekledik ✅
import '../services/group_services/group_service.dart';
import '../services/language_service.dart';
import '../components/snackbars/custom_snackbar.dart';

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
      
      // Sort events by expiration status before assigning
      var sortedEvents = response.events.toList();
      sortedEvents.sort((a, b) {
        bool aExpired = _isEventExpired(a);
        bool bExpired = _isEventExpired(b);
        
        // If one is expired and other is not, put active first
        if (aExpired != bExpired) {
          return aExpired ? 1 : -1; // Active events (not expired) come first
        }
        
        // If both have same expiration status, sort by end time (newer first)
        try {
          final dateA = DateTime.parse(a.endTime);
          final dateB = DateTime.parse(b.endTime);
          return dateB.compareTo(dateA); // Newer events first
        } catch (e) {
          return 0; // Keep original order if date parsing fails
        }
      });
      
      filteredEvents.assignAll(sortedEvents);

      debugPrint('🔍 Search results loaded:');
      debugPrint('🔍 Users: ${allUsers.length}');
      debugPrint('🔍 Groups: ${allGroups.length}');
      debugPrint('🔍 Events: ${allEvents.length}');
      
      for(var user in allUsers) {
        debugPrint('🔍 User: ${user.name} - isVerified: ${user.isVerified}');
      }
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

  // Helper method to check if event has expired
  bool _isEventExpired(EventModel event) {
    try {
      final endTime = DateTime.parse(event.endTime);
      return DateTime.now().isAfter(endTime);
    } catch (e) {
      return false; // If date parsing fails, assume not expired
    }
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

    // Filter events and sort by expiration status (active events first)
    var eventsToFilter = allEvents
        .where((event) =>
            event.title.toLowerCase().contains(searchQuery.value) ||
            event.description.toLowerCase().contains(searchQuery.value))
        .toList();
    
    // Sort events: active events first, then expired events
    eventsToFilter.sort((a, b) {
      bool aExpired = _isEventExpired(a);
      bool bExpired = _isEventExpired(b);
      
      // If one is expired and other is not, put active first
      if (aExpired != bExpired) {
        return aExpired ? 1 : -1; // Active events (not expired) come first
      }
      
      // If both have same expiration status, sort by end time (newer first)
      try {
        final dateA = DateTime.parse(a.endTime);
        final dateB = DateTime.parse(b.endTime);
        return dateB.compareTo(dateA); // Newer events first
      } catch (e) {
        return 0; // Keep original order if date parsing fails
      }
    });
    
    filteredEvents.value = eventsToFilter;
  }

  // Grup katılma işlevi
  Future<void> joinGroup(int groupId) async {
    try {
      final success = await _groupServices.sendJoinRequest(groupId.toString());
      
      if (success) {
        // Grup listesinde durumu güncelle
        final groupIndex = allGroups.indexWhere((group) => group.id == groupId);
        if (groupIndex != -1) {
          final originalGroup = allGroups[groupIndex];
          final updatedGroup = GroupSearchModel(
            id: originalGroup.id,
            userId: originalGroup.userId,
            groupAreaId: originalGroup.groupAreaId,
            name: originalGroup.name,
            description: originalGroup.description,
            status: originalGroup.status,
            isPrivate: originalGroup.isPrivate,
            createdAt: originalGroup.createdAt,
            updatedAt: originalGroup.updatedAt,
            userCountWithAdmin: originalGroup.userCountWithAdmin,
            userCountWithoutAdmin: originalGroup.userCountWithoutAdmin,
            messageCount: originalGroup.messageCount,
            isFounder: originalGroup.isFounder,
            isMember: originalGroup.isMember,
            isPending: true, // Sadece bu değişiyor
            avatarUrl: originalGroup.avatarUrl,
            bannerUrl: originalGroup.bannerUrl,
            humanCreatedAt: originalGroup.humanCreatedAt,
          );
          
          allGroups[groupIndex] = updatedGroup;
          
          final filteredIndex = filteredGroups.indexWhere((group) => group.id == groupId);
          if (filteredIndex != -1) {
            filteredGroups[filteredIndex] = updatedGroup;
          }
        }
        
        // Custom snackbar ile dil desteği
        final languageService = Get.find<LanguageService>();
        CustomSnackbar.show(
          title: languageService.tr("groups.success.requestSent"),
          message: languageService.tr("groups.success.joinRequestSent"),
          type: SnackbarType.success,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Hata durumu için custom snackbar
        final languageService = Get.find<LanguageService>();
        CustomSnackbar.show(
          title: languageService.tr("common.error"),
          message: languageService.tr("groups.errors.joinFailed"),
          type: SnackbarType.error,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      debugPrint("❗ Grup katılma hatası: $e");
      // Hata durumu için custom snackbar
      final languageService = Get.find<LanguageService>();
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("groups.errors.serverError"),
        type: SnackbarType.error,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
