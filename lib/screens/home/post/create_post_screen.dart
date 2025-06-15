import 'dart:io';
import 'package:edusocial/components/buttons/icon_button.dart';
import 'package:edusocial/components/snackbars/custom_snackbar.dart';
import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/controllers/profile_controller.dart';
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

  void sharePost() async {
    if (textController.text.isNotEmpty) {
      try {
        isPosting.value = true;
        final content = textController.text;
        final mediaFiles = _selectedImages.map((xfile) => File(xfile.path)).toList();
        await postController.createPost(content, mediaFiles);
        isPosting.value = false;
        Get.back();
      } catch (e) {
        isPosting.value = false;
        CustomSnackbar.show(
          title: "Hata",
          message: "Gönderi paylaşılırken bir hata oluştu.",
          type: SnackbarType.error,
        );
      }
    } else {
      CustomSnackbar.show(
        title: "Uyarı",
        message: "Lütfen gönderi içeriği girin.",
        type: SnackbarType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    color: isPosting.value ? Colors.grey : Color(0xFFF26B6B),
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Text(
                          "Gönderi",
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
                      backgroundImage: NetworkImage(
                        profileController.profileImage.value.isNotEmpty
                            ? profileController.profileImage.value
                            : "https://i.pravatar.cc/150?img=1", // fallback
                      ),
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: textController,
                  maxLines: null,
                  style: const TextStyle(color: Color(0xff414751)),
                  decoration: InputDecoration(
                    hintText: "Neler oluyor?",
                    hintStyle: GoogleFonts.inter(
                        color: Color(0xff414751), fontSize: 13.28),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: _selectedImages.isEmpty
                ? Center(
                    child: Text('Fotoğraf eklemedin',
                        style: GoogleFonts.inter(color: Colors.grey)))
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
