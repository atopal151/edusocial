  import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../models/user_model.dart';


  final ProfileController controller = Get.find();
  
Widget buildProfileDetails() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.profile.value == null) {
        return const Center(child: Text("Profil bilgileri alınamadı."));
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
                      const Text(
                        "Okuduğu Okul",
                        style: TextStyle(
                          fontSize: 13.28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                NetworkImage(profileData.schoolLogo),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profileData.schoolName,
                                style: const TextStyle(
                                  fontSize: 13.28,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF414751),
                                ),
                              ),
                              Text(
                                "${profileData.schoolDepartment} • ${profileData.schoolGrade}",
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

                      /// **Kişisel Bilgiler**
                      const Text(
                        "Kişisel Bilgiler",
                        style: TextStyle(
                          fontSize: 13.28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPersonalInfo(
                            icon: Icons.calendar_today,
                            label: "Doğum Tarihi",
                            value: profileData.birthDate,
                          ),
                          _buildPersonalInfo(
                            icon: Icons.email_outlined,
                            label: "E-posta Adresi",
                            value: profileData.email,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// **Aldığı Dersler**
                      const Text(
                        "Aldığı Dersler",
                        style: TextStyle(
                          fontSize: 13.28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profileData.courses.map((course) {
                          return _buildCourseChip(course);
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
                      const Text(
                        "Katıldığı Gruplar",
                        style: TextStyle(
                          fontSize: 13.28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 0),
                      SizedBox(
                        height:
                            120, // Kartların yüksekliği kadar bir alan belirlenmeli
                        child: ListView.builder(
                          scrollDirection:
                              Axis.horizontal, // **Yana kaydırılabilir yapı**
                          itemCount: profileData.joinedGroups.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _buildGroupCard(
                                  profileData.joinedGroups[index]),
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


  Widget _buildGroupCard(GroupModel group) {
    return Container(
      width: 170,
      height: 111,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(group.groupImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // 🔹 Siyah degrade efekti (Alttan üste şeffaflaşan siyah)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withAlpha(153), // En altta yoğun siyah
                    Colors.black.withAlpha(77), // Ortalarda daha hafif siyah
                    Colors.transparent, // Üstte tamamen şeffaf
                  ],
                ),
              ),
            ),
          ),

          // 🔹 Grup Profili (Yuvarlak Avatar)
          Positioned(
            top: 10,
            left: 10,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(group.groupAvatar),
            ),
          ),

          // 🔹 Grup İsmi (Alt kısımda, siyah degrade sayesinde okunaklı)
          Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: Text(
              group.groupName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 🔹 Üye Sayısı (Sağ üstte, okunaklı olacak şekilde)
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              children: [
                const Icon(Icons.group, color: Color(0xffEF5050), size: 16),
                const SizedBox(width: 3),
                Text(
                  group.memberCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// **Kişisel Bilgi Kartı**
  Widget _buildPersonalInfo(
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey, size: 20),
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

  /// **Ders Kartı (Chip)**
  Widget _buildCourseChip(String course) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        course,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: Color(0xFF1F1F1F),
        ),
      ),
    );
  }