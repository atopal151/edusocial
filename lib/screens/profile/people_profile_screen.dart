import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/components/widgets/build_people_profile_details.dart';
import 'package:edusocial/controllers/people_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/cards/entry_card.dart';
import '../../components/cards/post_card.dart';
import '../../components/profile_tabbar/profile_tabbar.dart';
import '../../components/profile_tabbar/toggle_tab_bar.dart';
import '../../controllers/entry_controller.dart';
import '../../controllers/post_controller.dart';

class PeopleProfileScreen extends StatefulWidget {
  final int userId;
  const PeopleProfileScreen({super.key, required this.userId});

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller.loadUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: BackAppBar(
        backgroundColor: Color(0xffffffff),
        iconBackgroundColor: Color(0xfffafafa),
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Obx(() {
                final profile = controller.profile.value;

                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (profile == null) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Kullanıcı profili yüklenemedi."),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: Image.network(
                          profile.avatar,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'images/user2.png', // 📌 local asset yolu
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${profile.name} ${profile.surname}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("@${profile.username}",
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text(profile.description ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => SizedBox(
                              width: 140,
                              child: CustomButton(
                                height: 40,
                                borderRadius: 5,
                                text: controller.isFollowing.value
                                    ? "Takibi Bırak"
                                    : "Takip Et",
                                onPressed: () {
                                  controller.isFollowing.value
                                      ? controller.unfollowUser(widget.userId)
                                      : controller.followUser(widget.userId);
                                },
                                backgroundColor: const Color(0xfff4f4f5),
                                textColor: const Color(0xff414751),
                                isLoading: controller
                                    .isFollowLoading, // 👈 burası değişti
                              ),
                            )),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 140,
                          child: CustomButton(
                            height: 40,
                            borderRadius: 5,
                            text: "Mesaj Gönder",
                            onPressed: () {
                              // mesaj gönder ekranına yönlendirme yapılabilir
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
                            iconColor: Color(0xffffffff),
                            isLoading: false.obs,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ProfileTabBar(tabController: _tabController),
                  ],
                );
              }),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Column(
                children: [
                  Container(
                    color: const Color(0xfffafafa),
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
              _buildProfileDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosts() {
    return Obx(() {
      if (postController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (postController.postList.isEmpty) {
        return const Center(child: Text("Hiç gönderi bulunamadı."));
      }

      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: postController.postList.length,
        itemBuilder: (context, index) {
          final post = postController.postList[index];
          return Container(
            color: const Color(0xfffafafa),
            child: PostCard(
              profileImage: post.profileImage,
              userName: post.userName,
              postDate: post.postDate,
              postDescription: post.postDescription,

              mediaUrls:
                  post.mediaUrls, // ✅ doğru alan              // 🔁 boş liste
              likeCount: post.likeCount,
              commentCount: post.commentCount,
            ),
          );
        },
      );
    });
  }

  Widget _buildEntries() {
    return Obx(() {
      if (entryController.entryPersonList.isEmpty) {
        return const Center(child: Text("Hiç entry bulunamadı."));
      }

      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: entryController.entryPersonList.length,
        itemBuilder: (context, index) {
          final entry = entryController.entryPersonList[index];
          return Container(
            color: const Color(0xfffafafa),
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

  Widget _buildProfileDetails() {
    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) return const SizedBox();
      return buildPeopleProfileDetails(profile);
    });
  }
}
