import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/cards/post_card.dart';
import '../../components/widgets/general_loading_indicator.dart';
import '../../components/widgets/empty_state_widget.dart';
import '../../controllers/post_controller.dart';
import '../../services/language_service.dart';

class PostHomeList extends StatelessWidget {
  PostHomeList({super.key});

  final PostController postController = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Obx(() {
      debugPrint(
          "🔄 PostHomeList build - Loading: ${postController.isHomeLoading.value}, Post count: ${postController.postHomeList.length}");

      if (postController.isHomeLoading.value) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: GeneralLoadingIndicator(
              size: 32,
              showIcon: false,
            ),
          ),
        );
      }

      if (postController.postHomeList.isEmpty) {
        return Container(
          constraints: const BoxConstraints(minHeight: 200),
          child: EmptyStateWidgets.postsEmptyState(languageService),
        );
      }

      return Column(
        children: postController.postHomeList.map((post) {
          return Container(
            color: const Color(0xfffafafa),
            child: PostCard(
              links: post.links,
              postId: post.id,
              profileImage: post.profileImage,
              userName: post.username,
              postDate: post.postDate,
              postDescription: post.postDescription,
              name: post.name,
              surname: post.surname,
              mediaUrls: post.mediaUrls, // ✅ doğru alan // 🔁 boş liste
              likeCount: post.likeCount,
              commentCount: post.commentCount,
              isLiked: post.isLiked,
              isOwner: post.isOwner,
              slug: post.slug,
            ),
          );
        }).toList(),
      );
    });
  }
}
