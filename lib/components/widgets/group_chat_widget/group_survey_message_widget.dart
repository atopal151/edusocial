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
    final controller = widget.controller;
    
    // Debug: Survey mesajı içeriğini kontrol et
    debugPrint('🔍 Survey Widget Debug:');
    debugPrint('🔍 Message content: "${message.content}"');
    debugPrint('🔍 Message pollOptions: ${message.pollOptions}');
    debugPrint('🔍 Message isMultipleChoice: ${message.isMultipleChoice}');
    debugPrint('🔍 Message surveyId: ${message.surveyId}');
    debugPrint('🔍 Message type: ${message.messageType}');
    
    return Column(
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
        Container(
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
      ],
    );
  }

  Widget _buildSurveyOption(String option) {
    final message = widget.message;
    final controller = widget.controller;
    final isMultipleChoice = message.isMultipleChoice ?? false;
    
    // Choice ID'sini bul
    int? choiceId;
    if (message.choiceIds != null && message.pollOptions != null) {
      final index = message.pollOptions!.indexOf(option);
      if (index >= 0 && index < message.choiceIds!.length) {
        choiceId = message.choiceIds![index];
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Survey cevaplama işlemi
          if (isMultipleChoice) {
            _showMultipleChoiceDialog(option, choiceId);
          } else {
            _showSurveyAnswerDialog(option, choiceId);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xff9ca3ae).withAlpha(30)),
          ),
          child: Row(
            children: [
              Icon(
                isMultipleChoice ? Icons.check_box_outline_blank : Icons.radio_button_unchecked,
                color: Color(0xffED7474),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  option,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Color(0xff414751),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMultipleChoiceDialog(String selectedOption, int? choiceId) {
    final message = widget.message;
    final controller = widget.controller;
    
    Get.dialog(
      AlertDialog(
        title: Text('Çoktan Seçmeli Anket'),
        content: Text('"$selectedOption" seçeneğini seçmek istediğinizden emin misiniz?\n\nDiğer seçenekleri de seçebilirsiniz.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              final surveyId = message.surveyId ?? 1;
              if (choiceId != null) {
                controller.answerSurvey(surveyId, [choiceId.toString()]);
              } else {
                controller.answerSurvey(surveyId, [selectedOption]);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffED7474),
              foregroundColor: Colors.white,
            ),
            child: Text('Seç'),
          ),
        ],
      ),
    );
  }

  void _showSurveyAnswerDialog(String selectedOption, int? choiceId) {
    final message = widget.message;
    final controller = widget.controller;
    
    Get.dialog(
      AlertDialog(
        title: Text('Anket Cevabı'),
        content: Text('"$selectedOption" seçeneğini seçmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              final surveyId = message.surveyId ?? 1;
              if (choiceId != null) {
                controller.answerSurvey(surveyId, [choiceId.toString()]);
              } else {
                controller.answerSurvey(surveyId, [selectedOption]);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffED7474),
              foregroundColor: Colors.white,
            ),
            child: Text('Onayla'),
          ),
        ],
      ),
    );
  }
}
