import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/story_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../components/snackbars/custom_snackbar.dart';
import '../../../services/language_service.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final List<XFile> _selectedImages = [];
  final ImagePicker picker = ImagePicker();
  var isPosting = false.obs;

  Future<void> pickImages() async {
    try {
      if (Platform.isIOS) {
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          setState(() {
            _selectedImages.add(picked);
          });
        }
      } else {
        final pickedFiles = await picker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(pickedFiles);
          });
        }
      }
    } catch (e) {
      debugPrint("Hata: $e", wrapWidth: 1024);
      final LanguageService languageService = Get.find<LanguageService>();
      CustomSnackbar.show(
        title: languageService.tr("common.errors.error"),
        message: languageService.tr("home.story.addStory.photoSelectionError"),
        type: SnackbarType.error,
      );
    }
  }

  Future<void> pickFromCamera() async {
    try {
      final photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _selectedImages.add(photo);
        });
      }
    } catch (e) {
      final LanguageService languageService = Get.find<LanguageService>();
      CustomSnackbar.show(
        title: languageService.tr("common.errors.error"),
        message: languageService.tr("home.story.addStory.cameraError"),
        type: SnackbarType.error,
      );
    }
  }

  void shareStory() async {
    if (_selectedImages.isNotEmpty) {
      try {
        isPosting.value = true;
        final StoryController storyController = Get.find<StoryController>();
        
        // Tüm seçilen görselleri File listesine çevir
        final List<File> imageFiles = _selectedImages
            .map((xfile) => File(xfile.path))
            .toList();
        
        // Birden fazla story oluştur
        await storyController.createMultipleStories(imageFiles);
        
        isPosting.value = false;
        Get.back();
        
        // Başarı mesajı göster
        final LanguageService languageService = Get.find<LanguageService>();
        CustomSnackbar.show(
          title: languageService.tr("common.success"),
          message: "${imageFiles.length} ${languageService.tr("home.story.addStory.storiesShared")}",
          type: SnackbarType.success,
        );
      } catch (e) {
        isPosting.value = false;
        final LanguageService languageService = Get.find<LanguageService>();
        CustomSnackbar.show(
          title: languageService.tr("common.errors.error"),
          message: languageService.tr("home.story.addStory.shareError"),
          type: SnackbarType.error,
        );
      }
    } else {
      final LanguageService languageService = Get.find<LanguageService>();
      CustomSnackbar.show(
        title: languageService.tr("common.warnings.warning"),
        message: languageService.tr("home.story.addStory.selectPhotoWarning"),
        type: SnackbarType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          languageService.tr("home.story.addStory.title"),
          style: GoogleFonts.inter(
            color: const Color(0xFF414751),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF414751)),
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.close),
        ),
      ),
      body: Column(
        children: [
          
          Expanded(
            child: _selectedImages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: pickFromCamera,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 40,
                              color: Color(0xFFF26B6B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          languageService.tr("home.story.addStory.selectPhotoWarning"),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF9CA3AE),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Story Preview (9:16 aspect ratio)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.6,
                            ),
                            child: AspectRatio(
                              aspectRatio: 9 / 16,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: Colors.black,
                                      child: Image.file(
                                        File(_selectedImages.first.path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Story preview overlay
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    right: 16,
                                    child: Row(
                                      children: [
                                        Obx(() {
                                          final ProfileController profileController = Get.find<ProfileController>();
                                          return CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.white,
                                            backgroundImage: profileController.profileImage.value.isNotEmpty &&
                                                profileController.profileImage.value.startsWith("http")
                                                ? NetworkImage(profileController.profileImage.value)
                                                : null,
                                            child: profileController.profileImage.value.isEmpty ||
                                                !profileController.profileImage.value.startsWith("http")
                                                ? Icon(
                                                    Icons.person,
                                                    size: 20,
                                                    color: Color(0xFF9CA3AE),
                                                  )
                                                : null,
                                          );
                                        }),
                                        const SizedBox(width: 8),
                                        Obx(() {
                                          final ProfileController profileController = Get.find<ProfileController>();
                                          return Text(
                                            profileController.username.value,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );
                                        }),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _selectedImages.clear();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Küçük thumbnail'ler (eğer birden fazla seçili varsa)
                        if (_selectedImages.length > 1)
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    // İlk sıraya taşı
                                    setState(() {
                                      final selected = _selectedImages.removeAt(index);
                                      _selectedImages.insert(0, selected);
                                    });
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 80,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      border: index == 0
                                          ? Border.all(color: Color(0xFFF26B6B), width: 2)
                                          : null,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.file(
                                            File(_selectedImages[index].path),
                                            width: 60,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedImages.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(2),
                                              child: const Icon(
                                                Icons.close,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      foregroundColor: const Color(0xFFF26B6B),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: pickImages,
                    label: Text(
                      languageService.tr("home.story.addStory.selectFromGallery"),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF26B6B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPosting.value ? null : shareStory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPosting.value
                            ? Colors.grey
                            : const Color(0xFFF26B6B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isPosting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              languageService.tr("home.story.addStory.share"),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  )),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
