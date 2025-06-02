import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/chat_models/group_message_model.dart';

class GroupImageMessageWidget extends StatelessWidget {
  final GroupMessageModel message;

  const GroupImageMessageWidget({super.key, required this.message});

  bool isLocalFile(String path) {
    return path.startsWith('/'); // iOS/Android dosya yolu böyle başlar
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm').format(message.timestamp);
    return Align(
      alignment:
          message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Column(
           crossAxisAlignment:
              message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if(message.isSentByMe==false)
            Row(
               mainAxisAlignment:
                  message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: isLocalFile(message.content)
                    ? Image.file(
                        File(message.content),
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        message.content,
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
