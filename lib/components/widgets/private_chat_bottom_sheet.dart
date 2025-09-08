import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';
import '../../services/onesignal_service.dart';
import '../../controllers/chat_controllers/chat_detail_controller.dart';

class PrivateChatBottomSheet extends StatefulWidget {
  const PrivateChatBottomSheet({super.key});

  @override
  State<PrivateChatBottomSheet> createState() => _PrivateChatBottomSheetState();
}

class _PrivateChatBottomSheetState extends State<PrivateChatBottomSheet> {
  final LanguageService languageService = Get.find<LanguageService>();
  final OneSignalService oneSignalService = Get.find<OneSignalService>();
  final ChatDetailController chatController = Get.find<ChatDetailController>();
  
  bool? isPrivateChatMuted;

  @override
  void initState() {
    super.initState();
    _loadMuteStatus();
  }

  Future<void> _loadMuteStatus() async {
    final conversationId = chatController.currentConversationId.value;
    if (conversationId != null && conversationId.isNotEmpty) {
      final muted = await oneSignalService.isPrivateChatMuted(conversationId);
      setState(() {
        isPrivateChatMuted = muted;
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
            
            // Kullanıcı bilgileri
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: const Icon(Icons.person, color: Color(0xffef5050), size: 20),
              ),
              title: Text(
                languageService.tr("chat.actions.userInfo"),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff272727),
                ),
              ),
              onTap: () {
                Get.back();
              },
            ),
            
            // Private chat sessize alma butonu
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: Icon(
                  isPrivateChatMuted == true ? Icons.volume_off : Icons.volume_up,
                  color: isPrivateChatMuted == true ? Color(0xffef5050) : Color(0xffef5050),
                  size: 20,
                ),
              ),
              title: Text(
                isPrivateChatMuted == true 
                  ? languageService.tr("chat.actions.muteChat.muted")
                  : languageService.tr("chat.actions.muteChat.unmuted"),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff272727),
                ),
              ),
              subtitle: Text(
                isPrivateChatMuted == true
                  ? languageService.tr("chat.actions.muteChat.mutedDesc")
                  : languageService.tr("chat.actions.muteChat.unmutedDesc"),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff9ca3ae),
                ),
              ),
              trailing: Switch(
                value: isPrivateChatMuted ?? false,
                onChanged: (value) async {
                  final conversationId = chatController.currentConversationId.value;
                  if (conversationId != null && conversationId.isNotEmpty) {
                    if (value) {
                      await oneSignalService.mutePrivateChat(conversationId);
                    } else {
                      await oneSignalService.unmutePrivateChat(conversationId);
                    }
                    setState(() {
                      isPrivateChatMuted = value;
                    });
                  }
                },
                activeColor: Color(0xffef5050),
              ),
            ),
            
            // Mesajları temizle
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xfffff5f5),
                child: const Icon(Icons.delete_outline, color: Color(0xffef5050), size: 20),
              ),
              title: Text(
                languageService.tr("chat.actions.clearMessages"),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff272727),
                ),
              ),
              onTap: () {
                Get.back();
                _showClearMessagesDialog();
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

  void _showClearMessagesDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(
          languageService.tr("chat.dialogs.clearMessages.title"),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff272727),
          ),
        ),
        content: Text(
          languageService.tr("chat.dialogs.clearMessages.message"),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xff9ca3ae),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              languageService.tr("common.actions.cancel"),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff9ca3ae),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              //  
              // chatController.clearMessages();
            },
            child: Text(
              languageService.tr("chat.dialogs.clearMessages.confirm"),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xffef5050),
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
        title: Text(
          languageService.tr("chat.dialogs.report.title"),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff272727),
          ),
        ),
        content: Text(
          languageService.tr("chat.dialogs.report.message"),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xff9ca3ae),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              languageService.tr("common.actions.cancel"),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff9ca3ae),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); 
            },
            child: Text(
              languageService.tr("chat.dialogs.report.confirm"),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xffef5050),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
