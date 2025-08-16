import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:edusocial/utils/date_format.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/comment_controller.dart';
import '../../services/language_service.dart';
import '../../models/comment_model.dart';

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
  
  // Yanıtlama state'i
  CommentModel? replyingTo;

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

  // Yanıtlama modunu başlat
  void _startReply(CommentModel comment) {
    setState(() {
      replyingTo = comment;
    });
    messageController.clear();
  }

  // Yanıtlama modunu iptal et
  void _cancelReply() {
    setState(() {
      replyingTo = null;
    });
    messageController.clear();
  }

  // Yorum veya yanıt gönder
  void _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      if (replyingTo != null) {
        // Yanıt gönder
        debugPrint('🔄 Yanıt gönderiliyor: $text');
        debugPrint('🔄 Yanıtlanan yorum: ${replyingTo!.userName}');
        
        // await controller.addReply(widget.postId, replyingTo!.id, text);
        
        _cancelReply();
      } else {
        // Normal yorum gönder
        await controller.addComment(widget.postId, text);
        messageController.clear();
        widget.onCommentAdded?.call();
      }
    }
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
                  return RefreshIndicator(
                    color: Color(0xFFef5050),
                backgroundColor: Color(0xfffafafa),
                
                    onRefresh: () async {
                      await controller.fetchComments(widget.postId);
                    },
                    child: ListView.separated(
                      itemCount: controller.commentList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final comment = controller.commentList[index];
                        return _buildCommentItem(comment);
                      },
                    ),
                  );
                }),
              ),

              // Yanıtlama alanı (Instagram tarzı)
              if (replyingTo != null) _buildReplyArea(),

              // Yorum Yazma Alanı
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: _buildCommentInputField()),
            ],
          ),
        ),
      ),
    );
  }

  // Yorum bileşeni
  Widget _buildCommentItem(CommentModel comment) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil resmi
          CircleAvatar(
            backgroundColor: Color(0xfffafafa),
            radius: 16,
            backgroundImage: NetworkImage(
              comment.userAvatar.isNotEmpty
                  ? comment.userAvatar
                  : "${AppConstants.baseUrl}/images/static/avatar.png",
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row( 
                  children: [
                    Expanded(
                      child: Text(
                        "@${comment.userName}", // @ işareti eklendi
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      formatSimpleDateClock(comment.createdAt),
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
                const SizedBox(height: 8),
                // Yanıtla butonu
                GestureDetector(
                  onTap: () => _startReply(comment),
                  child: Text(
                    Get.find<LanguageService>().tr("comments.reply.replyButton"),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Color(0xff414751),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Alt yorumlar varsa göster
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...comment.replies.map((reply) => _buildReplyItem(reply)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Yanıt bileşeni (girintili)
  Widget _buildReplyItem(CommentModel reply) {
    return Container(
      margin: const EdgeInsets.only(left: 24, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(
              reply.userAvatar.isNotEmpty
                  ? reply.userAvatar
                  : "${AppConstants.baseUrl}/images/static/avatar.png",
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "@${reply.userName}",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      formatSimpleDateClock(reply.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reply.content,
                  style: GoogleFonts.inter(fontSize: 11, color: Color(0xff9ca3ae)),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _startReply(reply),
                  child: Text(
                    Get.find<LanguageService>().tr("comments.reply.replyButton"),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Color(0xff9ca3ae),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Yanıtlama alanı (Instagram tarzı)
  Widget _buildReplyArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xffe9ecef), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                                       Text(
                     Get.find<LanguageService>().tr("comments.reply.replyTo"),
                     style: GoogleFonts.inter(
                       fontSize: 12,
                       color: Color(0xff6c757d),
                     ),
                   ),
                    Text(
                      "@${replyingTo!.userName}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff495057),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xff6c757d),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Yorum input alanı (tek alan hem yorum hem yanıt için)
  Widget _buildCommentInputField() {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfffafafa),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              textInputAction: TextInputAction.send,
              enableSuggestions: true,
              autocorrect: true,
                             decoration: InputDecoration(
                 hintText: replyingTo != null 
                     ? languageService.tr("comments.reply.replyPlaceholder")
                     : languageService.tr("comments.input.placeholder"),
                hintStyle: TextStyle(color: Color(0xff9ca3ae), fontSize: 13.28),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              minLines: 1,
              maxLines: 4,
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          Obx(() => IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF7743), Color(0xFFEF5050)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.send,
                      size: 16,
                      color: Colors.white,
                    ),
            ),
            onPressed: controller.isLoading.value
                ? null
                : _sendMessage,
          )),
        ],
      ),
    );
  }
}
