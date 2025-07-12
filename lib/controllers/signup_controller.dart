import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../components/snackbars/custom_snackbar.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/story_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/group_controller/group_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/post_controller.dart';
import '../controllers/appbar_controller.dart';
import '../controllers/entry_controller.dart';
import '../controllers/match_controller.dart';

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
    final languageService = Get.find<LanguageService>();
    
    if (!isAccepted.value) {
      return languageService.tr("signup.validation.privacyPolicyRequired");
    }

    if (nameSuController.text.isEmpty) {
      return languageService.tr("signup.validation.nameRequired");
    }

    if (surnameSuController.text.isEmpty) {
      return languageService.tr("signup.validation.surnameRequired");
    }

    if (usernameSuController.text.isEmpty) {
      return languageService.tr("signup.validation.usernameRequired");
    }

    if (emailSuController.text.isEmpty) {
      return languageService.tr("signup.validation.emailRequired");
    }

    if (passwordSuController.text.isEmpty) {
      return languageService.tr("signup.validation.passwordRequired");
    }

    if (confirmPasswordSuController.text.isEmpty) {
      return languageService.tr("signup.validation.confirmPasswordRequired");
    }

    if (!_isValidEmail(emailSuController.text)) {
      return languageService.tr("signup.validation.emailInvalid");
    }

    if (!_isValidUsername(usernameSuController.text)) {
      return languageService.tr("signup.validation.usernameMinLength");
    }

    if (passwordSuController.text.length < 6) {
      return languageService.tr("signup.validation.passwordMinLength");
    }

    if (passwordSuController.text != confirmPasswordSuController.text) {
      return languageService.tr("signup.validation.passwordsNotMatch");
    }

    return null;
  }

  void toggleAcceptance() {
    isAccepted.value = !isAccepted.value;
  }

  void signup() async {
    final languageService = Get.find<LanguageService>();
    final validationError = _validateInputs();
    if (validationError != null) {
      CustomSnackbar.show(
        title: languageService.tr("common.warning"),
        message: validationError,
        type: SnackbarType.warning,
      );
      return;
    }

    isSuLoading.value = true;
    try {
      final user = await _authService.register(
        username: usernameSuController.text.trim(),
        name: nameSuController.text.trim(),
        surname: surnameSuController.text.trim(),
        email: emailSuController.text.trim(),
        password: passwordSuController.text,
        confirmPassword: confirmPasswordSuController.text,
      );

      if (user != null) {
        final schoolId = user['school_id'];
        final departmentId = user['school_department_id'];

        CustomSnackbar.show(
          title: languageService.tr("signup.success.signupSuccess"),
          message: languageService.tr("signup.success.welcomeMessage"),
          type: SnackbarType.success,
        );

        if (schoolId == null || departmentId == null) {
          /// İlk kayıt, onboarding'e git
          final onboardingController = Get.find<OnboardingController>();
          onboardingController.userEmail = emailSuController.text;
          onboardingController.loadSchoolList();
          Get.offAllNamed('/step1');
        } else {
          /// Zaten onboarding tamamlamış, ana ekrana
          // Tüm verileri yeniden yükle
          await _reloadAllData();
          Get.offAllNamed('/main');
        }
      } else {
        CustomSnackbar.show(
          title: languageService.tr("signup.errors.signupFailed"),
          message: _authService.lastErrorMessage ?? languageService.tr("signup.errors.serverError"),
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("signup.errors.serverError"),
        type: SnackbarType.error,
      );
    } finally {
      isSuLoading.value = false;
    }
  }

  /// 🔄 Signup başarılı olduğunda tüm verileri yeniden yükle
  Future<void> _reloadAllData() async {
    try {
      debugPrint("🔄 Signup sonrası veriler yeniden yükleniyor...");
      
      // Temel controller'ları kontrol et ve var olanları al
      final profileController = Get.find<ProfileController>();
      final groupController = Get.find<GroupController>();
      final notificationController = Get.find<NotificationController>();
      final appBarController = Get.find<AppBarController>();
      final storyController = Get.find<StoryController>();
      final postController = Get.find<PostController>();

      // Önce profil bilgilerini yükle (diğer controller'lar buna bağımlı)
      await profileController.loadProfile();
      debugPrint("✅ Profil bilgileri yüklendi");

      // AppBar'daki profil resmini güncelle
      await appBarController.fetchAndSetProfileImage();
      debugPrint("✅ AppBar profil resmi güncellendi");

      // Paralel olarak diğer verileri yükle
      final futures = <Future>[];
      
      // Async fonksiyonları futures listesine ekle
      futures.add(postController.fetchHomePosts());
      futures.add(storyController.fetchStories());
      futures.add(notificationController.fetchNotifications());

      // Entry controller'ı varsa onu da güncelle
      try {
        final entryController = Get.find<EntryController>();
        futures.add(entryController.fetchAndPrepareEntries());
      } catch (e) {
        debugPrint("⚠️ EntryController bulunamadı: $e");
      }

      // Void döndüren fonksiyonları ayrı ayrı çağır
      groupController.fetchUserGroups();
      groupController.fetchAllGroups();
      groupController.fetchSuggestionGroups();
      groupController.fetchGroupAreas();

      // Match controller'ı varsa onu da güncelle
      try {
        final matchController = Get.find<MatchController>();
        matchController.findMatches();
      } catch (e) {
        debugPrint("⚠️ MatchController bulunamadı: $e");
      }

      // Future döndüren fonksiyonları bekle
      await Future.wait(futures);

      debugPrint("✅ Signup sonrası tüm veriler başarıyla yüklendi");
      
      // Veri yükleme kontrolü
      Future.delayed(const Duration(seconds: 2), () {
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
