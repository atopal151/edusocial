import 'package:edusocial/components/widgets/user_tree_point_bottom_sheet_post.dart';
import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/comment_bottom_sheet.dart';
import '../widgets/share_bottom_sheet.dart';
import '../widgets/tree_point_bottom_sheet.dart';
import '../snackbars/custom_snackbar.dart';

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
  final List<String> links; // ✅ Yeni ekledik!
  final String slug;

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
      required this.isOwner,
    required this.links,
    required this.slug,});

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
        color: Color(0xffffffff),
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
                          backgroundColor: Color(0xfff3f4f6), // Gri arkaplan
                          backgroundImage: widget.profileImage.isNotEmpty
                              ? NetworkImage(widget.profileImage)
                              : null, // Eğer profil resmi varsa kullan
                          child: widget.profileImage.isEmpty
                              ? const Icon(Icons.person, color: Color(0xffffffff))
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
                              fontWeight: FontWeight.w400,
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
                            backgroundColor: Color(0xffffffff),
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
                            backgroundColor: Color(0xffffffff),
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
                if (widget.links.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       
                        ...widget.links.map(
                          (link) => InkWell(
                            onTap: () async {
                              try {
                                debugPrint("🔗 Link açma deneniyor: $link");
                                
                                // URL'yi temizle ve kontrol et
                                String cleanLink = link.trim();
                                if (!cleanLink.startsWith('http://') && !cleanLink.startsWith('https://')) {
                                  cleanLink = 'https://$cleanLink';
                                }
                                
                                debugPrint("🔗 Temizlenmiş link: $cleanLink");
                                
                                final Uri url = Uri.parse(cleanLink);
                                debugPrint("🔗 Parsed URL: $url");
                                
                                // URL'nin açılabilir olup olmadığını kontrol et
                                final canLaunch = await canLaunchUrl(url);
                                debugPrint("🔗 canLaunchUrl sonucu: $canLaunch");
                                
                                if (canLaunch) {
                                  debugPrint("🔗 URL açılıyor...");
                                  final result = await launchUrl(
                                    url, 
                                    mode: LaunchMode.externalApplication
                                  );
                                  debugPrint("🔗 launchUrl sonucu: $result");
                                  
                                  if (!result && mounted) {
                                    CustomSnackbar.show(
                                      title: "Hata",
                                      message: "Link açılamadı. Lütfen tekrar deneyin.",
                                      type: SnackbarType.error,
                                    );
                                  }
                                } else {
                                  debugPrint("🔗 URL açılamıyor: $url");
                                  if (mounted) {
                                    CustomSnackbar.show(
                                      title: "Hata",
                                      message: "Bu link açılamıyor: $cleanLink",
                                      type: SnackbarType.error,
                                    );
                                  }
                                }
                              } catch (e) {
                                debugPrint("🔗 Link açma hatası: $e");
                                if (mounted) {
                                  CustomSnackbar.show(
                                    title: "Hata",
                                    message: "Link açılırken bir hata oluştu: ${e.toString()}",
                                    type: SnackbarType.error,
                                  );
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                link,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Color(0xff007bff),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xff007bff),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    String shareText = "${widget.userName} bir gönderi paylaştı:\n\n${widget.postDescription}";
                    
                    // Eğer linkler varsa onları da ekle
                    if (widget.links.isNotEmpty) {
                      shareText += "\n\nLinkler:\n";
                      for (String link in widget.links) {
                        shareText += "$link\n";
                      }
                    }
                    
                    showModalBottomSheet(
                      backgroundColor: Color(0xffffffff),
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25)),
                      ),
                      builder: (_) => ShareOptionsBottomSheet(
                        postText: shareText,
                        postId: widget.postId,
                        postSlug: widget.slug,
                      ),
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
