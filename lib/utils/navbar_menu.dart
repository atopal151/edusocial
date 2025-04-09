import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/nav_bar_controller.dart';

class NavbarMenu extends StatefulWidget {
  const NavbarMenu({super.key});

  @override
  State<NavbarMenu> createState() => _NavbarMenuState();
}

class _NavbarMenuState extends State<NavbarMenu> {
  final NavigationController controller = Get.put(NavigationController());

  final List<String> icons = ["post", "chat", "match", "event", "profile"];

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ALT NAVBAR
        Obx(
          () => Container(
            padding: EdgeInsets.only(top: 15, bottom: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10, spreadRadius: 2),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                bool isSelected = controller.selectedIndex.value == index;

                return GestureDetector(
                  onTap: () {
                    if (index != 2) {
                      controller.changeIndex(index);
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            isSelected
                                ? "images/icons/${icons[index]}_selected.svg"
                                : "images/icons/${icons[index]}.svg",
                            width: isSelected ? 35 : 22,
                            height: isSelected ? 35 : 22,
                            theme: SvgTheme(currentColor: Color(0xEF505061)),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        Positioned(
          bottom: 50, // Navbarın üstüne çıkmasını sağlar
          left: MediaQuery.of(context).size.width / 2 - 35, // Ortalar
          child: GestureDetector(
            onTap: () {
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
