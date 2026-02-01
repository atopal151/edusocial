import 'package:edusocial/components/cards/people_profile_card.dart';
import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/components/widgets/build_people_profile_details.dart';
import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:edusocial/components/widgets/empty_state_widget.dart';
import 'package:edusocial/controllers/people_profile_controller.dart';
import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/cards/person_entry_card.dart';
import '../../components/cards/post_card.dart';
import '../../components/profile_tabbar/toggle_tab_bar.dart';
import '../../controllers/entry_controller.dart';
import '../../controllers/post_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/language_service.dart';
import '../../models/people_profile_model.dart';

class PeopleProfileScreen extends StatefulWidget {
  final String username;
  const PeopleProfileScreen({super.key, required this.username});

  @override
  State<PeopleProfileScreen> createState() => _PeopleProfileScreenState();
}

class _PeopleProfileScreenState extends State<PeopleProfileScreen> {
  final PeopleProfileController controller = Get.put(PeopleProfileController());
  final PostController postController = Get.put(PostController());
  final EntryController entryController = Get.put(EntryController());

  final RxInt selectedTabIndex = 0.obs;
  final RxBool isAboutExpanded = false.obs;

  /// Profil verilerini yenile
  Future<void> _refreshProfile() async {
    debugPrint("🔄 People Profile sayfası yenileniyor...");
    await controller.loadUserProfileByUsername(widget.username);
    debugPrint("✅ People Profile sayfası yenilendi");
  }

  @override
  void initState() {
    super.initState();
    controller.loadUserProfileByUsername(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: BackAppBar(
        backgroundColor: const Color(0xffffffff),
        iconBackgroundColor: const Color(0xfffafafa),
      ),
      body: Obx(() {
        // Loading durumunda kişiselleştirilmiş loading göster
        if (controller.isLoading.value) {
          return Center(
            child: GeneralLoadingIndicator(
              size: 36,
              color: const Color(0xFFEF5050),
            ),
          );
        }

        final profile = controller.profile.value;
        if (profile == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child:
                  Text(languageService.tr("profile.peopleProfile.loadError")),
            ),
          );
        }

        return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildPeopleProfileHeader(controller),
                    const SizedBox(height: 20),

                    /// Sosyal medya kısayolları (sadece takip ediyorsa veya kendi profiliyse)
                    _buildSocialLinks(profile),
                    const SizedBox(height: 16),

                    /// Takip ve Mesaj Gönder Butonları
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() {
                          final isPending = controller.isFollowingPending.value;
                          final isFollowing = controller.isFollowing.value;

                          final String buttonText = isPending
                              ? languageService
                                  .tr("profile.peopleProfile.actions.pendingApproval")
                              : isFollowing
                                  ? languageService
                                      .tr("profile.peopleProfile.actions.unfollow")
                                  : languageService
                                      .tr("profile.peopleProfile.actions.follow");

                          final Color bgColor = isPending
                              ? const Color(0xFFFF8C00)
                              : isFollowing
                                  ? const Color(0xffffffff) // unfollow: beyaz arka plan
                                  : const Color(0xffffffff); // follow: beyaz arka plan

                          final Color txtColor = isPending
                              ? const Color(0xffffffff)
                              : isFollowing
                                  ? const Color(0xFFEF5050) // unfollow: kırmızı metin
                                  : const Color(0xFF28A745); // follow: yeşil metin

                          final Color? borderColor = isPending
                              ? const Color(0xFFFF8C00) // pending outline turuncu
                              : isFollowing
                                  ? const Color(0xFFEF5050) // unfollow outline kırmızı
                                  : const Color(0xFF28A745); // follow outline yeşil

                          final double? borderWidth = isFollowing ? 1 : 1;

                          return SizedBox(
                            width: 140,
                            child: CustomButton(
                              height: 40,
                              borderRadius: 5,
                              text: buttonText,
                              onPressed: () {
                                if (!isPending) {
                                  if (isFollowing) {
                                    controller.unfollowUser(profile.id);
                                  } else if (controller.isFollowingPending.value) {
                                    // kontrol
                                  } else {
                                    controller.followUser(profile.id);
                                  }
                                }
                              },
                              backgroundColor: bgColor,
                              textColor: txtColor,
                              borderColor: borderColor,
                              borderWidth: borderWidth,
                              isLoading: controller.isFollowLoading,
                            ),
                          );
                        }),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 140,
                          child: CustomButton(
                            height: 40,
                            borderRadius: 5,
                            text: languageService.tr(
                                "profile.peopleProfile.actions.sendMessage"),
                            onPressed: () {
                              // Mesaj gönderme ekranına yönlendirme
                              Get.toNamed(Routes.chatDetail, arguments: {
                                'userId': profile.id,
                                'conversationId':
                                    null, // Yeni konuşma başlatılacak
                                'name': '${profile.name} ${profile.surname}',
                                'username': profile.username,
                                'avatarUrl': profile.avatarUrl.isNotEmpty
                                    ? profile.avatarUrl
                                    : profile.avatar,
                                'isOnline': profile.isOnline,
                              });
                            },
                            backgroundColor: const Color(0xff1f1f1f),
                            textColor: const Color(0xffffffff),
                            icon: SvgPicture.asset(
                              "images/icons/post_chat.svg",
                              colorFilter: const ColorFilter.mode(
                                Color(0xffffffff),
                                BlendMode.srcIn,
                              ),
                              width: 20,
                              height: 20,
                            ),
                            iconColor: const Color(0xffffffff),
                            isLoading: false.obs,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
            body: RefreshIndicator(
              onRefresh: _refreshProfile,
              color: const Color(0xFFef5050),
              backgroundColor: Colors.white,
              elevation: 0,
              strokeWidth: 2.0,
              displacement: 40.0,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  /// About bölümü üstte - açılıp kapanabilir
                  SliverToBoxAdapter(
                    child: _buildAboutSection(),
                  ),
                  /// Grid içeriği (Postlar / Entryler) altta
                  SliverToBoxAdapter(
                    child: Container(
                      color: const Color(0xfffafafa),
                      child: ToggleTabBar(
                        selectedIndex: selectedTabIndex,
                        onTabChanged: (index) {
                          selectedTabIndex.value = index;
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Obx(() {
                      return selectedTabIndex.value == 0
                          ? _buildPosts()
                          : _buildEntries();
                    }),
                  ),
                ],
              ),
            ),
        );
      }),
    );
  }

  Widget _buildPosts() {
    final LanguageService languageService = Get.find<LanguageService>();
    final posts = controller.profile.value?.posts ?? [];
    final profile = controller.profile.value;

    // Gizli profil kontrolü - sadece takip ediyorsa içerik göster
    if (profile != null) {
      final isPrivateProfile = profile.accountType == "private";
      final isFollowing = controller.isFollowing.value;

      if (isPrivateProfile && !isFollowing) {
        return _buildLockedContent();
      }
    }

    if (posts.isEmpty) {
      return Container(
        constraints: const BoxConstraints(minHeight: 200),
        child: EmptyStateWidgets.postsEmptyState(languageService),
      );
    }

    return Container(
      decoration: BoxDecoration(color: Color(0xfffafafa)),
      child: Column(
        children: posts.map((post) {
          final date = formatSimpleDateClock(post.postDate);
          return PostCard(
            postId: post.id,
            profileImage: post.profileImage,
            name: post.name,
            surname: post.surname,
            userName: post.username,
            postDate: date,
            postDescription: post.postDescription,
            mediaUrls: post.mediaUrls,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            isLiked: post.isLiked,
            isOwner: post.isLiked,
            links: post.links,
            slug: post.slug,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEntries() {
    final LanguageService languageService = Get.find<LanguageService>();

    return Obx(() {
      final profile = controller.profile.value;

      // Gizli profil kontrolü - sadece takip ediyorsa içerik göster
      if (profile != null) {
        final isPrivateProfile = profile.accountType == "private";
        final isFollowing = controller.isFollowing.value;

        if (isPrivateProfile && !isFollowing) {
          return _buildLockedContent();
        }
      }

      // Entries loading durumu
      if (controller.isEntriesLoading.value) {
        return SizedBox(
          height: 200,
          child: Center(
            child: GeneralLoadingIndicator(
              size: 24,
              color: const Color(0xFFEF5050),
            ),
          ),
        );
      }

      if (controller.peopleEntries.isEmpty) {
        return Container(
          constraints: const BoxConstraints(minHeight: 200),
          child: EmptyStateWidgets.entriesEmptyState(languageService),
        );
      }

      return Column(
        children: controller.peopleEntries.map((entry) {
          // Entry'nin kullanıcı bilgilerini al
          final user = entry.user;

          //debugPrint("🔍 PersonEntryCard - Kullanıcı bilgileri: ${user.avatarUrl}");
          return Container(
            color: const Color(0xfffafafa),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: PersonEntryCard(
                entry: entry,
                user: user, // Kullanıcı bilgilerini dışarıdan veriyoruz
                topicName: entry.topic?.name,
                categoryTitle: entry.topic?.category?.title,
                onPressed: () {
                  Get.toNamed(Routes.entryDetail, arguments: {'entry': entry});
                },
                onPressedProfile: () {
                  // Topic'i oluşturan kullanıcının profil sayfasına yönlendir
                  if (user.username.isNotEmpty) {
                    Get.to(() => PeopleProfileScreen(username: user.username));
                  } else {
                    debugPrint(
                        "⚠️ Kullanıcı bilgileri eksik, profil sayfasına yönlendirilemiyor");
                  }
                },
                onUpvote: () => entryController.voteEntry(entry.id, "up"),
                onDownvote: () => entryController.voteEntry(entry.id, "down"),
                onShare: () {
                  // Konu bilgilerini al
                  final topicName = entry.topic?.name ??
                      languageService
                          .tr("profile.peopleProfile.shareText.topicInfo");
                  final categoryTitle = entry.topic?.category?.title ??
                      languageService
                          .tr("profile.peopleProfile.shareText.categoryInfo");

                  final String shareText = """
  📝 **$topicName** (#${entry.id})

  🏷️ **${languageService.tr("profile.peopleProfile.shareText.category")}:** $categoryTitle
  👤 **${languageService.tr("profile.peopleProfile.shareText.author")}:** ${user.name} ${user.surname}

  💬 **${languageService.tr("profile.peopleProfile.shareText.entryContent")}:**
  ${entry.content}

  📱 **${languageService.tr("profile.peopleProfile.shareText.downloadApp")}**
  📲 ${languageService.tr("profile.peopleProfile.shareText.appStore")}
  📱 ${languageService.tr("profile.peopleProfile.shareText.playStore")}

  ${languageService.tr("profile.peopleProfile.shareText.hashtags")} #$categoryTitle
  """;
                  Share.share(shareText);
                },
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildProfileDetails() {
    final profile = controller.profile.value;

    // Gizli profil kontrolü - sadece takip ediyorsa içerik göster
    if (profile != null) {
      final isPrivateProfile = profile.accountType == "private";
      final isFollowing = controller.isFollowing.value;

      if (isPrivateProfile && !isFollowing) {
        return _buildLockedContent();
      }
    }

    if (profile == null) {
      final LanguageService languageService = Get.find<LanguageService>();
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(languageService.tr("profile.peopleProfile.notFound")),
        ),
      );
    }

    return buildPeopleProfileDetails(profile);
  }

  /// About detaylarını açılır/kapanır kart olarak gösterir
  Widget _buildAboutSection() {
    final LanguageService languageService = Get.find<LanguageService>();
    final aboutText = languageService.tr("profile.details.about");
    final aboutTitle =
        aboutText == "profile.details.about" ? "About" : aboutText;

    return Obx(() {
      return Container(
        color: const Color(0xfffafafa),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  isAboutExpanded.value = !isAboutExpanded.value;
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(
                        aboutTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff414751),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xfff3f4f6),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: AnimatedRotation(
                          turns: isAboutExpanded.value ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: Color(0xffbfc3c9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: isAboutExpanded.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildProfileDetails(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }

  // Kilitli içerik widget'ı
  Widget _buildLockedContent() {
    final LanguageService languageService = Get.find<LanguageService>();

    return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xfff4f4f5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.lock,
                  size: 30,
                  color: Color(0xff9ca3ae),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                languageService.tr("profile.peopleProfile.lockedContent.title"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff414751),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                languageService
                    .tr("profile.peopleProfile.lockedContent.description"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xff9ca3ae),
                ),
              ),
            ],
          ),
        ));
  }

  /// Sosyal medya butonlarını gösterir
  Widget _buildSocialLinks(PeopleProfileModel profile) {
    final bool canShow = controller.isFollowing.value || profile.isSelf == true;
    if (!canShow) return const SizedBox.shrink();

    final List<_SocialLink> socials = [
      _SocialLink(
        handle: profile.facebook,
        baseUrl: "https://facebook.com/",
        asset: "images/icons/social_icon/facebook.svg",
        color: const Color(0xFF1877F2),
      ),
      _SocialLink(
        handle: profile.linkedin,
        baseUrl: "https://www.linkedin.com/in/",
        asset: "images/icons/social_icon/linkedin.svg",
        color: const Color(0xFF0A66C2),
      ),
      _SocialLink(
        handle: profile.instagram,
        baseUrl: "https://www.instagram.com/",
        asset: "images/icons/social_icon/instagram.svg",
        color: const Color(0xFFE1306C),
      ),
      _SocialLink(
        handle: profile.twitter,
        baseUrl: "https://x.com/",
        asset: "images/icons/social_icon/xsocial.svg",
        color: const Color(0xFF000000),
      ),
      _SocialLink(
        handle: profile.tiktok,
        baseUrl: "https://www.tiktok.com/@",
        asset: "images/icons/social_icon/tiktok.svg",
        color: const Color(0xFFE60053), // TikTok için kırmızı arka plan
        allowColorFilter: false, // çok renkli icon, boyama yapma
      ),
    ];

    final links = socials
        .where((link) => link.handle != null && link.handle!.trim().isNotEmpty)
        .map((link) => _SocialIconButton(link: link))
        .toList();

    if (links.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: links,
      ),
    );
  }
}

class _SocialLink {
  final String? handle;
  final String baseUrl;
  final String asset;
  final Color color;
  final bool allowColorFilter;

  _SocialLink({
    required this.handle,
    required this.baseUrl,
    required this.asset,
    required this.color,
    this.allowColorFilter = true,
  });

  Uri? get uri {
    if (handle == null) return null;
    String value = handle!.trim();
    if (value.isEmpty) return null;
    if (value.startsWith("http://") || value.startsWith("https://")) {
      return Uri.tryParse(value);
    }
    if (value.startsWith("@")) {
      value = value.substring(1);
    }
    return Uri.tryParse("$baseUrl$value");
  }
}

class _SocialIconButton extends StatelessWidget {
  final _SocialLink link;

  const _SocialIconButton({required this.link});

  @override
  Widget build(BuildContext context) {
    final uri = link.uri;
    if (uri == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () async {
        final canOpen = await canLaunchUrl(uri);
        if (canOpen) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 30,
        height: 30,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: link.color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(50),
        ),
        child: SvgPicture.asset(
          link.asset,
          width: 16,
          height: 16,
          colorFilter: link.allowColorFilter
              ? ColorFilter.mode(link.color, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }
}
