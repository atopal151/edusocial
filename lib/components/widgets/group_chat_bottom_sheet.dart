import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';
import '../../services/onesignal_service.dart';
import '../../controllers/chat_controllers/group_chat_detail_controller.dart';

class GroupChatBottomSheet extends StatefulWidget {
  const GroupChatBottomSheet({super.key});

  @override
  State<GroupChatBottomSheet> createState() => _GroupChatBottomSheetState();
}

class _GroupChatBottomSheetState extends State<GroupChatBottomSheet> {
  final LanguageService languageService = Get.find<LanguageService>();
  final OneSignalService oneSignalService = Get.find<OneSignalService>();
  final GroupChatDetailController chatController = Get.find<GroupChatDetailController>();
  
  bool? isGroupMuted;

  @override
  void initState() {
    super.initState();
    _loadMuteStatus();
  }

  Future<void> _loadMuteStatus() async {
    final group = chatController.groupData.value;
    if (group != null) {
      final muted = await oneSignalService.isGroupMuted(group.id);
      setState(() {
        isGroupMuted = muted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
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
            
            // Grup bilgileri
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: const Icon(Icons.info_outline, color: Color(0xffef5050), size: 20),
              ),
              title: Text(
                languageService.tr("groups.actions.groupInfo"),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff272727),
                ),
              ),
              onTap: () {
                Get.back();
                chatController.getToGrupDetailScreen();
              },
            ),
            
            // Grup sessize alma butonu
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: Icon(
                  isGroupMuted == true ? Icons.volume_off : Icons.volume_up,
                  color: isGroupMuted == true ? Color(0xffef5050) : Color(0xffef5050),
                  size: 20,
                ),
              ),
              title: Text(
                isGroupMuted == true 
                  ? languageService.tr("groups.actions.muteGroup.muted")
                  : languageService.tr("groups.actions.muteGroup.unmuted"),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff272727),
                ),
              ),
              subtitle: Text(
                isGroupMuted == true
                  ? languageService.tr("groups.actions.muteGroup.mutedDesc")
                  : languageService.tr("groups.actions.muteGroup.unmutedDesc"),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff9ca3ae),
                ),
              ),
              trailing: Switch(
                value: isGroupMuted ?? false,
                onChanged: (value) async {
                  final group = chatController.groupData.value;
                  if (group != null) {
                    if (value) {
                      await oneSignalService.muteGroup(group.id);
                    } else {
                      await oneSignalService.unmuteGroup(group.id);
                    }
                    setState(() {
                      isGroupMuted = value;
                    });
                  }
                },
                activeColor: Color(0xffef5050),
              ),
            ),
            
            // Üyeleri görüntüle
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: const Icon(Icons.people, color: Color(0xffef5050), size: 20),
              ),
              title: Text(
                languageService.tr("groups.actions.viewMembers"),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff272727),
                ),
              ),
              onTap: () {
                Get.back();
                // Üyeler sayfasına git
                // Get.toNamed('/group_participants');
              },
            ),
            
            // Grubu paylaş
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: const Icon(Icons.share, color: Color(0xffef5050), size: 20),
              ),
              title: Text(
                languageService.tr("groups.actions.shareGroup"),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff272727),
                ),
              ),
              onTap: () {
                Get.back();
                // Paylaş işlemi
              },
            ),
            
            // Gruptan ayrıl
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: const Icon(Icons.exit_to_app, color: Color(0xffef5050), size: 20),
              ),
              title: Text(
                languageService.tr("groups.actions.leaveGroup"),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xffef5050),
                ),
              ),
              onTap: () {
                Get.back();
                _showLeaveGroupDialog();
              },
            ),
            
            // Rapor et
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: const Icon(Icons.warning_rounded, color: Color(0xffef5050), size: 20),
              ),
              title: Text(
                languageService.tr("common.actions.report"),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xffef5050),
                ),
              ),
              onTap: () {
                Get.back();
                _showReportDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveGroupDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.exit_to_app, color: Color(0xffef5050), size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                languageService.tr("groups.dialogs.leaveGroup.title"),
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
          languageService.tr("groups.dialogs.leaveGroup.message"),
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
              languageService.tr("common.cancel"),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff9ca3ae),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Gruptan ayrıl işlemi
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffef5050),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              languageService.tr("groups.dialogs.leaveGroup.confirm"),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    Get.dialog(
      AlertDialog(
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
              Get.back();
              // Rapor işlemi
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
      ),
    );
  }
}
