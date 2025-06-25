import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:io';

import '../../controllers/social/chat_detail_controller.dart';

class MessageInputField extends StatefulWidget {
  final ChatDetailController controller;

  const MessageInputField({
    super.key,
    required this.controller,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  late TextEditingController messageController;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xfffafafa),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seçilen dosyaların önizlemesi
          Obx(() {
            if (widget.controller.selectedFiles.isNotEmpty) {
              return Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    ...widget.controller.selectedFiles.map((file) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _buildFilePreview(file),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.path.split('/').last,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, size: 20),
                                onPressed: () {
                                  widget.controller.selectedFiles.remove(file);
                                },
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          }),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: widget.controller.isSendingMessage.value
                      ? null
                      : () {
                          widget.controller.pickDocument();
                        },
                  child: SvgPicture.asset(
                    "images/icons/selected_document.svg",
                    colorFilter: ColorFilter.mode(
                      widget.controller.isSendingMessage.value
                          ? Color(0xffe5e5e5)
                          : Color(0xffc9c9c9),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: widget.controller.selectedFiles.isNotEmpty
                        ? "Dosya seçildi. Mesaj yazabilir veya direkt gönderebilirsiniz..."
                        : "Bir mesaj yazınız... ",
                    hintStyle:
                        TextStyle(color: Color(0xff9ca3ae), fontSize: 13.28),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) async {
                    if (value.isNotEmpty ||
                        widget.controller.selectedFiles.isNotEmpty) {
                      await widget.controller.sendMessage(value);
                      messageController.clear();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: widget.controller.isSendingMessage.value
                      ? null
                      : () {
                          widget.controller.openPollBottomSheet();
                        },
                  child: SvgPicture.asset(
                    "images/icons/poll_icon.svg",
                    colorFilter: ColorFilter.mode(
                      widget.controller.isSendingMessage.value
                          ? Color(0xffe5e5e5)
                          : Color(0xffc9c9c9),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: widget.controller.isSendingMessage.value
                      ? null
                      : () {
                          widget.controller.pickImageFromGallery();
                        },
                  child: SvgPicture.asset(
                    "images/icons/camera.svg",
                    colorFilter: ColorFilter.mode(
                      widget.controller.isSendingMessage.value
                          ? Color(0xffe5e5e5)
                          : Color(0xffc9c9c9),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF7743), Color(0xFFEF5050)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'images/icons/send_icon.svg',
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
                onPressed: widget.controller.isSendingMessage.value
                    ? null
                    : () async {
                        if (messageController.text.isNotEmpty ||
                            widget.controller.selectedFiles.isNotEmpty) {
                          await widget.controller
                              .sendMessage(messageController.text);
                          messageController.clear();
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(File file) {
    final fileName = file.path.toLowerCase();

    if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif') ||
        fileName.endsWith('.webp')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.image, color: Colors.grey[400]),
        ),
      );
    } else if (fileName.endsWith('.pdf')) {
      return Icon(Icons.picture_as_pdf, color: Colors.red[400], size: 30);
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      return Icon(Icons.description, color: Colors.blue[400], size: 30);
    } else if (fileName.endsWith('.txt')) {
      return Icon(Icons.text_snippet, color: Colors.grey[400], size: 30);
    } else {
      return Icon(Icons.insert_drive_file, color: Colors.grey[400], size: 30);
    }
  }
}
