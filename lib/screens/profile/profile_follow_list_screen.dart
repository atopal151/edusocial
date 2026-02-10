import 'package:edusocial/components/input_fields/search_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edusocial/screens/profile/people_profile_screen.dart';
import 'package:edusocial/services/people_profile_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../services/language_service.dart';
import '../../components/widgets/verification_badge.dart';

/// Tek sayfa: Takipçi ve Takip edilen listeleri tab bar ile ayrılır.
/// App bar'da kişinin ismi, tab bar altında arama alanı.
class ProfileFollowListScreen extends StatefulWidget {
  final String displayName;
  final bool isVerified;
  final int? userId;
  final int initialTabIndex;
  final List<Map<String, dynamic>> initialFollowers;
  final List<Map<String, dynamic>> initialFollowings;
  final int followerCount;
  final int followingCount;

  static const int _perPage = 20;

  const ProfileFollowListScreen({
    super.key,
    required this.displayName,
    this.isVerified = false,
    this.userId,
    this.initialTabIndex = 0,
    this.initialFollowers = const [],
    this.initialFollowings = const [],
    required this.followerCount,
    required this.followingCount,
  });

  @override
  State<ProfileFollowListScreen> createState() => _ProfileFollowListScreenState();
}

class _ProfileFollowListScreenState extends State<ProfileFollowListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchControllerFollowers;
  late TextEditingController _searchControllerFollowing;
  late ScrollController _scrollControllerFollowers;
  late ScrollController _scrollControllerFollowing;

  List<Map<String, dynamic>> _allFollowers = [];
  List<Map<String, dynamic>> _allFollowings = [];
  int _pageFollowers = 2;
  int _pageFollowings = 2;
  bool _hasMoreFollowers = true;
  bool _hasMoreFollowings = true;
  bool _isLoadingMoreFollowers = false;
  bool _isLoadingMoreFollowings = false;
  final Set<int> _followLoadingUserIds = {};

  void _onTabChange() => setState(() {});

  Future<void> _onFollowUser(Map<String, dynamic> user) async {
    final userId = user['id'] as int?;
    if (userId == null) return;
    setState(() => _followLoadingUserIds.add(userId));
    try {
      final success = await PeopleProfileService.followUser(userId);
      if (success && mounted) {
        _updateUserFollowStatus(userId, isFollowing: false, isPending: true);
      }
    } finally {
      if (mounted) setState(() => _followLoadingUserIds.remove(userId));
    }
  }

  void _updateUserFollowStatus(int userId, {required bool isFollowing, required bool isPending}) {
    for (final u in _allFollowers) {
      if (u['id'] == userId) {
        u['is_following'] = isFollowing;
        u['is_following_pending'] = isPending;
        break;
      }
    }
    for (final u in _allFollowings) {
      if (u['id'] == userId) {
        u['is_following'] = isFollowing;
        u['is_following_pending'] = isPending;
        break;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _searchControllerFollowers = TextEditingController();
    _searchControllerFollowing = TextEditingController();
    _scrollControllerFollowers = ScrollController();
    _scrollControllerFollowing = ScrollController();
    _allFollowers = List.from(widget.initialFollowers);
    _allFollowings = List.from(widget.initialFollowings);
    _hasMoreFollowers = widget.initialFollowers.length >= ProfileFollowListScreen._perPage;
    _hasMoreFollowings = widget.initialFollowings.length >= ProfileFollowListScreen._perPage;
    _scrollControllerFollowers.addListener(_onScrollFollowers);
    _scrollControllerFollowing.addListener(_onScrollFollowing);
    _tabController.addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _searchControllerFollowers.dispose();
    _searchControllerFollowing.dispose();
    _scrollControllerFollowers.removeListener(_onScrollFollowers);
    _scrollControllerFollowers.dispose();
    _scrollControllerFollowing.removeListener(_onScrollFollowing);
    _scrollControllerFollowing.dispose();
    super.dispose();
  }

  void _onScrollFollowers() {
    if (widget.userId == null || _isLoadingMoreFollowers || !_hasMoreFollowers) return;
    final pos = _scrollControllerFollowers.position;
    if (pos.pixels >= pos.maxScrollExtent - 120) _loadMoreFollowers();
  }

  void _onScrollFollowing() {
    if (widget.userId == null || _isLoadingMoreFollowings || !_hasMoreFollowings) return;
    final pos = _scrollControllerFollowing.position;
    if (pos.pixels >= pos.maxScrollExtent - 120) _loadMoreFollowing();
  }

  Future<void> _loadMoreFollowers() async {
    if (widget.userId == null || _isLoadingMoreFollowers || !_hasMoreFollowers) return;
    setState(() => _isLoadingMoreFollowers = true);
    try {
      final list = await PeopleProfileService.fetchUserFollowers(
        widget.userId!,
        page: _pageFollowers,
        perPage: ProfileFollowListScreen._perPage,
      );
      setState(() {
        _allFollowers.addAll(list);
        _pageFollowers++;
        _hasMoreFollowers = list.length >= ProfileFollowListScreen._perPage;
      });
    } catch (_) {
      setState(() => _hasMoreFollowers = false);
    } finally {
      setState(() => _isLoadingMoreFollowers = false);
    }
  }

  Future<void> _loadMoreFollowing() async {
    if (widget.userId == null || _isLoadingMoreFollowings || !_hasMoreFollowings) return;
    setState(() => _isLoadingMoreFollowings = true);
    try {
      final list = await PeopleProfileService.fetchUserFollowing(
        widget.userId!,
        page: _pageFollowings,
        perPage: ProfileFollowListScreen._perPage,
      );
      setState(() {
        _allFollowings.addAll(list);
        _pageFollowings++;
        _hasMoreFollowings = list.length >= ProfileFollowListScreen._perPage;
      });
    } catch (_) {
      setState(() => _hasMoreFollowings = false);
    } finally {
      setState(() => _isLoadingMoreFollowings = false);
    }
  }

  List<Map<String, dynamic>> _getApprovedFollowers(List<Map<String, dynamic>> list) {
    return list.where((f) => f['is_following_pending'] != true).toList();
  }

  List<Map<String, dynamic>> _getDisplayFollowers() {
    final approved = _getApprovedFollowers(_allFollowers);
    final q = _searchControllerFollowers.text.trim().toLowerCase();
    if (q.isEmpty) return approved;
    return approved.where((user) {
      final name = '${user["name"]} ${user["surname"]}'.toLowerCase();
      final username = (user["username"] ?? '').toString().toLowerCase();
      return name.contains(q) || username.contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> _getDisplayFollowings() {
    final q = _searchControllerFollowing.text.trim().toLowerCase();
    if (q.isEmpty) return _allFollowings;
    return _allFollowings.where((user) {
      final name = '${user["name"]} ${user["surname"]}'.toLowerCase();
      final username = (user["username"] ?? '').toString().toLowerCase();
      return name.contains(q) || username.contains(q);
    }).toList();
  }

  Future<void> _refreshFollowers() async {
    if (widget.userId == null) return;
    final list = await PeopleProfileService.fetchUserFollowers(
      widget.userId!,
      page: 1,
      perPage: ProfileFollowListScreen._perPage,
    );
    setState(() {
      _allFollowers = list;
      _pageFollowers = 2;
      _hasMoreFollowers = list.length >= ProfileFollowListScreen._perPage;
    });
  }

  Future<void> _refreshFollowings() async {
    if (widget.userId == null) return;
    final list = await PeopleProfileService.fetchUserFollowing(
      widget.userId!,
      page: 1,
      perPage: ProfileFollowListScreen._perPage,
    );
    setState(() {
      _allFollowings = list;
      _pageFollowings = 2;
      _hasMoreFollowings = list.length >= ProfileFollowListScreen._perPage;
    });
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  Widget _buildUserTile({
    required Map<String, dynamic> user,
    required String sendMessageKey,
  }) {
    final LanguageService languageService = Get.find<LanguageService>();
    final isFollowing = user['is_following'] == true;
    final isPending = user['is_following_pending'] == true;
    final userId = user['id'];
    final isLoadingFollow = userId != null && _followLoadingUserIds.contains(userId);

    const double trailingButtonWidth = 120;
    const double trailingButtonHeight = 36;

    Widget trailingWidget;
    if (isFollowing) {
      trailingWidget = SizedBox(
        width: trailingButtonWidth,
        height: trailingButtonHeight,
        child: TextButton(
          onPressed: () {
            Get.toNamed(Routes.chatDetail, arguments: {
              'userId': user['id'],
              'conversationId': null,
              'name': '${user["name"]} ${user["surname"]}',
              'username': user["username"],
              'avatarUrl': user["avatar_url"] ?? '',
              'isOnline': false,
            });
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xfff0f1f3),
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            languageService.tr(sendMessageKey),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xff414751),
            ),
          ),
        ),
      );
    } else if (isPending) {
      trailingWidget = SizedBox(
        width: trailingButtonWidth,
        height: trailingButtonHeight,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFF8C00).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            languageService.tr("profile.peopleProfile.actions.pendingApproval"),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFF8C00),
            ),
          ),
        ),
      );
    } else {
      trailingWidget = SizedBox(
        width: trailingButtonWidth,
        height: trailingButtonHeight,
        child: TextButton(
          onPressed: isLoadingFollow ? null : () => _onFollowUser(user),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF28A745).withValues(alpha: 0.12),
            foregroundColor: const Color(0xFF28A745),
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: isLoadingFollow
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  languageService.tr("profile.peopleProfile.actions.follow"),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF28A745),
                  ),
                ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () {
          Get.to(() => PeopleProfileScreen(username: user['username']));
        },
        leading: CircleAvatar(
          backgroundColor: const Color(0xffffffff),
          backgroundImage: NetworkImage(user["avatar_url"] ?? ''),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '${user["name"]} ${user["surname"]}',
                style: GoogleFonts.inter(
                  fontSize: 13.28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff414751),
                ),
              ),
            ),
            const SizedBox(width: 2),
            VerificationBadge(
              isVerified: user['is_verified'] ?? false,
              size: 14.0,
            ),
          ],
        ),
        subtitle: Text(
          '@${user["username"]}',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xff9ca3ae),
          ),
        ),
        trailing: trailingWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    final followersLabel = languageService.tr("profile.followers.title");
    final followingLabel = languageService.tr("profile.following.title");

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBar(
        backgroundColor: const Color(0xfffafafa),
        surfaceTintColor: const Color(0xfffafafa),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffffffff),
              ),
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: SvgPicture.asset('images/icons/back_icon.svg'),
              ),
            ),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff272727),
                ),
              ),
              const SizedBox(width: 4),
              VerificationBadge(isVerified: widget.isVerified, size: 18),
            ],
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xff272727),
          unselectedLabelColor: const Color(0xff9ca3ae),
          indicatorColor: const Color(0xFFEF5050),
          labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: '${_formatCount(widget.followerCount)} $followersLabel'),
            Tab(text: '${_formatCount(widget.followingCount)} $followingLabel'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _tabController.index == 0
                ? SearchTextField(
                    controller: _searchControllerFollowers,
                    label: languageService.tr("profile.followers.searchPlaceholder"),
                    onChanged: (_) => setState(() {}),
                  )
                : SearchTextField(
                    controller: _searchControllerFollowing,
                    label: languageService.tr("profile.following.searchPlaceholder"),
                    onChanged: (_) => setState(() {}),
                  ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(
                  displayList: _getDisplayFollowers(),
                  scrollController: _scrollControllerFollowers,
                  isLoadingMore: _isLoadingMoreFollowers,
                  onRefresh: _refreshFollowers,
                  searchPlaceholder: "profile.followers.searchPlaceholder",
                  sendMessageKey: "profile.followers.sendMessage",
                ),
                _buildList(
                  displayList: _getDisplayFollowings(),
                  scrollController: _scrollControllerFollowing,
                  isLoadingMore: _isLoadingMoreFollowings,
                  onRefresh: _refreshFollowings,
                  searchPlaceholder: "profile.following.searchPlaceholder",
                  sendMessageKey: "profile.following.sendMessage",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList({
    required List<Map<String, dynamic>> displayList,
    required ScrollController scrollController,
    required bool isLoadingMore,
    required Future<void> Function() onRefresh,
    required String searchPlaceholder,
    required String sendMessageKey,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFFEF5050),
      backgroundColor: const Color(0xfffafafa),
      strokeWidth: 2.0,
      displacement: 40.0,
      child: ListView.builder(
        controller: scrollController,
        itemCount: displayList.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= displayList.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final user = displayList[index];
          return _buildUserTile(
            user: user,
            sendMessageKey: sendMessageKey,
          );
        },
      ),
    );
  }
}
