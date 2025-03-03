import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      // Burada giriş işlemi yapılacak (API çağrısı veya Firebase doğrulama)
      print("Giriş başarılı: $email");
    } else {
      Get.snackbar("Uyarı", "Lütfen tüm alanları doldurun.");
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
