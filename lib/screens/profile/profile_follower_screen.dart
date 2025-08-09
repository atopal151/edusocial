import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/language_service.dart';

class ProfileFollowerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> followers;
  final String screenTitle;
  
  const ProfileFollowerScreen({
    super.key, 
    required this.followers,
    this.screenTitle = '',
  });

  @override
  State<ProfileFollowerScreen> createState() => _ProfileFollowerScreenState();
}

class _ProfileFollowerScreenState extends State<ProfileFollowerScreen> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _filteredFollowers = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // Debug: Followers verilerini listele
    debugPrint("🔍 === FOLLOWERS SCREEN DEBUG ===");
    debugPrint("📊 Toplam takipçi sayısı: ${widget.followers.length}");
    for (int i = 0; i < widget.followers.length; i++) {
      final follower = widget.followers[i];
      debugPrint("👤 Takipçi ${i + 1}:");
      debugPrint("  - ID: ${follower['id']}");
      debugPrint("  - Name: ${follower['name']} ${follower['surname']}");
      debugPrint("  - Username: ${follower['username']}");
      debugPrint("  - Avatar URL: ${follower['avatar_url']}");
      debugPrint("  - Is Following: ${follower['is_following']}");
      debugPrint("  - Is Following Pending: ${follower['is_following_pending']}");
      debugPrint("  - Account Type: ${follower['account_type']}");
      debugPrint("  - Created At: ${follower['created_at']}");
      debugPrint("  - Raw Data: ${follower.toString()}");
      debugPrint("  - ---");
    }
    debugPrint("🔍 === FOLLOWERS DEBUG END ===");
    
    // Sadece kabul edilmiş takipçileri göster (is_following_pending != true)
    final approvedFollowers = widget.followers.where((follower) {
      final isPending = follower['is_following_pending'] == true;
      debugPrint("🔍 Follower ${follower['username']}: isPending = $isPending");
      return !isPending; // Pending olmayanları göster
    }).toList();
    
    debugPrint("📊 Filtrelenmiş takipçi sayısı: ${approvedFollowers.length} (Toplam: ${widget.followers.length})");
    _filteredFollowers = List.from(approvedFollowers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFollowers(String query) {
    setState(() {
      // Önce pending olmayan takipçileri al
      final approvedFollowers = widget.followers.where((follower) {
        return follower['is_following_pending'] != true;
      }).toList();
      
      if (query.isEmpty) {
        _filteredFollowers = List.from(approvedFollowers);
      } else {
        _filteredFollowers = approvedFollowers.where((user) {
          final name = '${user["name"]} ${user["surname"]}'.toLowerCase();
          final username = user["username"].toLowerCase();
          final searchQuery = query.toLowerCase();
          
          return name.contains(searchQuery) || username.contains(searchQuery);
        }).toList();
      }
      
      debugPrint("🔍 Arama sonucu: ${_filteredFollowers.length} takipçi bulundu");
    });
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        title: widget.screenTitle.isEmpty 
            ? languageService.tr("profile.followers.title")
            : widget.screenTitle,
        backgroundColor: Color(0xfffafafa),
        iconBackgroundColor: Color(0xffffffff),
      ),
      body: Column(
        children: [
          // Arama alanı
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchTextField(
              controller: _searchController,
              label: languageService.tr("profile.followers.searchPlaceholder"),
              onChanged: _filterFollowers,
            ),
          ),
          // Takipçiler listesi
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFollowers.length,
              itemBuilder: (context, index) {
                final user = _filteredFollowers[index];
          return ListTile(
            onTap: () {
              Get.to(() => PeopleProfileScreen(
                  username: user['username']));
            },
            leading: CircleAvatar(
              backgroundColor: Color(0xffffffff),
              backgroundImage: NetworkImage(user["avatar_url"] ?? ''),
            ),
            title: Text(
              '${user["name"]} ${user["surname"]}',
              style: TextStyle(
                  fontSize: 13.28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff414751)),
            ),
            subtitle: Text(
              '@${user["username"]}',
              style: TextStyle(
                  fontSize: 13.28,
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
                languageService.tr("profile.followers.sendMessage"),
                 style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff414751)),
              ),
            ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
