import 'package:edusocial/controllers/onboarding_controller.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_validator/email_validator.dart';

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

  bool _isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  String? _validateInputs() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      return "Lütfen tüm alanları doldurun.";
    }

    // Eğer e-posta formatında ise kontrol et
    if (emailController.text.contains('@') && !_isValidEmail(emailController.text)) {
      return "Geçerli bir e-posta adresi giriniz.";
    }

    return null;
  }

  void login() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      EduSocialDialogs.showError(
        title: "Uyarı!",
        message: validationError,
      );
      return;
    }

    isLoading.value = true;
    try {
      final user = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (user != null) {
        final schoolId = user['school_id'];
        final departmentId = user['school_department_id'];

        if (schoolId == null || departmentId == null) {
          /// İlk giriş, onboarding'e git
          final onboardingController = Get.find<OnboardingController>();
          onboardingController.userEmail = emailController.text;
          onboardingController.loadSchoolList();
          Get.offAllNamed('/step1');
        } else {
          /// Zaten onboarding tamamlamış, ana ekrana
          final storyController = Get.find<StoryController>();
          storyController.fetchStories();
          Get.offAllNamed('/main');
        }
      } else {
        EduSocialDialogs.showError(
          title: "Uyarı!",
          message: "Giriş işlemi başarısız. Lütfen bilgilerinizi kontrol edin.",
        );
      }
    } catch (e) {
      EduSocialDialogs.showError(
        title: "Hata!",
        message: "Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loginPasswordUpgrade() {
    // TODO: Implement password reset functionality
    Get.toNamed('/forgot-password');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
