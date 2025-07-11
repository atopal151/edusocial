import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/nav_bar_controller.dart';
import '../controllers/match_controller.dart';
import '../controllers/chat_controllers/chat_controller.dart';

class NavbarMenu extends StatefulWidget {
  const NavbarMenu({super.key});

  @override
  State<NavbarMenu> createState() => _NavbarMenuState();
}

class _NavbarMenuState extends State<NavbarMenu> {
  final MatchController matchController = Get.find();
  final NavigationController controller = Get.find();
  final ChatController chatController = Get.find();

  final List<String> icons = ["post", "chat", "match", "event", "profile"];
  static const double centerButtonWidth = 57;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ALT NAVBAR
        Container(
          padding: EdgeInsets.only(top: 15, bottom: 30, left: 15, right: 15),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  bool isSelected = controller.selectedIndex.value == index;

                  /// Orta butonu (index 2) Row'dan kaldır, sadece boşluk bırak
                  if (index == 2) {
                    return const SizedBox(width: centerButtonWidth);
                  }

                  return GestureDetector(
                    onTap: () {
                      debugPrint(
                          '🔄 Navbar: Tapped on index $index (${icons[index]})');
                      controller.changeIndex(index);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
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
                            if (index == 1) // Chat index'i
                              Builder(builder: (context) {
                                final unreadCount =
                                    chatController.totalUnreadCount;
                                if (unreadCount > 0) {
                                  return Positioned(
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
                                  );
                                }
                                return SizedBox.shrink();
                              }),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              )),
        ),

        Positioned(
          bottom: 35, // Navbarın üstüne çıkmasını sağlar
          left: MediaQuery.of(context).size.width / 2 - 25, // Ortalar
          child: GestureDetector(
            onTap: () {
              /* if (matchController.matches.isEmpty) {
                Get.toNamed("/match");
                return;
              }*/
              controller.changeIndex(2);
            },
            child: Container(
              width: 57,
              height: 57,
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
