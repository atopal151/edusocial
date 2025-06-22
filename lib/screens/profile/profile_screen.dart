import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/cards/entry_card.dart';
import '../../components/cards/post_card.dart';
import '../../components/cards/profile_cards.dart';
import '../../components/cards/profile_header.dart';
import '../../components/profile_tabbar/profile_tabbar.dart';
import '../../components/profile_tabbar/toggle_tab_bar.dart';
import '../../controllers/entry_controller.dart';
import '../../controllers/post_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../components/sheets/share_options_bottom_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ProfileController controller = Get.put(ProfileController());
  final PostController postController = Get.put(PostController());
  final EntryController entryController = Get.put(EntryController());
  // TabController
  late TabController _tabController;

  // Seçili ToggleTabBar'ı kontrol eden değişken
  final RxInt selectedTabIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
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
      body: RefreshIndicator(
        onRefresh: () async {
          debugPrint("🔄 Profil verileri yenileniyor...");
          await controller.loadProfile();
          await postController.fetchHomePosts();
          await entryController.fetchAllEntries();
          debugPrint("✅ Profil verileri başarıyla yenilendi");
        },
        color: Color(0xFFEF5050),
        backgroundColor: Color(0xfffafafa),
        strokeWidth: 2.0,
        displacement: 40.0,
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
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
                        text: "Profili Düzenle",
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
                    SizedBox(
                      height: 20,
                    ),

                    /// **✅ Üst TabBar (İkonlu)**
                    ProfileTabBar(tabController: _tabController),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                /// **📌 Grid View Sekmesi - ToggleTabBar ile göster**
                Column(
                  children: [
                    Container(
                      color: Color(0xfffafafa),
                      child: ToggleTabBar(
                        selectedIndex: selectedTabIndex,
                        onTabChanged: (index) {
                          selectedTabIndex.value = index;
                        },
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        return selectedTabIndex.value == 0
                            ? _buildPosts()
                            : _buildEntries();
                      }),
                    ),
                  ],
                ),

                /// **👤 Person Sekmesi - ToggleTabBar olmadan göster**
                buildProfileDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPosts() {
    final posts = controller.profilePosts;

    if (posts.isEmpty) {
      return const Center(child: Text("Hiç gönderi bulunamadı."));
    }

    return Container(
      decoration: BoxDecoration(color: Color(0xfffafafa)),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            postId: post.id,
            profileImage: post.profileImage,
            userName: post.username,
            name: post.name,
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
  }

  /// **Entryler Sekmesi İçeriği**
  Widget _buildEntries() {
    return Obx(() {
      if (entryController.entryPersonList.isEmpty) {
        return const Center(child: Text("Hiç entry bulunamadı."));
      }

      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: entryController.entryPersonList.length,
        itemBuilder: (context, index) {
          final entry = entryController.entryPersonList[index];
          return Container(
            color: Color(0xfffafafa),
            child: EntryCard(
              onPressed: () {
                Get.toNamed("/entryDetail", arguments: entry);
              },
              entry: entry,
              topicName: entry.topic?.name,
              categoryTitle: entry.topic?.category?.title,
              onPressedProfile: () {
                Get.toNamed("/peopleProfile");
              },
              onUpvote: () => entryController.voteEntry(entry.id, "up"),
              onDownvote: () => entryController.voteEntry(entry.id, "down"),
              onShare: () {
                final String shareText = """
${entry.content}

📱 EduSocial Uygulamasını İndir:
🔗 Uygulamayı Aç: edusocial://app
📲 App Store: https://apps.apple.com/app/edusocial/id123456789
📱 Play Store: https://play.google.com/store/apps/details?id=com.edusocial.app

#EduSocial #Eğitim
""";
                Share.share(shareText);
              },
            ),
          );
        },
      );
    });
  }
}
