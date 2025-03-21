import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  RxString selectedSchool = "".obs;
  RxString selectedDepartment = "".obs;
  RxBool isLoading = false.obs;

  RxList<String> schools = <String>[].obs;
  RxList<String> departments = <String>[].obs;

  TextEditingController courseController = TextEditingController();
  RxList<String> courses = <String>[].obs;

  RxList<Map<String, dynamic>> groups = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMockData();
    fetchMockGroups();
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
    isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.toNamed("/step3");
    });
  }

  void joinGroup(String groupName) {
    int index = groups.indexWhere((group) => group["name"] == groupName);
    if (index != -1) {
      groups[index]["action"] =
          "Katılım Bekleniyor"; // Butonun durumunu güncelle
      groups.refresh(); // GetX state'ini güncelle
    }
  }

  void fetchMockData() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simüle edilen gecikme
    schools.value = [
      "Monnet International School",
      "Another School",
      "Tech Academy",
      "Global High School"
    ];
    departments.value = [
      "Computer Engineering",
      "Mathematics",
      "Physics",
      "Biology",
      "Chemistry"
    ];

    // Eğer listeler boş değilse, varsayılan olarak ilk öğeyi seç
    if (schools.isNotEmpty) {
      selectedSchool.value = schools.first;
    }
    if (departments.isNotEmpty) {
      selectedDepartment.value = departments.first;
    }
  }

  void fetchMockGroups() {
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
    isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.toNamed("/step2");
    });
  }

  void completeOnboarding() {
    isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.offAllNamed("/main");

    });
  }
}
