import 'package:edusocial/controllers/group_controller/group_controller.dart';
import 'package:edusocial/controllers/home_controller.dart';
import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:edusocial/controllers/topics_controller.dart';
import 'package:edusocial/controllers/social/chat_controller.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/controllers/notification_controller.dart';
import 'package:edusocial/controllers/appbar_controller.dart';
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

  /// Verilerin yüklenip yüklenmediğini kontrol et ve gerekirse yükle
  void _checkAndLoadData() {
    debugPrint("🔍 Veri kontrolü yapılıyor...");
    
    // ProfileController kontrolü
    try {
      final profileController = Get.find<ProfileController>();
      if (profileController.profile.value == null) {
        debugPrint("🔄 Profil verisi yüklenmemiş, yükleniyor...");
        profileController.loadProfile();
      }
    } catch (e) {
      debugPrint("❌ ProfileController hatası: $e");
    }
    
    // GroupController kontrolü
    try {
      final groupController = Get.find<GroupController>();
      if (groupController.userGroups.isEmpty) {
        debugPrint("🔄 Grup verileri yüklenmemiş, yükleniyor...");
        groupController.fetchUserGroups();
        groupController.fetchAllGroups();
        groupController.fetchSuggestionGroups();
        groupController.fetchGroupAreas();
      }
    } catch (e) {
      debugPrint("❌ GroupController hatası: $e");
    }
    
    // NotificationController kontrolü
    try {
      final notificationController = Get.find<NotificationController>();
      if (notificationController.notifications.isEmpty) {
        debugPrint("🔄 Bildirimler yüklenmemiş, yükleniyor...");
        notificationController.fetchNotifications();
      }
    } catch (e) {
      debugPrint("❌ NotificationController hatası: $e");
    }
    
    // AppBarController kontrolü
    try {
      final appBarController = Get.find<AppBarController>();
      if (appBarController.profileImagePath.value.isEmpty) {
        debugPrint("🔄 AppBar resmi yüklenmemiş, yükleniyor...");
        appBarController.fetchAndSetProfileImage();
      }
    } catch (e) {
      debugPrint("❌ AppBarController hatası: $e");
    }
    
    // StoryController kontrolü
    try {
      final storyController = Get.find<StoryController>();
      if (storyController.otherStories.isEmpty && storyController.myStory.value == null) {
        debugPrint("🔄 Story'ler yüklenmemiş, yükleniyor...");
        storyController.fetchStories();
      }
    } catch (e) {
      debugPrint("❌ StoryController hatası: $e");
    }
    
    // PostController kontrolü
    try {
      final postController = Get.find<PostController>();
      if (postController.postHomeList.isEmpty) {
        debugPrint("🔄 Postlar yüklenmemiş, yükleniyor...");
        postController.fetchHomePosts();
      }
    } catch (e) {
      debugPrint("❌ PostController hatası: $e");
    }
  }

  /// Socket bağlantısını başlat
  void _initializeSocket() {
    try {
      final socketService = Get.find<SocketService>();
      final token = GetStorage().read('token');
      
      if (token != null && token.isNotEmpty) {
        debugPrint('🔌 Socket bağlantısı başlatılıyor...');
        socketService.connect(token);
      } else {
        debugPrint('⚠️ Token bulunamadı, socket bağlantısı kurulamıyor.');
      }
    } catch (e) {
      debugPrint('❌ Socket başlatma hatası: $e');
    }
  }

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

    // Socket bağlantısını başlat
    Future.delayed(const Duration(milliseconds: 500), () {
      _initializeSocket();
    });

    // Verilerin yüklenip yüklenmediğini kontrol et
    Future.delayed(Duration(milliseconds: 100), () {
      _checkAndLoadData();
    });

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
