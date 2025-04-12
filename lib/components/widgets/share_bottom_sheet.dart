import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ShareOptionsBottomSheet extends StatelessWidget {
  final String postText;

  const ShareOptionsBottomSheet({super.key, required this.postText});

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.messenger, color: Color(0xfffb535c)),
              title: const Text(
                "WhatsApp ile paylaş",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff414751)),
              ),
              onTap: () {
                Share.share(postText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.telegram, color: Color(0xfffb535c)),
              title: const Text("Telegram ile paylaş",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff414751))),
              onTap: () {
                Share.share(postText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Color(0xfffb535c)),
              title: const Text("Bağlantıyı kopyala",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff414751))),
              onTap: () {
                Clipboard.setData(ClipboardData(text: postText));
                Navigator.pop(context);
                Get.snackbar("Başarılı", "Bağlantı kopyalandı",
                    snackPosition: SnackPosition.BOTTOM);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.mail_outline,
                color: Color(0xfffb535c),
              ),
              title: const Text("Mail ile paylaş",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff414751))),
              onTap: () {
                Share.share(postText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xfffb535c)),
              title: const Text("Diğer uygulamalarla paylaş",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff414751))),
              onTap: () {
                Share.share(postText);
              },
            ),
          ],
        ),
      ),
    );
  }
}
