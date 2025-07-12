import 'package:edusocial/models/chat_models/chat_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../services/language_service.dart';

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
    final LanguageService languageService = Get.find<LanguageService>();
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: message.isMe 
                  ? const Color(0xFFff7c7c) // Kırmızı
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: message.isMe 
                    ? const Radius.circular(18) 
                    : const Radius.circular(4),
                bottomRight: message.isMe 
                    ? const Radius.circular(4) 
                    : const Radius.circular(18),
              ),
             
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metin varsa göster
                if (displayText.isNotEmpty) ...[
                  Text(
                    displayText,
                    style: GoogleFonts.inter(
                      color: message.isMe ? Colors.white : const Color(0xff000000),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Link container'ı
                if (links.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isMe 
                          ? Colors.white.withValues(alpha: 0.2)
                          : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.messageLink.isNotEmpty) ...[
                          // messageLink varsa title göster
                          Text(
                            message.messageLink.first.linkTitle,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: message.isMe
                                  ? Colors.white
                                  : const Color(0xff000000),
                            ),
                          ),
                          const SizedBox(height: 6),
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
                                            content: Text(languageService.tr("chat.link.cannotOpen")),
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
                                          content: Text("${languageService.tr("chat.link.cannotOpenThis")}: $cleanLink"),
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
                
                // Saat bilgisi mesaj balonunun içinde sağ altta
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: message.isMe 
                            ? Colors.white.withValues(alpha: 0.8)
                            : const Color(0xff8E8E93),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ),
    );
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '';
    }
  }
}
