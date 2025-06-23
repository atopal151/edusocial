import 'package:edusocial/models/chat_models/chat_detail_model.dart';
import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkMessageWidget extends StatelessWidget {
  final MessageModel message;

  const LinkMessageWidget({super.key, required this.message});

  // URL'leri tespit et
  List<String> extractUrls(String text) {
    final urlRegex = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );
    return urlRegex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    // messageLink varsa onu kullan, yoksa text içindeki URL'leri çıkar
    List<String> links = [];
    String displayText = message.message;

    if (message.messageLink.isNotEmpty) {
      // messageLink varsa onu kullan
      links = message.messageLink.map((link) => link.link).toList();
    } else {
      // Text içindeki URL'leri çıkar
      links = extractUrls(message.message);
      // URL'leri text'ten çıkar
      for (String link in links) {
        displayText = displayText.replaceAll(link, '');
      }
      displayText = displayText.trim();
    }

    return Column(
      crossAxisAlignment:
          message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // 🔹 Kullanıcı Bilgileri ve Saat
        Row(
          mainAxisAlignment:
              message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!message.isMe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xffd9d9d9),
                  backgroundImage: (message.senderAvatarUrl != null &&
                          message.senderAvatarUrl!.isNotEmpty &&
                          !message.senderAvatarUrl!.endsWith('/0'))
                      ? NetworkImage(message.senderAvatarUrl!)
                      : null,
                  child: (message.senderAvatarUrl == null ||
                          message.senderAvatarUrl!.isEmpty ||
                          message.senderAvatarUrl!.endsWith('/0'))
                      ? const Icon(Icons.person, color: Colors.white, size: 14)
                      : null,
                ),
              ),
            Text(
              '${message.sender.name} ${message.sender.surname}',
              style: GoogleFonts.inter(fontSize: 10, color: Color(0xff414751)),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                formatSimpleDateClock(message.createdAt),
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Color(0xff9ca3ae),
                    fontWeight: FontWeight.w500),
              ),
            ),
            if (message.isMe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xffd9d9d9),
                  backgroundImage: (message.senderAvatarUrl != null &&
                          message.senderAvatarUrl!.isNotEmpty &&
                          !message.senderAvatarUrl!.endsWith('/0'))
                      ? NetworkImage(message.senderAvatarUrl!)
                      : null,
                  child: (message.senderAvatarUrl == null ||
                          message.senderAvatarUrl!.isEmpty ||
                          message.senderAvatarUrl!.endsWith('/0'))
                      ? const Icon(Icons.person, color: Colors.white, size: 14)
                      : null,
                ),
              ),
          ],
        ),
        // 🔹 Mesaj Balonu
        Align(
          alignment:
              message.isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isMe ? const Color(0xFFFF7C7C) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: message.isMe
                    ? const Radius.circular(20)
                    : const Radius.circular(0),
                topRight: message.isMe
                    ? const Radius.circular(0)
                    : const Radius.circular(20),
                bottomLeft: const Radius.circular(20),
                bottomRight: const Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Link container'ı
                if (links.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.messageLink.isNotEmpty) ...[
                          // messageLink varsa title göster
                          Text(
                            message.messageLink.first.linkTitle,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: message.isMe
                                  ? Color(0xff414751)
                                  : Color(0xff414751),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        // Link'leri göster
                        ...links.map((link) => GestureDetector(
                              onTap: () async {
                                try {
                                  debugPrint("🔗 Chat - Link açma deneniyor: $link");
                                  
                                  // URL'yi temizle ve kontrol et
                                  String cleanLink = link.trim();
                                  if (!cleanLink.startsWith('http://') && !cleanLink.startsWith('https://')) {
                                    cleanLink = 'https://$cleanLink';
                                  }
                                  
                                  debugPrint("🔗 Chat - Temizlenmiş link: $cleanLink");
                                  
                                  final Uri url = Uri.parse(cleanLink);
                                  debugPrint("🔗 Chat - Parsed URL: $url");
                                  
                                  // URL'nin açılabilir olup olmadığını kontrol et
                                  final canLaunch = await canLaunchUrl(url);
                                  debugPrint("🔗 Chat - canLaunchUrl sonucu: $canLaunch");
                                  
                                  if (canLaunch) {
                                    debugPrint("🔗 Chat - URL açılıyor...");
                                    final result = await launchUrl(
                                      url, 
                                      mode: LaunchMode.externalApplication
                                    );
                                    debugPrint("🔗 Chat - launchUrl sonucu: $result");
                                    
                                    if (!result) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Link açılamadı. Lütfen tekrar deneyin."),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    debugPrint("🔗 Chat - URL açılamıyor: $url");
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Bu link açılamıyor: $cleanLink"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  debugPrint("🔗 Chat - Link açma hatası: $e");
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Link açılırken bir hata oluştu: ${e.toString()}"),
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
                // Text mesajı
                if (displayText.isNotEmpty) ...[
                  if (links.isNotEmpty) const SizedBox(height: 8),
                  Text(
                    displayText,
                      style: GoogleFonts.inter(
                      color:
                          message.isMe ? Colors.white : Color(0xff414751),
                      fontSize: 12,
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
