import 'package:edusocial/components/widgets/chat_widget/message_widget_factory.dart';
import 'package:edusocial/components/widgets/general_loading_indicator.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../components/input_fields/message_input_field.dart';
import '../../../controllers/chat_controllers/chat_detail_controller.dart';
import '../../../services/language_service.dart';

class ChatDetailScreen extends StatelessWidget {
  ChatDetailScreen({super.key});

  final ChatDetailController controller = Get.put(ChatDetailController());
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Obx(() {
      final userDetail = controller.userChatDetail.value;
      final isLoading = controller.isLoading.value;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          surfaceTintColor: const Color(0xffffffff),
          title: InkWell(
            onTap: () {
              if (controller.username.value.isNotEmpty) {
                profileController
                    .getToPeopleProfileScreen(controller.username.value);
              }
            },
            child: Row(
              children: [
                Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        final imageUrl = controller.avatarUrl.value;
                        final isImageAvailable =
                            imageUrl.isNotEmpty && !imageUrl.endsWith('/0');
                        return CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xffd9d9d9),
                          backgroundImage:
                              isImageAvailable ? NetworkImage(imageUrl) : null,
                          child: !isImageAvailable
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 20)
                              : null,
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: controller.isOnline.value
                              ? const Color(0xff65d384)
                              : const Color(0xffd9d9d9),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Color(0xffffffff), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.name.value,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff272727)),
                    ),
                    Text(
                      controller.isOnline.value ? languageService.tr("chat.chatDetail.onlineStatus.online") : languageService.tr("chat.chatDetail.onlineStatus.offline"),
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Color(0xff9ca3ae),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            InkWell(
              onTap: () => _onUserDetailTap(userDetail),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.more_horiz),
              ),
            ),
          ],
        ),
        body: Container(
          color: const Color(0xfffafafa),
          child: Column(
            children: [
              Expanded(
                child: (isLoading && controller.messages.isEmpty)
                    ? Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: GeneralLoadingIndicator(
                            size: 32,
                            showIcon: false,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: controller.scrollController,
                        itemCount: controller.messages.length,
                        padding: const EdgeInsets.only(bottom: 75),
                        itemBuilder: (context, index) {
                          final message = controller.messages[index];
                          return MessageWidgetFactory.buildMessageWidget(
                              message);
                        },
                      ),
              ),
              Container(
                decoration: const BoxDecoration(color: Color(0xffffffff)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16, top: 8, bottom: 20),
                  child: MessageInputField(controller: controller),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _onUserDetailTap(dynamic userDetail) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    if (userDetail == null) {
      Get.snackbar(languageService.tr("chat.chatDetail.error.title"), languageService.tr("chat.chatDetail.error.userInfoNotLoaded"));
      return;
    }

    Get.toNamed('/user_chat_detail', arguments: {
      'chatId': controller.currentChatId.value,
      'userDetail': userDetail,
    });
  }
}
