import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../components/widgets/edusocial_dialog.dart';
import '../services/auth_service.dart';

class SignupController extends GetxController {

  TextEditingController nameSuController = TextEditingController();
  TextEditingController surnameSuController = TextEditingController();
  TextEditingController usernameSuController = TextEditingController();
  TextEditingController emailSuController = TextEditingController();
  TextEditingController passwordSuController = TextEditingController();
  TextEditingController confirmPasswordSuController = TextEditingController();

  final AuthService _authService = AuthService();

  var isAccepted = false.obs;
  var isSuLoading = false.obs;

  void toggleAcceptance() {
    isAccepted.value = !isAccepted.value;
  }

  void signup() async {
    if (!isAccepted.value) {
      EduSocialDialogs.showError(
        title: "Uyarı!",
        message: "Lütfen gizlilik sözleşmesini kabul edin.",
      );

      return;
    }
    if (usernameSuController.text.isEmpty ||
        emailSuController.text.isEmpty ||
        nameSuController.text.isEmpty ||
        surnameSuController.text.isEmpty ||
        passwordSuController.text.isEmpty ||
        confirmPasswordSuController.text.isEmpty) {
      EduSocialDialogs.showError(
        title: "Uyarı!",
        message: "Tüm alanları doldurmalısınız.",
      );
      return;
    }
    if (passwordSuController.text != confirmPasswordSuController.text) {
      EduSocialDialogs.showError(
        title: "Uyarı!",
        message: "Şifreler Eşleşmiyor.",
      );
      return;
    }

    isSuLoading.value = true;
    final success = await _authService.register(
      username: usernameSuController.text,
      name: nameSuController.text,
      surname: surnameSuController.text,
      email: emailSuController.text,
      password: passwordSuController.text,
      confirmPassword: confirmPasswordSuController.text,
    );
    isSuLoading.value = false;

    if (success) {
      EduSocialDialogs.showSuccess(
        title: "Başarılı!",
        message: "Kayıt işlemi başarı ile tamamlandı. Giriş yapabilirsiniz.",
      );
      Get.offAllNamed('/login');
    } else {
      EduSocialDialogs.showError(
        title: "Uyarı!",
        message: _authService.lastErrorMessage ?? "Kayıt işlemi başarısız.",
      );
    }
  }

  @override
  void onClose() {
    usernameSuController.dispose();
    emailSuController.dispose();
    passwordSuController.dispose();
    confirmPasswordSuController.dispose();
    super.onClose();
  }
}
