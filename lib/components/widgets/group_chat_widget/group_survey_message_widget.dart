import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../models/chat_models/group_message_model.dart';
import '../../../controllers/chat_controllers/group_chat_detail_controller.dart';

class GroupSurveyMessageWidget extends StatefulWidget {
  final GroupMessageModel message;
  final GroupChatDetailController controller;

  const GroupSurveyMessageWidget({
    super.key, 
    required this.message,
    required this.controller,
  });

  @override
  State<GroupSurveyMessageWidget> createState() => _GroupSurveyMessageWidgetState();
}

class _GroupSurveyMessageWidgetState extends State<GroupSurveyMessageWidget> {
  final Set<String> selectedOptions = <String>{};

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    
    // Debug: Survey mesajı içeriğini kontrol et
    debugPrint('🔍 Survey Widget Debug:');
    debugPrint('🔍 Message content: "${message.content}"');
    debugPrint('🔍 Message pollOptions: ${message.pollOptions}');
    debugPrint('🔍 Message isMultipleChoice: ${message.isMultipleChoice}');
    debugPrint('🔍 Message surveyId: ${message.surveyId}');
    debugPrint('🔍 Message type: ${message.messageType}');
    
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: message.isSentByMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // 🔹 Kullanıcı Bilgileri
          Row(
            mainAxisAlignment: message.isSentByMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!message.isSentByMe)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 6.0),
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
                  padding: const EdgeInsets.only(left: 6.0, right: 8.0),
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
          
          const SizedBox(height: 4),
          
          // 🔹 Survey Container
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.controller.isCurrentUserAdmin) ...[
                GestureDetector(
                  onTap: () {
                    widget.controller.pinMessage(message.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.push_pin,
                      size: 16,
                      color: message.isPinned 
                          ? const Color(0xff414751)
                          : const Color(0xff9ca3ae),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              GestureDetector(
                onLongPress: () {
                  _showPinOptions(context);
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  margin: EdgeInsets.only(
                    left: message.isSentByMe ? 50 : 0,
                    right: message.isSentByMe ? 0 : 50,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      
                      // Survey sorusu
                      Text(
                        message.content,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff414751),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Survey seçenekleri
                      if (message.pollOptions != null)
                        ...message.pollOptions!.map((option) => 
                          _buildSurveyOption(option)
                        ).toList(),
                      
                      const SizedBox(height: 8),
                      
                      // Survey zamanı
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Color(0xff9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.controller.isCurrentUserAdmin) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    widget.controller.pinMessage(message.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.push_pin,
                      size: 16,
                      color: message.isPinned 
                          ? const Color(0xff414751)
                          : const Color(0xff9ca3ae),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyOption(String option) {
    final message = widget.message;
    final isMultipleChoice = message.isMultipleChoice ?? false;
    
    // Choice ID'sini bul
    int? choiceId;
    double percentage = 0.0;
    bool isSelected = false;
    
    if (message.choiceIds != null && message.pollOptions != null) {
      final index = message.pollOptions!.indexOf(option);
      if (index >= 0 && index < message.choiceIds!.length) {
        choiceId = message.choiceIds![index];
        
        // API'den gelen survey verilerini kontrol et
        if (message.surveyData != null && message.surveyData!['choices'] != null) {
          final choices = message.surveyData!['choices'] as List<dynamic>;
          debugPrint('🔍 Survey choices data: $choices');
          for (var choice in choices) {
            if (choice['id'] == choiceId) {
              percentage = (choice['percentage'] ?? 0.0).toDouble();
              isSelected = choice['is_selected'] ?? false;
              debugPrint('🔍 Choice $choiceId - percentage: $percentage, isSelected: $isSelected');
              break;
            }
          }
        }
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Direkt survey cevaplama işlemi
          final message = widget.message;
          final controller = widget.controller;
          final surveyId = message.surveyId ?? 1;
          
          if (choiceId != null) {
            controller.answerSurvey(surveyId, [choiceId.toString()]);
          } else {
            controller.answerSurvey(surveyId, [option]);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:  Color(0xffffffff),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:  Color(0xff9ca3ae).withAlpha(30),
              width:  1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMultipleChoice 
                  ? (isSelected ? Icons.check_box : Icons.check_box_outline_blank)
                  : (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                color: Color(0xffED7474),
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Color(0xff414751),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (percentage > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Color(0xffe0e0e0),
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xffED7474)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Color(0xff666666),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  widget.message.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: Colors.amber,
                ),
                title: Text(
                  widget.message.isPinned ? 'Unpin Message' : 'Pin Message',
                  style: GoogleFonts.inter(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.controller.pinMessage(widget.message.id);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.blue),
                title: Text(
                  'Copy Message',
                  style: GoogleFonts.inter(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Copy message to clipboard
                  // You can implement clipboard functionality here
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
