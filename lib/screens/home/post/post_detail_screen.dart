import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../components/cards/post_card.dart';
import '../../../components/widgets/general_loading_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../components/snackbars/custom_snackbar.dart';
import '../../../controllers/post_controller.dart';
import '../../../controllers/comment_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../models/comment_model.dart';
import '../../../services/language_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/people_profile_services.dart';
import '../../../utils/date_format.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostController postController = Get.find<PostController>();
  final LanguageService languageService = Get.find<LanguageService>();
  final ProfileController profileController = Get.find<ProfileController>();
  final AuthService _authService = AuthService();
  late CommentController commentController;
  final TextEditingController messageController = TextEditingController();
  String? postId;
  String? currentUsername;
  CommentModel? replyingTo;
  CommentModel? editingComment;
  Set<int> expandedComments = {};

  @override
  void initState() {
    super.initState();
    postId = Get.arguments?['post_id']?.toString();
    debugPrint('🔍 Post Detail Screen - Post ID: $postId');

    if (postId != null && postId!.isNotEmpty) {
      // CommentController'ı tag ile oluştur
      if (Get.isRegistered<CommentController>(tag: postId)) {
        commentController = Get.find<CommentController>(tag: postId);
      } else {
        commentController = Get.put(CommentController(), tag: postId);
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        postController.fetchPostDetail(postId!);
        commentController.fetchComments(postId!);
        _getCurrentUsername();
      });
    } else {
      debugPrint('❌ Post ID bulunamadı');
    }
  }

  Future<void> _getCurrentUsername() async {
    try {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        setState(() {
          currentUsername = userData['username'];
        });
      }
    } catch (e) {
      debugPrint('❌ Kullanıcı bilgisi alınamadı: $e');
    }
  }

  void _startReply(CommentModel comment) {
    setState(() {
      replyingTo = comment;
      editingComment = null;
    });
    messageController.text = '@${comment.userName} ';
    messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: messageController.text.length),
    );
  }

  void _cancelReply() {
    setState(() {
      replyingTo = null;
    });
    messageController.clear();
  }

  void _startEdit(CommentModel comment) {
    setState(() {
      editingComment = comment;
      replyingTo = null;
      messageController.text = comment.content;
    });
  }

  void _cancelEdit() {
    setState(() {
      editingComment = null;
    });
    messageController.clear();
  }

  void _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    if (editingComment != null) {
      final success = await commentController.editComment(
        editingComment!.id.toString(),
        postId!,
        text,
      );
      if (success) {
        _cancelEdit();
      }
    } else if (replyingTo != null) {
      final success = await commentController.addReply(
        postId!,
        replyingTo!.id.toString(),
        text,
      );
      if (success) {
        expandedComments.add(replyingTo!.id);
        _cancelReply();
      }
    } else {
      await commentController.addComment(postId!, text);
      messageController.clear();
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
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBar(
        surfaceTintColor: const Color(0xffFAFAFA),
        backgroundColor: const Color(0xffFAFAFA),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: SvgPicture.asset('images/icons/back_icon.svg'),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (postController.isPostDetailLoading.value) {
          return Center(
            child: GeneralLoadingIndicator(
              size: 32,
              color: const Color(0xFFFF7743),
              showText: true,
            ),
          );
        }

        final post = postController.selectedPost.value;
        if (post == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  languageService.tr("common.error"),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Post bulunamadı',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Post Card ve Yorumlar bölümü - Scroll edilebilir
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Post Card
                    PostCard(
                      postId: post.id,
                      profileImage: post.profileImage,
                      userName: post.username,
                      name: post.name,
                      surname: post.surname,
                      postDate: post.postDate,
                      postDescription: post.postDescription,
                      mediaUrls: post.mediaUrls,
                      likeCount: post.likeCount,
                      commentCount: post.commentCount,
                      isLiked: post.isLiked,
                      isOwner: post.isOwner,
                      links: post.links,
                      slug: post.slug,
                      isVerified: post.isVerified,
                    ),
                    // Yorumlar bölümü
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                languageService.tr("comments.title"),
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff414751),
                                ),
                              ),
                            ),
                            // Yorumlar listesi
                            Obx(() {
                              if (commentController.isLoading.value) {
                                return const Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Center(
                                    child: GeneralLoadingIndicator(
                                      size: 32,
                                      color: Color(0xFFef5050),
                                    ),
                                  ),
                                );
                              }
                    
                              if (commentController.commentList.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
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
                                          languageService.tr("comments.noComments"),
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                    
                              return Column(
                                children: [
                                  ...commentController.commentList.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final comment = entry.value;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: index == commentController.commentList.length - 1 ? 16 : 10,
                                      ),
                                      child: _buildCommentItem(comment),
                                    );
                                  }).toList(),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Yanıtlama alanı
            if (replyingTo != null) _buildReplyArea(),
            // Düzenleme alanı
            if (editingComment != null) _buildEditArea(),
            // Yorum yazma alanı
            Container(
              padding: const EdgeInsets.only(top: 16.0, bottom: 35.0, left: 16.0, right: 16.0),
              child: _buildCommentInputField(),
            ),
          ],
        );
      }),
    );
  }

  // Avatar URL'ini düzelt
  String _getAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return "https://stageapi.edusocial.pl/images/static/avatar.png";
    }
    
    // Eğer zaten tam URL ise olduğu gibi döndür
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return avatarUrl;
    }
    
    // Eğer /storage/ ile başlıyorsa (Laravel storage path)
    if (avatarUrl.startsWith('/storage/') || avatarUrl.startsWith('storage/')) {
      return "https://stageapi.edusocial.pl/${avatarUrl.replaceFirst('/', '')}";
    }
    
    // Eğer / ile başlıyorsa
    if (avatarUrl.startsWith('/')) {
      return "https://stageapi.edusocial.pl$avatarUrl";
    }
    
    // Diğer durumlarda storage path olarak kabul et
    return "https://stageapi.edusocial.pl/storage/$avatarUrl";
  }

  // Helper metodlar
  bool _isOwnComment(CommentModel comment) {
    return currentUsername != null && comment.userName == currentUsername;
  }

  bool _isRepliesExpanded(int commentId) {
    return expandedComments.contains(commentId);
  }

  void _toggleReplies(int commentId) {
    setState(() {
      if (expandedComments.contains(commentId)) {
        expandedComments.remove(commentId);
      } else {
        expandedComments.add(commentId);
      }
    });
  }

  String _formatReplyCount(int count) {
    if (count == 1) return 'yanıt';
    return 'yanıt';
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
          InkWell(
            onTap: () {
              profileController.getToPeopleProfileScreen(comment.userName);
            },
            child: CircleAvatar(
              backgroundColor: const Color(0xfffafafa),
              radius: 16,
              backgroundImage: NetworkImage(
                _getAvatarUrl(comment.userAvatar),
              ),
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('❌ Avatar yüklenemedi: ${comment.userAvatar}');
              },
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
                      child: InkWell(
                        onTap: () {
                          profileController.getToPeopleProfileScreen(comment.userName);
                        },
                        child: Text(
                          "@${comment.userName}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
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
                _buildCommentText(comment.content),
                const SizedBox(height: 8),
                // Yanıtla, Düzenle ve Sil butonları
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _startReply(comment),
                      child: Text(
                        languageService.tr("comments.reply.replyButton"),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xff414751),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_isOwnComment(comment)) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _startEdit(comment),
                        child: Text(
                          languageService.tr("comments.edit.editButton"),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF9ca3ae),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _showDeleteConfirmDialog(comment),
                        child: Text(
                          languageService.tr("comments.delete.deleteButton"),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFFEF5050),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                // Alt yorumlar varsa göster
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _toggleReplies(comment.id),
                    child: Row(
                      children: [
                        Container(
                          width: 2,
                          height: 20,
                          color: const Color(0xffe9ecef),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isRepliesExpanded(comment.id)
                              ? languageService.tr("comments.reply.hideReplies")
                              : "${comment.replies.length} ${_formatReplyCount(comment.replies.length)} • ${languageService.tr("comments.reply.showReplies")}",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xff6c757d),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isRepliesExpanded(comment.id)) ...[
                    const SizedBox(height: 8),
                    ...comment.replies.map((reply) => _buildReplyItem(reply)),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Yanıt bileşeni
  Widget _buildReplyItem(CommentModel reply) {
    return Container(
      margin: const EdgeInsets.only(left: 24, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              profileController.getToPeopleProfileScreen(reply.userName);
            },
            child: CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(
                _getAvatarUrl(reply.userAvatar),
              ),
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('❌ Avatar yüklenemedi: ${reply.userAvatar}');
              },
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
                      child: InkWell(
                        onTap: () {
                          profileController.getToPeopleProfileScreen(reply.userName);
                        },
                        child: Text(
                          "@${reply.userName}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
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
                _buildReplyText(reply.content),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _startReply(reply),
                      child: Text(
                        languageService.tr("comments.reply.replyButton"),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xff414751),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_isOwnComment(reply)) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _startEdit(reply),
                        child: Text(
                          languageService.tr("comments.edit.editButton"),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFF9ca3ae),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _showDeleteConfirmDialog(reply),
                        child: Text(
                          languageService.tr("comments.delete.deleteButton"),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFFEF5050),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Yorum metnini mention'larla göster
  Widget _buildCommentText(String content) {
    final RegExp mentionRegex = RegExp(r'@\w+');
    final List<TextSpan> spans = [];
    int lastEnd = 0;

    for (final Match match in mentionRegex.allMatches(content)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: content.substring(lastEnd, match.start),
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xff9ca3ae)),
        ));
      }

      final mentionText = match.group(0)!;
      final username = mentionText.substring(1);

      spans.add(TextSpan(
        text: mentionText,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xff007bff),
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _handleMentionTap(username),
      ));

      lastEnd = match.end;
    }

    if (lastEnd < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastEnd),
        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xff9ca3ae)),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  // Yanıt metnini mention'larla göster
  Widget _buildReplyText(String content) {
    final RegExp mentionRegex = RegExp(r'@\w+');
    final List<TextSpan> spans = [];
    int lastEnd = 0;

    for (final Match match in mentionRegex.allMatches(content)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: content.substring(lastEnd, match.start),
          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xff9ca3ae)),
        ));
      }

      final mentionText = match.group(0)!;
      final username = mentionText.substring(1);

      spans.add(TextSpan(
        text: mentionText,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: const Color(0xffef5050),
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _handleMentionTap(username),
      ));

      lastEnd = match.end;
    }

    if (lastEnd < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastEnd),
        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xff9ca3ae)),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  void _handleMentionTap(String username) async {
    try {
      final userExists = await _checkUserExists(username);
      if (userExists) {
        profileController.getToPeopleProfileScreen(username);
      } else {
        CustomSnackbar.show(
          title: languageService.tr("common.error"),
          message: "@$username kullanıcısı bulunamadı",
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      debugPrint('❌ Mention tap error: $e');
      CustomSnackbar.show(
        title: languageService.tr("common.error"),
        message: languageService.tr("common.error"),
        type: SnackbarType.error,
      );
    }
  }

  Future<bool> _checkUserExists(String username) async {
    try {
      if (username.isEmpty || username.length < 3) {
        return false;
      }
      final userProfile = await PeopleProfileService.fetchUserByUsername(username);
      return userProfile != null;
    } catch (e) {
      debugPrint('❌ User existence check error: $e');
      return false;
    }
  }

  void _showDeleteConfirmDialog(CommentModel comment) {
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            width: Get.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageService.tr("comments.delete.deleteConfirmTitle"),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  languageService.tr("comments.delete.deleteConfirmMessage"),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xfff8f9fa),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            languageService.tr("comments.delete.cancelButton"),
                            style: GoogleFonts.inter(
                              fontSize: 13.28,
                              color: const Color(0xffed7474),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Get.back();
                          await _deleteComment(comment);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF5050),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            languageService.tr("comments.delete.deleteConfirmButton"),
                            style: GoogleFonts.inter(
                              fontSize: 13.28,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final success = await commentController.deleteComment(
      comment.id.toString(),
      postId!,
    );
    if (success) {
      // Yorum silindi, liste otomatik güncellenecek
    }
  }

  // Yanıtlama alanı
  Widget _buildReplyArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe9ecef), width: 1),
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
                      languageService.tr("comments.reply.replyTo"),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xff6c757d),
                      ),
                    ),
                    Text(
                      "@${replyingTo!.userName}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff495057),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            languageService.tr("comments.reply.cancelReply"),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: const Color(0xff6c757d),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xff6c757d),
                          ),
                        ],
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

  // Düzenleme alanı
  Widget _buildEditArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.edit,
                      size: 16,
                      color: Color(0xFFEF6C00),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      languageService.tr("comments.edit.editingComment"),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF9ca3ae),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelEdit,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            languageService.tr("comments.edit.cancelEdit"),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: const Color(0xFFEF6C00),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFFEF6C00),
                          ),
                        ],
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

  // Yorum input alanı
  Widget _buildCommentInputField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            textInputAction: TextInputAction.send,
            enableSuggestions: true,
            autocorrect: true,
            style: GoogleFonts.inter(
              fontSize: 13.28,
              color: const Color(0xff414751),
            ),
            decoration: InputDecoration(
              hintText: editingComment != null
                  ? languageService.tr("comments.edit.editPlaceholder")
                  : replyingTo != null
                      ? languageService.tr("comments.reply.replyPlaceholder")
                      : languageService.tr("comments.input.placeholder"),
              hintStyle: GoogleFonts.inter(
                color: const Color(0xff9ca3ae),
                fontSize: 13.28,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            minLines: 1,
            maxLines: 4,
            onSubmitted: (value) => _sendMessage(),
          ),
        ),
        Obx(() => IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7743), Color(0xFFEF5050)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: commentController.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        editingComment != null ? Icons.check : Icons.send,
                        size: 16,
                        color: Colors.white,
                      ),
              ),
              onPressed: commentController.isLoading.value ? null : _sendMessage,
            )),
      ],
      ),
    );
  }
}

