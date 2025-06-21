import 'package:edusocial/components/widgets/chat_widget/message_widget_factory.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/input_fields/message_input_field.dart';
import '../../../controllers/social/chat_detail_controller.dart';

class ChatDetailScreen extends StatelessWidget {
  ChatDetailScreen({super.key});

  final ChatDetailController controller = Get.put(ChatDetailController());
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userDetail = controller.userChatDetail.value;
      final isLoading = controller.isLoading.value;

      // Yükleniyorsa veya kullanıcı detayı yoksa farklı bir UI göster
      if (isLoading && userDetail == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Yükleniyor..."),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      
      // Kullanıcı detayı yüklendiğinde gösterilecek UI
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          surfaceTintColor: const Color(0xffffffff),
          title: InkWell(
            onTap: () {
              if (userDetail?.name != null) {
                // `username` alanı modelde yok, `name` kullanılıyor varsayalım
                // Eğer `username` gerekiyorsa model güncellenmeli.
                profileController.getToPeopleProfileScreen(userDetail!.name);
              }
            },
            child: Row(
              children: [
                Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        final imageUrl = userDetail?.imageUrl;
                        final isImageAvailable = imageUrl != null && imageUrl.isNotEmpty && !imageUrl.endsWith('/0');
                        return CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: isImageAvailable ? NetworkImage(imageUrl) : null,
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
                          color: const Color(0xff65d384), // Online durumu modelde yok, sabit varsayalım
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white, width: 2),
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
                      userDetail?.name ?? 'Bilinmiyor',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff414751)),
                    ),
                    const Text( // Online durumu modelde yok, sabit varsayalım
                      "Çevrimiçi",
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff9ca3ae),
                          fontWeight: FontWeight.w400),
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
                child: ListView.builder(
                  controller: controller.scrollController,
                  itemCount: controller.messages.length,
                  padding: const EdgeInsets.only(bottom: 75),
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return MessageWidgetFactory.buildMessageWidget(message);
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
    if (userDetail == null) {
      Get.snackbar('Hata', 'Kullanıcı bilgileri henüz yüklenmedi!');
      return;
    }

    Get.toNamed('/user_chat_detail', arguments: {
      'chatId': controller.currentChatId.value,
      'userDetail': userDetail,
    });
  }
}
