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

    return Column(
      
      crossAxisAlignment: message.isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 🔹 Kullanıcı Bilgileri (Saat kaldırıldı)
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
              '@${message.username}',
              style: const TextStyle(fontSize: 10, color: Color(0xff414751)),
            ),
            if (message.isSentByMe)
              Padding(
                padding: const EdgeInsets.all( 8.0),
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
        // 🔹 Mesaj Balonu (Private Chat Tasarımı)
        Padding(
          padding: const EdgeInsets.only(left: 16.0,right: 16.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Align(
              alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: message.isSentByMe 
                      ? const Color(0xFFff7c7c) // Kırmızı
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(18),
                    bottomRight: const Radius.circular(18),
                    topLeft: message.isSentByMe 
                        ? const Radius.circular(18) 
                        : const Radius.circular(4),
                    topRight: message.isSentByMe 
                        ? const Radius.circular(4) 
                        : const Radius.circular(18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ana metin içeriği
                    if (message.content.isNotEmpty) ...[
                      Text(
                        message.content,
                        style: GoogleFonts.inter(
                          color: message.isSentByMe ? Colors.white : const Color(0xff000000),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Links container
                    if (message.links != null && message.links!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                                                   color: message.isSentByMe 
                               ? Colors.white.withValues(alpha: 0.2)
                               : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Link'leri göster
                            ...message.links!.map((link) => GestureDetector(
                                  onTap: () async {
                                    try {
                                      debugPrint("🔗 Group Text+Links - Link açma deneniyor: $link");
                                      
                                      // URL'yi temizle ve kontrol et
                                      String cleanLink = link.trim();
                                      
                                      // URL validation ve normalization
                                      if (!cleanLink.startsWith('http://') && !cleanLink.startsWith('https://')) {
                                        // www. ile başlıyorsa https ekle
                                        if (cleanLink.startsWith('www.')) {
                                          cleanLink = 'https://$cleanLink';
                                        } 
                                        // Diğer durumlarda da https ekle
                                        else if (cleanLink.contains('.')) {
                                          cleanLink = 'https://$cleanLink';
                                        } else {
                                          // Geçersiz URL formatı
                                          debugPrint("🔗 Group Text+Links - Geçersiz URL formatı: $cleanLink");
                                          return;
                                        }
                                      }
                                      
                                      // Boşlukları temizle
                                      cleanLink = cleanLink.replaceAll(' ', '');
                                      
                                      // Geçerli URL formatı kontrolü
                                      if (!Uri.parse(cleanLink).hasAbsolutePath && !cleanLink.contains('.')) {
                                        debugPrint("🔗 Group Text+Links - URL yapısı geçersiz: $cleanLink");
                                        return;
                                      }
                                      
                                      debugPrint("🔗 Group Text+Links - Temizlenmiş link: $cleanLink");
                                      
                                      final Uri url = Uri.parse(cleanLink);
                                      debugPrint("🔗 Group Text+Links - Parsed URL: $url");
                                      
                                      // URL'nin açılabilir olup olmadığını kontrol et
                                      final canLaunch = await canLaunchUrl(url);
                                      debugPrint("🔗 Group Text+Links - canLaunchUrl sonucu: $canLaunch");
                                      
                                      if (canLaunch) {
                                        debugPrint("🔗 Group Text+Links - URL açılıyor (platformDefault)...");
                                        bool result = await launchUrl(
                                          url, 
                                          mode: LaunchMode.platformDefault
                                        );
                                        debugPrint("🔗 Group Text+Links - platformDefault sonucu: $result");
                                        
                                        // Eğer platformDefault başarısız olursa externalApplication dene
                                        if (!result) {
                                          debugPrint("🔗 Group Text+Links - Fallback: externalApplication deneniyor...");
                                          result = await launchUrl(
                                            url, 
                                            mode: LaunchMode.externalApplication
                                          );
                                          debugPrint("🔗 Group Text+Links - externalApplication sonucu: $result");
                                        }
                                        
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
                                        debugPrint("🔗 Group Text+Links - URL açılamıyor: $url");
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
                                      debugPrint("🔗 Group Text+Links - Link açma hatası: $e");
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
                          _formatTime(message.timestamp),
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: message.isSentByMe 
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
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    try {
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '';
    }
  }
} 