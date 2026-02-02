import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/chat_controllers/group_chat_detail_controller.dart';
import '../../models/chat_models/group_message_model.dart';
import '../../services/language_service.dart';

class GroupMessageInputField extends StatefulWidget {
  const GroupMessageInputField({super.key});

  @override
  State<GroupMessageInputField> createState() => _GroupMessageInputFieldState();
}

class _GroupMessageInputFieldState extends State<GroupMessageInputField> {
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

  @override
  Widget build(BuildContext context) {
    final GroupChatDetailController controller = Get.find();
    final LanguageService languageService = Get.find<LanguageService>();

    return Container(
      decoration: BoxDecoration(
        color: Color(0xfffafafa),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Yanıtlanacak mesaj önizlemesi (grup reply)
          Obx(() {
            final replyingTo = controller.replyingToMessage.value;
            if (replyingTo != null) {
              final hasImage = replyingTo.messageType == GroupMessageType.image ||
                  (replyingTo.media != null && replyingTo.media!.isNotEmpty);
              final hasLink = replyingTo.messageType == GroupMessageType.link ||
                  (replyingTo.links != null && replyingTo.links!.isNotEmpty);
              final previewText = hasImage
                  ? '📸 ${languageService.tr("chat.replyPhoto")}'
                  : hasLink
                      ? '🔗 ${languageService.tr("chat.replyLink")}'
                      : replyingTo.replyPreviewDisplayText;
              final imageUrl = replyingTo.replyPreviewImageUrl;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xfff0f0f0),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  border: Border(bottom: BorderSide(color: Color(0xffe5e7eb), width: 1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.reply, size: 18, color: Color(0xffef5050)),
                    const SizedBox(width: 8),
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            imageUrl,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 36,
                              height: 36,
                              color: Colors.grey.shade300,
                              child: Icon(Icons.image, size: 20, color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            languageService.tr("comments.reply.replyTo"),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff6b7280),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            previewText,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xff374151),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: Color(0xff6b7280)),
                      onPressed: () => controller.clearReplyingTo(),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        // Seçilen dosyaların önizlemesi
           Obx(() {
            if (controller.selectedFiles.isNotEmpty) {
              return Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    ...controller.selectedFiles.map((file) => Padding(
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
                                  controller.selectedFiles.remove(file);
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

        // Ana input alanı ve butonlar
        Row(
          children: [
            // Document picker butonu
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: controller.isSendingMessage.value
                    ? null
                    : () {
                        controller.pickDocument();
                      },
                child: SvgPicture.asset(
                  "images/icons/selected_document.svg",
                  colorFilter: ColorFilter.mode(
                    controller.isSendingMessage.value 
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
                textInputAction: TextInputAction.send,
                enableSuggestions: true,
                autocorrect: true,
                decoration: InputDecoration(
                  hintText: languageService.tr("chat.groupChat.messagePlaceholder"),
                  hintStyle: TextStyle(color: Color(0xff9ca3ae), fontSize: 13.28),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSubmitted: (value) async {
                  if (value.isNotEmpty || controller.selectedFiles.isNotEmpty) {
                    await controller.sendMessage(value);
                    messageController.clear();
                  }
                },
              ),
            ),
            
            // Camera butonu
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: controller.isSendingMessage.value
                    ? null
                    : () {
                        controller.pickImageFromGallery();
                      },
                child: SvgPicture.asset(
                  "images/icons/camera.svg",
                  colorFilter: ColorFilter.mode(
                    controller.isSendingMessage.value 
                        ? Color(0xffe5e5e5) 
                        : Color(0xffc9c9c9),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            
            // Poll butonu
            Padding(
             padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: controller.isSendingMessage.value
                    ? null
                    : () {
                        controller.openSurveyBottomSheet();
                      },
                child: SvgPicture.asset(
                  "images/icons/poll_icon.svg",
                  colorFilter: ColorFilter.mode(
                    controller.isSendingMessage.value 
                        ? Color(0xffe5e5e5) 
                        : Color(0xffc9c9c9),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            
           
            
            // Send butonu
            Obx(() => IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF7743),
                      Color(0xFFEF5050)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Center(
                  child: controller.isSendingMessage.value
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : SvgPicture.asset(
                          'images/icons/send_icon.svg',
                          width: 18,
                          height: 18,
                        ),
                ),
              ),
              onPressed: controller.isSendingMessage.value
                  ? null
                  : () async {
                      if (messageController.text.isNotEmpty ||
                          controller.selectedFiles.isNotEmpty) {
                        await controller.sendMessage(messageController.text);
                        messageController.clear();
                      }
                    },
            )),
          ],
        ),
        ],
      ),
    );
  }
}

Widget buildGroupMessageInputField() {
  return GroupMessageInputField();
}
