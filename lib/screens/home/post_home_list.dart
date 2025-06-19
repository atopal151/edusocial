import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/cards/post_card.dart';
import '../../components/widgets/general_loading_indicator.dart';
import '../../controllers/post_controller.dart';

class PostHomeList extends StatelessWidget {
  PostHomeList({super.key});

  final PostController postController = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
              mediaUrls: post.mediaUrls, // ✅ doğru alan // 🔁 boş liste
              likeCount: post.likeCount,
              commentCount: post.commentCount, isLiked: post.isLiked,
              isOwner: post.isOwner,
            ),
          );
        }).toList(),
      );
    });
  }
}
