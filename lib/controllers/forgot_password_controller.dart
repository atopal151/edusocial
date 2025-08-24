import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_validator/email_validator.dart';
import '../components/widgets/edusocial_dialog.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';

class ForgotPasswordController extends GetxController {
  late TextEditingController emailController;
  var isLoading = false.obs;

  final AuthService _authService = AuthService();
  final LanguageService languageService = Get.find<LanguageService>();

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
  }

  bool _isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  String? _validateEmail() {
    if (emailController.text.isEmpty) {
      return languageService.tr("forgotPassword.validation.emailRequired");
    }

    if (!_isValidEmail(emailController.text)) {
      return languageService.tr("forgotPassword.validation.validEmailRequired");
    }

    return null;
  }

  void sendResetEmail() async {
    debugPrint("🔄 Şifre sıfırlama e-postası gönderme işlemi başlatılıyor...");
    
    final validationError = _validateEmail();
    if (validationError != null) {
      debugPrint("❌ Validation hatası: $validationError");
      EduSocialDialogs.showError(
        title: languageService.tr("common.warning"),
        message: validationError,
      );
      return;
    }

    debugPrint("✅ Validation başarılı, e-posta: ${emailController.text.trim()}");
    isLoading.value = true;
    
    try {
      debugPrint("📤 AuthService.sendForgotPasswordEmail() çağrılıyor...");
      final success = await _authService.sendForgotPasswordEmail(
        emailController.text.trim(),
      );

      debugPrint("📥 AuthService'den dönen sonuç: $success");

      if (success) {
        debugPrint("✅ Şifre sıfırlama e-postası başarıyla gönderildi");
        EduSocialDialogs.showSuccess(
          title: languageService.tr("forgotPassword.success.title"),
          message: languageService.tr("forgotPassword.success.message"),
        );
        // Başarılı olduktan sonra login ekranına dön
        Get.back();
      } else {
        debugPrint("❌ Şifre sıfırlama e-postası gönderilemedi");
        debugPrint("❌ AuthService lastErrorMessage: ${_authService.lastErrorMessage}");
        EduSocialDialogs.showError(
          title: languageService.tr("common.error"),
          message: _authService.lastErrorMessage ?? 
                   languageService.tr("forgotPassword.errors.sendFailed"),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("💥 Controller'da hata oluştu: $e");
      debugPrint("💥 Stack trace: $stackTrace");
      EduSocialDialogs.showError(
        title: languageService.tr("common.error"),
        message: languageService.tr("forgotPassword.errors.networkError"),
      );
    } finally {
      debugPrint("🏁 Şifre sıfırlama işlemi tamamlandı");
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
