import 'package:edusocial/controllers/onboarding_controller.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/widgets/edusocial_dialog.dart';
import '../services/auth_service.dart';

class LoginController extends GetxController {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  var isLoading = false.obs;
  var isFirstLogin =
      true.obs; // Kullanıcının ilk kez giriş yapıp yapmadığını kontrol et

  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      EduSocialDialogs.showError(
        title: "Uyarı!",
        message: "Lütfen tüm alanları doldurun.",
      );
      return;
    }

    isLoading.value = true;
    final user =
        await _authService.login(emailController.text, passwordController.text);
    isLoading.value = false;

    if (user != null) {
      final schoolId = user['school_id'];
      final departmentId = user['school_department_id'];

      if (schoolId == null || departmentId == null) {
        /// İlk giriş, onboarding'e git
        final onboardingController = Get.find<OnboardingController>();
        onboardingController.userEmail = emailController.text;
        onboardingController.loadSchoolList();

        Future.delayed(Duration(milliseconds: 200), () {
          Get.offAllNamed('/step1');
        });
      } else {
        /// Zaten onboarding tamamlamış, ana ekrana
        Future.delayed(Duration(milliseconds: 200), () {
          final storyController = Get.find<StoryController>();
          storyController.fetchStories();
          Get.offAllNamed('/home');
        });
      }
    } else {
      EduSocialDialogs.showError(
        title: "Uyarı!",
        message: "Giriş işlemi başarısız. Lütfen bilgilerinizi kontrol edin.",
      );
    }
  }

  void loginPasswordUpgrade() {
    Get.snackbar("Mesaj", "Şifre Yenileme Alanına Yönlendirileceksiniz.");
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
