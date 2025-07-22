import 'package:edusocial/components/widgets/course_chip.dart';
import 'package:edusocial/models/group_models/grup_suggestion_model.dart';
import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/profile_controller.dart';
import 'group_suggestion_card.dart';
import '../../services/language_service.dart';

final ProfileController controller = Get.find();

Widget buildProfileDetails() {
  final LanguageService languageService = Get.find<LanguageService>();
  return Obx(() {


    if (controller.profile.value == null) {
      return Center(child: Text(languageService.tr("profile.fallbackTexts.profileInfoNotAvailable")));
    }

    final profileData = controller.profile.value!;

    return SingleChildScrollView(
      child: Container(
        color: Color(0xfffafafa),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// **Okul Bilgisi**
                    Text(
                      languageService.tr("profile.details.school"),
                      style: GoogleFonts.inter(
                        fontSize: 13.28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff414751),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xfffafafa),
                          radius: 20,
                          backgroundImage: (profileData.school?.logo
                                      ?.toString()
                                      .isNotEmpty ??
                                  false)
                              ? NetworkImage(
                                  profileData.school!.logo.toString())
                              : AssetImage('images/school_logo.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileData.school?.name ?? languageService.tr("profile.fallbackTexts.noSchoolInfo"),
                              style: GoogleFonts.inter(
                                fontSize: 13.28,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff414751),
                              ),
                            ),
                            Text(
                              "${profileData.schoolDepartment?.title ?? languageService.tr("profile.fallbackTexts.noDepartmentInfo")}" ,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff9ca3ae),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// **Kişisel Bilgiler**
                    Text(
                      languageService.tr("profile.details.personalInfo"),
                      style: GoogleFonts.inter(
                        fontSize: 13.28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff414751),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPersonalInfo(
                          icon: SvgPicture.asset(
                            "images/icons/calendar_icon.svg",
                            colorFilter: ColorFilter.mode(
                              Color(0xff414751),
                              BlendMode.srcIn,
                            ),
                            width: 20,
                            height: 20,
                          ),
                          label: languageService.tr("profile.details.birthDate"),
                          value: formatSimpleDate(profileData.birthDate),
                        ),
                        _buildPersonalInfo(
                          icon: SvgPicture.asset(
                            "images/icons/profile_tab_icon.svg",
                            colorFilter: ColorFilter.mode(
                              Color(0xff414751),
                              BlendMode.srcIn,
                            ),
                            width: 20,
                            height: 20,
                          ),
                          label: languageService.tr("profile.details.email"),
                          value: profileData.email,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// **Aldığı Dersler**
                    Text(
                      languageService.tr("profile.details.courses"),
                      style: GoogleFonts.inter(
                        fontSize: 13.28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff414751),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profileData.lessons.map((course) {
                        return buildCourseChip(course);
                      }).toList(),
                    ),

                    const SizedBox(height: 10),
                    // 📌 Katıldığı Gruplar
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageService.tr("profile.details.joinedGroups"),
                      style: GoogleFonts.inter(
                        fontSize: 13.28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff414751),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height:
                          200, // Kartların yüksekliği kadar bir alan belirlenmeli
                      child: ListView.builder(
                        scrollDirection:
                            Axis.horizontal, // **Yana kaydırılabilir yapı**
                        itemCount: profileData.approvedGroups.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Get.toNamed("/group_chat_detail");
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: buildGroupSuggestionCard(
                                GroupSuggestionModel.fromJson(
                                    profileData.approvedGroups[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  });
}

/// **Kişisel Bilgi Kartı**
Widget _buildPersonalInfo(
    {required Widget? icon, required String label, required String value}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: icon,
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xff9ca3ae),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xff414751),
            ),
          ),
        ],
      ),
    ],
  );
}
