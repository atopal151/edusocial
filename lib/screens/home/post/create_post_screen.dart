import 'dart:io';
import 'package:edusocial/components/buttons/icon_button.dart';
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
  final List<XFile> _selectedImages = [];
  final ImagePicker picker = ImagePicker();
  final TextEditingController textController = TextEditingController();
  var isLoading = false.obs;

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

  void sharePost() {
    if (textController.text.isNotEmpty) {
      print("Yeni post: ${textController.text}");
      for (var img in _selectedImages) {
        print("Görsel: ${img.path}");
      }
      Get.back();
      Get.snackbar("Başarılı", "Gönderi paylaşıldı");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
              child: GestureDetector(
                onTap: () {
                  sharePost();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF26B6B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize:
                        MainAxisSize.min, // Buton içinde sıkışmaması için
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
              ),
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
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/1.jpg'),
                ),
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
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildIconButton(Icon(Icons.camera_alt_outlined),
                    iconColor: Color(0xFFF26B6B), onPressed: () {
                  pickFromCamera();
                }),
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
