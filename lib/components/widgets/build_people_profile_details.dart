import 'package:edusocial/components/cards/group_suggestion_card.dart';
import 'package:edusocial/components/widgets/course_chip.dart';
import 'package:edusocial/models/people_profile_model.dart';
import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../services/language_service.dart';
import '../../components/snackbars/custom_snackbar.dart';

Widget buildPeopleProfileDetails(PeopleProfileModel profileData) {
  final LanguageService languageService = Get.find<LanguageService>();
  return SingleChildScrollView(
    child: Container(
      color: const Color(0xfffafafa),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// **Okul Bilgisi**
                  if (profileData.school != null) ...[
                    Text(
                      languageService.tr("profile.details.school"),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
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
                              profileData.school?.name ?? '',
                              style: const TextStyle(
                                fontSize: 13.28,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF414751),
                              ),
                            ),
                            if (profileData.schoolDepartment != null)
                              Text(
                                profileData.schoolDepartment?.title ?? '',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF9CA3AE),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  /// **Kişisel Bilgiler**
                  Text(
                    languageService.tr("profile.details.personalInfo"),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPersonalInfo(
                        icon: SvgPicture.asset(
                          "images/icons/calendar_icon.svg",
                          colorFilter: const ColorFilter.mode(
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
                      if (profileData.language != null &&
                          profileData.language is Map &&
                          profileData.language['name'] != null)
                        _buildPersonalInfo(
                          icon: SvgPicture.asset(
                            "images/icons/language_icon.svg",
                            colorFilter: const ColorFilter.mode(
                              Color(0xff414751),
                              BlendMode.srcIn,
                            ),
                            width: 20,
                            height: 20,
                          ),
                          label: "Dil",
                          value: profileData.language['name'],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPersonalInfo(
                        icon: SvgPicture.asset(
                          "images/icons/document_icon.svg",
                          colorFilter: const ColorFilter.mode(
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
                          colorFilter: const ColorFilter.mode(
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
                  if (profileData.lessons.isNotEmpty) ...[
                    Text(
                      languageService.tr("profile.details.courses"),
                      style: const TextStyle(
                        fontSize: 13.28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
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
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// **Katıldığı Gruplar**
            if (profileData.approvedGroups.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      languageService.tr("profile.details.joinedGroups"),
                      style: TextStyle(
                        fontSize: 13.28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
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
                                  message: languageService.tr("groups.errors.noGroupSelected"),
                                  type: SnackbarType.error,
                                  duration: const Duration(seconds: 3),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: buildGroupSuggestionCard(group),
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
}

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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AE),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF414751),
            ),
          ),
        ],
      ),
    ],
  );
}
