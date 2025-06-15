import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/components/snackbars/custom_snackbar.dart';

class UserTreePointBottomSheet extends StatelessWidget {
  final int postId;

  const UserTreePointBottomSheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final PostController postController = Get.find();

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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xfffb535c)),
              title: const Text(
                "Delete",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff414751),
                ),
              ),
              onTap: () {
                Get.back(); // Bottom sheet'i kapat
                postController.deletePost(postId.toString());
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.warning_rounded,
                color: Color(0xfffb535c),
              ),
              title: const Text(
                "Şikayet Et",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff414751),
                ),
              ),
              onTap: () {
                Get.back(); // Bottom sheet'i kapat
                CustomSnackbar.show(
                  title: "Bilgi",
                  message: "Şikayet özelliği yakında eklenecek",
                  type: SnackbarType.info,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
