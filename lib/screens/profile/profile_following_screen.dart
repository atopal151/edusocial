import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../services/language_service.dart';
import '../../components/widgets/verification_badge.dart';

class ProfileFollowingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> followings;
  final String screenTitle;

  const ProfileFollowingScreen({
    super.key,
    required this.followings,
    this.screenTitle = '',
  });

  @override
  State<ProfileFollowingScreen> createState() => _ProfileFollowingScreenState();
}

class _ProfileFollowingScreenState extends State<ProfileFollowingScreen> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _filteredFollowings = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredFollowings = List.from(widget.followings);

    // Debug: Following verilerini listele
    //debugPrint("🔍 === FOLLOWING SCREEN DEBUG ===");
    //debugPrint("📊 Toplam takip edilen sayısı: ${widget.followings.length}");
    /* for (int i = 0; i < widget.followings.length; i++) {
      final following = widget.followings[i];
      debugPrint("👤 Takip Edilen ${i + 1}:");
      debugPrint("  - ID: ${following['id']}");
      debugPrint("  - Name: ${following['name']} ${following['surname']}");
      debugPrint("  - Username: ${following['username']}");
      debugPrint("  - Avatar URL: ${following['avatar_url']}");
      debugPrint("  - Is Following: ${following['is_following']}");
      debugPrint("  - Is Following Pending: ${following['is_following_pending']}");
      debugPrint("  - Account Type: ${following['account_type']}");
      debugPrint("  - Created At: ${following['created_at']}");
      debugPrint("  - Raw Data: ${following.toString()}");
      debugPrint("  - ---");
    }*/
    //debugPrint("🔍 === FOLLOWING DEBUG END ===");

    // Sadece takip isteği kabul edilenleri göster (is_following = true && is_following_pending != true)
    final approvedFollowings = widget.followings.where((following) {
      final isFollowing = following['is_following'] == true;
      final isPending = following['is_following_pending'] == true;
      //debugPrint("🔍 Following ${following['username']}: isFollowing = $isFollowing, isPending = $isPending");
      return isFollowing && !isPending; // Takip ediliyor ve pending değil
    }).toList();

    //debugPrint("📊 Filtrelenmiş takip edilen sayısı: ${approvedFollowings.length} (Toplam: ${widget.followings.length})");
    _filteredFollowings = List.from(approvedFollowings);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFollowings(String query) {
    setState(() {
      // Önce takip isteği kabul edilenleri al
      final approvedFollowings = widget.followings.where((following) {
        final isFollowing = following['is_following'] == true;
        final isPending = following['is_following_pending'] == true;
        return isFollowing && !isPending; // Takip ediliyor ve pending değil
      }).toList();

      if (query.isEmpty) {
        _filteredFollowings = List.from(approvedFollowings);
      } else {
        _filteredFollowings = approvedFollowings.where((user) {
          final name = '${user["name"]} ${user["surname"]}'.toLowerCase();
          final username = user["username"].toLowerCase();
          final searchQuery = query.toLowerCase();

          return name.contains(searchQuery) || username.contains(searchQuery);
        }).toList();
      }

      //debugPrint("🔍 Arama sonucu: ${_filteredFollowings.length} takip edilen bulundu");
    });
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        title: widget.screenTitle.isEmpty
            ? languageService.tr("profile.following.title")
            : widget.screenTitle,
        backgroundColor: Color(0xfffafafa),
        iconBackgroundColor: Color(0xffffffff),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh işlemi - şimdilik sadece UI'ı yeniden yüklüyoruz
          // İleride API çağrısı eklenebilir
          setState(() {
            // Mevcut filtreyi koruyarak listeyi yeniden yükle
            final approvedFollowings = widget.followings.where((following) {
              final isFollowing = following['is_following'] == true;
              final isPending = following['is_following_pending'] == true;
              return isFollowing && !isPending; // Takip ediliyor ve pending değil
            }).toList();
            _filteredFollowings = List.from(approvedFollowings);
          });
          
          // Kısa bir gecikme ekleyerek refresh animasyonunu göster
          await Future.delayed(Duration(milliseconds: 500));
        },
        color: const Color(0xFFEF5050),
        backgroundColor: Color(0xfffafafa),
        elevation: 0,
        strokeWidth: 2.0,
        displacement: 40.0,
        child: Column(
          children: [
            // Arama alanı
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchTextField(
                controller: _searchController,
                label: languageService.tr("profile.following.searchPlaceholder"),
                onChanged: _filterFollowings,
              ),
            ),
            // Takip edilenler listesi
            Expanded(
              child: ListView.builder(
                itemCount: _filteredFollowings.length,
                itemBuilder: (context, index) {
                  final user = _filteredFollowings[index];
                  return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                      decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        onTap: () {
                          Get.to(() =>
                              PeopleProfileScreen(username: user['username']));
                        },
                        leading: CircleAvatar(
                          backgroundColor: Color(0xffffffff),
                          backgroundImage: NetworkImage(user["avatar_url"] ?? ''),
                        ),
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                '${user["name"]} ${user["surname"]} ',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff414751)),
                              ),
                            ),
                            VerificationBadge(
                              isVerified: user['is_verified'] ?? false,
                              size: 12.0,
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '@${user["username"]}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff9ca3ae)),
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            // Mesaj gönderme ekranına yönlendirme
                            Get.toNamed(Routes.chatDetail, arguments: {
                              'userId': user['id'],
                              'conversationId': null, // Yeni konuşma başlatılacak
                              'name': '${user["name"]} ${user["surname"]}',
                              'username': user["username"],
                              'avatarUrl': user["avatar_url"] ?? '',
                              'isOnline': false, // Varsayılan olarak çevrimdışı
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xfff0f1f3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            languageService.tr("profile.following.sendMessage"),
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff414751)),
                          ),
                        ),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
