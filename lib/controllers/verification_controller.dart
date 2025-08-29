import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/verification_service.dart';
import '../components/snackbars/custom_snackbar.dart';
import '../services/language_service.dart';

class VerificationController extends GetxController {
  final VerificationService _verificationService = Get.find<VerificationService>();
  final LanguageService _languageService = Get.find<LanguageService>();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString selectedDocumentType = ''.obs;
  final Rx<File?> uploadedFile = Rx<File?>(null);
  final RxString uploadedFileName = ''.obs;
  final RxBool isVerificationSent = false.obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Eğer arguments varsa document type'ı set et
    if (Get.arguments != null && Get.arguments['documentType'] != null) {
      selectedDocumentType.value = Get.arguments['documentType'];
    }
  }

  /// Belge türü seç
  void selectDocumentType(String documentType) {
    selectedDocumentType.value = documentType;
  }

  /// Dosya yükle (kamera veya galeri)
  Future<void> uploadFile(String source) async {
    try {
      XFile? pickedFile;
      
      if (source == 'camera') {
        pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
      } else if (source == 'gallery') {
        pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
      }

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        
        // Dosya validasyonları
        if (!_verificationService.isValidFileType(file)) {
          CustomSnackbar.show(
            title: _languageService.tr("verification.snackbar.error"),
            message: _languageService.tr("verification.validation.fileTypeNotSupported"),
            type: SnackbarType.error,
          );
          return;
        }

        if (!_verificationService.isValidFileSize(file)) {
          CustomSnackbar.show(
            title: _languageService.tr("verification.snackbar.error"),
            message: _languageService.tr("verification.validation.fileSizeLimit"),
            type: SnackbarType.error,
          );
          return;
        }

        uploadedFile.value = file;
        uploadedFileName.value = pickedFile.name;

        CustomSnackbar.show(
          title: _languageService.tr("verification.snackbar.success"),
          message: _languageService.tr("verification.messages.fileUploadSuccess"),
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      debugPrint("❌ Dosya yükleme hatası: $e");
      CustomSnackbar.show(
        title: _languageService.tr("verification.snackbar.error"),
        message: _languageService.tr("verification.messages.fileUploadFailed"),
        type: SnackbarType.error,
      );
    }
  }

  /// Dosyayı kaldır
  void removeFile() {
    uploadedFile.value = null;
    uploadedFileName.value = '';

    CustomSnackbar.show(
      title: _languageService.tr("verification.snackbar.success"),
      message: _languageService.tr("verification.messages.fileRemoved"),
      type: SnackbarType.success,
    );
  }

  /// Doğrulama gönder
  Future<void> sendVerification() async {
    if (selectedDocumentType.value.isEmpty) {
      CustomSnackbar.show(
        title: _languageService.tr("verification.snackbar.warning"),
        message: _languageService.tr("verification.validation.documentTypeRequired"),
        type: SnackbarType.warning,
      );
      return;
    }

    if (uploadedFile.value == null) {
      CustomSnackbar.show(
        title: _languageService.tr("verification.snackbar.warning"),
        message: _languageService.tr("verification.validation.fileRequired"),
        type: SnackbarType.warning,
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await _verificationService.verifyUser(
        uploadedFile.value!,
        selectedDocumentType.value,
      );

      if (result['success']) {
        isVerificationSent.value = true;
        CustomSnackbar.show(
          title: _languageService.tr("verification.snackbar.success"),
          message: result['message'],
          type: SnackbarType.success,
        );
        
        // Başarılı doğrulama sonrası ana sayfaya yönlendir
        await Future.delayed(Duration(seconds: 2));
        Get.offAllNamed('/main');
      } else {
        CustomSnackbar.show(
          title: _languageService.tr("verification.snackbar.error"),
          message: result['message'],
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      debugPrint("❌ Doğrulama gönderme hatası: $e");
      CustomSnackbar.show(
        title: _languageService.tr("verification.snackbar.error"),
        message: _languageService.tr("verification.messages.verificationFailed"),
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Belge türü adını getir
  String getDocumentTypeName(String documentType) {
    return _verificationService.getDocumentTypeName(documentType);
  }

  /// Geçerli belge türlerini getir
  List<String> getDocumentTypes() {
    return _verificationService.getDocumentTypes();
  }

  /// Dosya yüklü mü kontrol et
  bool get hasFile => uploadedFile.value != null;

  /// Doğrulama gönderilebilir mi kontrol et
  bool get canSendVerification => 
      selectedDocumentType.value.isNotEmpty && uploadedFile.value != null;
}
