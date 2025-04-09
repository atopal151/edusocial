import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SignupController extends GetxController {
  TextEditingController usernameSuController = TextEditingController();
  TextEditingController emailSuController = TextEditingController();
  TextEditingController passwordSuController = TextEditingController();
  TextEditingController confirmPasswordSuController = TextEditingController();
  var isAccepted = false.obs;
  var isSuLoading = false.obs;

  void toggleAcceptance() {
    isAccepted.value = !isAccepted.value;
  }

  void signup() async {
    //kullanıcı kayıt alanı
    
    if (!isAccepted.value) {
      Get.snackbar("Hata", "Lütfen gizlilik politikasını kabul edin.");
      return;
    }
    if (usernameSuController.text.isEmpty || emailSuController.text.isEmpty || passwordSuController.text.isEmpty || confirmPasswordSuController.text.isEmpty) {
      Get.snackbar("Hata", "Tüm alanları doldurmalısınız.");
      return;
    }
    if (passwordSuController.text != confirmPasswordSuController.text) {
      Get.snackbar("Hata", "Şifreler eşleşmiyor.");
      return;
    }
    
    isSuLoading.value = true;
    await Future.delayed(Duration(seconds: 2)); // Mock API isteği simülasyonu
    isSuLoading.value = false;

    Get.snackbar("Başarılı", "Kayıt başarılı! Giriş yapabilirsiniz.");
    Get.offAllNamed('/login'); 
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