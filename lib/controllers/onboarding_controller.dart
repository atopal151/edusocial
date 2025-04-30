import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/onboarding_service.dart';

class OnboardingController extends GetxController {
  RxString selectedSchool = "".obs;
  RxString selectedDepartment = "".obs;
  RxBool isLoading = false.obs;

  RxList<Map<String, dynamic>> schools =
      <Map<String, dynamic>>[].obs; // ✅ id ve name
  RxList<String> departments = <String>[].obs;

  TextEditingController courseController = TextEditingController();
  RxList<String> courses = <String>[].obs;

  RxList<Map<String, dynamic>> groups = <Map<String, dynamic>>[].obs;

  String userEmail = "";
  int? selectedSchoolId;

  @override
  void onInit() {
    super.onInit();
    //fetchGroupsFromApi();
  }

  //-------------------------------------------------------------//
  void addCourse() {
    if (courseController.text.isNotEmpty) {
      courses.add(courseController.text);
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
      // Dersleri sırayla kaydet
      for (var course in courses) {
        bool success = await OnboardingServices.addLesson(course);
        if (!success) {
          print("❗ Ders eklenemedi: $course");
        }
      }

      // Tüm dersler eklenince Step3'e geç
      await fetchGroupsFromApi();
      isLoading.value = false;
      Get.toNamed("/step3");
    } catch (e) {
      print("❗ Ders ekleme işlemlerinde hata: $e");
      isLoading.value = false;
    }
  }

  //-------------------------------------------------------------//
  void joinGroup(String groupName) async {
    int index = groups.indexWhere((group) => group["name"] == groupName);
    if (index != -1 && groups[index]["id"] != null) {
      final groupId = groups[index]["id"];
      final success = await OnboardingServices.requestGroupJoin(groupId);
      if (success) {
        groups[index]["action"] = "Katılım Bekleniyor";
        groups.refresh();
      } else {
        Get.snackbar("İşlem Başarısız", "Gruba katılım isteği gönderilemedi.");
      }
    }
  }

  //-------------------------------------------------------------//
  void loadSchoolList() async {
    print("🌟 loadSchoolList çağrıldı.");
    isLoading.value = true;
    try {
      final data = await OnboardingServices.fetchSchools();
      print("🌟 fetchSchools tamamlandı, data: $data");
      schools.assignAll(data);
      if (schools.isNotEmpty) {
        selectedSchool.value = schools.first['name'];
        selectedSchoolId = schools.first['id'];
        loadDepartments(selectedSchoolId!);
      }
    } catch (e) {
      print("Okul listesi yüklenirken hata: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //-------------------------------------------------------------//
  Future<void> loadDepartments(int schoolId) async {
    isLoading.value = true;
    try {
      final data = await OnboardingServices.fetchDepartments(schoolId);
      departments.assignAll(data);
      if (departments.isNotEmpty) {
        selectedDepartment.value = departments.first;
      }
    } catch (e) {
      print("Bölüm listesi yüklenirken hata: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //-------------------------------------------------------------//
  Future<void> onSchoolChanged(String schoolName) async {
    final selected =
        schools.firstWhereOrNull((school) => school['name'] == schoolName);
    if (selected != null) {
      selectedSchool.value = selected['name'];
      selectedSchoolId = selected['id'];

      isLoading.value = true;
      await loadDepartments(selectedSchoolId!);
      isLoading.value = false;
    }
  }

  //-------------------------------------------------------------//
  /*
  void fetchMockGroups() {
    //tavsiye edilen grupların getireleceği alan
    groups.value = [
      {
        "name": "Murata hayranlar Grubu",
        "description":
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "members": 352,
        "image":
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "action": "Katılma İsteği Gönder"
      },
      {
        "name": "Teknoloji Severler",
        "description":
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "members": 500,
        "image":
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "action": "Gruba Katıl"
      },
      {
        "name": "Teknoloji Severler",
        "description":
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "members": 500,
        "image":
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "action": "Gruba Katıl"
      },
      {
        "name": "Teknoloji Severler",
        "description":
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "members": 500,
        "image":
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "action": "Gruba Katıl"
      },
      {
        "name": "Teknoloji Severler",
        "description":
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "members": 500,
        "image":
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "action": "Gruba Katıl"
      }
    ];
  }*/
  Future<void> fetchGroupsFromApi() async {
    isLoading.value = true;
    try {
      final data = await OnboardingServices.fetchAllGroups();
      groups.assignAll(data);
    } catch (e) {
      print("❗ Grup verileri alınamadı: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //-------------------------------------------------------------//
  void proceedToNextStep() {
    //okul-ders alanının seçilip gönderileceği alan
    isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.toNamed("/step2");
    });
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
