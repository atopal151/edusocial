import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/comment_controller.dart';
import '../input_fields/comment_input_field.dart';

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet({super.key});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final CommentController controller = Get.put(CommentController());

  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: Get.height,
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔘 Üstteki sürükleme çubuğu
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              //  Başlık
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Yorumlar",
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
      
              // 🧾 Yorumlar listesi
              Expanded(
                child: Obx(() {
                  return ListView.separated(
                    itemCount: controller.comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final comment = controller.comments[index];
                      return Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(comment.userProfileImage),
                              radius: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          comment.username,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        comment.commentDate,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.commentText,
                                    style: GoogleFonts.inter(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
      
              // Yorum Yazma Alanı
              Padding(
                padding: const EdgeInsets.all(5),
                child: buildCommentInputField(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
