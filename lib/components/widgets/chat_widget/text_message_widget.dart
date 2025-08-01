import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/chat_models/chat_detail_model.dart';

class TextMessageWidget extends StatelessWidget {
  final MessageModel message;

  const TextMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
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
             
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: GoogleFonts.inter(
                    color: message.isMe ? Colors.white : const Color(0xff000000),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                // Saat bilgisi mesaj balonunun içinde sağ altta
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: message.isMe 
                            ? Colors.white.withAlpha(80)
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