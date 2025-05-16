import 'dart:io';
import 'package:edusocial/models/profile_model.dart';
import 'package:edusocial/services/profile_service.dart';
import 'package:edusocial/services/profile_update_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileUpdateController extends GetxController {
  final _profileService = ProfileService();

  // Ana model (backend'den gelen tüm veriler burada tutulur)
  Rx<ProfileModel?> userProfileModel = Rx<ProfileModel?>(null);

  // Yüklenme durumu
  var isLoading = false.obs;

  // Seçilen avatar dosyası
  File? selectedAvatar;

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

  // Ekstra seçenekler
  var accountType = 'private'.obs; // "private" veya "public"
  var emailNotification = true.obs;
  var mobileNotification = true.obs;
  var selectedLessons = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  /// 📸 Galeriden resim seçme
  Future<void> pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedAvatar = File(pickedFile.path);
    }
  }

  /// 🔄 Profil verisini API'den çek
  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final profileData = await _profileService.fetchProfileData();
      userProfileModel.value = profileData;
      loadUserData(); // TextField'lara aktar
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

    debugPrint("📥 Profil form verileri yükleniyor...", wrapWidth: 1024);

    usernameController.text = data.username;
    nameController.text = data.name;
    surnameController.text = data.surname;
    emailController.text = data.email;
    birthdayController.text = data.birthDate;
    phoneController.text = data.phone; // null olabilir
    instagramController.text = data.instagram;
    twitterController.text = data.twitter;
    facebookController.text = data.facebook;
    linkedinController.text = data.linkedin;
    schoolIdController.text = data.schoolId;
    departmentIdController.text = data.schoolDepartmentId;
    accountType.value = data.accountType;
    emailNotification.value = data.notificationEmail;
    mobileNotification.value = data.notificationMobile;
    selectedLessons.value = data.courses;
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
  void addLesson(String lesson) {
    if (!selectedLessons.contains(lesson)) {
      selectedLessons.add(lesson);
    }
  }

  void removeLesson(String lesson) {
    selectedLessons.remove(lesson);
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
        schoolId: schoolIdController.text,
        departmentId: departmentIdController.text,
        lessons: selectedLessons,
        avatarFile: selectedAvatar,
      );

      Get.snackbar("Başarılı", "Profil bilgileri güncellendi!");
      await fetchUserProfile(); // Güncel verileri tekrar çek
    } catch (e) {
      Get.snackbar("Hata", "Profil güncellenemedi: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
