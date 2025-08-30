import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';
import '../../controllers/post_controller.dart';

class TreePointBottomSheet extends StatelessWidget {
  final int? postId;
  
  const TreePointBottomSheet({super.key, this.postId});

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    final PostController postController = Get.find<PostController>();
    
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Color(0xff9ca3ae),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: const Icon(Icons.person, color: Color(0xffef5050), size: 20),
              ),
              title: Text(
                languageService.tr("common.actions.about"),
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff272727)),
              ),
              onTap: () {},
            ),
            // Sadece postId verildiğinde rapor seçeneğini göster
            if (postId != null)
              ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xfffff5f5),
                  child: const Icon(Icons.warning_rounded, color: Color(0xffef5050), size: 20),
                ),
                title: Text(
                  languageService.tr("common.actions.report"),
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff272727))
                ),
                onTap: () {
                  Get.back(); // Bottom sheet'i kapat
                  
                  // Onay diyalogu göster
                  Get.dialog(
                    Obx(() => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Color(0xffef5050), size: 24),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              languageService.tr("common.report.dialog.title"),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff272727),
                              ),
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        languageService.tr("common.report.dialog.message"),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff5a5a5a),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            languageService.tr("common.report.dialog.cancel"),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff9ca3ae),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.back(); // Dialog'u kapat
                            postController.reportPost(postId!); // Post'u şikayet et
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffef5050),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            languageService.tr("common.report.dialog.confirm"),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )),
                  );
                },
              ),
          ],
        )),
      ),
    );
  }
}
