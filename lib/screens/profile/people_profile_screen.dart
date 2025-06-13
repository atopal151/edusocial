import 'package:edusocial/components/cards/people_profile_card.dart';
import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/components/widgets/build_people_profile_details.dart';
import 'package:edusocial/controllers/people_profile_controller.dart';
import 'package:edusocial/utils/date_format.dart';
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
import '../../components/sheets/share_options_bottom_sheet.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller.loadUserProfileByUsername(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: BackAppBar(
        backgroundColor: const Color(0xffffffff),
        iconBackgroundColor: const Color(0xfffafafa),
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
                                    ? "Onay Bekliyor"
                                    : controller.isFollowing.value
                                        ? "Takibi Bırak"
                                        : "Takip Et",
                                onPressed: () {
                                  if (!controller.isFollowingPending.value) {
                                    if (controller.isFollowing.value) {
                                      controller.unfollowUser(profile.id);
                                    } else {
                                      controller.followUser(profile.id);
                                    }
                                  }
                                },
                                backgroundColor: const Color(0xfff4f4f5),
                                textColor: const Color(0xff414751),
                                isLoading: controller.isFollowLoading,
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
                              // Mesaj gönderme ekranına yönlendirme
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
    final posts = controller.profile.value?.posts ?? [];

    if (controller.profile.value?.isFollowingPending == true) {
      return const Center(child: Icon(Icons.lock));
    }

    if (posts.isEmpty) {
      return const Center(child: Text("Hiç gönderi bulunamadı."));
    }

    return Container(
      decoration: BoxDecoration(color: Color(0xfffafafa)),
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final date = formatSimpleDateClock(post.postDate);
          return PostCard(
            postId: post.id,
            profileImage: post.profileImage,
            name: post.name,
            userName: post.username,
            postDate: date,
            postDescription: post.postDescription,
            mediaUrls: post.mediaUrls,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            isLiked: post.isLiked,
            isOwner: post.isLiked,
            links: post.links,
          );
        },
      ),
    );
  }

  Widget _buildEntries() {
    return Obx(() {
      if (controller.profile.value?.isFollowingPending == true) {
        return const Center(child: Icon(Icons.lock));
      }
      if (entryController.entryPersonList.isEmpty) {
        return const Center(child: Text("Hiç entry bulunamadı."));
      }
      return ListView.builder(
        itemCount: entryController.entryPersonList.length,
        itemBuilder: (context, index) {
          final entry = entryController.entryPersonList[index];
          return Container(
            color: const Color(0xfffafafa),
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
                final String shareText = entry.content;
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  builder: (_) => ShareOptionsBottomSheet(postText: shareText),
                );
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildProfileDetails() {
    if (controller.profile.value?.isFollowingPending == true) {
      return const Center(child: Icon(Icons.lock));
    }
    return Obx(() {
      final profile = controller.profile.value;
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (profile == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text("Kullanıcı profili bulunamadı."),
          ),
        );
      }

      return buildPeopleProfileDetails(profile);
    });
  }
}
