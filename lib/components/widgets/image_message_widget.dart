import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/chat_detail_model.dart';

class ImageMessageWidget extends StatelessWidget {
  final MessageModel message;

  const ImageMessageWidget({super.key, required this.message});

  bool isLocalFile(String path) {
    return path.startsWith('/'); // iOS/Android dosya yolu böyle başlar
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
    );
  }
}
