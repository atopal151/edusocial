import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../components/buttons/custom_button.dart';
import '../../controllers/settings_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Color(0xffFAFAFA),
        backgroundColor: Color(0xffFAFAFA),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: controller.goBack,
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: SvgPicture.asset(
                  'images/icons/back_icon.svg',
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xffFAFAFA),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    Obx(() => CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              controller.userProfile.value.profileImage),
                        )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: controller.changeProfilePicture,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Color(0xFFEF5050),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: SvgPicture.asset(
                                'images/icons/edit_icon.svg',
                                width: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Center(
                  child: Text("Profil Fotoğrafı",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.28,
                          color: Color(0xff414751)))),
              Center(
                  child: Text("Profil fotoğrafınızı değiştirin.",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff9CA3AE)))),

              SizedBox(height: 40),
          
              // Username Field
              _buildTextField(
                  "Kullanıcı Adı", "@", controller.usernameController),
              SizedBox(height: 30),

              Text("Sosyal Profiller",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xff414751))),
              SizedBox(height: 20),
              // Instagram Field
              _buildTextField("Instagram", "/", controller.instagramController),
              SizedBox(height: 10),

              // Youtube Field
              _buildTextField("Youtube", "/", controller.youtubeController),
              SizedBox(height: 10),

              // Demo Notification Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Demo Notification",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.28,
                              color: Color(0xff414751))),
                      Text("Bildirimler Etkinleştirin",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xff9CA3AE))),
                    ],
                  ),
                  Obx(() => Switch(
                        value: controller.demoNotification.value,
                        activeColor: Color(0xFFEF5050),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white,
                        inactiveThumbColor: Color(0xFFD0D4DB),
                        trackOutlineColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onChanged: controller.toggleNotification,
                      )),
                ],
              ),
              SizedBox(height: 20),

              // Save Button
              CustomButton(

                        height: 50,
                        borderRadius: 15,
                text: "Kaydet",
                onPressed: controller.saveProfile,
                isLoading: controller.isLoading,
                backgroundColor: Color(0xFFEF5050),
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String prefix, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.28,
                color: Color(0xff414751))),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixText: "$prefix ",
              prefixStyle: TextStyle(color: Color(0xffd0d4db)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
