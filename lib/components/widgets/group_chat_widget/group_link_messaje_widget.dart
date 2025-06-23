import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/chat_models/group_message_model.dart';

class GroupLinkMessageWidget extends StatelessWidget {
  final GroupMessageModel message;

  const GroupLinkMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
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
          alignment:
              message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onTap: () async {
              try {
                debugPrint("🔗 GroupLink - Link açma deneniyor: ${message.content}");
                
                // URL'yi temizle ve kontrol et
                String cleanLink = message.content.trim();
                if (!cleanLink.startsWith('http://') && !cleanLink.startsWith('https://')) {
                  cleanLink = 'https://$cleanLink';
                }
                
                debugPrint("🔗 GroupLink - Temizlenmiş link: $cleanLink");
                
                final Uri url = Uri.parse(cleanLink);
                debugPrint("🔗 GroupLink - Parsed URL: $url");
                
                // URL'nin açılabilir olup olmadığını kontrol et
                final canLaunch = await canLaunchUrl(url);
                debugPrint("🔗 GroupLink - canLaunchUrl sonucu: $canLaunch");
                
                if (canLaunch) {
                  debugPrint("🔗 GroupLink - URL açılıyor...");
                  final result = await launchUrl(
                    url, 
                    mode: LaunchMode.externalApplication
                  );
                  debugPrint("🔗 GroupLink - launchUrl sonucu: $result");
                  
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
                  debugPrint("🔗 GroupLink - URL açılamıyor: $url");
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
                debugPrint("🔗 GroupLink - Link açma hatası: $e");
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
              child: Text(
                message.content,
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
