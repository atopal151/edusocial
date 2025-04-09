import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                  color: const Color(0xffFAFAFA),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(Icons.settings, color: Colors.black),
                ),
              ),
            ),
          )
        ],
      ),
      body: DefaultTabController(
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
                      icon: Icons.person,
                      isLoading: controller.isPrLoading,
                    ),
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
              /// **👤 Person Sekmesi - ToggleTabBar olmadan göster**
              buildProfileDetails(),

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
            ],
          ),
        ),
      ),
    );
  }

  /// **Gönderiler Sekmesi İçeriği**
  Widget _buildPosts() {
    return Obx(() {
      if (postController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (postController.postList.isEmpty) {
        return const Center(child: Text("Hiç gönderi bulunamadı."));
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: postController.postList.length,
        itemBuilder: (context, index) {
          final post = postController.postList[index];
          return Container(
            color: Color(0xfffafafa),
            child: PostCard(
              profileImage: post.profileImage,
              userName: post.userName,
              postDate: post.postDate,
              postDescription: post.postDescription,
              postImage: post.postImage,
              likeCount: post.likeCount,
              commentCount: post.commentCount,
            ),
          );
        },
      );
    });
  }

  /// **Entryler Sekmesi İçeriği**
  Widget _buildEntries() {
    return Obx(() {
      if (entryController.entryPersonList.isEmpty) {
        return const Center(child: Text("Hiç entry bulunamadı."));
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: entryController.entryPersonList.length,
        itemBuilder: (context, index) {
          final entry = entryController.entryPersonList[index];
          return Container(
            color: Color(0xfffafafa),
            child: EntryCard(
              onPressed: () {},
              entry: entry,
              onUpvote: () => entryController.upvoteEntry(index),
              onDownvote: () => entryController.downvoteEntry(index),
              onShare: () {},
            ),
          );
        },
      );
    });
  }
}
