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
import '../../components/snackbars/custom_snackbar.dart';

final ProfileController controller = Get.find();

Widget buildProfileDetails({bool wrapWithScroll = true}) {
  final LanguageService languageService = Get.find<LanguageService>();
  return Obx(() {
    if (controller.profile.value == null) {
      return Center(
        child: Text(
          languageService.tr("profile.fallbackTexts.profileInfoNotAvailable"),
        ),
      );
    }

    final profileData = controller.profile.value!;
    final content = _buildProfileDetailsContent(profileData, languageService);

    if (wrapWithScroll) {
      return SingleChildScrollView(child: content);
    }
    return content;
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

Widget _buildProfileDetailsContent(
    dynamic profileData, LanguageService languageService) {
  return Container(
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
                      backgroundImage:
                          (profileData.school?.logo?.toString().isNotEmpty ??
                                  false)
                              ? NetworkImage(profileData.school!.logo.toString())
                              : AssetImage('images/school_logo.png')
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileData.school?.name ??
                              languageService
                                  .tr("profile.fallbackTexts.noSchoolInfo"),
                          style: GoogleFonts.inter(
                            fontSize: 13.28,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff414751),
                          ),
                        ),
                        Text(
                          profileData.schoolDepartment?.title ??
                              languageService
                                  .tr("profile.fallbackTexts.noDepartmentInfo"),
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
                      label: languageService.tr("groups.groupList.joined"),
                      value: formatSimpleDate(profileData.createdAt),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPersonalInfo(
                      icon: SvgPicture.asset(
                        "images/icons/document_icon.svg",
                        colorFilter: ColorFilter.mode(
                          Color(0xff414751),
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                      label: languageService.tr("entry.entryDetail.topic"),
                      value: profileData.topicCount.toString(),
                    ),
                    _buildPersonalInfo(
                      icon: SvgPicture.asset(
                        "images/icons/entry.svg",
                        colorFilter: ColorFilter.mode(
                          Color(0xff414751),
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                      label: languageService.tr("entry.entryDetail.entryCount"),
                      value: profileData.entryCount.toString(),
                    ),
                    const SizedBox(width: 10),
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
                  children: profileData.lessons
                      .map<Widget>((course) => buildCourseChip(course))
                      .toList(),
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
                  height: 200, // Kartların yüksekliği kadar bir alan belirlenmeli
                  child: ListView.builder(
                    scrollDirection:
                        Axis.horizontal, // **Yana kaydırılabilir yapı**
                    itemCount: profileData.approvedGroups.length,
                    itemBuilder: (context, index) {
                      final group = profileData.approvedGroups[index];
                      return InkWell(
                        onTap: () {
                          // Group ID'yi al ve group chat'e yönlendir
                          final groupId = group['id']?.toString();
                          if (groupId != null && groupId.isNotEmpty) {
                            Get.toNamed('/group_chat_detail', arguments: {
                              'groupId': groupId,
                            });
                          } else {
                            debugPrint('❌ Group ID not found in group data');
                            // Custom snackbar ile hata mesajı
                            CustomSnackbar.show(
                              title: languageService.tr("common.error"),
                              message: languageService
                                  .tr("groups.errors.noGroupSelected"),
                              type: SnackbarType.error,
                              duration: const Duration(seconds: 3),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: buildGroupSuggestionCard(
                            GroupSuggestionModel.fromJson(group),
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
  );
}
