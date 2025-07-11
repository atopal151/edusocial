import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/custom_textfield_step2.dart';
import '../../components/lists/custom_chip_list.dart';
import '../../controllers/match_controller.dart';
import '../../services/language_service.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final MatchController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Scaffold(
      
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF26B6B), Color(0xFFE55050)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              image: DecorationImage(
                image: AssetImage("images/mask_group.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                Center(
                  child: SizedBox(
                    width: 250, 
                    height: 250, 
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 39, 
                          child: Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFFFFF), Color(0xFFFFD9D9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -20, 
                          child: SizedBox(
                            width: 190,
                            height: 250,
                            child: Image.asset(
                              'images/ch_group.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Text(
                        languageService.tr("match.title"),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: Color(0xffffffff),
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Text(
                        languageService.tr("match.subtitle"),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: Color(0xffffffff),
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    languageService.tr("match.form.courseQuestion"),
                    textAlign: TextAlign.start,
                    style: GoogleFonts.inter(
                        color: Color(0xffffffff),
                        fontSize: 13.28,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextFieldStep2(
                    controller: controller.textFieldController,
                    onAdd: controller.addTopic,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        languageService.tr("match.form.savedTopics"),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.28,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomChipList(
                    items: controller.savedTopics,
                    textColor: Color(0xffffffff),
                    backgroundColor: Color(0xffED7474),
                    onRemove: controller.removeTopic,
                    iconColor: Color(0xffED7474),
                    iconbackColor: Color(0xffffffff),
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(

                        height: 50,
                        borderRadius: 15,
                      text: languageService.tr("match.findMatchesButton"),
                      onPressed: controller.addCoursesToProfile,
                      isLoading: controller.isLoading,
                      backgroundColor: Colors.white,
                      textColor: Color(0xffE75555)),
                ),

                SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
