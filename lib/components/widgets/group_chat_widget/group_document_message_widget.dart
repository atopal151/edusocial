import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../models/chat_models/group_message_model.dart';
import '../../../services/language_service.dart';
import '../../../controllers/chat_controllers/group_chat_detail_controller.dart';

class GroupDocumentMessageWidget extends StatelessWidget {
  final GroupMessageModel message;
  final GroupChatDetailController controller;

  const GroupDocumentMessageWidget({
    super.key, 
    required this.message,
    required this.controller,
  });



  // Document URL'sini al
  String? getDocumentUrl() {
    if (message.content.startsWith('http')) {
      return message.content;
    } else {
      return 'https://stageapi.edusocial.pl/storage/${message.content}';
    }
  }

  // Document adını al
  String getDocumentName() {
    return message.content.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    final documentUrl = getDocumentUrl();
    final documentName = getDocumentName();
    
    return Column(
      crossAxisAlignment: message.isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 🔹 Kullanıcı Bilgileri ve Pin İkonu
        Row(
          mainAxisAlignment: message.isSentByMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!message.isSentByMe)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 6.0),
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
                padding: const EdgeInsets.only(left: 6.0, right: 8.0),
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
          padding: EdgeInsets.only(
            left: message.isSentByMe ? 48.0 : 30.0,
            right: message.isSentByMe ? 30.0 : 48.0,
            top: 2.0,
            bottom: 4.0,
          ),
          child: Align(
            alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.insert_drive_file, 
                        color: message.isSentByMe ? Colors.white : const Color(0xff000000),
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
                                color: message.isSentByMe ? Colors.white : const Color(0xff000000),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (documentUrl != null)
                                                                   Text(
                                     languageService.tr("chat.document.clickToDownload"),
                                     style: GoogleFonts.inter(
                                       fontSize: 12,
                                       color: message.isSentByMe 
                                           ? Colors.white.withValues(alpha: 0.8)
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
                             color: message.isSentByMe 
                                 ? Colors.white.withValues(alpha: 0.8)
                                 : const Color(0xff8E8E93),
                             size: 16,
                           ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Saat bilgisi mesaj balonunun içinde sağ altta
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
