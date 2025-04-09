import 'package:flutter/material.dart';
import '../../controllers/topics_controller.dart';
import 'package:get/get.dart';

class HotTopicsListView extends StatelessWidget {
  HotTopicsListView({super.key});

  final TopicsController controller = Get.put(TopicsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedTopic.value;

      if (controller.isLoading.value) {
        return const Center();
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
            final isSelected = selected == topic.title;

            return GestureDetector(
              onTap: () => controller.selectTopic(topic.title),
              child: Container(
                width: 230,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xffffab1b), Color(0xFFffb427)],
                          begin: Alignment.topRight,
                          end: Alignment.topLeft,
                        )
                      : const LinearGradient(
                          colors: [Color(0xffffffff), Color(0xffffffff)],
                          begin: Alignment.topRight,
                          end: Alignment.topLeft,
                        ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star,
                        color: isSelected ? Color(0xfffffce6) : Color(0xffffab1b),
                        size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topic.title,
                        style: TextStyle(
                          color: isSelected ? Color(0xffffffff) : Color(0xff414751),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
