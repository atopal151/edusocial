import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../models/chat_models/group_message_model.dart';
import '../../../services/language_service.dart';

class GroupTextWithLinksMessageWidget extends StatelessWidget {
  final GroupMessageModel message;

  const GroupTextWithLinksMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    String formattedTime =
        DateFormat('dd.MM.yyyy HH:mm').format(message.timestamp);

    return Column(
      crossAxisAlignment: message.isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 🔹 Kullanıcı Bilgileri ve Saat
        Row(
          mainAxisAlignment: message.isSentByMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!message.isSentByMe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (message.profileImage.isNotEmpty &&
                          !message.profileImage.endsWith('/0'))
                      ? NetworkImage(message.profileImage)
                      : null,
                  child: (message.profileImage.isEmpty ||
                          message.profileImage.endsWith('/0'))
                      ? const Icon(Icons.person, color: Colors.white, size: 14)
                      : null,
                ),
              ),
            Text(
              '${message.name} ${message.surname}',
              style: GoogleFonts.inter(fontSize: 10, color: Color(0xff414751)),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                formattedTime,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Color(0xff9ca3ae),
                    fontWeight: FontWeight.w500),
              ),
            ),
            if (message.isSentByMe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (message.profileImage.isNotEmpty &&
                          !message.profileImage.endsWith('/0'))
                      ? NetworkImage(message.profileImage)
                      : null,
                  child: (message.profileImage.isEmpty ||
                          message.profileImage.endsWith('/0'))
                      ? const Icon(Icons.person, color: Colors.white, size: 14)
                      : null,
                ),
              ),
          ],
        ),
        // 🔹 Mesaj Balonu
        Align(
          alignment:
              message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  message.isSentByMe ? const Color(0xFFFF7C7C) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: message.isSentByMe
                    ? const Radius.circular(20)
                    : const Radius.circular(0),
                topRight: message.isSentByMe
                    ? const Radius.circular(0)
                    : const Radius.circular(20),
                bottomLeft: const Radius.circular(20),
                bottomRight: const Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.content.isNotEmpty)
                  Text(
                    message.content,
                    style: GoogleFonts.inter(
                      color: message.isSentByMe ? Colors.white : Color(0xff414751),
                      fontSize: 12,
                    ),
                  ),
                if (message.links != null && message.links!.isNotEmpty) ...[
                  if (message.content.isNotEmpty) const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...message.links!.map((link) => GestureDetector(
                          onTap: () async {
                            try {
                              debugPrint("🔗 GroupTextWithLinks - Link açma deneniyor: $link");
                              
                              // URL'yi temizle ve kontrol et
                              String cleanLink = link.trim();
                              if (!cleanLink.startsWith('http://') && !cleanLink.startsWith('https://')) {
                                cleanLink = 'https://$cleanLink';
                              }
                              
                              debugPrint("🔗 GroupTextWithLinks - Temizlenmiş link: $cleanLink");
                              
                              final Uri url = Uri.parse(cleanLink);
                              debugPrint("🔗 GroupTextWithLinks - Parsed URL: $url");
                              
                              // URL'nin açılabilir olup olmadığını kontrol et
                              final canLaunch = await canLaunchUrl(url);
                              debugPrint("🔗 GroupTextWithLinks - canLaunchUrl sonucu: $canLaunch");
                              
                              if (canLaunch) {
                                debugPrint("🔗 GroupTextWithLinks - URL açılıyor...");
                                final result = await launchUrl(
                                  url, 
                                  mode: LaunchMode.externalApplication
                                );
                                debugPrint("🔗 GroupTextWithLinks - launchUrl sonucu: $result");
                                
                                if (!result) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(languageService.tr("chat.link.cannotOpen")),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              } else {
                                debugPrint("🔗 GroupTextWithLinks - URL açılamıyor: $url");
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("${languageService.tr("chat.link.cannotOpenThis")}: $cleanLink"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint("🔗 GroupTextWithLinks - Link açma hatası: $e");
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("${languageService.tr("chat.link.openError")}: ${e.toString()}"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              link,
                              style: GoogleFonts.inter(
                                color: Color(0xff2c96ff),
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xff2c96ff),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
} 