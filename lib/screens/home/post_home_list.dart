import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/cards/post_card.dart';
import '../../controllers/post_controller.dart';

class PostHomeList extends StatelessWidget {
   PostHomeList({super.key});

  final PostController postController = Get.put(PostController());
  @override
  Widget build(BuildContext context) {
    
    return  Obx(() {
        if (postController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (postController.postHomeList.isEmpty) {
          return const Center(child: Text("Hiç gönderi bulunamadı."));
        }

        return Column(
          children: postController.postHomeList.map((post) {
            return Container(
              color: const Color(0xfffafafa),
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
          }).toList(),
        );
      });
  }
}