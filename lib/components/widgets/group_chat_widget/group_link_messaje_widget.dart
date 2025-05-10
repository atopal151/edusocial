import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/group_models/group_message_model.dart';

class GroupLinkMessageWidget extends StatelessWidget {
  final GroupMessageModel message;

  const GroupLinkMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: message.isSentByMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          /// İsim + Saat + Profil Fotoğrafı Satırı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: message.isSentByMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!message.isSentByMe) ...[
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(message.profileImage),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${message.name} ${message.surname}",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF414751),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  formattedTime,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.grey,
                  ),
                ),
                if (message.isSentByMe) ...[
                  const SizedBox(width: 8),
                  Text(
                    "${message.name} ${message.surname}",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF414751),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(message.profileImage),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 6),

          /// Link Mesaj Balonu
          Align(
            alignment: message.isSentByMe
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => launchUrl(Uri.parse(message.content)),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
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
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
