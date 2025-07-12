import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
    final question = parts.isNotEmpty ? parts.first.trim() : "Anket";
    final options =
        parts.length > 1 ? parts.last.split(',').map((e) => e.trim()).toList() : [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Anket ikonu ve başlık
                Row(
                  children: [
                    Icon(
                      Icons.poll,
                      color: message.isMe ? Colors.white : const Color(0xFFff7c7c),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "ANKET",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: message.isMe ? Colors.white : const Color(0xFFff7c7c),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Anket sorusu
                Text(
                  question,
                  style: GoogleFonts.inter(
                    color: message.isMe ? Colors.white : const Color(0xff000000),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Anket seçenekleri
                ...options.map((option) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: message.isMe 
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.radio_button_unchecked,
                        size: 16,
                        color: message.isMe 
                            ? Colors.white
                            : const Color(0xff8E8E93),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          option,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: message.isMe 
                                ? Colors.white
                                : const Color(0xff000000),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
                // Saat bilgisi
                const SizedBox(height: 4),
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
