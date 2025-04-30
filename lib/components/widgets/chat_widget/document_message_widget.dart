import 'package:flutter/material.dart';
import '../../../models/chat_detail_model.dart';

class DocumentMessageWidget extends StatelessWidget {
  final MessageModel message;

  const DocumentMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xfff4f4f5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    );
  }
}
