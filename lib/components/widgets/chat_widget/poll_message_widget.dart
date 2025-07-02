import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/chat_models/chat_detail_model.dart';
import '../../../services/language_service.dart';

class PollMessageWidget extends StatelessWidget {
  final MessageModel message;

  const PollMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    // Mesajın içinde "[POLL] Anket başlığı - Seçenek1, Seçenek2" gibi bir yapı varsa parçalayabilirsin
    final content = message.message.replaceFirst('[POLL]', '').trim();
    final parts = content.split('-');
    final question = parts.isNotEmpty ? parts.first.trim() : languageService.tr("chat.poll.defaultTitle");
    final options =
        parts.length > 1 ? parts.last.split(',').map((e) => e.trim()).toList() : [];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...options.map((option) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.radio_button_unchecked, size: 16),
                        const SizedBox(width: 6),
                        Text(option, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
