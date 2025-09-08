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
import '../../components/buttons/custom_button.dart';
import '../../components/cards/person_entry_card.dart';
import '../../components/cards/post_card.dart';
import '../../components/profile_tabbar/profile_tabbar.dart';
import '../../components/profile_tabbar/toggle_tab_bar.dart';
import '../../controllers/entry_controller.dart';
import '../../controllers/post_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/language_service.dart';

class PeopleProfileScreen extends StatefulWidget {
  final String username;
  const PeopleProfileScreen({super.key, required this.username});

  @override
  State<PeopleProfileScreen> createState() => _PeopleProfileScreenState();
}

class _PeopleProfileScreenState extends State<PeopleProfileScreen>
    with SingleTickerProviderStateMixin {
  final PeopleProfileController controller = Get.put(PeopleProfileController());
  final PostController postController = Get.put(PostController());
  final EntryController entryController = Get.put(EntryController());

  late TabController _tabController;
  final RxInt selectedTabIndex = 0.obs;

  /// Profil verilerini yenile
  Future<void> _refreshProfile() async {
    debugPrint("🔄 People Profile sayfası yenileniyor...");
    await controller.loadUserProfileByUsername(widget.username);
    debugPrint("✅ People Profile sayfası yenilendi");
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

        return DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildPeopleProfileHeader(controller),
                    const SizedBox(height: 20),

                    /// Takip ve Mesaj Gönder Butonları
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => SizedBox(
                              width: 140,
                              child: CustomButton(
                                height: 40,
                                borderRadius: 5,
                                text: controller.isFollowingPending.value
                                    ? languageService.tr(
                                        "profile.peopleProfile.actions.pendingApproval")
                                    : controller.isFollowing.value
                                        ? languageService.tr(
                                            "profile.peopleProfile.actions.unfollow")
                                        : languageService.tr(
                                            "profile.peopleProfile.actions.follow"),
                                onPressed: () {
                                  if (!controller.isFollowingPending.value) {
                                    if (controller.isFollowing.value) {
                                      controller.unfollowUser(profile.id);
                                    } else if (controller
                                        .isFollowingPending.value) {
                                      //controller.unfollowUser(profile.id);
                                      //kontrol edilecek
                                    } else {
                                      controller.followUser(profile.id);
                                    }
                                  }
                                },
                                backgroundColor: controller
                                        .isFollowingPending.value
                                    ? const Color(
                                        0xFFFF8C00) // Onay bekliyor durumunda turuncu
                                    : controller.isFollowing.value
                                        ? const Color(
                                            0xfff4f4f5) // Unfollow durumunda gri
                                        : const Color(
                                            0xFFEF5050), // Follow durumunda kırmızı
                                textColor: controller.isFollowingPending.value
                                    ? const Color(
                                        0xffffffff) // Onay bekliyor durumunda beyaz metin
                                    : controller.isFollowing.value
                                        ? const Color(
                                            0xff414751) // Unfollow durumunda koyu gri metin
                                        : const Color(
                                            0xffffffff), // Follow durumunda beyaz metin
                                isLoading: controller.isFollowLoading,
                              ),
                            )),
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

                    /// TabBar
                    ProfileTabBar(tabController: _tabController),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                RefreshIndicator(
                  onRefresh: _refreshProfile,
                  color: const Color(0xFFef5050),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  strokeWidth: 2.0,
                  displacement: 40.0,
                  child: CustomScrollView(
                    slivers: [
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
                RefreshIndicator(
                  onRefresh: _refreshProfile,
                  color: const Color(0xFFef5050),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  strokeWidth: 2.0,
                  displacement: 40.0,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _buildProfileDetails(),
                  ),
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
}
