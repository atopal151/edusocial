import 'package:edusocial/components/widgets/user_tree_point_bottom_sheet_post.dart';
import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../widgets/comment_bottom_sheet.dart';
import '../widgets/share_bottom_sheet.dart';
import '../widgets/tree_point_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  final int postId;
  final String profileImage;
  final String name;
  final String userName;
  final String postDate;
  final String postDescription;
  final List<String> mediaUrls;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isOwner;

  const PostCard(
      {super.key,
      required this.profileImage,
      required this.postId,
      required this.userName,
      required this.name,
      required this.postDate,
      required this.postDescription,
      required this.mediaUrls,
      required this.likeCount,
      required this.commentCount,
      required this.isLiked,
      required this.isOwner});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    likeCount = widget.likeCount;
  }

  @override
  void dispose() {
    _pageController.dispose(); // bellek sızıntısını önler
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    final PostController postController = Get.find<PostController>();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Profil ve açıklama kısmı
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                        onTap: () {
                          if (widget.isOwner == false) {
                            profileController
                                .getToPeopleProfileScreen(widget.userName);
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade300, // Gri arkaplan
                          backgroundImage: widget.profileImage.isNotEmpty
                              ? NetworkImage(widget.profileImage)
                              : null, // Eğer profil resmi varsa kullan
                          child: widget.profileImage.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null, // Profil resmi yoksa ikon
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: const Color(0xff414751),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.postDate,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: const Color(0xff9CA3AE),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (widget.isOwner == false) {
                          showModalBottomSheet(
                            backgroundColor: Colors.white,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25)),
                            ),
                            builder: (_) => const TreePointBottomSheet(),
                          );
                        }
                        if (widget.isOwner == true) {
                          showModalBottomSheet(
                            backgroundColor: Colors.white,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25)),
                            ),
                            builder: (_) => UserTreePointBottomSheet(
                              postId: widget.postId,
                            ),
                          );
                        }
                      },
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: SvgPicture.asset(
                          "images/icons/tree_dot.svg",
                          colorFilter: const ColorFilter.mode(
                              Color(0xff414751), BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.postDescription,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff414751),
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 🔹 Slider Alanı
          if (widget.mediaUrls.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.mediaUrls.length,
                    onPageChanged: (index) {
                      setState(() => currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        child: Image.network(
                          widget.mediaUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image,
                                  size: 40, color: Colors.grey),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.mediaUrls.length,
                  effect: const WormEffect(
                    dotHeight: 6,
                    dotWidth: 6,
                    activeDotColor: Color(0xff414751),
                    dotColor: Color(0xffd1d5db),
                  ),
                ),
              ],
            ),

          // 🔹 Alt butonlar (like, yorum, paylaş)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isLiked = !isLiked;
                      likeCount += isLiked ? 1 : -1;
                    });
                    postController.toggleLike(widget.postId.toString());
                  },
                  child: SvgPicture.asset(
                    "images/icons/post_like.svg",
                    colorFilter: ColorFilter.mode(
                      isLiked ? Colors.red : Color(0xff9ca3ae),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  likeCount.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff414751),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (_) => DraggableScrollableSheet(
                        initialChildSize: 0.95,
                        maxChildSize: 0.95,
                        minChildSize: 0.95,
                        expand: false,
                        builder: (_, controller) => CommentBottomSheet(
                            postId: widget.postId.toString()),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    "images/icons/post_chat.svg",
                    colorFilter: const ColorFilter.mode(
                        Color(0xff9ca3ae), BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.commentCount.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff414751),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    final shareText =
                        "${widget.userName} bir gönderi paylaştı:\n\n${widget.postDescription}";
                    showModalBottomSheet(
                      backgroundColor: Colors.white,
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25)),
                      ),
                      builder: (_) =>
                          ShareOptionsBottomSheet(postText: shareText),
                    );
                  },
                  child: SvgPicture.asset(
                    "images/icons/share.svg",
                    colorFilter: const ColorFilter.mode(
                        Color(0xff9ca3ae), BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  "Paylaş",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff414751),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
