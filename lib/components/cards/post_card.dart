import 'package:edusocial/components/widgets/user_tree_point_bottom_sheet_post.dart';
import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/verification_badge.dart';

import 'package:share_plus/share_plus.dart';

import '../widgets/comment_bottom_sheet.dart';
import '../widgets/tree_point_bottom_sheet.dart';
import '../snackbars/custom_snackbar.dart';
import '../../services/language_service.dart';

class PostCard extends StatefulWidget {
  final int postId;
  final String profileImage;
  final String name;
  final String surname;
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
  final bool? isVerified; // Hesap doğrulama durumu

  const PostCard(
      {super.key,
      required this.profileImage,
      required this.postId,
      required this.userName,
      required this.name,
      required this.surname,
      required this.postDate,
      required this.postDescription,
      required this.mediaUrls,
      required this.likeCount,
      required this.commentCount,
      required this.isLiked,
      required this.isOwner,
    required this.links,
    required this.slug,
    this.isVerified,});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int currentPage = 0;
  late bool isLiked;
  late int likeCount;
  late int commentCount; // Yorum sayısı için state değişkeni

  // 🆕 Double tap animation için controller'lar
  late AnimationController _doubleTapAnimationController;
  late Animation<double> _doubleTapAnimation;
  bool _showDoubleTapHeart = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    likeCount = widget.likeCount;
    commentCount = widget.commentCount; // Initial comment count

    // 🆕 Double tap animation setup
    _doubleTapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200), // 🔧 600ms → 1200ms uzatıldı
      vsync: this,
    );
    
    _doubleTapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _doubleTapAnimationController,
      curve: Curves.easeInOutBack, // 🔧 elasticOut → easeInOutBack (daha uzun görünür)
    ));

    // Animation listener
    _doubleTapAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showDoubleTapHeart = false;
        });
        _doubleTapAnimationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // bellek sızıntısını önler
    _doubleTapAnimationController.dispose(); // 🆕 Animation controller'ı dispose et
    super.dispose();
  }

  // Tarihi "gg.aa.yyyy hh:mm" formatında formatla
  String _formatDate(String dateString) {
    try {
      if (dateString.contains('T')) {
        final parts = dateString.split('T');
        if (parts.length >= 2) {
          final datePart = parts[0]; // 2025-05-28
          final timePart = parts[1]; // 22:37:10.000000Z
          
          // Tarih kısmını parçala
          final dateParts = datePart.split('-');
          if (dateParts.length >= 3) {
            final year = dateParts[0];
            final month = dateParts[1];
            final day = dateParts[2];
            
            // Saat kısmını parçala
            final timeParts = timePart.split(':');
            if (timeParts.length >= 2) {
              final hour = timeParts[0];
              final minute = timeParts[1];
              
              // "gg.aa.yyyy hh:mm" formatında döndür
              return "$day.$month.$year $hour:$minute";
            }
          }
        }
      }
      return dateString; // Format edilemezse orijinal string'i döndür
    } catch (e) {
      return dateString; // Hata durumunda orijinal string'i döndür
    }
  }

  /// 🆕 Double tap like fonksiyonu
  void _handleDoubleTapLike() {
    // Sadece beğenilmemiş postları beğen
    if (!isLiked) {
      setState(() {
        isLiked = true;
        likeCount += 1;
        _showDoubleTapHeart = true;
      });

      // API call
      final PostController postController = Get.find<PostController>();
      postController.toggleLike(widget.postId.toString());

      // Animation başlat
      _doubleTapAnimationController.forward();
    } else {
      // Zaten beğenilmişse sadece animation göster
      setState(() {
        _showDoubleTapHeart = true;
      });
      _doubleTapAnimationController.forward();
    }
  }

  /// 🆕 Double tap heart widget
  Widget _buildDoubleTapHeart() {
    return AnimatedBuilder(
      animation: _doubleTapAnimation,
      builder: (context, child) {
        // 🔧 Opacity hesaplaması iyileştirildi - kalp daha uzun süre görünür
        double opacity;
        if (_doubleTapAnimation.value <= 0.3) {
          // İlk %30'da hızla belirir (0 → 1)
          opacity = (_doubleTapAnimation.value / 0.3).clamp(0.0, 1.0);
        } else if (_doubleTapAnimation.value <= 0.7) {
          // Orta %40'da tam görünür kalır (1.0)
          opacity = 1.0;
        } else {
          // Son %30'da yavaşça kaybolur (1 → 0)
          opacity = (1.0 - ((_doubleTapAnimation.value - 0.7) / 0.3)).clamp(0.0, 1.0);
        }

        return Transform.scale(
          scale: 0.5 + (_doubleTapAnimation.value * 0.5), // 🔧 Daha yumuşak scale (0.5 → 1.0)
          child: Opacity(
            opacity: opacity,
            child: Icon(
              Icons.favorite,
              color: Colors.red,
              size: 100,
            ),
          ),
        );
      },
    );
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
      child: GestureDetector(
        onDoubleTap: _handleDoubleTapLike,
        behavior: HitTestBehavior.translucent,
        child: Stack(
        children: [
          Column(
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
                                backgroundColor: Color(0xfffafafa), // Gri arkaplan
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.userName.isNotEmpty ? '@${widget.userName}' : '${widget.name} ${widget.surname}',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: const Color(0xff414751),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    VerificationBadge(
                                      isVerified: widget.isVerified ?? false,
                                      size: 14.0,
                                    ),
                                  ],
                                ),
                                Text(
                                  _formatDate(widget.postDate),
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
                                  builder: (_) => TreePointBottomSheet(postId: widget.postId),
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
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                      
                                      // URL'yi temizle ve kontrol et
                                      String cleanLink = link.trim();
                                      if (!cleanLink.startsWith('http://') && !cleanLink.startsWith('https://')) {
                                        cleanLink = 'https://$cleanLink';
                                      }
                                      
                                      
                                      final Uri url = Uri.parse(cleanLink);
                                      
                                      // URL'nin açılabilir olup olmadığını kontrol et
                                      final canLaunch = await canLaunchUrl(url);
                                      
                                      if (canLaunch) {
                                        final result = await launchUrl(
                                          url, 
                                          mode: LaunchMode.externalApplication
                                        );
                                        
                                        if (!result && mounted) {
                                          CustomSnackbar.show(
                                            title: "Hata",
                                            message: "Link açılamadı. Lütfen tekrar deneyin.",
                                            type: SnackbarType.error,
                                          );
                                        }
                                      } else {
                                        if (mounted) {
                                          CustomSnackbar.show(
                                            title: "Hata",
                                            message: "Bu link açılamıyor: $cleanLink",
                                            type: SnackbarType.error,
                                          );
                                        }
                                      }
                                    } catch (e) {
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

              // 🔹 Slider Alanı - Double tap eklenmiş
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
                            builder: (context, controller) => CommentBottomSheet(
                              postId: widget.postId.toString(),
                              onCommentAdded: () {
                                // Yorum eklendiğinde comment count'u artır
                                setState(() {
                                  commentCount++;
                                });
                                
                                // Badge sayısı otomatik güncellenir - fetchNotifications() kaldırıldı
                              },
                            ),
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
                      commentCount.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff414751),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        final languageService = Get.find<LanguageService>();
                        String shareText = "${widget.userName} ${languageService.tr("common.buttons.postShared")}:\n\n${widget.postDescription}";
                        
                        // Eğer linkler varsa onları da ekle
                        if (widget.links.isNotEmpty) {
                          shareText += "\n\n${languageService.tr("common.buttons.links")}:\n";
                          for (String link in widget.links) {
                            shareText += "$link\n";
                          }
                        }
                        
                        // Sistem varsayılanı share sheet'ini kullan
                        Share.share(shareText);
                      },
                      child: SvgPicture.asset(
                        "images/icons/share.svg",
                        colorFilter: const ColorFilter.mode(
                            Color(0xff9ca3ae), BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      Get.find<LanguageService>().tr("common.buttons.share"),
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
          
          // 🆕 Double tap kalp animasyonu
          if (_showDoubleTapHeart)
            Positioned.fill(
              child: Center(
                child: _buildDoubleTapHeart(),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
