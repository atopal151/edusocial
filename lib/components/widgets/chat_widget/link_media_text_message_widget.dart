import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../models/chat_models/chat_detail_model.dart';
import '../../../services/language_service.dart';

class LinkMediaTextMessageWidget extends StatelessWidget {
  final MessageModel message;

  const LinkMediaTextMessageWidget({super.key, required this.message});

  // Dosya türünü kontrol et
  bool isImageFile(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerUrl = url.toLowerCase();
    return imageExtensions.any((ext) => lowerUrl.endsWith(ext));
  }

  bool isPdfFile(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  bool isDocumentFile(String url) {
    final documentExtensions = ['.pdf', '.doc', '.docx', '.txt', '.rtf'];
    final lowerUrl = url.toLowerCase();
    return documentExtensions.any((ext) => lowerUrl.endsWith(ext));
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    // 🔹 Media Path kontrolü
    String? mediaUrl;
    if (message.messageMedia.isNotEmpty) {
      final rawMediaPath = message.messageMedia.first.path;
      if (rawMediaPath.startsWith('http') || rawMediaPath.startsWith('https')) {
        mediaUrl = rawMediaPath;
      } else if (rawMediaPath.startsWith('file://')) {
        mediaUrl = rawMediaPath;
      } else {
        mediaUrl = 'https://stageapi.edusocial.pl/storage/$rawMediaPath';
      }
    }

    // 🔹 Link kontrolü
    String? linkUrl;
    if (message.messageLink.isNotEmpty) {
      linkUrl = message.messageLink.first.link;
    }

    // 🔹 Görsel Widget
    Widget? mediaWidget;
    if (mediaUrl != null) {
      if (mediaUrl.startsWith('file://')) {
        final file = File(Uri.parse(mediaUrl).path);
        if (isImageFile(mediaUrl)) {
          mediaWidget = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dosya bulunamadı',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: child,
                );
              },
            ),
          );
        } else {
          // Dosya türü resim değilse dosya ikonu göster
          mediaWidget = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  isPdfFile(mediaUrl)
                      ? Icons.picture_as_pdf
                      : Icons.insert_drive_file,
                  size: 32,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  mediaUrl.split('/').last,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Color(0xff9ca3ae),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
      } else {
        // Network dosyaları için
        if (isImageFile(mediaUrl)) {
          mediaWidget = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              mediaUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFFff7c7c),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Görsel yüklenemedi',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          // Dosya türü resim değilse dosya ikonu göster
          mediaWidget = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  isPdfFile(mediaUrl)
                      ? Icons.picture_as_pdf
                      : Icons.insert_drive_file,
                  size: 32,
                  color: Color(0xff9ca3ae),
                ),
                const SizedBox(height: 8),
                Text(
                  mediaUrl.split('/').last,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Color(0xff9ca3ae),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
      }
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
                if (mediaWidget != null) ...[
                  mediaWidget,
                  const SizedBox(height: 8),
                ],
                if (message.message.isNotEmpty) ...[
                  Text(
                    message.message,
                    style: GoogleFonts.inter(
                      color: message.isMe ? Colors.white : const Color(0xff000000),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (linkUrl != null && linkUrl.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: message.isMe 
                          ? Colors.white.withValues(alpha: 0.2)
                          : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          debugPrint("🔗 LinkMediaText - Link açma deneniyor: $linkUrl");

                          // URL'yi temizle ve kontrol et
                          String cleanLink = linkUrl!.trim();
                          
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
                              debugPrint("🔗 LinkMediaText - Geçersiz URL formatı: $cleanLink");
                              return;
                            }
                          }
                          
                          // Boşlukları temizle
                          cleanLink = cleanLink.replaceAll(' ', '');
                          
                          // Geçerli URL formatı kontrolü
                          if (!Uri.parse(cleanLink).hasAbsolutePath && !cleanLink.contains('.')) {
                            debugPrint("🔗 LinkMediaText - URL yapısı geçersiz: $cleanLink");
                            return;
                          }

                          debugPrint("🔗 LinkMediaText - Temizlenmiş link: $cleanLink");

                          final Uri url = Uri.parse(cleanLink);
                          debugPrint("🔗 LinkMediaText - Parsed URL: $url");

                          // URL'nin açılabilir olup olmadığını kontrol et
                          final canLaunch = await canLaunchUrl(url);
                          debugPrint("🔗 LinkMediaText - canLaunchUrl sonucu: $canLaunch");

                          if (canLaunch) {
                            debugPrint("🔗 LinkMediaText - URL açılıyor...");
                                                      final result = await launchUrl(url,
                              mode: LaunchMode.platformDefault);
                            debugPrint("🔗 LinkMediaText - launchUrl sonucu: $result");

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
                            debugPrint("🔗 LinkMediaText - URL açılamıyor: $url");
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
                          debugPrint("🔗 LinkMediaText - Link açma hatası: $e");
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
                      child: Text(
                        linkUrl,
                        style: GoogleFonts.inter(
                          color: const Color(0xff2c96ff),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xff2c96ff),
                        ),
                      ),
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
