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

  // Document URL'sini al
  String? getDocumentUrl() {
    if (message.messageDocument != null && message.messageDocument!.isNotEmpty) {
      final document = message.messageDocument!.first;
      if (document.url.startsWith('http')) {
        return document.url;
      } else {
        return 'https://stageapi.edusocial.pl/storage/${document.url}';
      }
    }
    return null;
  }

  // Document adını al
  String getDocumentName() {
    if (message.messageDocument != null && message.messageDocument!.isNotEmpty) {
      return message.messageDocument!.first.name;
    }
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
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                        Icons.insert_drive_file, 
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
                                      ? Colors.white.withOpacity(0.8)
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
                              ? Colors.white.withOpacity(0.8)
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
                              ? Colors.white.withOpacity(0.8)
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

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '';
    }
  }
}
