import 'package:get/get.dart';
import 'package:edusocial/controllers/login_controller.dart';
import 'package:edusocial/controllers/social/match_controller.dart';
import 'package:edusocial/controllers/profile_controller.dart';
import 'package:edusocial/controllers/onboarding_controller.dart';
import 'package:edusocial/controllers/event_controller.dart';
import 'package:edusocial/controllers/entry_detail_controller.dart';
import 'package:edusocial/controllers/search_text_controller.dart';
import 'package:edusocial/controllers/home_controller.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:edusocial/controllers/entry_controller.dart';
import 'package:edusocial/controllers/group_controller.dart';
import 'package:edusocial/controllers/appbar_controller.dart';
import 'package:edusocial/controllers/topics_controller.dart';
import 'package:edusocial/controllers/post_controller.dart';
import 'package:edusocial/controllers/settings_controller.dart';

import '../controllers/nav_bar_controller.dart';
import '../controllers/social/chat_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    /// Login işlemi için gerekli controller'lar
    Get.put(HomeController()); 
    Get.put(LoginController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
    Get.put(MatchController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    Get.put(OnboardingController(), permanent: true);
    Get.put(GetMaterialController(), permanent: true);

    /// Ana Sayfa ve diğer sosyal özellikler
    Get.lazyPut(() => EventController());
    Get.lazyPut(() => EntryDetailController());
    Get.lazyPut(() => SearchTextController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => StoryController());
    Get.lazyPut(() => EntryController());
    Get.lazyPut(() => GroupController());
    Get.lazyPut(() => AppBarController());
    Get.lazyPut(() => TopicsController());
    Get.lazyPut(() => PostController());
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => SettingsController());
  }
}
