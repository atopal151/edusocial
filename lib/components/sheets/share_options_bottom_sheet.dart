import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

class ShareOptionsBottomSheet extends StatelessWidget {
  final String postText;

  const ShareOptionsBottomSheet({
    super.key,
    required this.postText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Paylaş",
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
                label: "WhatsApp",
                onTap: () => _shareToWhatsApp(postText),
              ),
              _buildShareOption(
                icon: "images/icons/telegram_icon.svg",
                label: "Telegram",
                onTap: () => _shareToTelegram(postText),
              ),
              _buildShareOption(
                icon: "images/icons/twitter_icon.svg",
                label: "Twitter",
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
                label: "Facebook",
                onTap: () => _shareToFacebook(postText),
              ),
              _buildShareOption(
                icon: "images/icons/linkedin_icon.svg",
                label: "LinkedIn",
                onTap: () => _shareToLinkedIn(postText),
              ),
              _buildShareOption(
                icon: "images/icons/copy_icon.svg",
                label: "Kopyala",
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
    Share.share(text, subject: "WhatsApp ile paylaş");
  }

  void _shareToTelegram(String text) {
    Share.share(text, subject: "Telegram ile paylaş");
  }

  void _shareToTwitter(String text) {
    Share.share(text, subject: "Twitter ile paylaş");
  }

  void _shareToFacebook(String text) {
    Share.share(text, subject: "Facebook ile paylaş");
  }

  void _shareToLinkedIn(String text) {
    Share.share(text, subject: "LinkedIn ile paylaş");
  }

  void _copyToClipboard(BuildContext context, String text) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Metin panoya kopyalandı"),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 