import 'package:edusocial/controllers/onboarding_controller.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/controllers/group_controller/group_controller.dart';
import 'package:edusocial/controllers/notification_controller.dart';
import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/controllers/appbar_controller.dart';
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

  /// 🔄 Login başarılı olduğunda tüm verileri yeniden yükle
  Future<void> _reloadAllData() async {
    try {
      debugPrint("🔄 Login sonrası veriler yeniden yükleniyor...");
      
      // Sadece mevcut controller'ları kullan
      final profileController = Get.find<ProfileController>();
      final groupController = Get.find<GroupController>();
      final notificationController = Get.find<NotificationController>();
      final appBarController = Get.find<AppBarController>();
      final storyController = Get.find<StoryController>();

      // Sıralı olarak tüm verileri yükle
      profileController.loadProfile();
      groupController.fetchUserGroups();
      groupController.fetchAllGroups();
      groupController.fetchSuggestionGroups();
      groupController.fetchGroupAreas();
      notificationController.fetchNotifications();
      appBarController.fetchAndSetProfileImage();
      storyController.fetchStories();

      debugPrint("✅ Login sonrası veriler başarıyla yüklendi");
      
      // 3 saniye sonra verilerin yüklenip yüklenmediğini kontrol et
      Future.delayed(const Duration(seconds: 3), () {
        _checkDataLoaded();
      });
      
    } catch (e) {
      debugPrint("❌ Veri yeniden yükleme hatası: $e");
    }
  }

  /// 🔍 Verilerin yüklenip yüklenmediğini kontrol et
  void _checkDataLoaded() {
    try {
      final profileController = Get.find<ProfileController>();
      final groupController = Get.find<GroupController>();
      final notificationController = Get.find<NotificationController>();
      final postController = Get.find<PostController>();
      final appBarController = Get.find<AppBarController>();
      final storyController = Get.find<StoryController>();

      debugPrint("🔍 Veri yükleme kontrolü:");
      debugPrint("   📊 Profil: ${profileController.profile.value != null ? '✅' : '❌'}");
      debugPrint("   📊 Kullanıcı Grupları: ${groupController.userGroups.length} grup");
      debugPrint("   📊 Tüm Gruplar: ${groupController.allGroups.length} grup");
      debugPrint("   📊 Önerilen Gruplar: ${groupController.suggestionGroups.length} grup");
      debugPrint("   📊 Bildirimler: ${notificationController.notifications.length} bildirim");
      debugPrint("   📊 Postlar: ${postController.postHomeList.length} post");
      debugPrint("   📊 AppBar Resmi: ${appBarController.profileImagePath.value.isNotEmpty ? '✅' : '❌'}");
      debugPrint("   📊 Story'ler: ${storyController.otherStories.length} story");
    } catch (e) {
      debugPrint("❌ Veri kontrol hatası: $e");
    }
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
          // Tüm verileri yeniden yükle
          await _reloadAllData();
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
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
