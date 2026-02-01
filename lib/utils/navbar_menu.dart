import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/nav_bar_controller.dart';
import '../controllers/match_controller.dart';
import '../controllers/chat_controllers/chat_controller.dart';
import '../controllers/profile_controller.dart';

class NavbarMenu extends StatefulWidget {
  const NavbarMenu({super.key});

  @override
  State<NavbarMenu> createState() => _NavbarMenuState();
}

class _NavbarMenuState extends State<NavbarMenu> {
  final MatchController matchController = Get.find();
  final NavigationController controller = Get.find();
  final ChatController chatController = Get.find();
  final ProfileController profileController = Get.find();

  final List<String> icons = ["post", "subjects", "match", "chat", "profile"];
  static const double centerButtonWidth = 57;

  Widget _buildNavItem(int index) {
    bool isSelected = controller.selectedIndex.value == index;
    final unreadCount = profileController.unreadMessagesTotalCount.value;
    
    return GestureDetector(
      onTap: () {
        debugPrint('🔄 Navbar: Tapped on index $index (${icons[index]})');
        HapticFeedback.lightImpact();
        controller.changeIndex(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        constraints: BoxConstraints(minWidth: 48, minHeight: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  "images/icons/${icons[index]}.svg",
                  colorFilter: ColorFilter.mode(
                    isSelected
                        ? const Color(0xFFEF5050)
                        : const Color(0xFF9CA3AE),
                    BlendMode.srcIn,
                  ),
                ),
                // Chat ikonu için badge göster
                if (index == 3 && unreadCount > 0) // Chat index'i
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(0xffff565f),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ALT NAVBAR
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 20, left: 15, right: 15),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Obx(() => Row(
                children: [
                  // İlk iki icon (post, subjects)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(0), // post
                        _buildNavItem(1), // subjects
                      ],
                    ),
                  ),
                  // Orta buton için boşluk
                  SizedBox(width: centerButtonWidth),
                  // Son iki icon (chat, profile)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(3), // chat
                        _buildNavItem(4), // profile
                      ],
                    ),
                  ),
                ],
              )),
        ),

        Positioned(
          bottom: 45, // Navbarın üstüne çıkmasını sağlar
          left: MediaQuery.of(context).size.width / 2 - (centerButtonWidth / 2), // Tam ortalar
          child: GestureDetector(
            onTap: () {
              // Haptic feedback ekle
              HapticFeedback.lightImpact();
              /* if (matchController.matches.isEmpty) {
                Get.toNamed("/match");
                return;
              }*/
              controller.changeIndex(2);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: centerButtonWidth,
              height: centerButtonWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF7743),
                    Color(0xFFEF5050)
                  ], // Linear gradient renkleri
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'images/icons/match.svg',
                  width: 27,
                  height: 27,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
