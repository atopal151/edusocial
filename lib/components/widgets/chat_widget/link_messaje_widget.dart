import 'package:edusocial/models/chat_models/chat_detail_model.dart';
import 'package:flutter/material.dart';

class LinkMessageWidget extends StatelessWidget {
  final MessageModel message;

  const LinkMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final linkData = message.messageLink.first; // Birden fazla varsa listeleyebilirsin
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(linkData.linkTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    // URL'yi açmak için launch paketi veya benzeri kullanılabilir
                  },
                  child: Text(
                    linkData.link,
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
          if (message.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(message.message),
            ),
        ],
      ),
    );
  }
}
