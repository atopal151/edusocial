import 'package:get/get.dart';

class OnboardingController extends GetxController {
  RxString selectedSchool = "".obs;
  RxString selectedDepartment = "".obs;
  RxBool isLoading = false.obs;

  RxList<String> schools = <String>[].obs;
  RxList<String> departments = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMockData();
  }

  void fetchMockData() async {
    await Future.delayed(Duration(milliseconds:500 )); // Simüle edilen gecikme
    schools.value = ["Monnet International School", "Another School", "Tech Academy", "Global High School"];
    departments.value = ["Computer Engineering", "Mathematics", "Physics", "Biology", "Chemistry"];

    // Eğer listeler boş değilse, varsayılan olarak ilk öğeyi seç
    if (schools.isNotEmpty) {
      selectedSchool.value = schools.first;
    }
    if (departments.isNotEmpty) {
      selectedDepartment.value = departments.first;
    }
  }

  void proceedToNextStep() {
    isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.toNamed("/step2");
    });
  }
}
