import 'dart:io';
import 'package:edusocial/components/buttons/icon_button.dart';
import 'package:edusocial/components/snackbars/custom_snackbar.dart';
import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ProfileController profileController = Get.find();
  final PostController postController = Get.find();
  final List<XFile> _selectedImages = [];
  final ImagePicker picker = ImagePicker();
  final TextEditingController textController = TextEditingController();
  final List<String> _links = [];
  var isPosting = false.obs;

  Future<void> pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  Future<void> pickFromCamera() async {
    final photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImages.add(photo);
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void removeLink(int index) {
    setState(() {
      _links.removeAt(index);
    });
  }

  // URL tespit fonksiyonu
  List<String> extractLinksFromText(String text) {
    final RegExp urlRegex = RegExp(
      r'https?://[^\s]+|www\.[^\s]+',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  void onTextChanged(String text) {
    setState(() {
      _links.clear();
      _links.addAll(extractLinksFromText(text));
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void sharePost() async {
    try {
      isPosting.value = true;

      // Linkleri text'ten çıkar
      String cleanContent = textController.text;
      List<String> extractedLinks = extractLinksFromText(cleanContent);

      // Linkleri text'ten temizle
      for (String link in extractedLinks) {
        cleanContent = cleanContent.replaceAll(link, '').trim();
      }

      // Fazla boşlukları temizle
      cleanContent = cleanContent.replaceAll(RegExp(r'\s+'), ' ').trim();

      final mediaFiles =
          _selectedImages.map((xfile) => File(xfile.path)).toList();
      await postController.createPost(cleanContent, mediaFiles,
          links: extractedLinks);
      isPosting.value = false;
      Get.offAllNamed('/main'); // Main screen'e git (navbar 0. index)
    } catch (e) {
      isPosting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: AppBar(
        backgroundColor: Color(0xfffafafa),
        iconTheme: const IconThemeData(color: Color(0xff414751)),
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.close),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 100,
              height: 33,
              child: Obx(() => GestureDetector(
                    onTap: isPosting.value ? null : sharePost,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isPosting.value
                            ? Color(0xff9ca3ae)
                            : Color(0xffef5050),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isPosting.value)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: GeneralLoadingIndicator(
                                size: 16,
                                color: Colors.white,
                                showIcon: false,
                              ),
                            )
                          else
                            Text(
                              languageService.tr("post.createPost.share"),
                              style: GoogleFonts.inter(
                                color: Color(0xffffffff),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Obx(() => CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xffffffff),
                      backgroundImage: profileController
                              .profileImage.value.isNotEmpty
                          ? NetworkImage(profileController.profileImage.value)
                          : null,
                      child: profileController.profileImage.value.isEmpty
                          ? Icon(
                              Icons.person,
                              color: Color(0xffef5050),
                              size: 24,
                            )
                          : null,
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: textController,
                  maxLines: null,
                  style: const TextStyle(color: Color(0xff414751)),
                  decoration: InputDecoration(
                    hintText: languageService.tr("post.createPost.placeholder"),
                    hintStyle: GoogleFonts.inter(
                        color: Color(0xff414751),
                        fontSize: 13.28,
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                  ),
                  onChanged: onTextChanged,
                ),
              ),
            ],
          ),
          Expanded(
            child: _selectedImages.isEmpty
                ? Center()
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _selectedImages.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    ),
                    itemBuilder: (context, index) {
                      final file = File(_selectedImages[index].path);
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(file,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () => removeImage(index),
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
                    },
                  ),
          ),
          // Link ekleme alanı
          if (_links.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${languageService.tr("post.createPost.links")} (${_links.length}):",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff414751),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._links.asMap().entries.map((entry) {
                    final index = entry.key;
                    final link = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xffffeeee),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Color(0xffef5050).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.link,
                            size: 16,
                            color: Color(0xffef5050),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              link,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Color(0xffef5050),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xffef5050),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => removeLink(index),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xffef5050),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          Container(
            color: Color(0xfffafafa),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildIconButton(Icon(Icons.camera_alt_outlined),
                    iconColor: Color(0xFFF26B6B), onPressed: () {
                  pickFromCamera();
                }),
                SizedBox(width: 10),
                buildIconButton(Icon(Icons.photo_outlined),
                    iconColor: Color(0xFFF26B6B), onPressed: () {
                  pickImages();
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
