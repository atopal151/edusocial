import 'package:edusocial/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/match_controller.dart';

class MatchCard extends StatefulWidget {
  const MatchCard({super.key});

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  final ProfileController profileController = Get.find();
  final MatchController controller = Get.find();
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final match = controller.currentMatch;
      double rotationAngle = _dragOffset.dx / 300;

      return GestureDetector(
        onTap: () {
          profileController.getToPeopleProfileScreen(match.username);
        },
        onPanUpdate: (details) {
          setState(() {
            _dragOffset += details.delta;
          });
        },
        onPanEnd: (details) {
          if (_dragOffset.dx > 100) {
            controller.followUser();
          } else if (_dragOffset.dx < -100) {
            controller.nextMatch();
          }
          setState(() {
            _dragOffset = Offset.zero;
          });
        },
        child: Transform.translate(
          offset: _dragOffset,
          child: Transform.rotate(
            angle: rotationAngle * -1.5,
            child: Stack(
              children: [
                _buildMatchCard(match),
                if (_dragOffset.dx.abs() > 20)
                  Positioned.fill(
                    child: Align(
                      alignment: _dragOffset.dx > 0
                          ? Alignment.topLeft
                          : Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: _dragOffset.dx > 0
                                ? const Color(0xff65D384).withAlpha(150)
                                : const Color(0xffEF5050).withAlpha(150),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _dragOffset.dx > 0 ? "Takip Et" : "Geç",
                              style: GoogleFonts.inter(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMatchCard(match) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: match.profileImage.isNotEmpty
              ? NetworkImage(match.profileImage)
              : const AssetImage("images/user1.jpg") as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withAlpha(200),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${match.name}, ${match.age ?? '-'}",
              style: const TextStyle(
                  fontSize: 18.72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            if (match.isOnline)
              Row(
                children: [
                  const CircleAvatar(
                    radius: 5,
                    backgroundColor: Color(0xff4DD64B),
                  ),
                  const SizedBox(width: 4),
                  const Text("Çevrimiçi",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            const SizedBox(height: 16),
            const Text("Eğitim",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 39,
                  height: 39,
                  decoration: const BoxDecoration(
                    color: Color(0xffF6F6F6),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: match.schoolLogo.isNotEmpty
                        ? Image.network(match.schoolLogo, width: 21, height: 21)
                        : const Icon(Icons.school,
                            size: 18, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.schoolName.isNotEmpty
                          ? match.schoolName
                          : 'Okul bilgisi yok',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "${match.department.isNotEmpty ? match.department : 'Bölüm yok'} • Grade ${match.grade}",
                      style: const TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Hakkında",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              match.about.isNotEmpty ? match.about : 'Henüz bilgi yok',
              style: const TextStyle(
                  color: Color(0xffffffff),
                  fontSize: 10,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 16),
            const Text("Seninle eşleştiği konular",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: match.matchedTopics
                  .map<Widget>(
                    (topic) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(70),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        topic,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  iconPath: 'images/icons/match_user_add_icon.svg',
                  label: match.isFollowing ? 'Takip Ediliyor' : 'Takip Et',
                  color: const Color(0xff65D384),
                  onTap: controller.followUser,
                ),
                _buildActionButton(
                  iconPath: 'images/icons/match_message_icon.svg',
                  label: 'mesaj',
                  color: const Color(0xffFF7743),
                  onTap: controller.startChat,
                ),
                _buildActionButton(
                  iconPath: 'images/icons/match_next_icon.svg',
                  label: 'Geç',
                  color: const Color(0xffEF5050),
                  onTap: controller.nextMatch,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String iconPath,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: color.withAlpha(120),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
