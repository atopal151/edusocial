import 'dart:io';
import 'package:edusocial/models/language_model.dart';
import 'package:edusocial/models/profile_model.dart';
import 'package:edusocial/services/onboarding_service.dart';
import 'package:edusocial/services/profile_service.dart';
import 'package:edusocial/services/profile_update_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileUpdateController extends GetxController {
  final _profileService = ProfileService();

  // Ana model (backend'den gelen tüm veriler burada tutulur)
  Rx<ProfileModel?> userProfileModel = Rx<ProfileModel?>(null);

  RxList<Map<String, dynamic>> userSchools = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> userDepartments = <Map<String, dynamic>>[].obs;
  final TextEditingController lessonController = TextEditingController();

  /// 🌍 Diller
  var languages = <LanguageModel>[].obs;
  var selectedLanguageId = Rxn<int>();

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
    } catch (e) {
      Get.snackbar('Hata', 'Dilleri çekerken hata oluştu!');
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
    descriptionController.text = data.description ?? '';
    tiktokController.text = data.tiktok ?? '';
    languageIdController.text = data.languageId ?? '';

    // 🌍 Seçili dil id'sini de set et
    if (data.languageId != null && data.languageId!.isNotEmpty) {
      selectedLanguageId.value = int.tryParse(data.languageId!);
    }
  }

  /// 🌍 Dil seçildiğinde çağrılacak
  void onLanguageSelected(int languageId) {
    selectedLanguageId.value = languageId;
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
        schoolId: selectedSchoolId?.toString() ?? '',
        departmentId: selectedDepartmentId?.toString() ?? '',
        lessons: selectedLessons.toList(),
        avatarFile: selectedAvatar,
        coverFile: selectedCoverPhoto,
        description: descriptionController.text,
        tiktok: tiktokController.text,
        languageId: selectedLanguageId.value?.toString() ?? '',
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
