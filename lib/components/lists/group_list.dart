import 'package:edusocial/models/group_models/group_search_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/search_text_controller.dart';
import '../../services/language_service.dart';

class GroupListItem extends StatelessWidget {
  final GroupSearchModel group;

  const GroupListItem({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final SearchTextController controller = Get.find<SearchTextController>();
    final LanguageService languageService = Get.find<LanguageService>();
    
    return GestureDetector(
      onTap: () {
        debugPrint('🔍 Group tapped: ${group.name}');
        debugPrint('🔍 Is member: ${group.isMember}');
        debugPrint('🔍 Group ID: ${group.id}');
        
        if (group.isMember) {
          debugPrint('🚀 Navigating to group chat with ID: ${group.id}');
          Get.toNamed('/group_chat_detail', arguments: {'groupId': group.id.toString()});
        } else {
          debugPrint('❌ User is not a member of this group');
          Get.snackbar(
            languageService.tr("groups.list.groupSelected"), 
            "${group.name} ${languageService.tr("groups.list.redirectingToGroup")}"
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 6),
        height: 106,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      Colors.grey[300], // Hata durumunda gösterilecek arka plan
                  child: group.bannerUrl.trim().isEmpty
                      ? Icon(Icons.group,
                          color: Colors.white) // URL boşsa ikon göster
                      : ClipOval(
                          child: Image.network(
                            group.bannerUrl,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.group,
                                  color:
                                      Colors.white); // Yüklenemezse ikon göster
                            },
                          ),
                        ),
                ),
                Positioned(
                  bottom: -20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, color: Color(0xffEF5050), size: 14),
                      SizedBox(width: 4),
                      Text(
                        "${group.userCountWithAdmin}",
                        style: GoogleFonts.inter(
                            color: Color(0xff414751),
                            fontSize: 13.28,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    group.name,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff414751)),
                  ),
                  SizedBox(height: 4), // Boşluk ekledim
                  Text(
                    group.description,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Color(0xff9CA3AE)),
                    maxLines: 2, // Çok uzun açıklamalarda taşmayı önlemek için
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Katıl butonu - sadece üye değilse göster
            if (!group.isMember && !group.isPending)
              Container(
                margin: EdgeInsets.only(left: 8),
                child: InkWell(
                  onTap: () => controller.joinGroup(group.id),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xffEF5050),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      languageService.tr("groups.list.join"),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            else if (group.isPending && group.isPrivate)
              Container(
                margin: EdgeInsets.only(left: 8),
                child: Text(
                  languageService.tr("groups.list.pendingApproval"),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff9CA3AE),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
