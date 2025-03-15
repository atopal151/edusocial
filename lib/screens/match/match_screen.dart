import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/custom_textfield_step2.dart';
import '../../components/lists/custom_chip_list.dart';
import '../../controllers/social/match_controller.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final MatchController controller = Get.put(MatchController());

  @override
  Widget build(BuildContext context) {
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
                        "Benzer İlgi Alanlarına \n Sahip Kişilerle Tanış!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "EduSocial, Polonya’daki uluslararası okullarda eğitim \n gören öğrenciler için tasarlanmış yenilikçi bir sosyal \n platformdur.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
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
                    "Hangi Konuyu Çalışacaksın?",
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
                  child: CustomTextFieldStep2(
                    controller: controller.textFieldController,
                    onAdd: controller.addTopic,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "Hangi Konuyu Çalışacaksın?",
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
                      text: "Uygun Eşleşmeleri Bul",
                      onPressed: controller.findMatches,
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
