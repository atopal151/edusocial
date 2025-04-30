import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/chat_detail_model.dart';


class TextMessageWidget extends StatelessWidget {
  final MessageModel message;

  const TextMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {

    // 📌 `DateTime` → `String` formatına çeviriyoruz
    String formattedTime = DateFormat('HH:mm').format(message.timestamp);
    
    return Column(
      crossAxisAlignment: message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // 🔹 **Mesaj Saati**
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            formattedTime, // Buraya mesaj saatini ekliyoruz
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),

        // 🔹 **Mesaj Balonu**
        Align(
          alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isSentByMe ? const Color(0xFFFF7C7C) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: message.isSentByMe ? const Radius.circular(20) : const Radius.circular(0),
                topRight: message.isSentByMe ? const Radius.circular(0) : const Radius.circular(20),
                bottomLeft: const Radius.circular(20),
                bottomRight: const Radius.circular(20),
              ),
              
            ),
            child: Text(
              message.content,
              style: TextStyle(color: message.isSentByMe ? Colors.white : Colors.black,fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
