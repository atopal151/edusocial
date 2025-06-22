import 'package:flutter/material.dart';
import '../../../models/chat_models/chat_detail_model.dart';
import '../../../utils/date_format.dart';

class TextMessageWidget extends StatelessWidget {
  final MessageModel message;

  const TextMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: Colors.grey[300],
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
              style: const TextStyle(fontSize: 10, color: Color(0xff414751)),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                formatSimpleDateClock(message.createdAt),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
            if (message.isMe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
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
            child: Text(
              message.message,
              style: TextStyle(
                color: message.isMe ? Colors.white : const Color(0xff414751),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 