import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/chat_models/group_message_model.dart';
import '../../../services/language_service.dart';

class GroupPollMessageWidget extends StatelessWidget {
  final GroupMessageModel message;
  final RxMap<String, int> pollVotes;
  final RxString selectedOption;
  final Function(String) onVote;

  const GroupPollMessageWidget({
    super.key,
    required this.message,
    required this.pollVotes,
    required this.selectedOption,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: message.isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 🔹 Kullanıcı Bilgileri (Saat kaldırıldı)
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
              '@${message.username}',
              style: const TextStyle(fontSize: 10, color: Color(0xff414751)),
            ),
            if (message.isSentByMe)
              Padding(
                padding: const EdgeInsets.all( 8.0),
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
          padding: const EdgeInsets.only(left: 16.0,right: 16.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Align(
              alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
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
                    // Poll başlığı
                    Row(
                      children: [
                        Icon(
                          Icons.poll,
                          color: message.isSentByMe ? Colors.white : const Color(0xff000000),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message.content,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: message.isSentByMe ? Colors.white : const Color(0xff000000),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Poll seçenekleri
                    if (message.pollOptions != null) ...[
                      ...message.pollOptions!.map((option) {
                        final isSelected = selectedOption.value == option;
                        final voteCount = pollVotes[option] ?? 0;
                        
                        return Obx(() => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => onVote(option),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (message.isSentByMe 
                                        ? Colors.white.withValues(alpha: 0.3)
                                        : const Color(0xFFE3F2FD))
                                    : (message.isSentByMe 
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : const Color(0xFFF5F5F5)),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected 
                                      ? (message.isSentByMe 
                                          ? Colors.white
                                          : const Color(0xFF2196F3))
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: isSelected
                                        ? (message.isSentByMe 
                                            ? Colors.white
                                            : const Color(0xFF2196F3))
                                        : (message.isSentByMe 
                                            ? Colors.white.withValues(alpha: 0.7)
                                            : Colors.grey),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: message.isSentByMe ? Colors.white : const Color(0xff000000),
                                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (voteCount > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: message.isSentByMe 
                                            ? Colors.white.withValues(alpha: 0.2)
                                            : const Color(0xFFEEEEEE),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        voteCount.toString(),
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: message.isSentByMe 
                                              ? Colors.white.withValues(alpha: 0.9)
                                              : const Color(0xff666666),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ));
                      }).toList(),
                    ],
                    
                    // Saat bilgisi mesaj balonunun içinde sağ altta
                    const SizedBox(height: 4),
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
