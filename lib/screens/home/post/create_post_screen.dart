import 'dart:io';
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

  void sharePost() {
    if (textController.text.isNotEmpty || _selectedImages.isNotEmpty) {
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Align(
            alignment: Alignment.centerLeft,
            child: const Text("Gönderi Oluştur",
                style: TextStyle(color: Colors.white, fontSize: 16))),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: textController,
              maxLines: null,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Ne düşünüyorsun?",
                hintStyle: TextStyle(color: Colors.white54, fontSize: 13.28),
                border: InputBorder.none,
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
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.camera_alt_rounded,
                            size: 32, color: Colors.white),
                      ),
                    ),
                  );
                } else {
                  final file = File(_selectedImages[index - 1].path);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(file, fit: BoxFit.cover),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  foregroundColor: Colors.white,
                ),
                onPressed: pickImages,
                icon: const Icon(
                  Icons.photo_library,
                  size: 18,
                ),
                label: Text(
                  "Galeri",
                  style: GoogleFonts.inter(fontSize: 13.28),
                ),
              ),
            ),
          ),
          if (_selectedImages.isNotEmpty || textController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: sharePost,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text("Paylaş",
                      style:
                          TextStyle(color: Color(0xff414751), fontSize: 13.28)),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
