import 'package:edusocial/controllers/home_controller.dart';
import 'package:edusocial/screens/entry/entry_screen.dart';
import 'package:edusocial/screens/match/match_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    print('MAIN controller hash: ${navigationController.hashCode}');

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: navigationController.selectedIndex.value,
            children: [
              HomeScreen(),
              ChatListScreen(),
              MatchResultScreen(),
              EntryScreen(),
              ProfileScreen(),
            ],
          )),
      bottomNavigationBar: NavbarMenu(),
    );
  }
}
