import 'dart:io';

import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/models/language_model.dart';
import 'package:edusocial/models/profile_model.dart';
import 'package:edusocial/services/onboarding_service.dart';
import 'package:edusocial/services/profile_service.dart';
import 'package:edusocial/services/profile_update_services.dart';
import 'package:edusocial/services/language_service.dart';
import 'package:edusocial/services/lesson_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../components/snackbars/custom_snackbar.dart';

class ProfileUpdateController extends GetxController {
  final _profileService = ProfileService();
  final _languageService = Get.find<LanguageService>();

  // Ana model (backend'den gelen tüm veriler burada tutulur)
  Rx<ProfileModel?> userProfileModel = Rx<ProfileModel?>(null);

  RxList<Map<String, dynamic>> userSchools = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> userDepartments = <Map<String, dynamic>>[].obs;
  final TextEditingController lessonController = TextEditingController();

  /// 🌍 Diller
  var languages = <LanguageModel>[].obs;
  var selectedLanguageId = Rxn<int>();
  var selectedLanguageCode = ''.obs; // Dil kodu (tr, en)

  var selectedSchoolName = "".obs;
  int? selectedSchoolId;

  var selectedDepartmentName = "".obs;
  int? selectedDepartmentId;

  // Yüklenme durumu
  var isLoading = false.obs;

  // Seçilen avatar dosyası
  File? selectedAvatar;
  File? selectedCoverPhoto; // Yeni alan
  // Form controller'ları
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final birthdayController = TextEditingController();
  final instagramController = TextEditingController();
  final twitterController = TextEditingController();
  final facebookController = TextEditingController();
  final linkedinController = TextEditingController();
  final schoolIdController = TextEditingController();
  final departmentIdController = TextEditingController();
  final descriptionController = TextEditingController();
  final tiktokController = TextEditingController();
  final languageIdController = TextEditingController();

  // Ekstra seçenekler
  var accountType = ''.obs; // "private" veya "public"
  var emailNotification = true.obs;
  var mobileNotification = true.obs;
  var selectedLessons = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    fetchLanguages();
  }

  /// 🌍 Dilleri API'den çek
  Future<void> fetchLanguages() async {
    try {
      languages.value = await ProfileUpdateService.fetchLanguages();
      
      // Mevcut dili seç
      _setCurrentLanguage();
    } catch (e) {
      Get.snackbar('Hata', 'Dilleri çekerken hata oluştu!');
    }
  }

  /// Mevcut dili seç
  void _setCurrentLanguage() {
    // Önce profil verisinden dil kodunu al
    final profileLanguage = userProfileModel.value?.language;
    
    if (profileLanguage != null && profileLanguage.isNotEmpty) {
      // Profilde dil varsa, o dili seç
      final languageModel = languages.firstWhereOrNull(
        (lang) => lang.code == profileLanguage,
      );
      
      if (languageModel != null) {
        selectedLanguageId.value = languageModel.id;
        selectedLanguageCode.value = languageModel.code;
      } else {
        // Profildeki dil desteklenmiyorsa varsayılan dili seç
        _setDefaultLanguage();
      }
    } else {
      // Profilde dil yoksa varsayılan dili seç
      _setDefaultLanguage();
    }
  }

  /// Varsayılan dili seç (İngilizce)
  void _setDefaultLanguage() {
    final defaultLanguage = languages.firstWhereOrNull(
      (lang) => lang.code == 'en',
    );
    
    if (defaultLanguage != null) {
      selectedLanguageId.value = defaultLanguage.id;
      selectedLanguageCode.value = defaultLanguage.code;
    }
  }

  /// Dil seçildiğinde çağrılır
  void onLanguageSelected(int languageId) {
    final selectedLanguage = languages.firstWhereOrNull(
      (lang) => lang.id == languageId,
    );
    
    if (selectedLanguage != null) {
      selectedLanguageId.value = languageId;
      selectedLanguageCode.value = selectedLanguage.code;
      
      // Dil servisini güncelle
      _languageService.changeLanguage(selectedLanguage.code);
      
      debugPrint('Dil değiştirildi: ${selectedLanguage.code}');
    }
  }

  Future<void> loadUserSchoolList() async {
    isLoading.value = true;
    try {
      final data = await OnboardingServices.fetchSchools();
      userSchools.assignAll(data);

      if (userSchools.isNotEmpty) {
        // Eğer profilden gelen ID varsa, okul adı eşleşmesi yap
        final selectedSchool = userSchools.firstWhereOrNull(
          (school) => school['id'].toString() == schoolIdController.text,
        );
        if (selectedSchool != null) {
          selectedSchoolName.value = selectedSchool['name'];
          selectedSchoolId = selectedSchool['id'];
          loadDepartmentsForSelectedSchool();
        }
      }
    } catch (e) {
      debugPrint("❗ Kullanıcı okul listesi yüklenirken hata: $e",
          wrapWidth: 1024);
    } finally {
      isLoading.value = false;
    }
  }

  void loadDepartmentsForSelectedSchool() {
    final selected = userSchools.firstWhereOrNull(
      (school) => school['id'] == selectedSchoolId,
    );
    if (selected != null && selected['departments'] != null) {
      userDepartments.assignAll(
        (selected['departments'] as List)
            .map<Map<String, dynamic>>((d) => {
                  "id": d['id'],
                  "title": d['title'],
                })
            .toList(),
      );

      if (userDepartments.isNotEmpty) {
        final selectedDept = userDepartments.firstWhereOrNull(
          (dept) => dept['id'].toString() == departmentIdController.text,
        );
        if (selectedDept != null) {
          selectedDepartmentName.value = selectedDept['title'];
          selectedDepartmentId = selectedDept['id'];
        }
      }
    }
  }

  void onSchoolChanged(String schoolName) {
    final selected =
        userSchools.firstWhereOrNull((school) => school['name'] == schoolName);

    if (selected != null) {
      selectedSchoolName.value = selected['name'];
      selectedSchoolId = selected['id'];
      loadDepartmentsForSelectedSchool();
    }
  }

  void onDepartmentChanged(String departmentName) {
    final selected = userDepartments.firstWhereOrNull(
      (dept) => dept['title'] == departmentName,
    );
    if (selected != null) {
      selectedDepartmentName.value = selected['title'];
      selectedDepartmentId = selected['id'];
    }
  }

  String formatBirthday(String isoString) {
    try {
      DateTime parsed = DateTime.parse(isoString);
      return DateFormat('dd.MM.yyyy').format(parsed);
    } catch (e) {
      return '';
    }
  }

  /// 📸 Galeriden resim seçme
  Future<void> pickImageFromGallery() async {
    final pickedProfileFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedProfileFile != null) {
      selectedAvatar = File(pickedProfileFile.path);
    }
  }

  Future<void> pickCoverPhotoFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedCoverPhoto = File(pickedFile.path);
    }
  }

  /// 🔄 Profil verisini API'den çek
  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final profileData = await _profileService.fetchProfileData();
      userProfileModel.value = profileData;
      loadUserData(); // TextField'lara aktar
      await loadUserSchoolList();
    } catch (e) {
      Get.snackbar("Hata", "Profil verisi alınamadı: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🧠 Gelen verileri formlara yerleştir
  void loadUserData() {
    final data = userProfileModel.value;
    if (data == null) return;

    //adebugPrint("📥 Profil form verileri yükleniyor...", wrapWidth: 1024);

    usernameController.text = data.username;
    nameController.text = data.name;
    surnameController.text = data.surname;
    emailController.text = data.email;
    birthdayController.text = formatBirthday(data.birthDate);
    phoneController.text = data.phone ?? ''; // null olabilir
    instagramController.text = data.instagram ?? '';
    twitterController.text = data.twitter ?? '';
    facebookController.text = data.facebook ?? '';
    linkedinController.text = data.linkedin ?? '';
    schoolIdController.text = data.schoolId ?? '';
    departmentIdController.text = data.schoolDepartmentId ?? '';
    accountType.value = data.accountType;
    emailNotification.value = data.notificationEmail;
    mobileNotification.value = data.notificationMobile;
    selectedLessons.value = data.lessons;
    
    debugPrint("📚 Profil verilerinden dersler yüklendi: ${data.lessons}");
    descriptionController.text = data.description ?? '';
    tiktokController.text = data.tiktok ?? '';
    languageIdController.text = data.languageId ?? '';

    // 🌍 Seçili dil id'sini de set et
    if (data.languageId != null && data.languageId!.isNotEmpty) {
      selectedLanguageId.value = int.tryParse(data.languageId!);
      
      // Dil kodunu da set et
      final languageModel = languages.firstWhereOrNull(
        (lang) => lang.id == selectedLanguageId.value,
      );
      if (languageModel != null) {
        selectedLanguageCode.value = languageModel.code;
        
        // Dil servisini güncelle
        _languageService.setLanguageFromProfile(languageModel.code);
      }
    }
  }

  /// 🎛️ Switch kontroller
  void toggleEmailNotification(bool value) {
    emailNotification.value = value;
  }

  void toggleMobileNotification(bool value) {
    mobileNotification.value = value;
  }

  void changeAccountType(String type) {
    accountType.value = type;
  }

  /// 📚 Ders işlemleri
  
  /// Dersi sadece UI'dan kaldır (backend'den silme)
  void removeLessonFromUI(String lesson) {
    debugPrint("🔄 ProfileUpdateController: Ders UI'dan kaldırılıyor...");
    debugPrint("📚 Kaldırılacak ders: $lesson");
    debugPrint("📊 Mevcut ders listesi: ${selectedLessons.toList()}");
    
    if (selectedLessons.contains(lesson)) {
      selectedLessons.remove(lesson);
      debugPrint("✅ Ders UI'dan kaldırıldı: $lesson");
      debugPrint("📊 Güncel ders listesi: ${selectedLessons.toList()}");
      
      CustomSnackbar.show(
        title: _languageService.tr("common.success"),
        message: "'$lesson' dersi listeden kaldırıldı",
        type: SnackbarType.success,
      );
    } else {
      debugPrint("❌ Ders listede bulunamadı: $lesson");
    }
  }
  
  Future<void> addLesson(String lesson) async {
    debugPrint("🔄 ProfileUpdateController: Ders ekleme işlemi başlatılıyor...");
    debugPrint("📚 Ders adı: ${lesson.trim()}");
    
    if (lesson.trim().isEmpty) {
      debugPrint("❌ Validation hatası: Ders adı boş");
      CustomSnackbar.show(
        title: _languageService.tr("common.warning"),
        message: _languageService.tr("profile.editProfile.lessonNameEmpty"),
        type: SnackbarType.warning,
      );
      return;
    }

    if (selectedLessons.contains(lesson.trim())) {
      debugPrint("❌ Validation hatası: Ders zaten mevcut");
      CustomSnackbar.show(
        title: _languageService.tr("common.warning"),
        message: _languageService.tr("profile.editProfile.lessonAlreadyExists"),
        type: SnackbarType.warning,
      );
      return;
    }

    debugPrint("✅ Validation başarılı, API çağrısı yapılıyor...");
    
    try {
      debugPrint("📤 LessonService.addLessonWithId() çağrılıyor...");
      final result = await LessonService.addLessonWithId(lesson.trim());
      
      debugPrint("📥 LessonService'den dönen sonuç: $result");
      
      if (result['success'] as bool) {
        debugPrint("✅ Ders başarıyla eklendi: ${lesson.trim()}");
        
        debugPrint("📝 selectedLessons listesine ekleniyor...");
        selectedLessons.add(lesson.trim());
        debugPrint("📊 Güncel ders listesi: ${selectedLessons.toList()}");
        
        CustomSnackbar.show(
          title: _languageService.tr("common.success"),
          message: _languageService.tr("profile.editProfile.lessonAdded"),
          type: SnackbarType.success,
        );
        
        debugPrint("🔄 Profil verileri yenileniyor...");
        await fetchUserProfile();
        debugPrint("✅ Profil verileri yenilendi");
      } else {
        debugPrint("❌ Ders eklenemedi: ${lesson.trim()}");
        debugPrint("❌ API'den başarısız sonuç döndü");
        CustomSnackbar.show(
          title: _languageService.tr("common.error"),
          message: _languageService.tr("profile.editProfile.lessonAddError"),
          type: SnackbarType.error,
        );
      }
    } catch (e, stackTrace) {
      debugPrint("💥 Ders ekleme hatası: $e");
      debugPrint("💥 Stack trace: $stackTrace");
      CustomSnackbar.show(
        title: _languageService.tr("common.error"),
        message: _languageService.tr("profile.editProfile.lessonAddError"),
        type: SnackbarType.error,
      );
    }
    
    debugPrint("🏁 Ders ekleme işlemi tamamlandı");
  }



  /// ⬅️ Geri dön
  void goBack() {
    Get.back();
  }

  /// 💾 Kaydetme işlemi
  Future<void> saveProfile() async {
    isLoading.value = true;

    if (usernameController.text.isEmpty || emailController.text.isEmpty) {
      Get.snackbar("Hata", "Kullanıcı adı ve e-posta boş olamaz.");
      isLoading.value = false;
      return;
    }

    try {
      await ProfileUpdateService.updateProfile(
        username: usernameController.text,
        name: nameController.text,
        surname: surnameController.text,
        email: emailController.text,
        phone: phoneController.text,
        birthday: birthdayController.text,
        instagram: instagramController.text,
        twitter: twitterController.text,
        facebook: facebookController.text,
        linkedin: linkedinController.text,
        accountType: accountType.value,
        emailNotification: emailNotification.value,
        mobileNotification: mobileNotification.value,
        schoolId: selectedSchoolId?.toString() ?? '',
        departmentId: selectedDepartmentId?.toString() ?? '',
        lessons: selectedLessons.toList(),
        avatarFile: selectedAvatar,
        coverFile: selectedCoverPhoto,
        description: descriptionController.text,
        tiktok: tiktokController.text,
        languageId: selectedLanguageId.value?.toString() ?? '',
      );

      // Başarılı snackbar'ı kaldırıldı.
      // Ana profil sayfasındaki verileri güncelle.
      await Get.find<ProfileController>().loadProfile();
      // Post verilerini de güncelle
      await Get.find<PostController>().fetchHomePosts();
      Get.back(); // Bir önceki sayfaya dön.
    } catch (e) {
      CustomSnackbar.show(
          title: "Hata",
          message: "Profil güncellenemedi: $e",
          type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
