import 'package:edusocial/controllers/chat_controllers/chat_detail_controller.dart';
import 'package:edusocial/screens/chat/user_chat/widgets/chat_detail_app_bar.dart';
import 'package:edusocial/screens/chat/user_chat/widgets/chat_detail_body.dart';
// import 'package:edusocial/screens/chat/user_chat/widgets/chat_detail_bottom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusocial/services/language_service.dart';

class UserChatDetailScreen extends StatefulWidget {
  const UserChatDetailScreen({super.key});

  @override
  State<UserChatDetailScreen> createState() => _UserChatDetailScreenState();
}

class _UserChatDetailScreenState extends State<UserChatDetailScreen> {
  late final ChatDetailController chatController;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatDetailController>();
    scrollController = ScrollController();

    final args = Get.arguments as Map<String, dynamic>?;
    debugPrint('🔍 UserChatDetailScreen - Gelen Arguments: $args');

    if (args == null || !args.containsKey('chatId') || !args.containsKey('userDetail')) {
      debugPrint('❌ UserChatDetailScreen - Eksik veya hatalı arguments');
      final languageService = Get.find<LanguageService>();
      Future.microtask(() {
        Get.snackbar(languageService.tr("userChat.errorTitle"), languageService.tr("userChat.userNotFound"));
        Get.back();
      });
      return;
    }

    
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  String formatMemberCount(int count) {
    if (count >= 10000) {
      return '${(count / 1000).floor()}k';
    } else {
      // binlik ayraç eklemek için
      return count.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: const ChatDetailAppBar(),
      body: Obx(() {

        if (chatController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatController.userChatDetail.value == null) {
          final languageService = Get.find<LanguageService>();
          return Center(child: Text(languageService.tr("userChat.userNotLoaded")));
        }

        return const ChatDetailBody();
      }),
      // bottomNavigationBar: const ChatDetailBottom(),
    );
  }
}
