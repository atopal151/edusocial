import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';

class ShareOptionsBottomSheet extends StatelessWidget {
  final String postText;

  const ShareOptionsBottomSheet({
    super.key,
    required this.postText,
  });

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            languageService.tr("share.title"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                icon: "images/icons/whatsapp_icon.svg",
                label: languageService.tr("share.platforms.whatsapp"),
                onTap: () => _shareToWhatsApp(postText),
              ),
              _buildShareOption(
                icon: "images/icons/telegram_icon.svg",
                label: languageService.tr("share.platforms.telegram"),
                onTap: () => _shareToTelegram(postText),
              ),
              _buildShareOption(
                icon: "images/icons/twitter_icon.svg",
                label: languageService.tr("share.platforms.twitter"),
                onTap: () => _shareToTwitter(postText),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                icon: "images/icons/facebook_icon.svg",
                label: languageService.tr("share.platforms.facebook"),
                onTap: () => _shareToFacebook(postText),
              ),
              _buildShareOption(
                icon: "images/icons/linkedin_icon.svg",
                label: languageService.tr("share.platforms.linkedin"),
                onTap: () => _shareToLinkedIn(postText),
              ),
              _buildShareOption(
                icon: "images/icons/copy_icon.svg",
                label: languageService.tr("share.actions.copy"),
                onTap: () => _copyToClipboard(context, postText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xfff6f6f6),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff414751),
            ),
          ),
        ],
      ),
    );
  }

  void _shareToWhatsApp(String text) {
    final LanguageService languageService = Get.find<LanguageService>();
    Share.share(text, subject: languageService.tr("share.subjects.whatsapp"));
  }

  void _shareToTelegram(String text) {
    final LanguageService languageService = Get.find<LanguageService>();
    Share.share(text, subject: languageService.tr("share.subjects.telegram"));
  }

  void _shareToTwitter(String text) {
    final LanguageService languageService = Get.find<LanguageService>();
    Share.share(text, subject: languageService.tr("share.subjects.twitter"));
  }

  void _shareToFacebook(String text) {
    final LanguageService languageService = Get.find<LanguageService>();
    Share.share(text, subject: languageService.tr("share.subjects.facebook"));
  }

  void _shareToLinkedIn(String text) {
    final LanguageService languageService = Get.find<LanguageService>();
    Share.share(text, subject: languageService.tr("share.subjects.linkedin"));
  }

  void _copyToClipboard(BuildContext context, String text) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(languageService.tr("share.copySuccess")),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 