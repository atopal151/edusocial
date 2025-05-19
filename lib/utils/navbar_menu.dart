import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/nav_bar_controller.dart';
import '../controllers/social/match_controller.dart';

class NavbarMenu extends StatefulWidget {
  const NavbarMenu({super.key});

  @override
  State<NavbarMenu> createState() => _NavbarMenuState();
}

class _NavbarMenuState extends State<NavbarMenu> {
  final MatchController matchController = Get.find();
  final NavigationController controller = Get.find();

  final List<String> icons = ["post", "chat", "match", "event", "profile"];
  static const double centerButtonWidth = 57;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ALT NAVBAR
        Obx(
          () => Container(
            padding: EdgeInsets.only(top: 15, bottom: 30, left: 15, right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                bool isSelected = controller.selectedIndex.value == index;

                /// Orta butonu (index 2) Row’dan kaldır, sadece boşluk bırak
                if (index == 2) {
                  return const SizedBox(width: centerButtonWidth);
                }

                return GestureDetector(
                  onTap: () {
                    controller.changeIndex(index);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                    ],
                  ),
                );
              }),
            ),
          ),
        ),

        Positioned(
          bottom: 35, // Navbarın üstüne çıkmasını sağlar
          left: MediaQuery.of(context).size.width / 2 - 25, // Ortalar
          child: GestureDetector(
            onTap: () {
              if (matchController.matches.isEmpty) {
                Get.toNamed("/match");
                return;
              }
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
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
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
