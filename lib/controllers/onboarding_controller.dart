import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/onboarding_service.dart';

class OnboardingController extends GetxController {
  RxString selectedSchool = "".obs;
  RxString selectedDepartment = "".obs;
  RxBool isLoading = false.obs;

  RxList<String> schools = <String>[].obs;
  RxList<String> departments = <String>[].obs;

  TextEditingController courseController = TextEditingController();
  RxList<String> courses = <String>[].obs;

  RxList<Map<String, dynamic>> groups = <Map<String, dynamic>>[].obs;


  String userEmail = ""; 

  @override
  void onInit() {
    super.onInit();
    fetchMockGroups();
    fetchSchoolAndDepartmentsByEmail(userEmail);
  }

  void addCourse() {
    if (courseController.text.isNotEmpty) {
      courses.add(courseController.text);
      courseController.clear();
    }
  }

  void removeCourse(String course) {
    courses.remove(course);
  }

  void proceedToNextStep2() {
    //alınan derlerin listeye eklenip gönderileceği alan
    isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.toNamed("/step3");
    });
  }

  void joinGroup(String groupName) {
    //gruba katılma isteği gönderilecek alan
    int index = groups.indexWhere((group) => group["name"] == groupName);
    if (index != -1) {
      groups[index]["action"] =
          "Katılım Bekleniyor"; 
      groups.refresh();
    }
  }



  void fetchSchoolAndDepartmentsByEmail(String email) async {
    //mail adresine göre okul bilgisinin otomatik alınıp o okula uygun bölümlerin listeleneceği alan
    isLoading.value = true;
    try {
      final data = await OnboardingServices.fetchSchoolAndDepartments(email);
      selectedSchool.value = data.school;
      schools.value = [data.school]; 

      departments.value = data.departments;
      if (departments.isNotEmpty) {
        selectedDepartment.value = departments.first;
      }
    } catch (e) {
      //print("Hata: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchMockGroups() {
    //tavsiye edilen grupların getireleceği alan
    groups.value = [
      {
        "name": "Murata hayranlar Grubu",
        "description":
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "members": 352,
        "image":
            "https://s3-alpha-sig.figma.com/img/8c4e/4ff3/89ac8c2d58aba07e899bb77bd953856d?Expires=1743379200&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=qGQa5IiGNaEeF13SE8zztRLAbCWiYwTvO7Bdk773NHK9cqXSO4GMViNXpOfFanoCYsdTlZuufkHrT1MFnLZf0t33qOmpMVXJ~TkpTegCig5Mh6GkSTKM5-~Qezza0rXNdSo99avvl35tEfVJXJYwCegZx63EObwtv94-Q-NGyIusKSpPUwMh4~CLg~mzKqD54gjnP~Kh5zZPbNvTnwppuNiArOOuqgOtyXGKtgAO4z6iSssGpNBsCtZkisnZ~fWkH3V4FHHIwL2Jlue2vSRvNUxu~QDt~XU341Dt59zu7pb3K8KUyPtlcWp3antWhvKlDT61aehR~b6NRKemvkjTyA__",
        "action": "Katılma İsteği Gönder"
      },
      {
        "name": "Teknoloji Severler",
        "description":
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "members": 500,
        "image":
            "https://s3-alpha-sig.figma.com/img/8c4e/4ff3/89ac8c2d58aba07e899bb77bd953856d?Expires=1743379200&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=qGQa5IiGNaEeF13SE8zztRLAbCWiYwTvO7Bdk773NHK9cqXSO4GMViNXpOfFanoCYsdTlZuufkHrT1MFnLZf0t33qOmpMVXJ~TkpTegCig5Mh6GkSTKM5-~Qezza0rXNdSo99avvl35tEfVJXJYwCegZx63EObwtv94-Q-NGyIusKSpPUwMh4~CLg~mzKqD54gjnP~Kh5zZPbNvTnwppuNiArOOuqgOtyXGKtgAO4z6iSssGpNBsCtZkisnZ~fWkH3V4FHHIwL2Jlue2vSRvNUxu~QDt~XU341Dt59zu7pb3K8KUyPtlcWp3antWhvKlDT61aehR~b6NRKemvkjTyA__",
        "action": "Gruba Katıl"
      }
    ];
  }

  void proceedToNextStep() {
    //okul-ders alanının seçilip gönderileceği alan
    isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.toNamed("/step2");
    });
  }

  void completeOnboarding() {
    //onboarding alanının tamamlama işleminin yapılacağı alan
    isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.offAllNamed("/main");
    });
  }
}
