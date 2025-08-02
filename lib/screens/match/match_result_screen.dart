import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/cards/match_card/match_card.dart';
import '../../components/user_appbar/user_appbar.dart';
import '../../controllers/match_controller.dart';
import '../../services/language_service.dart';

class MatchResultScreen extends StatefulWidget {
  const MatchResultScreen({super.key});

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  final MatchController controller = Get.find();
  final LanguageService languageService = Get.find();

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında eşleşmeleri getir
    controller.findMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserAppBar(),
      backgroundColor: const Color(0xffFAFAFA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.matches.isEmpty) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    languageService.tr("match.resultScreen.noMatchesFound"),
                    style: GoogleFonts.inter(
                      color: Color(0xff9ca3ae),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                ],
              ),
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MatchCard(),
              ],
            );
          }
        }),
      ),
    );
  }
}
