import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../models/chat_models/chat_detail_model.dart';
import '../../../services/language_service.dart';

class DocumentMessageWidget extends StatelessWidget {
  final MessageModel message;

  const DocumentMessageWidget({super.key, required this.message});

  // Document URL'sini al (messageDocument veya messageMedia'dan)
  String? getDocumentUrl() {
    // Önce messageDocument field'ını kontrol et
    if (message.messageDocument != null && message.messageDocument!.isNotEmpty) {
      final document = message.messageDocument!.first;
      if (document.url.startsWith('http')) {
        return document.url;
      } else {
        return 'https://stageapi.edusocial.pl/storage/${document.url}';
      }
    }
    
    // messageMedia'da document var mı kontrol et
    if (message.messageMedia.isNotEmpty) {
      for (var media in message.messageMedia) {
        if (media.isDocument) {
          // Yeni MessageMediaModel'in fullPath özelliğini kullan
          return media.fullPath.isNotEmpty ? media.fullPath : 
                 (media.path.startsWith('http') ? media.path : 'https://stageapi.edusocial.pl/storage/${media.path}');
        }
      }
    }
    
    return null;
  }

  // Document adını al (messageDocument veya messageMedia'dan)
  String getDocumentName() {
    // Önce messageDocument field'ını kontrol et
    if (message.messageDocument != null && message.messageDocument!.isNotEmpty) {
      return message.messageDocument!.first.name;
    }
    
    // messageMedia'da document var mı kontrol et
    if (message.messageMedia.isNotEmpty) {
      for (var media in message.messageMedia) {
        if (media.isDocument) {
          // Media document'i için dosya ismini al
          return media.path.split('/').last;
        }
      }
    }
    
    // Fallback olarak message'dan al
    return message.message.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    final documentUrl = getDocumentUrl();
    final documentName = getDocumentName();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
            onTap: documentUrl != null ? () async {
              try {
                final uri = Uri.parse(documentUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.platformDefault);
                } else {
                  // URL açılamadığında kullanıcıya bilgi ver
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${languageService.tr("chat.document.cannotOpen")}: $documentName'),
                        backgroundColor: Color(0xffFF5050),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${languageService.tr("chat.document.openError")}: $e'),
                      backgroundColor: Color(0xffff7c7c),
                    ),
                  );
                }
              }
            } : null,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getDocumentIcon(),
                        color: message.isMe ? Colors.white : const Color(0xff000000),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              documentName,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: message.isMe ? Colors.white : const Color(0xff000000),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (documentUrl != null)
                              Text(
                                languageService.tr("chat.document.clickToDownload"),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: message.isMe 
                                      ? Colors.white.withAlpha(80)
                                      : const Color(0xff8E8E93),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (documentUrl != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.download,
                          color: message.isMe 
                              ? Colors.white.withAlpha(80)
                              : const Color(0xff8E8E93),
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Saat bilgisi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: message.isMe 
                              ? Colors.white.withAlpha(80)
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
    );
  }

  /// Dosya tipine göre uygun ikonu döndürür
  IconData _getDocumentIcon() {
    if (message.messageMedia.isNotEmpty) {
      for (var media in message.messageMedia) {
        if (media.isDocument) {
          if (media.isPdf) {
            return Icons.picture_as_pdf;
          } else if (media.isWord) {
            return Icons.description;
          } else if (media.isText) {
            return Icons.text_snippet;
          }
        }
      }
    }
    
    // Fallback
    return Icons.insert_drive_file;
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
