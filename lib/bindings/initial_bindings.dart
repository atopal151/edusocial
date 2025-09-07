import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:edusocial/controllers/login_controller.dart';
import 'package:edusocial/controllers/match_controller.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/controllers/onboarding_controller.dart';
import 'package:edusocial/controllers/event_controller.dart';
import 'package:edusocial/controllers/entry_detail_controller.dart';
import 'package:edusocial/controllers/search_text_controller.dart';
import 'package:edusocial/controllers/home_controller.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:edusocial/controllers/entry_controller.dart';
import 'package:edusocial/controllers/group_controller/group_controller.dart';
import 'package:edusocial/controllers/appbar_controller.dart';
import 'package:edusocial/controllers/topics_controller.dart';
import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/controllers/profile_update_controller.dart';
import 'package:edusocial/controllers/notification_controller.dart';
import '../controllers/nav_bar_controller.dart';
import '../controllers/chat_controllers/chat_controller.dart';
import '../controllers/global_sliding_notification_controller.dart';
import '../services/socket_services.dart';
import '../services/translation_service.dart';
import '../services/language_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Global controller'lar (uygulama boyunca hep açık kalacaklar)
    Get.put(LoginController(), permanent: true);
    Get.put(MatchController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
    Get.put(OnboardingController(), permanent: true);
    Get.put(AppBarController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    Get.put(GroupController(), permanent: true);
    Get.put(GetMaterialController(), permanent: true);
    Get.put(StoryController(), permanent: true);
    Get.put(SocketService(), permanent: true);
    Get.put(NotificationController(), permanent: true);
    Get.put(GlobalSlidingNotificationController(), permanent: true);
    Get.put(TranslationService(), permanent: true);
    Get.put(LanguageService(), permanent: true);
    
    // Socket durumunu kontrol et (binding'ler yüklendikten sonra)
    try {
      final socketService = Get.find<SocketService>();
      socketService.checkInitialSocketStatus();
    } catch (e) {
      debugPrint('⚠️ SocketService kontrol edilemedi: $e');
    }

    // İhtiyaç anında yüklenecek olanlar (lazy yükleme)
    Get.lazyPut(() => EventController());
    Get.lazyPut(() => EntryDetailController());
    Get.lazyPut(() => SearchTextController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => StoryController());
    Get.lazyPut(() => EntryController());
    Get.lazyPut(() => TopicsController());
    Get.lazyPut(() => PostController());
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => ProfileUpdateController());
  }
}
