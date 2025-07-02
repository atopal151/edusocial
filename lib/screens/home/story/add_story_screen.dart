import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/story_controller.dart';
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
        message: languageService.tr("story.addStory.photoSelectionError"),
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
        message: languageService.tr("story.addStory.cameraError"),
        type: SnackbarType.error,
      );
    }
  }

  void shareStory() async {
    if (_selectedImages.isNotEmpty) {
      try {
        isPosting.value = true;
        final StoryController storyController = Get.find<StoryController>();
        final File imageFile = File(_selectedImages.first.path);
        await storyController.createStory(imageFile);
        isPosting.value = false;
        Get.back();
      } catch (e) {
        isPosting.value = false;
        final LanguageService languageService = Get.find<LanguageService>();
        CustomSnackbar.show(
          title: languageService.tr("common.errors.error"),
          message: languageService.tr("story.addStory.shareError"),
          type: SnackbarType.error,
        );
      }
    } else {
      final LanguageService languageService = Get.find<LanguageService>();
      CustomSnackbar.show(
        title: languageService.tr("common.warnings.warning"),
        message: languageService.tr("story.addStory.selectPhotoWarning"),
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
          languageService.tr("story.addStory.title"),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            alignment: Alignment.centerLeft,
            child: Text(
              languageService.tr("story.addStory.nearby"),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF414751),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _selectedImages.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: pickFromCamera,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 32,
                          color: Color(0xFFF26B6B),
                        ),
                      ),
                    ),
                  );
                } else {
                  final file = File(_selectedImages[index - 1].path);
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(file, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index - 1);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
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
                    icon: const Icon(Icons.photo_library, color: Color(0xFFF26B6B)),
                    label: Text(
                      languageService.tr("story.addStory.selectFromGallery"),
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
                              languageService.tr("story.addStory.share"),
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
