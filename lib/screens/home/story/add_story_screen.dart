import 'dart:io';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/story_controller.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final List<XFile> _selectedImages = [];
  final ImagePicker picker = ImagePicker();

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
      debugPrint("Hata: $e",wrapWidth: 1024);
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

void shareStory() async {
  if (_selectedImages.isNotEmpty) {
    final StoryController storyController = Get.find<StoryController>();

    final File imageFile = File(_selectedImages.first.path);

    await storyController.createStory(imageFile);

    debugPrint("✅ Hikaye yüklendi ve güncellendi.");
    Get.back();
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 🔥 siyah arka plan
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Align(
            alignment: Alignment.center,
            child: const Text("Hikayeye Ekle",
                style: TextStyle(color: Colors.white,fontSize: 18.72,fontWeight: FontWeight.w600))),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: InkWell(onTap: () {
          Get.back();
        }, child: Icon(Icons.arrow_back_ios)),
        actions: [Icon(Icons.settings)],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            alignment: Alignment.centerLeft,
            child: const Text(
              "Yakınlardakiler",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
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
                  // Kamera kutusu
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
                icon: const Icon(Icons.photo_library),
                label: const Text("Galeriden Seç"),
              ),
            ),
          ),
          if (_selectedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16,left: 16,right: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: shareStory,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text("Paylaş",
                      style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
            SizedBox(height: 20,)
        ],
      ),
    );
  }
}
