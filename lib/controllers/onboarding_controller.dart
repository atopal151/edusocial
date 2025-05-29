import 'package:edusocial/components/widgets/edusocial_dialog.dart';
import 'package:edusocial/models/group_models/group_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/onboarding_service.dart';

class OnboardingController extends GetxController {
  RxString selectedSchool = "".obs;
  RxString selectedDepartment = "".obs;
  int? selectedSchoolId;
  int? selectedDepartmentId;
  RxString warningMessage = ''.obs;
  RxBool isLoading = false.obs;

  RxList<Map<String, dynamic>> schools = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> departments = <Map<String, dynamic>>[].obs;

  TextEditingController courseController = TextEditingController();
  RxList<String> courses = <String>[].obs;

  RxList<GroupModel> groups = <GroupModel>[].obs;

  String userEmail = "";

  //-------------------------------------------------------------//
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
    int index = groups.indexWhere((group) => group.name == groupName);
    if (index != -1) {
      final groupId = int.tryParse(groups[index].id) ?? 0;
      final success = await OnboardingServices.requestGroupJoin(groupId);

      if (success) {
        final updatedGroup = groups[index].copyWith(isJoined: true);
        groups[index] = updatedGroup;
        groups.refresh();
      } else {
        Get.snackbar("İşlem Başarısız", "Gruba katılım isteği gönderilemedi.");
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
    if (selectedSchoolId != null && selectedDepartmentId != null) {
      isLoading.value = true;

      // 🔥 Önce submit işlemini yap
      final success = await submitSchoolAndDepartment();

      if (success) {
        // ✅ Eğer kayıt başarılıysa Step2'ye geç
        Get.toNamed("/step2");
      } else {
        // ❌ Başarısızsa ekrana mesaj bas (isteğe bağlı)
        Get.snackbar("Hata", "Okul ve bölüm bilgileri kaydedilemedi.");
      }

      isLoading.value = false;
    } else {
      Get.snackbar(
          "Eksik Bilgi", "Lütfen okul ve bölüm seçimini tamamlayınız.");
    }
  }

  //-------------------------------------------------------------//
  void completeOnboarding() {
    //onboarding alanının tamamlama işleminin yapılacağı alan
    isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.offAllNamed("/main");
    });
  }

  //-------------------------------------------------------------//

  //-------------------------------------------------------------//

  //-------------------------------------------------------------//

  //-------------------------------------------------------------//
}
