import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/chat_models/chat_detail_model.dart';

class TextMessageWidget extends StatelessWidget {
  final MessageModel message;

  const TextMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // 📌 `DateTime` → `String` formatına çeviriyoruz
    String formattedTime = DateFormat('HH:mm')
        .format(DateTime.tryParse(message.createdAt) ?? DateTime.now());

    return Column(
      crossAxisAlignment:
          message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (message.isMe == true)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 🔹 **Mesaj Saati**
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  formattedTime, // Buraya mesaj saatini ekliyoruz
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
              Text(
                '${message.sender.name} ${message.sender.surname}', // Buraya mesaj saatini ekliyoruz
                style: TextStyle(fontSize: 10, color: Color(0xff414751)),
              ),
              SizedBox(
                width: 5,
              ),
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

        if (message.isMe == false)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                '${message.sender.name} ${message.sender.surname}', // Buraya mesaj saatini ekliyoruz
                style: TextStyle(fontSize: 10, color: Color(0xff414751)),
              ),
              SizedBox(
                width: 5,
              ),

              // 🔹 **Mesaj Saati**
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  formattedTime, // Buraya mesaj saatini ekliyoruz
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),

        // 🔹 **Mesaj Balonu**
        Align(
          alignment:
              message.isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 35),
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
                  color: message.isMe ? Colors.white : Colors.black,
                  fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
