import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

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

  // Validation methods
  bool _isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  bool _isValidUsername(String username) {
    // Username should be 3-20 characters, alphanumeric and underscore only
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return usernameRegex.hasMatch(username);
  }

  String? _validateInputs() {
    if (!isAccepted.value) {
      return "Lütfen gizlilik sözleşmesini kabul edin.";
    }

    if (nameSuController.text.isEmpty ||
        surnameSuController.text.isEmpty ||
        usernameSuController.text.isEmpty ||
        emailSuController.text.isEmpty ||
        passwordSuController.text.isEmpty ||
        confirmPasswordSuController.text.isEmpty) {
      return "Tüm alanları doldurmalısınız.";
    }

    if (!_isValidEmail(emailSuController.text)) {
      return "Geçerli bir e-posta adresi giriniz.";
    }

    if (!_isValidUsername(usernameSuController.text)) {
      return "Kullanıcı adı 3-20 karakter arasında olmalı ve sadece harf, rakam ve alt çizgi içermelidir.";
    }

    if (passwordSuController.text != confirmPasswordSuController.text) {
      return "Şifreler eşleşmiyor.";
    }

    return null;
  }

  void toggleAcceptance() {
    isAccepted.value = !isAccepted.value;
  }

  void signup() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      EduSocialDialogs.showError(
        title: "Uyarı!",
        message: validationError,
      );
      return;
    }

    isSuLoading.value = true;
    try {
      final success = await _authService.register(
        username: usernameSuController.text.trim(),
        name: nameSuController.text.trim(),
        surname: surnameSuController.text.trim(),
        email: emailSuController.text.trim(),
        password: passwordSuController.text,
        confirmPassword: confirmPasswordSuController.text,
      );

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
    } catch (e) {
      EduSocialDialogs.showError(
        title: "Hata!",
        message: "Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.",
      );
    } finally {
      isSuLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameSuController.dispose();
    surnameSuController.dispose();
    usernameSuController.dispose();
    emailSuController.dispose();
    passwordSuController.dispose();
    confirmPasswordSuController.dispose();
    super.onClose();
  }
}
