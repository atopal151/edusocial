import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  var isLoading = false.obs;
  var isFirstLogin = true.obs; // Kullanıcının ilk kez giriş yapıp yapmadığını kontrol et

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Hata", "Lütfen tüm alanları doldurun.");
      return;
    }

    isLoading.value = true;
    await Future.delayed(Duration(seconds: 2)); // Mock API simülasyonu
    isLoading.value = false;

    Get.snackbar("Başarılı", "Giriş başarılı!");

    // Eğer kullanıcı ilk kez giriş yapıyorsa onboarding sayfalarına yönlendir
    if (isFirstLogin.value) {
      Future.delayed(Duration(milliseconds: 200), () {
        Get.offAllNamed('/step1');
      });
    } else {
      Future.delayed(Duration(milliseconds: 200), () {
        Get.offAllNamed('/home');
      });
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
