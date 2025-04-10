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
                  child: Container(padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Color(0xffef5050),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: InkWell(
                        child: Center(
                            child: Text(
                          "Katılma İsteği Gönder",
                          style: GoogleFonts.inter(color: Color(0xffffffff),fontSize: 10,fontWeight: FontWeight.w400),
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
