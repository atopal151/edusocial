import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';
import '../../controllers/group_controller/group_controller.dart';

class GroupDetailTreePointBottomSheet extends StatelessWidget {
  final String? groupId;
  final bool isFounder;
  
  const GroupDetailTreePointBottomSheet({
    super.key, 
    this.groupId,
    this.isFounder = false,
  });

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Sadece grup kurucusu/yöneticisi etkinlik oluşturabilir
            if (isFounder) 
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: SvgPicture.asset(
                    "images/icons/event.svg",
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Color(0xffef5050),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                title: Text(
                  languageService.tr("groups.groupDetail.bottomSheet.createEvent"),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff414751)),
                ),
                onTap: () {
                  Get.back(); // Bottom sheet'i kapat
                  _navigateToCreateEvent();
                },
              ),
            ListTile(
              leading:
                  const Icon(Icons.outbond_outlined, color: Color(0xfffb535c)),
              title: Text(
                languageService.tr("groups.groupDetail.bottomSheet.leaveGroup"),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff414751)),
              ),
              onTap: () {
                Get.back();
                if (groupId != null) {
                  _showLeaveGroupConfirmation(groupId!);
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.warning_amber_outlined,
                color: Color(0xfffb535c),
              ),
              title: Text(languageService.tr("groups.groupDetail.bottomSheet.report"),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff414751))),
              onTap: () {
              },
            ),
            
          ],
        ),
      ),
    );
  }

  void _navigateToCreateEvent() {
    if (groupId != null) {
      Get.toNamed('/createEvent', arguments: {
        'groupId': groupId,
      });
    }
  }

  void _showLeaveGroupConfirmation(String groupId) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    Get.dialog(
      AlertDialog(
        title: Text(
          languageService.tr("groups.groupDetail.leaveGroup.confirmation.title"),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff414751),
          ),
        ),
        content: Text(
          languageService.tr("groups.groupDetail.leaveGroup.confirmation.message"),
          style: TextStyle(
            fontSize: 14,
            color: Color(0xff9ca3ae),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              languageService.tr("common.cancel"),
              style: TextStyle(
                color: Color(0xff9ca3ae),
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Dialog'u kapat
              final groupController = Get.find<GroupController>();
              groupController.leaveGroup(groupId);
            },
            child: Text(
              languageService.tr("groups.groupDetail.leaveGroup.confirmation.confirm"),
              style: TextStyle(
                color: Color(0xffef5050),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
