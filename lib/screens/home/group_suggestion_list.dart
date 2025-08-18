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
                          // Sadece katılmamış ve beklemede olmayan gruplar için tıklanabilir
                          if (!group.isMember && !group.isPending) {
                            groupController.handleGroupJoin(group.id);
                          }
                        },
                        child: Center(
                            child: Text(
                          _getButtonText(group, languageService),
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

  String _getButtonText(dynamic group, LanguageService languageService) {
    // Eğer kullanıcı zaten üyeyse
    if (group.isMember) {
      return languageService.tr("groups.suggestion.joined");
    }
    
    // Eğer grup gizli değilse (public) ve kullanıcı üye değilse
    if (!group.isPrivate && !group.isMember) {
      return languageService.tr("groups.suggestion.joinGroup");
    }
    
    // Eğer grup gizli ise (private) ve kullanıcı başvuru yaptıysa
    if (group.isPrivate && group.isPending) {
      return languageService.tr("groups.suggestion.requestSent");
    }
    
    // Eğer grup gizli ise (private) ve kullanıcı daha başvuru yapmadıysa
    if (group.isPrivate && !group.isPending) {
      return languageService.tr("groups.suggestion.sendRequest");
    }
    
    // Varsayılan durum
    return languageService.tr("groups.suggestion.joinGroup");
  }
}
