import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/cards/match_card/match_card.dart';
import '../../components/user_appbar/user_appbar.dart';
import '../../controllers/match_controller.dart';
import '../../components/buttons/custom_button.dart'; // CustomButton importunu unutma

class MatchResultScreen extends StatefulWidget {
  const MatchResultScreen({super.key});

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  final MatchController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserAppBar(),
      backgroundColor: const Color(0xffFAFAFA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.matches.isEmpty) {
            // 👇 Eşleşme yoksa butonu göster
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: IconButton(
                  onPressed: () {
                    controller.findMatches();
                  },
                  icon: const Icon(Icons.refresh,
                      color: Color(0xff9ca3ae), size: 20),
                ),
              ),
            );
          } else {
            // 👇 Eşleşme varsa kartı göster
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MatchCard(),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: IconButton(
                    onPressed: () {
                      controller.findMatches();
                    },
                    icon: const Icon(Icons.refresh,
                        color: Color(0xff9ca3ae), size: 20),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: CustomButton(
                    text: 'Ders Ekle',
                    height: 30,
                    borderRadius: 15,
                    isLoading: controller.isLoading,
                    backgroundColor: Colors.transparent,
                    textColor: Color(0xff9ca3ae),
                    onPressed: () {
                      Get.toNamed('/match');
                    },
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
