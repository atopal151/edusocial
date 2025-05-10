import 'dart:io';

import 'package:edusocial/services/profile_update_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile_model.dart';

class ProfileUpdateController extends GetxController {
  var userProfile = UserProfile.empty().obs;
  var isLoading = false.obs;

  // TextEditingControllers
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

  // Ekstra Ayarlar
  var accountType = 'private'.obs; // private ya da public
  var emailNotification = true.obs;
  var mobileNotification = true.obs;
  var selectedLessons = <String>[].obs;
  File? selectedAvatar;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedAvatar = File(pickedFile.path);
      userProfile.update((val) {
        if (val != null) {
          val.profileImage = pickedFile.path; // Localde görüntü için
        }
      });
    }
  }

Future<void> fetchUserProfile() async {
  isLoading.value = true;
  try {
    final data = await ProfileUpdateService.fetchUserProfile();
    if (data != null) {
      userProfile.value = UserProfile.fromJson(data);
      loadUserData();
    } else {
      Get.snackbar("Hata", "Profil bilgisi alınamadı.");
    }
  } catch (e) {
    Get.snackbar("Hata", "Profil verisi alınırken hata oluştu: $e");
  } finally {
    isLoading.value = false;
  }
}


  void loadUserData() {
    usernameController.text = userProfile.value.username;
    nameController.text = userProfile.value.name;
    surnameController.text = userProfile.value.surname;
    emailController.text = userProfile.value.email;
    phoneController.text = userProfile.value.phone;
    birthdayController.text = userProfile.value.birthday;
    instagramController.text = userProfile.value.instagram;
    twitterController.text = userProfile.value.twitter;
    facebookController.text = userProfile.value.facebook;
    linkedinController.text = userProfile.value.linkedin;
    schoolIdController.text = userProfile.value.schoolId;
    departmentIdController.text = userProfile.value.departmentId;
    accountType.value = userProfile.value.accountType;
    emailNotification.value = userProfile.value.emailNotification;
    mobileNotification.value = userProfile.value.mobileNotification;
    selectedLessons.value = userProfile.value.lessons;
  }

  void toggleEmailNotification(bool value) {
    emailNotification.value = value;
  }

  void toggleMobileNotification(bool value) {
    mobileNotification.value = value;
  }

  void changeAccountType(String type) {
    accountType.value = type;
  }

  void addLesson(String lesson) {
    if (!selectedLessons.contains(lesson)) {
      selectedLessons.add(lesson);
    }
  }

  void removeLesson(String lesson) {
    selectedLessons.remove(lesson);
  }

  void goBack() {
    Get.back();
  }

  Future<void> saveProfile() async {
    isLoading.value = true;
    
    if (usernameController.text.isEmpty || emailController.text.isEmpty) {
      Get.snackbar("Hata", "Kullanıcı adı ve e-posta boş olamaz.");
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
        avatarFile: selectedAvatar, // ✅ artık doğru dosyayı gönderiyoruz
      );

      Get.snackbar("Başarılı", "Profil bilgileri güncellendi!");
    } catch (e) {
      Get.snackbar("Hata", "Profil güncellenemedi: $e");
    } finally {
      isLoading.value = false;
    }
  }
}



/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_profile_model.dart';



class ProfileUpdateController extends GetxController {
  var userProfile = UserProfile.empty().obs;
  var usernameController = TextEditingController();
  var instagramController = TextEditingController();
  var youtubeController = TextEditingController();
  var demoNotification = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      await Future.delayed(Duration(milliseconds: 500)); // API çağrısını simüle etme
      var mockData = {
        "profileImage": "https://i.pravatar.cc/150?img=20",
        "username": "mockuser",
        "instagram": "mock_insta",
        "youtube": "mock_yt",
        "demoNotification": true,
      };
      userProfile.value = UserProfile.fromJson(mockData);
      loadUserData();
    } catch (e) {
      Get.snackbar("Hata", "Bağlantı hatası: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void loadUserData() {
    usernameController.text = userProfile.value.username;
    instagramController.text = userProfile.value.instagram;
    youtubeController.text = userProfile.value.youtube;
    demoNotification.value = userProfile.value.demoNotification;
  }

  void goBack() {
    Get.back();
  }

  void changeProfilePicture() {
    //print("Profil fotoğrafı değiştirildi");
  }

  void toggleNotification(bool value) {
    demoNotification.value = value;
    userProfile.update((val) {
      if (val != null) {
        val.demoNotification = value;
      }
    });
  }

  Future<void> saveProfile() async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(milliseconds: 500)); // API güncellemesini simüle etme
      userProfile.update((val) {
        if (val != null) {
          val.username = usernameController.text;
          val.instagram = instagramController.text;
          val.youtube = youtubeController.text;
          val.demoNotification = demoNotification.value;
        }
      });
      Get.snackbar("Başarılı", "Profil bilgileri kaydedildi");
    } catch (e) {
      Get.snackbar("Hata", "Bağlantı hatası: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
*/