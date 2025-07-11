// widgets/group_suggestion_list_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/group_controller/group_controller.dart';
import '../../components/cards/group_suggestion_card.dart';
import '../../services/language_service.dart';

class GroupSuggestionListView extends StatelessWidget {
  GroupSuggestionListView({super.key});

  final GroupController groupController = Get.find();

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    return Obx(() {
      if (groupController.isLoading.value) {
        return const Center();
      }

      if (groupController.suggestionGroups.isEmpty) {
        return const Center();
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
                          groupController.joinGroup(group.id);
                        },
                        child: Center(
                            child: Text(
                          group.isMember 
                            ? languageService.tr("groups.suggestion.joined") 
                            : group.isPrivate 
                              ? languageService.tr("groups.suggestion.sendRequest") 
                              : languageService.tr("groups.suggestion.joinGroup"),
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
