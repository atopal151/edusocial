import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ShareOptionsBottomSheet extends StatelessWidget {
  final String postText;
  final int? postId;
  final String? postSlug;

  const ShareOptionsBottomSheet({
    super.key, 
    required this.postText, 
    this.postId,
    this.postSlug,
  });

  // Uygulama market linkleri
  String _getAppStoreLink() {
    return "https://apps.apple.com/app/edusocial/id123456789";
  }

  String _getPlayStoreLink() {
    return "https://play.google.com/store/apps/details?id=com.edusocial.app";
  }

  // Deep link (uygulama açma)
  String _getDeepLink() {
    return "edusocial://app";
  }

  // Paylaşım metni
  String _getPostShareText() {
    final deepLink = _getDeepLink();
    final appStoreLink = _getAppStoreLink();
    final playStoreLink = _getPlayStoreLink();
    
    return """
$postText

📱 EduSocial Uygulamasını İndir:
🔗 Uygulamayı Aç: $deepLink
📲 App Store: $appStoreLink  
📱 Play Store: $playStoreLink

#EduSocial #Eğitim
""";
  }

  // Uygulamayı aç veya markete yönlendir
  Future<void> _openAppOrStore() async {
    final deepLink = Uri.parse(_getDeepLink());
    final playStore = Uri.parse(_getPlayStoreLink());
    final appStore = Uri.parse(_getAppStoreLink());

    try {
      if (await canLaunchUrl(deepLink)) {
        await launchUrl(deepLink);
      } else {
        if (Platform.isAndroid) {
          await launchUrl(playStore);
        } else if (Platform.isIOS) {
          await launchUrl(appStore);
        }
      }
    } catch (e) {
      await launchUrl(playStore);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Direkt varsayılan paylaş ekranını aç
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Share.share(_getPostShareText());
      Navigator.pop(context);
    });

    // Boş container döndür (paylaş ekranı açılırken kısa süre görünür)
    return Container();
  }
}
