import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/comment_controller.dart';
import '../../services/language_service.dart';
import '../input_fields/comment_input_field.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId;
  final VoidCallback? onCommentAdded;
  const CommentBottomSheet({super.key, required this.postId, this.onCommentAdded});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  late final CommentController controller;
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Controller'ın var olup olmadığını kontrol et
    try {
      if (Get.isRegistered<CommentController>(tag: widget.postId)) {
        controller = Get.find<CommentController>(tag: widget.postId);
      } else {
        controller = Get.put(CommentController(), tag: widget.postId);
      }
    } catch (e) {
      // Eğer hata olursa yeni instance oluştur
      controller = Get.put(CommentController(), tag: widget.postId);
    }
    
    // Yorumlar daha önce yüklenmediyse yükle
    if (controller.commentList.isEmpty) {
      controller.fetchComments(widget.postId);
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  Get.find<LanguageService>().tr("comments.title"),
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),

              // 🧾 Yorumlar listesi
              Expanded(
                child: Obx(() {
                  // Loading durumu
                  if (controller.isLoading.value) {
                    return  Center(
                      child: GeneralLoadingIndicator(
                        size: 32,
                        color: Color(0xFFef5050),
                      ),
                    );
                  }
                  
                  // Yorum yoksa
                  if (controller.commentList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            Get.find<LanguageService>().tr("comments.noComments"),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Yorumlar listesi
                  return ListView.separated(
                    itemCount: controller.commentList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final comment = controller.commentList[index];
                      return Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(comment.userAvatar),
                              radius: 20,
                              onBackgroundImageError: (_, __) {},
                              child: comment.userAvatar.isEmpty 
                                ? Icon(Icons.person, color: Colors.grey.shade600)
                                : null,
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
                                          comment.userName,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formatSimpleDateClock(
                                            comment.createdAt),
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.content,
                                    style: GoogleFonts.inter(fontSize: 12, color: Color(0xff9ca3ae)),
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
                  child: buildCommentInputField(
                      controller, widget.postId, messageController, widget.onCommentAdded)),
            ],
          ),
        ),
      ),
    );
  }
}
