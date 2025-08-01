import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edusocial/controllers/post_controller.dart';
import '../../services/language_service.dart';

class UserTreePointBottomSheet extends StatelessWidget {
  final int postId;

  const UserTreePointBottomSheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final PostController postController = Get.find();
    final LanguageService languageService = Get.find<LanguageService>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Color(0xff9ca3ae),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: const Icon(Icons.delete, color: Color(0xffef5050), size: 20),
              ),
              title: Text(
                languageService.tr("common.actions.delete"),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff272727),
                ),
              ),
              onTap: () {
                Get.back(); // Bottom sheet'i kapat
                postController.deletePost(postId.toString());
              },
            ),
           
          ],
        ),
      ),
    );
  }
}
