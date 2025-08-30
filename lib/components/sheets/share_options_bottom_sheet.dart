import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ShareOptionsBottomSheet extends StatelessWidget {
  final String postText;
  final List<String>? mediaUrls;
  final int? postId;
  final String? postSlug;

  const ShareOptionsBottomSheet({
    super.key,
    required this.postText,
    this.mediaUrls,
    this.postId,
    this.postSlug,
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
    _shareWithMedia(text, languageService.tr("share.subjects.whatsapp"));
  }

  void _shareToTelegram(String text) {
    final LanguageService languageService = Get.find<LanguageService>();
    _shareWithMedia(text, languageService.tr("share.subjects.telegram"));
  }

  void _shareToTwitter(String text) {
    final LanguageService languageService = Get.find<LanguageService>();
    _shareWithMedia(text, languageService.tr("share.subjects.twitter"));
  }

  void _shareToFacebook(String text) {
    final LanguageService languageService = Get.find<LanguageService>();
    _shareWithMedia(text, languageService.tr("share.subjects.facebook"));
  }

  void _shareToLinkedIn(String text) {
    final LanguageService languageService = Get.find<LanguageService>();
    _shareWithMedia(text, languageService.tr("share.subjects.linkedin"));
  }

  void _shareWithMedia(String text, String subject) async {
    try {
      if (mediaUrls != null && mediaUrls!.isNotEmpty) {
        // Görseller varsa, ilk görseli paylaş
        final firstImageUrl = mediaUrls!.first;
        
        // URL'den dosya indir
        final response = await http.get(Uri.parse(firstImageUrl));
        
        if (response.statusCode == 200) {
          // Geçici dosya oluştur
          final tempPath = await getTemporaryDirectory();
          final tempFile = File('${tempPath.path}/shared_image.jpg');
          await tempFile.writeAsBytes(response.bodyBytes);
          
          // Görsel ile paylaş
          await Share.shareXFiles(
            [XFile(tempFile.path)],
            text: text,
            subject: subject,
          );
        } else {
          // Görsel indirilemezse sadece text paylaş
          Share.share(text, subject: subject);
        }
      } else {
        // Görsel yoksa sadece text paylaş
        Share.share(text, subject: subject);
      }
    } catch (e) {
      debugPrint("❌ Paylaşım hatası: $e");
      // Hata durumunda sadece text paylaş
      Share.share(text, subject: subject);
    }
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