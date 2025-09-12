// home_screen.dart
import 'package:edusocial/components/user_appbar/user_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/cards/story_card.dart';
import '../../controllers/story_controller.dart';
import 'group_suggestion_list.dart';
import '../../controllers/group_controller/group_controller.dart';
import '../../controllers/home_controller.dart';
import 'hot_topics_list.dart';
import '../../controllers/topics_controller.dart';
import '../../controllers/post_controller.dart';
import 'story/my_story_list.dart';
import 'post_home_list.dart';
import '../../services/language_service.dart';
//import '../../services/onesignal_service.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.find();
  final GroupController groupController = Get.find();
  final StoryController storyController = Get.find();
  final TopicsController topicsController = Get.find<TopicsController>();
  final PostController postController = Get.find<PostController>();

  HomeScreen({super.key});

  /// Ana sayfa verilerini yenile
  Future<void> _refreshHomeData() async {
    debugPrint("🔄 Ana sayfa verileri yenileniyor...");
    
    try {
      // Tüm verileri sıralı olarak yenile
      storyController.fetchStories();
      groupController.fetchSuggestionGroups();
      topicsController.fetchHotTopics();
      postController.fetchHomePosts();
      
      debugPrint("✅ Ana sayfa verileri başarıyla yenilendi");
    } catch (e) {
      debugPrint("❌ Ana sayfa verileri yenilenirken hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: UserAppBar(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Konfigürasyon test butonu
          /*Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                begin: Alignment.bottomCenter,
                end: Alignment.topRight,
              ),
            ),
            child: FloatingActionButton(
              onPressed: () async {
                try {
                  final oneSignalService = Get.find<OneSignalService>();
                  await oneSignalService.testOneSignalConfiguration();
                  
                  // Başarı mesajı göster
                  Get.snackbar(
                    'Konfigürasyon Testi',
                    'OneSignal konfigürasyon testi başlatıldı. Console loglarını kontrol edin.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Color(0xFF4CAF50),
                    colorText: Colors.white,
                    duration: Duration(seconds: 4),
                    icon: Icon(Icons.settings, color: Colors.white),
                  );
                } catch (e) {
                  Get.snackbar(
                    'Hata',
                    'Konfigürasyon testi başlatılamadı: $e',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: Duration(seconds: 3),
                  );
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(Icons.settings, color: Color(0xffffffff), size: 20),
            ),
          ),
          // Background test butonu
          Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
                begin: Alignment.bottomCenter,
                end: Alignment.topRight,
              ),
            ),
            child: FloatingActionButton(
              onPressed: () async {
                try {
                  final oneSignalService = Get.find<OneSignalService>();
                  await oneSignalService.testBackgroundNotification();
                  
                  // Başarı mesajı göster
                  Get.snackbar(
                    'Test Başlatıldı',
                    'Background notification testi başlatıldı. Uygulamayı kapatın ve bildirimi kontrol edin.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Color(0xFF2196F3),
                    colorText: Colors.white,
                    duration: Duration(seconds: 4),
                    icon: Icon(Icons.notifications, color: Colors.white),
                  );
                } catch (e) {
                  Get.snackbar(
                    'Hata',
                    'Test başlatılamadı: $e',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: Duration(seconds: 3),
                  );
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(Icons.notifications_active, color: Color(0xffffffff), size: 20),
            ),
          ),*/
          // Post ekleme butonu
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFEF5050), Color(0xFFFF7743)],
                begin: Alignment.bottomCenter,
                end: Alignment.topRight,
              ),
            ),
            child: FloatingActionButton(
              onPressed: () {
                Get.toNamed("/create_post");
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(Icons.add, color: Color(0xffffffff), size: 25),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  
      body: RefreshIndicator(
        onRefresh: _refreshHomeData,
        color: Color(0xFFef5050),
        backgroundColor: Color(0xfffafafa),
        elevation: 0,
        strokeWidth: 2.0,
        displacement: 20.0,
        edgeOffset: 10.0,
        child: Obx(() {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      MyStoryList(),
                      SizedBox(width: 5),
                      ...storyController.otherStories.map((story) => StoryCard(story: story)),
                    ],
                  ),
                ),
                if (groupController.suggestionGroups.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
                    child: Text(languageService.tr("home.homeScreen.suggestedGroups"),
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff272727))),
                  ),
                  GroupSuggestionListView(),
                ],
                if (topicsController.hotTopics.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
                    child: Text(languageService.tr("home.homeScreen.hotTopics"),
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff272727))),
                  ),
                  HotTopicsListView(),
                ],
                PostHomeList(),
                SizedBox(height: 80),
              ],
            ),
          );
        }),
      ),
    );
  }
}
