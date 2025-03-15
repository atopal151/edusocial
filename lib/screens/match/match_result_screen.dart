import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/cards/match_card/match_card.dart';
import '../../components/user_appbar/user_appbar.dart';
import '../../controllers/social/match_controller.dart';

class MatchResultScreen extends StatefulWidget {
  const MatchResultScreen({super.key});

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
    
  final MatchController controller = Get.put(MatchController());
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserAppBar(),
      backgroundColor: const Color(0xffFAFAFA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            if (controller.matches.isEmpty) {
              return ElevatedButton(
                onPressed: controller.findMatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Eşleşme Bul", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              );
            }
            return MatchCard();
          }),
        ),
      ),
    );
  }
}
