import 'package:get/get.dart';

class OnboardingController extends GetxController {
  RxString selectedSchool = "Monnet International School".obs;
  RxString selectedDepartment = "Computer Engineering".obs;
  RxBool isLoading = false.obs;

  void proceedToNextStep() {
    isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      Get.toNamed("/step2");
    });
  }
}