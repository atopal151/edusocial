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
            "https://s3-alpha-sig.figma.com/img/3844/67b6/9a7af0a5ea570e42f1e57aa8c0dce977?Expires=1742169600&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=dpl~~832qT8X30X2DoCvjWZboIq-cOAy~tXZFt7K3uNYvm1E7aW4eGsUf87A76LOrtGlLhY5ULmuV7j2cXKGvSwprP2UNopvDwGhKEKn3-NvF1bercxX5GoIU5aeu5E5PuUnzwCiYbZgMKuRQSL4ZchwatFtekIOW-P4ZN6WIc6Rxdhw6QtNQlsSJ1RGK7suXRgBffILxAs7x7xsYp3btvE1-Jqm63uRI6uM8DKH8E5KAoYcbO6fKA0~jLu2MpA1w114iT~wV5wRe9l9qnP68HjJj~LaYIm2pbnFVA84HnhZP0LBRSJxKRrGxnHuoRkEe7d3jggnx~W2IG2YEZH3gg__",
        "action": "Katılma İsteği Gönder"
      },
      {
        "name": "Teknoloji Severler",
        "description":
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "members": 500,
        "image":
            "https://s3-alpha-sig.figma.com/img/3844/67b6/9a7af0a5ea570e42f1e57aa8c0dce977?Expires=1742169600&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=dpl~~832qT8X30X2DoCvjWZboIq-cOAy~tXZFt7K3uNYvm1E7aW4eGsUf87A76LOrtGlLhY5ULmuV7j2cXKGvSwprP2UNopvDwGhKEKn3-NvF1bercxX5GoIU5aeu5E5PuUnzwCiYbZgMKuRQSL4ZchwatFtekIOW-P4ZN6WIc6Rxdhw6QtNQlsSJ1RGK7suXRgBffILxAs7x7xsYp3btvE1-Jqm63uRI6uM8DKH8E5KAoYcbO6fKA0~jLu2MpA1w114iT~wV5wRe9l9qnP68HjJj~LaYIm2pbnFVA84HnhZP0LBRSJxKRrGxnHuoRkEe7d3jggnx~W2IG2YEZH3gg__",
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
