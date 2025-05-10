import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/group_models/group_message_model.dart';

class GroupDocumentMessageWidget extends StatelessWidget {
  final GroupMessageModel message;

  const GroupDocumentMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm').format(message.timestamp);
    return Align(
      alignment:
          message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: message.isSentByMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if(message.isSentByMe==false)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12),
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
          SizedBox(
            height: 5,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xfff4f4f5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //if(message.isSentByMe==false)

                Icon(Icons.insert_drive_file, color: Color(0xff414751)),
                SizedBox(width: 10),
                Flexible(
                  child: Text(
                    message.content.split('/').last, // dosya adı
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
