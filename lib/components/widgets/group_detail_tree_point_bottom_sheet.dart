import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';

class GroupDetailTreePointBottomSheet extends StatelessWidget {
  const GroupDetailTreePointBottomSheet({super.key});

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
}
