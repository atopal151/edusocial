// widgets/group_suggestion_list_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/group_controller.dart';
import '../../components/cards/group_suggestion_card.dart';

class GroupSuggestionListView extends StatelessWidget {
  GroupSuggestionListView({super.key});

  final GroupController groupController = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (groupController.isLoading.value) {
        return const Center();
      }

      if (groupController.suggestionGroups.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Önerilen grup bulunamadı."),
        );
      }

      return SizedBox(
        height: 200,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: groupController.suggestionGroups.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final group = groupController.suggestionGroups[index];
            return Stack(
              children: [
                buildGroupSuggestionCard(group),
                Positioned(
                  bottom: 8,
                  right: 10,
                  left: 10,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(70),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          groupController.joinSuggestionGroup(group.id);
                        },
                        child: Center(
                            child: Text(
                          "Katıl",
                          style: GoogleFonts.inter(
                              color: Color(0xffffffff),
                              fontSize: 10,
                              fontWeight: FontWeight.w400),
                        )),
                      )),
                )
              ],
            ); // Casting yok!
          },
        ),
      );
    });
  }
}
