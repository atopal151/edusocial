import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';

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
                leading: const Icon(Icons.event_outlined, color: Color(0xff4CAF50)),
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
                  const Icon(Icons.outbond, color: Color(0xfffb535c)),
              title: Text(
                languageService.tr("groups.groupDetail.bottomSheet.leaveGroup"),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff414751)),
              ),
              onTap: () {
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.warning_rounded,
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
}
