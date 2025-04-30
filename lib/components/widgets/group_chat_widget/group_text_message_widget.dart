import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/group_message_model.dart';

class GroupTextMessageWidget extends StatelessWidget {
  final GroupMessageModel message;

  const GroupTextMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // 📌 `DateTime` → `String` formatına çeviriyoruz
    String formattedTime = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: message.isSentByMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          /// PROFIL FOTOĞRAFI
          ///
          SizedBox(
            height: 4,
          ),
          if(message.isSentByMe==false)
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Row(
              mainAxisAlignment: message.isSentByMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(message.profileImage),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${message.name} ${message.surname}",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF414751),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formattedTime, // Buraya mesaj saatini ekliyoruz
                  style: GoogleFonts.inter(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ),
          // 🔹 **Mesaj Balonu**
          Padding(
            padding: const EdgeInsets.only(left:43.0),
            child: Align(
              alignment: message.isSentByMe
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 12, bottom: 12),
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
                      color: message.isSentByMe ? Colors.white : Colors.black,
                      fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
