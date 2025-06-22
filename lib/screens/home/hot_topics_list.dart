import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
        return const Center();
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
              onTap: () {
                controller.selectTopic(topic.title);
                controller.onHotTopicTap(topic);
              },
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
                    isSelected
                        ? ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Color(0xFFfffce6), Color(0xFFffefd8)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: SvgPicture.asset(
                              "images/icons/selected_star.svg",
                             
                            ),
                          )
                        : ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [Color(0xFFffe61c), Color(0xFFffa929)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: SvgPicture.asset(
                              "images/icons/selected_star.svg",
                             
                            ),
                          ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topic.title,
                        style: GoogleFonts.inter(
                          color: isSelected
                              ? Color(0xffffffff)
                              : Color(0xff414751),
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
