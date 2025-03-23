import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/cards/hot_topics_card.dart';
import '../../controllers/topics_controller.dart';

class HotTopicsListView extends StatelessWidget {
  HotTopicsListView({super.key});

  final TopicsController controller = Get.put(TopicsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hotTopics.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Gündemde konu yok."),
        );
      }

      return SizedBox(
        height: 50,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.hotTopics.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final topic = controller.hotTopics[index];
            return buildHotTopicsCard(topic);
          },
        ),
      );
    });
  }
}
