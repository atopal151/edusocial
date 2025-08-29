// group_controller.dart
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:edusocial/models/group_models/group_detail_model.dart';
import 'package:edusocial/models/group_models/grup_suggestion_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/group_models/group_model.dart';
import '../../models/chat_models/group_chat_model.dart';
import '../../services/group_services/group_service.dart';
import '../../services/language_service.dart';
import '../../components/snackbars/custom_snackbar.dart';
import '../../components/print_full_text.dart';
import '../chat_controllers/chat_controller.dart';

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
    debugPrint("🔄 GroupController.fetchUserGroups() çağrıldı");
    
    try {
      // Hem kullanıcının gruplarını hem de tüm grupları al
      final userGroups = await _groupServices.fetchUserGroups();
      final allGroups = await _groupServices.fetchAllGroups();
      
      debugPrint("📥 API'den gelen user groups verisi (${userGroups.length} grup):");
      debugPrint("📥 API'den gelen all groups verisi (${allGroups.length} grup):");
      
      // Basit yaklaşım: Tüm gruplardan kullanıcının oluşturduğu veya üye olduğu olanları filtrele
      final accessibleGroups = allGroups.where((group) {
        // Kullanıcının oluşturduğu gruplar - her zaman göster
        if (group.isFounder) {
          debugPrint("✅ Group '${group.name}' gösteriliyor (kullanıcının oluşturduğu grup)");
          return true;
        }
        
        // Kullanıcının üye olduğu gruplar - her zaman göster
        if (group.isMember) {
          debugPrint("✅ Group '${group.name}' gösteriliyor (kullanıcının üye olduğu grup)");
          return true;
        }
        
        // Public gruplar - her zaman göster
        if (!group.isPrivate) {
          debugPrint("✅ Group '${group.name}' gösteriliyor (public grup)");
          return true;
        }
        
        // Private gruplar - sadece üye olan kullanıcılar görebilir
        if (group.isPrivate && group.isMember) {
          debugPrint("✅ Group '${group.name}' gösteriliyor (private grup, üye)");
          return true;
        } else {
          debugPrint("❌ Group '${group.name}' gizlendi (private grup, üye değil)");
          return false;
        }
      }).toList();
      
      debugPrint("🔍 Filtreleme sonucu: ${allGroups.length} gruptan ${accessibleGroups.length} grup gösteriliyor");
      
      // Filtreleme sonuçlarını detaylı yazdır
      printFullText("""
🎯 FİLTRELEME SONUÇLARI:
📊 Toplam grup sayısı: ${allGroups.length}
📊 Filtrelenmiş grup sayısı: ${accessibleGroups.length}
📊 Gizlenen grup sayısı: ${allGroups.length - accessibleGroups.length}
""");
      
      // Filtrelenmiş grupları listele
      for (int i = 0; i < accessibleGroups.length; i++) {
        final group = accessibleGroups[i];
        printFullText("""
✅ FİLTRELENMİŞ GRUP ${i + 1}:
  - ID: ${group.id}
  - Name: ${group.name}
  - Is Founder: ${group.isFounder}
  - Is Member: ${group.isMember}
  - Is Private: ${group.isPrivate}
  - Is Pending: ${group.isPending}
  ---
""");
      }
        
        // Her grubun JSON formatında tam verisini yazdır
        for (int i = 0; i < accessibleGroups.length; i++) {
          final group = accessibleGroups[i];
          final groupJson = {
            'id': group.id,
            'name': group.name,
            'description': group.description,
            'messageCount': group.messageCount,
            'humanCreatedAt': group.humanCreatedAt,
            'avatarUrl': group.avatarUrl,
            'bannerUrl': group.bannerUrl,
            'status': group.status,
            'isPrivate': group.isPrivate,
            'userCountWithAdmin': group.userCountWithAdmin,
            'userCountWithoutAdmin': group.userCountWithoutAdmin,
            'isFounder': group.isFounder,
            'isMember': group.isMember,
            'isPending': group.isPending,
            'createdAt': group.createdAt,
            'updatedAt': group.updatedAt,
          };
          printFullText('GROUP ${i + 1} FULL JSON DATA: ${groupJson}');
        }
        
        debugPrint("🔍 Filtreleme sonucu: ${allGroups.length} gruptan ${accessibleGroups.length} grup gösteriliyor");
      
      // printFullText kullanarak her grubun detaylı bilgilerini yazdır
      for (int i = 0; i < accessibleGroups.length; i++) {
        final group = accessibleGroups[i];
        final groupInfo = '''
🏷️ Group ${i + 1} - ${group.name}:
  - ID: ${group.id}
  - Name: ${group.name}
  - Description: ${group.description}
  - Message Count: ${group.messageCount}
  - Human Created At: ${group.humanCreatedAt}
  - Avatar URL: ${group.avatarUrl}
  - Banner URL: ${group.bannerUrl}
  - Status: ${group.status}
  - Is Private: ${group.isPrivate}
  - User Count With Admin: ${group.userCountWithAdmin}
  - User Count Without Admin: ${group.userCountWithoutAdmin}
  - Is Founder: ${group.isFounder}
  - Is Member: ${group.isMember}
  - Is Pending: ${group.isPending}
  - Created At: ${group.createdAt}
  - Updated At: ${group.updatedAt}
  ---
''';
        printFullText(groupInfo);
      }
      
                debugPrint("🔍 GroupController - userGroups.assignAll() çağrılıyor, accessibleGroups.length: ${accessibleGroups.length}");
          userGroups.assignAll(accessibleGroups);
          debugPrint("🔍 GroupController - userGroups.assignAll() tamamlandı, userGroups.length: ${userGroups.length}");
          
          // ChatController ile grup listesini senkronize et
          // Önce userGroups'ın güncellenmesini bekle
          await Future.delayed(Duration(milliseconds: 100));
          syncGroupListWithChatController();
      
      debugPrint("✅ User groups başarıyla yüklendi: ${filteredGroups.length} grup");
    } catch (e) {
      debugPrint("❌ User groups yüklenirken hata: $e");
    } finally {
      isLoading.value = false;
    }
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

  Future<void> fetchAllGroups() async {
    isLoading.value = true;
    allGroups.value = await _groupServices.fetchAllGroups();
    updateFilteredGroups(); // ✅ burada tetikleniyor
    isLoading.value = false;
  }

  Future<void> fetchGroupAreas() async {
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



  void sendJoinRequest(String groupId) async {
    isGroupLoading.value = true;

    final success = await _groupServices.sendJoinRequest(groupId);

    if (success) {
      final index = allGroups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        allGroups[index] = allGroups[index].copyWith(isJoined: true);
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

    isGroupLoading.value = false;
  }

  void joinGroup(String id) async {
    final success = await _groupServices.sendJoinRequest(id);

    if (success) {
      final index = allGroups.indexWhere((group) => group.id == id);
      if (index != -1) {
        allGroups[index] = allGroups[index].copyWith(isJoined: true);
        
        // Custom snackbar ile dil desteği
        final languageService = Get.find<LanguageService>();
        CustomSnackbar.show(
          title: languageService.tr("groups.success.joinedGroup"),
          message: "${allGroups[index].name} ${languageService.tr("groups.success.joinedGroup")}",
          type: SnackbarType.success,
          duration: const Duration(seconds: 3),
        );
      }
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

  /// 🔍 Grup arama filtresi
  void filterUserGroups(String value) {
    if (value.isEmpty) {
      // Arama boşsa tüm grupları göster - orijinal listeyi geri yükle
      fetchUserGroups();
    } else {
      final query = value.toLowerCase();
      // userGroups listesini filtrele
      userGroups.value = userGroups
          .where((group) => 
              group.name.toLowerCase().contains(query) ||
              group.description.toLowerCase().contains(query))
          .toList();
    }
  }

  /// 📊 Grup mesajlarının toplam okunmamış sayısını hesapla (ChatController'dan al)
  int get groupUnreadCount {
    try {
      // ChatController'dan grup unread count'unu al
      final chatController = Get.find<ChatController>();
      final unreadCount = chatController.groupUnreadCount;
      
      debugPrint("📊 GroupController.groupUnreadCount: $unreadCount (ChatController'dan alındı)");
      
      return unreadCount;
    } catch (e) {
      debugPrint("❌ GroupController.groupUnreadCount hatası: $e");
      return 0;
    }
  }

  /// 🔄 ChatController'daki grup listesini GroupController'daki verilerle senkronize et
  void syncGroupListWithChatController() {
    try {
      debugPrint("🔄 syncGroupListWithChatController() başladı - userGroups.length: ${userGroups.length}");
      final chatController = Get.find<ChatController>();
      
      // userGroups boşsa, allGroups'dan filtrele
      final groupsToSync = userGroups.isEmpty ? allGroups.where((group) => 
        group.isFounder || group.isMember || !group.isPrivate || (group.isPrivate && group.isMember)
      ).toList() : userGroups;
      debugPrint("🔄 Senkronize edilecek grup sayısı: ${groupsToSync.length}");
      
      // GroupController'daki userGroups'u ChatController'daki groupChatList ile senkronize et
      for (final userGroup in groupsToSync) {
        final chatGroupIndex = chatController.groupChatList.indexWhere((g) => g.groupId == int.parse(userGroup.id));
        
        if (chatGroupIndex != -1) {
          // ChatController'daki grubu güncelle
          final chatGroup = chatController.groupChatList[chatGroupIndex];
          chatGroup.groupName = userGroup.name;
          chatGroup.lastMessage = userGroup.description; // Geçici olarak description kullan
          chatGroup.lastMessageTime = userGroup.humanCreatedAt;
          
          // hasUnreadMessages durumunu da güncelle
          userGroup.hasUnreadMessages = chatGroup.hasUnreadMessages;
          
          debugPrint("🔄 Grup senkronize edildi: ${userGroup.name} (ID: ${userGroup.id}) - hasUnreadMessages: ${userGroup.hasUnreadMessages}");
        } else {
          // Yeni grup ekle
          final newChatGroup = GroupChatModel(
            groupId: int.parse(userGroup.id),
            groupName: userGroup.name,
            groupImage: userGroup.avatarUrl,
            lastMessage: userGroup.description,
            lastMessageTime: userGroup.humanCreatedAt,
            hasUnreadMessages: false, // Başlangıçta false
            isAdmin: userGroup.isFounder, // Kurucu bilgisini admin olarak aktar
          );
          
          chatController.groupChatList.add(newChatGroup);
          debugPrint("🔄 Yeni grup eklendi: ${userGroup.name} (ID: ${userGroup.id})");
        }
      }
      
      // GroupController'ı güncelle
      userGroups.refresh();
      debugPrint("🔄 GroupController userGroups listesi güncellendi - userGroups.length: ${userGroups.length}");
      
      // ChatController'ı güncelle
      chatController.groupChatList.refresh();
      
      debugPrint("✅ Grup listesi senkronizasyonu tamamlandı");
    } catch (e) {
      debugPrint("❌ Grup listesi senkronizasyon hatası: $e");
    }
  }

  /// 🎯 Dinamik buton metni için yardımcı metod
  String getButtonText(GroupModel group, LanguageService languageService) {
    // Eğer kullanıcı zaten üyeyse
    if (group.isMember) {
      return languageService.tr("groups.groupList.joined");
    }
    
    // Eğer grup gizli değilse (public) ve kullanıcı üye değilse
    if (!group.isPrivate && !group.isMember) {
      return languageService.tr("groups.groupList.join");
    }
    
    // Eğer grup gizli ise (private) ve kullanıcı başvuru yaptıysa
    if (group.isPrivate && group.isPending) {
      return languageService.tr("groups.suggestion.requestSent");
    }
    
    // Eğer grup gizli ise (private) ve kullanıcı daha başvuru yapmadıysa
    if (group.isPrivate && !group.isPending) {
      return languageService.tr("groups.suggestion.sendRequest");
    }
    
    // Varsayılan durum
    return languageService.tr("groups.groupList.join");
  }

  /// 🔄 Grup katılım durumunu güncelle (local state)
  void updateGroupJoinStatus(String groupId, bool isJoined) {
    // allGroups listesinde güncelle
    final allGroupsIndex = allGroups.indexWhere((g) => g.id == groupId);
    if (allGroupsIndex != -1) {
      allGroups[allGroupsIndex] = allGroups[allGroupsIndex].copyWith(isJoined: isJoined);
    }
    
    // filteredGroups listesinde güncelle
    final filteredGroupsIndex = filteredGroups.indexWhere((g) => g.id == groupId);
    if (filteredGroupsIndex != -1) {
      filteredGroups[filteredGroupsIndex] = filteredGroups[filteredGroupsIndex].copyWith(isJoined: isJoined);
    }
  }

  /// 🔄 Grup başvuru durumunu güncelle (local state)
  void updateGroupRequestStatus(String groupId, bool isPending) {
    // allGroups listesinde güncelle
    final allGroupsIndex = allGroups.indexWhere((g) => g.id == groupId);
    if (allGroupsIndex != -1) {
      allGroups[allGroupsIndex] = allGroups[allGroupsIndex].copyWith(isPending: isPending);
    }
    
    // filteredGroups listesinde güncelle
    final filteredGroupsIndex = filteredGroups.indexWhere((g) => g.id == groupId);
    if (filteredGroupsIndex != -1) {
      filteredGroups[filteredGroupsIndex] = filteredGroups[filteredGroupsIndex].copyWith(isPending: isPending);
    }
  }

  /// 🎯 Grup katılım işlemi (dinamik buton davranışı ile)
  void handleGroupJoin(String groupId) async {
    final group = allGroups.firstWhereOrNull((g) => g.id == groupId);
    if (group == null) return;

    // Eğer kullanıcı zaten üyeyse veya başvuru beklemedeyse, hiçbir şey yapma
    if (group.isMember || group.isPending) {
      return;
    }

    try {
      final success = await _groupServices.sendJoinRequest(groupId);
      
      if (success) {
        if (group.isPrivate) {
          // Gizli grup için başvuru durumunu güncelle
          updateGroupRequestStatus(groupId, true);
          
          // Custom snackbar ile dil desteği
          final languageService = Get.find<LanguageService>();
          CustomSnackbar.show(
            title: languageService.tr("groups.success.requestSent"),
            message: languageService.tr("groups.success.joinRequestSent"),
            type: SnackbarType.success,
            duration: const Duration(seconds: 3),
          );
        } else {
          // Açık grup için üyelik durumunu güncelle
          updateGroupJoinStatus(groupId, true);
          
          // Custom snackbar ile dil desteği
          final languageService = Get.find<LanguageService>();
          CustomSnackbar.show(
            title: languageService.tr("groups.success.joinedGroup"),
            message: "${group.name} ${languageService.tr("groups.success.joinedGroup")}",
            type: SnackbarType.success,
            duration: const Duration(seconds: 3),
          );
        }
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
