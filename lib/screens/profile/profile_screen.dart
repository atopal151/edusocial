import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/cards/person_entry_card.dart';
import '../../components/cards/post_card.dart';
import '../../components/cards/profile_cards.dart';
import '../../components/cards/profile_header.dart';
import '../../components/profile_tabbar/toggle_tab_bar.dart';
import '../../components/widgets/empty_state_widget.dart';
import '../../controllers/entry_controller.dart';
import '../../controllers/post_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../routes/app_routes.dart';
import '../profile/people_profile_screen.dart';
import '../../services/language_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.put(ProfileController());
  final PostController postController = Get.put(PostController());
  final EntryController entryController = Get.put(EntryController());

  // Seçili ToggleTabBar'ı kontrol eden değişken
  final RxInt selectedTabIndex = 0.obs;
  final RxBool isAboutExpanded = false.obs;

  /// Profil verilerini yenile
  Future<void> _refreshProfile() async {
    debugPrint("🔄 Profile sayfası yenileniyor...");
    try {
      await Future.wait([
        controller.loadProfile(),
        postController.fetchHomePosts(),
        entryController.fetchAllEntries(),
      ]);
      debugPrint("✅ Profile sayfası başarıyla yenilendi");
    } catch (e) {
      debugPrint("❌ Profile sayfası yenileme hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        surfaceTintColor: const Color(0xffFFFFFF),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              controller.getToUserSettingScreen();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xfffafafa),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    "images/icons/settings_icon.svg",
                    colorFilter: ColorFilter.mode(
                      Color(0xff414751),
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildProfileHeader(),
                const SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: CustomButton(
                    height: 40,
                    borderRadius: 5,
                    text: languageService.tr("profile.mainProfile.editProfile"),
                    onPressed: () {
                      controller.getToSettingScreen();
                    },
                    backgroundColor: const Color(0xfff4f4f5),
                    textColor: const Color(0xff414751),
                    icon: SvgPicture.asset(
                      "images/icons/profile_edit_icon.svg",
                      colorFilter: const ColorFilter.mode(
                        Color(0xff414751),
                        BlendMode.srcIn,
                      ),
                      width: 20,
                      height: 20,
                    ),
                    isLoading: controller.isPrLoading,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _refreshProfile,
          color: const Color(0xFFEF5050),
          backgroundColor: const Color(0xfffafafa),
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
      ),
    );
  }

  Widget _buildPosts() {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Obx(() {
      if (controller.profilePosts.isEmpty) {
        return Container(
          constraints: const BoxConstraints(minHeight: 200),
          child: EmptyStateWidgets.postsEmptyState(languageService),
        );
      }

      return Container(
        decoration: BoxDecoration(color: Color(0xfffafafa)),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.profilePosts.length,
          itemBuilder: (context, index) {
            final post = controller.profilePosts[index];
            return PostCard(
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
            );
          },
        ),
      );
    });
  }

  /// **Entryler Sekmesi İçeriği**
  Widget _buildEntries() {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Obx(() {
      if (controller.personEntries.isEmpty) {
        return Container(
          constraints: const BoxConstraints(minHeight: 200),
          child: EmptyStateWidgets.entriesEmptyState(languageService),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: controller.personEntries.length,
        itemBuilder: (context, index) {
          final entry = controller.personEntries[index];
          
          // Entry'nin kullanıcı bilgilerini al
          final user = entry.user;
          
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
                    debugPrint("⚠️ Kullanıcı bilgileri eksik, profil sayfasına yönlendirilemiyor");
                  }
                },
                onUpvote: () => controller.voteEntry(entry.id, "up"),
                onDownvote: () => controller.voteEntry(entry.id, "down"),
                onShare: () {
                  // Konu bilgilerini al
                  final topicName = entry.topic?.name ?? languageService.tr("profile.mainProfile.shareText.topicInfo");
                  final categoryTitle = entry.topic?.category?.title ?? languageService.tr("profile.mainProfile.shareText.categoryInfo");

                  final String shareText = """
📝 **$topicName** (#${entry.id})

🏷️ **${languageService.tr("profile.mainProfile.shareText.category")}:** $categoryTitle
👤 **${languageService.tr("profile.mainProfile.shareText.author")}:** ${user.name} ${user.surname}

💬 **${languageService.tr("profile.mainProfile.shareText.entryContent")}:**
${entry.content}

📱 **${languageService.tr("profile.mainProfile.shareText.downloadApp")}**
🔗 ${languageService.tr("profile.mainProfile.shareText.appLink")}
📲 ${languageService.tr("profile.mainProfile.shareText.appStore")}
📱 ${languageService.tr("profile.mainProfile.shareText.playStore")}

${languageService.tr("profile.mainProfile.shareText.hashtags")}
""";
                  Share.share(shareText);
                },
              ),
             
            ),
          );
        },
      );
    });
  }

  /// About detaylarını açılır/kapanır kart olarak gösterir
  Widget _buildAboutSection() {
    final LanguageService languageService = Get.find<LanguageService>();

    return Obx(() {
      final aboutText = languageService.tr("profile.details.about");
      final aboutTitle =
          aboutText == "profile.details.about" ? "About" : aboutText;

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
                child: buildProfileDetails(wrapWithScroll: false),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }
}
