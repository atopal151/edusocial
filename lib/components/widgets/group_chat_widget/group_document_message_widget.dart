import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/chat_models/group_message_model.dart';

class GroupDocumentMessageWidget extends StatelessWidget {
  final GroupMessageModel message;

  const GroupDocumentMessageWidget({super.key, required this.message});

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
    // 📌 `DateTime` → `String` formatına çeviriyoruz
    String formattedTime = DateFormat('dd.MM.yyyy HH:mm').format(message.timestamp);
    final documentUrl = getDocumentUrl();
    final documentName = getDocumentName();
    
    return Column(
      crossAxisAlignment: message.isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 🔹 Kullanıcı Bilgileri ve Saat
        Row(
          mainAxisAlignment:
              message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
              style: const TextStyle(fontSize: 10, color: Color(0xff414751)),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                formattedTime,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
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
          alignment: message.isSentByMe
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: GestureDetector(
            onTap: documentUrl != null ? () async {
              try {
                final uri = Uri.parse(documentUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  // URL açılamadığında kullanıcıya bilgi ver
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Document açılamadı: $documentName'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Document açılırken hata oluştu: $e'),
                      backgroundColor: Colors.red,
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
                color: message.isSentByMe ? const Color(0xFFFF7C7C) : Colors.white,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.insert_drive_file, 
                    color: message.isSentByMe ? Colors.white : const Color(0xff414751),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          documentName,
                          style: TextStyle(
                            fontSize: 12,
                            color: message.isSentByMe ? Colors.white : const Color(0xff414751),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (documentUrl != null)
                          Text(
                            'Tıklayarak indir',
                            style: TextStyle(
                              fontSize: 10,
                              color: message.isSentByMe ? Colors.white70 : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (documentUrl != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.download,
                      color: message.isSentByMe ? Colors.white70 : Colors.grey,
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
