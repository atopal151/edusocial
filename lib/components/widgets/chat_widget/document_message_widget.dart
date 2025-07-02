import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../models/chat_models/chat_detail_model.dart';
import '../../../utils/date_format.dart';
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
              style: GoogleFonts.inter(fontSize: 10, color: Color(0xff414751), fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                formatSimpleDateClock(message.createdAt),
                style: GoogleFonts.inter(fontSize: 10, color: Color(0xff9ca3ae), fontWeight: FontWeight.w400),
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
                      backgroundColor: Color(0xffFF5050),
                    ),
                  );
                }
              }
            } : null,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.insert_drive_file, 
                    color: message.isMe ? Colors.white : const Color(0xff414751),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          documentName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: message.isMe ? Colors.white : const Color(0xff414751),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (documentUrl != null)
                          Text(
                            languageService.tr("chat.document.clickToDownload"),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: message.isMe ? Colors.white70 : Color(0xff9ca3ae),
                              
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (documentUrl != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.download,
                      color: message.isMe ? Colors.white70 : Color(0xff9ca3ae),
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
