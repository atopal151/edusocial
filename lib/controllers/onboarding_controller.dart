import 'package:edusocial/components/widgets/edusocial_dialog.dart';
import 'package:edusocial/components/snackbars/custom_snackbar.dart';
import 'package:edusocial/models/group_models/group_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/onboarding_service.dart';
import '../services/language_service.dart';
import '../controllers/profile_controller.dart';
import '../controllers/group_controller/group_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/post_controller.dart';
import '../controllers/appbar_controller.dart';
import '../controllers/entry_controller.dart';
import '../controllers/match_controller.dart';
import '../controllers/story_controller.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingController extends GetxController {
  RxString selectedSchool = "".obs;
  RxString selectedDepartment = "".obs;
  int? selectedSchoolId;
  int? selectedDepartmentId;
  RxString warningMessage = ''.obs;
  RxBool isLoading = false.obs;
  var savedTopics = <String>[].obs;


  RxList<Map<String, dynamic>> schools = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> departments = <Map<String, dynamic>>[].obs;

  TextEditingController courseController = TextEditingController();
  RxList<String> courses = <String>[].obs;

  RxList<GroupModel> groups = <GroupModel>[].obs;

  String userEmail = "";

  //-------------------------------------------------------------//


  Future<void> _reloadAllData() async {
    try {
      debugPrint("🔄 Login sonrası veriler yeniden yükleniyor...");
      
      // Sadece mevcut controller'ları kullan
      final profileController = Get.find<ProfileController>();
      final groupController = Get.find<GroupController>();
      final notificationController = Get.find<NotificationController>();
      final appBarController = Get.find<AppBarController>();
      final storyController = Get.find<StoryController>();

      // Sıralı olarak tüm verileri yükle
      profileController.loadProfile();
      groupController.fetchUserGroups();
      groupController.fetchAllGroups();
      groupController.fetchSuggestionGroups();
      groupController.fetchGroupAreas();
      notificationController.fetchNotifications();
      appBarController.fetchAndSetProfileImage();
      storyController.fetchStories();

      debugPrint("✅ Login sonrası veriler başarıyla yüklendi");
      
  
      
    } catch (e) {
      debugPrint("❌ Veri yeniden yükleme hatası: $e");
    }
  }


  void addCourse() {
    if (courseController.text.isNotEmpty) {
      if (!courses.contains(courseController.text)) {
        courses.add(courseController.text);
      } else {
        EduSocialDialogs.showError(
          title: "Uyarı",
          message: "Bu dersi zaten eklediniz.",
        );
      }
      courseController.clear();
    }
  }

  //-------------------------------------------------------------//
  void removeCourse(String course) {
    courses.remove(course);
  }

  //-------------------------------------------------------------//
  void proceedToNextStep2() async {
    isLoading.value = true;

    try {
      for (var course in courses) {
        bool success = await OnboardingServices.addLesson(course);
        if (!success) {
          EduSocialDialogs.showError(
            title: "Ders Zaten Eklenmiş",
            message: "'$course' dersi daha önce eklenmiş.",
          );

          isLoading.value = false;
        } else {
          await fetchGroupsFromApi();
          isLoading.value = false;
          Get.toNamed("/step3");
        }
      }
    } catch (e) {
      debugPrint("❗ Ders ekleme işlemlerinde hata: $e", wrapWidth: 1024);
      isLoading.value = false;
    }
  }

  //-------------------------------------------------------------//
  void joinGroup(String groupName) async {
    final languageService = Get.find<LanguageService>();
    int index = groups.indexWhere((group) => group.name == groupName);
    if (index != -1) {
      final group = groups[index];
      
      // Önce grup durumunu kontrol et
      if (group.isMember) {
        CustomSnackbar.show(
          title: languageService.tr("common.warning"),
          message: languageService.tr("step3.errors.groupAlreadyJoined"),
          type: SnackbarType.warning,
        );
        return;
      }
      
      if (group.isPending) {
        CustomSnackbar.show(
          title: languageService.tr("common.warning"),
          message: languageService.tr("step3.errors.groupRequestPending"),
          type: SnackbarType.warning,
        );
        return;
      }

      final groupId = int.tryParse(group.id) ?? 0;
      if (groupId == 0) {
        CustomSnackbar.show(
          title: languageService.tr("common.error"),
          message: languageService.tr("step3.errors.invalidGroupId"),
          type: SnackbarType.error,
        );
        return;
      }

      final success = await OnboardingServices.requestGroupJoin(groupId);

      if (success) {
        // Reactivity için daha güvenli bir yaklaşım
        final updatedGroup = group.copyWith(isPending: true);
        
        // Listeyi tamamen yeniden oluştur
        final updatedGroups = List<GroupModel>.from(groups);
        updatedGroups[index] = updatedGroup;
        groups.assignAll(updatedGroups);
        
        // Ek güvenlik için refresh çağrısı
        groups.refresh();
        
        // Debug için
        debugPrint("✅ Grup durumu güncellendi: ${updatedGroup.name} - isPending: ${updatedGroup.isPending}");
        
        CustomSnackbar.show(
          title: languageService.tr("step3.success.title"),
          message: languageService.tr("step3.success.joinRequestSent"),
          type: SnackbarType.success,
        );
      } else {
        CustomSnackbar.show(
          title: languageService.tr("common.error"),
          message: languageService.tr("step3.snackbars.joinRequestFailed"),
          type: SnackbarType.error,
        );
      }
    }
  }

  //-------------------------------------------------------------//
  /// Okul listesini yükle
  Future<void> loadSchoolList() async {
    // debugPrint("🌟 loadSchoolList çağrıldı.");
    isLoading.value = true;
    try {
      final data = await OnboardingServices.fetchSchools();
      //debugPrint("🌟 fetchSchools tamamlandı, data: $data",wrapWidth: 1024);
      schools.assignAll(data);

      if (schools.isNotEmpty) {
        selectedSchool.value = schools.first['name'];
        selectedSchoolId = schools.first['id'];
        _loadDepartmentsForSelectedSchool();
      }
    } catch (e) {
      debugPrint("❗ Okul listesi yüklenirken hata: $e", wrapWidth: 1024);
    } finally {
      isLoading.value = false;
    }
  }

  /// Seçilen okul değişince bölümleri yükle
  Future<void> onSchoolChanged(String schoolName) async {
    final selected =
        schools.firstWhereOrNull((school) => school['name'] == schoolName);

    if (selected != null) {
      selectedSchool.value = selected['name'];
      selectedSchoolId = selected['id'];
      _loadDepartmentsForSelectedSchool();
    }
  }

  /// Seçilen okulun bölümlerini yükler
  void _loadDepartmentsForSelectedSchool() {
    final selected =
        schools.firstWhereOrNull((school) => school['id'] == selectedSchoolId);
    if (selected != null && selected['departments'] != null) {
      departments.assignAll(
        (selected['departments'] as List)
            .map<Map<String, dynamic>>((d) => {
                  "id": d['id'],
                  "title": d['title'],
                })
            .toList(),
      );

      if (departments.isNotEmpty) {
        selectedDepartment.value = departments.first['title'];
        selectedDepartmentId = departments.first['id'];
      }
    }
  }

  /// Bölüm seçildiğinde çalışır
  void onDepartmentChanged(String departmentName) {
    final selected =
        departments.firstWhereOrNull((d) => d['title'] == departmentName);

    if (selected != null) {
      selectedDepartment.value = selected['title'];
      selectedDepartmentId = selected['id'];
    }
  }

  /// Okul ve bölümü backend'e kaydet
  Future<bool> submitSchoolAndDepartment() async {
    if (selectedSchoolId != null && selectedDepartmentId != null) {
      //debugPrint("📤 Okul ve Bölüm Gönderiliyor:");
      //debugPrint("📚 School ID: $selectedSchoolId");
      //debugPrint("🏛️ Department ID: $selectedDepartmentId");

      final success = await OnboardingServices.updateSchool(
        schoolId: selectedSchoolId!,
        departmentId: selectedDepartmentId!,
      );

      return success;
    } else {
      return false;
    }
  }

  //-------------------------------------------------------------//
  Future<void> fetchGroupsFromApi() async {
    isLoading.value = true;
    try {
      final List<GroupModel> data = await OnboardingServices.fetchAllGroups();
      groups.assignAll(data);
      debugPrint('Groups: $groups');
    } catch (e) {
      debugPrint("❗ Grup verileri alınamadı: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //-------------------------------------------------------------//
  void proceedToNextStep() async {
    final languageService = Get.find<LanguageService>();
    
    if (selectedSchoolId != null && selectedDepartmentId != null) {
      isLoading.value = true;

      // 🔥 Önce submit işlemini yap
      final success = await submitSchoolAndDepartment();

      if (success) {
        // ✅ Eğer kayıt başarılıysa Step2'ye geç
        Get.toNamed("/step2");
      } else {
        // ❌ Başarısızsa ekrana mesaj bas (isteğe bağlı)
        CustomSnackbar.show(
          title: languageService.tr("common.error"),
          message: languageService.tr("step1.errors.schoolUpdateFailed"),
          type: SnackbarType.error,
        );
      }

      isLoading.value = false;
    } else {
      CustomSnackbar.show(
        title: languageService.tr("step1.snackbars.missingInfo"),
        message: languageService.tr("step1.snackbars.schoolSelectionRequired"),
        type: SnackbarType.warning,
      );
    }
  }

  //-------------------------------------------------------------//
  void completeOnboarding() async {
    //onboarding alanının tamamlama işleminin yapılacağı alan
    isLoading.value = true;
    
    try {
      debugPrint("🔄 Onboarding tamamlanıyor...");
      
      // Tüm verileri yeniden yükle ve tamamlanmasını bekle
      await _reloadAllData();
      
      debugPrint("✅ Onboarding tamamlandı, ana ekrana geçiliyor...");
      
      isLoading.value = false;
      Get.offAllNamed("/main");
      
    } catch (e) {
      debugPrint("❌ Onboarding tamamlama hatası: $e");
      isLoading.value = false;
      
      // Hata durumunda yine de ana ekrana geç
      Get.offAllNamed("/main");
    }
  }

  

  //-------------------------------------------------------------//

  //-------------------------------------------------------------//

  //-------------------------------------------------------------//

  //-------------------------------------------------------------//
}

