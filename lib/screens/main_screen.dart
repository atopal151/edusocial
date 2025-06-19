import 'package:edusocial/controllers/group_controller/group_controller.dart';
import 'package:edusocial/controllers/home_controller.dart';
import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:edusocial/controllers/topics_controller.dart';
import 'package:edusocial/controllers/social/chat_controller.dart';
import 'package:edusocial/screens/entry/entry_screen.dart';
import 'package:edusocial/screens/match/match_result_screen.dart';
import 'package:edusocial/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/entry_controller.dart';
import '../controllers/entry_detail_controller.dart';
import '../controllers/event_controller.dart';
import '../controllers/nav_bar_controller.dart';
import '../controllers/search_text_controller.dart';
import '../screens/home/home_screen.dart';
import 'chat/user_chat/chat_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../utils/navbar_menu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find();

    Get.put(EventController());
    Get.put(EntryDetailController());
    Get.put(SearchTextController());
    Get.put(HomeController());
    Get.put(EntryController());
    Get.put(StoryController());
    Get.put(PostController());
    Get.put(GroupController());
    Get.put(TopicsController());
    Get.put(ChatController());

    // 🌐 Socket Service
    final socketService = Get.put(SocketService());

    // Token kontrolü ve socket bağlantısı
    final token = GetStorage().read('token');
    if (token != null && token.isNotEmpty) {
      debugPrint('🔑 Token bulundu, socket bağlantısı başlatılıyor...');
      // Token'ı temizle ve kontrol et
      final cleanToken = token.trim();
      if (cleanToken.length > 10) { // Minimum token uzunluğu kontrolü
        // Socket bağlantısını başlat
        Future.delayed(const Duration(milliseconds: 500), () {
          socketService.connectSocket(cleanToken);
        });
      } else {
        debugPrint('⚠️ Token geçersiz uzunlukta: ${cleanToken.length}');
      }
    } else {
      debugPrint('⚠️ Token bulunamadı, socket bağlantısı kurulamıyor.');
    }

    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: navigationController.selectedIndex.value,
          children: [
            HomeScreen(),
            ChatListScreen(),
            MatchResultScreen(),
            EntryScreen(),
            ProfileScreen(),
          ],
        );
      }),
      bottomNavigationBar: NavbarMenu(),
    );
  }
}
