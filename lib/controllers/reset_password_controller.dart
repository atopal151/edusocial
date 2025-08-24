import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/widgets/edusocial_dialog.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';

class ResetPasswordController extends GetxController {
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  var isLoading = false.obs;
  
  String token = '';
  String email = '';

  final AuthService _authService = AuthService();
  final LanguageService languageService = Get.find<LanguageService>();

  @override
  void onInit() {
    super.onInit();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  String? _validateInputs() {
    if (newPasswordController.text.isEmpty) {
      return languageService.tr("resetPassword.validation.newPasswordRequired");
    }

    if (confirmPasswordController.text.isEmpty) {
      return languageService.tr("resetPassword.validation.confirmPasswordRequired");
    }

    if (newPasswordController.text.length < 6) {
      return languageService.tr("resetPassword.validation.passwordMinLength");
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      return languageService.tr("resetPassword.validation.passwordsDoNotMatch");
    }

    return null;
  }

  void resetPassword() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      EduSocialDialogs.showError(
        title: languageService.tr("common.warning"),
        message: validationError,
      );
      return;
    }

    isLoading.value = true;
    try {
      bool success;
      
      if (token.isNotEmpty) {
        // Token ile şifre sıfırla
        success = await _authService.resetPasswordWithToken(
          token: token,
          newPassword: newPasswordController.text,
          confirmPassword: confirmPasswordController.text,
        );
      } else if (email.isNotEmpty) {
        // E-posta ile şifre sıfırla
        success = await _authService.resetPasswordByEmail(
          email: email,
          newPassword: newPasswordController.text,
          confirmPassword: confirmPasswordController.text,
        );
      } else {
        EduSocialDialogs.showError(
          title: languageService.tr("common.error"),
          message: languageService.tr("resetPassword.errors.invalidRequest"),
        );
        return;
      }

      if (success) {
        EduSocialDialogs.showSuccess(
          title: languageService.tr("resetPassword.success.title"),
          message: languageService.tr("resetPassword.success.message"),
        );
        // Başarılı olduktan sonra login ekranına dön
        Get.offAllNamed('/login');
      } else {
        EduSocialDialogs.showError(
          title: languageService.tr("common.error"),
          message: _authService.lastErrorMessage ?? 
                   languageService.tr("resetPassword.errors.resetFailed"),
        );
      }
    } catch (e) {
      EduSocialDialogs.showError(
        title: languageService.tr("common.error"),
        message: languageService.tr("resetPassword.errors.networkError"),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
