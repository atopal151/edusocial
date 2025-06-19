import 'package:edusocial/components/cards/event_card.dart';
import 'package:edusocial/controllers/group_controller/group_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/cards/members_avatar.dart';
import '../../components/widgets/group_detail_tree_point_bottom_sheet.dart'
    show GroupDetailTreePointBottomSheet;
import '../../controllers/social/group_chat_detail_controller.dart';
import '../../models/chat_models/group_message_model.dart';
import '../../components/widgets/group_chat_widget/group_text_message_widget.dart';
import '../../components/widgets/group_chat_widget/group_document_message_widget.dart';
import '../../components/widgets/group_chat_widget/group_image_message_widget.dart';
import '../../components/widgets/group_chat_widget/group_link_messaje_widget.dart';
import '../../components/widgets/group_chat_widget/group_poll_message_widget.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupController groupController = Get.put(GroupController());
  final GroupChatDetailController chatController = Get.put(GroupChatDetailController());
  late ScrollController documentsScrollController;
  late ScrollController linksScrollController;
  late ScrollController photosScrollController;

  @override
  void initState() {
    super.initState();
    documentsScrollController = ScrollController();
    linksScrollController = ScrollController();
    photosScrollController = ScrollController();

    // Get group ID from arguments
    final groupId = Get.arguments?['groupId'];
    if (groupId != null) {
      debugPrint('🔍 Fetching details for group: $groupId');
      // Use Future.microtask to avoid build-time state updates
      Future.microtask(() {
        groupController.fetchGroupDetail(groupId);
        chatController.currentGroupId.value = groupId;
        chatController.fetchGroupDetails();
        chatController.fetchGroupMessages();
      });
    } else {
      debugPrint('❌ No group ID provided in arguments');
      // Use Future.microtask to avoid build-time navigation
      Future.microtask(() {
        Get.snackbar(
          'Error',
          'No group selected',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      });
    }
  }

  @override
  void dispose() {
    documentsScrollController.dispose();
    linksScrollController.dispose();
    photosScrollController.dispose();
    super.dispose();
  }

  String formatMemberCount(int count) {
    if (count >= 10000) {
      return '${(count / 1000).floor()}k';
    } else {
      return count.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: AppBar(
        backgroundColor: Color(0xfffafafa),
        surfaceTintColor: Color(0xfffafafa),
        leading: Center(
          child: InkWell(
            onTap: () {
              Get.back();
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Color(0xff414751),
                ),
              ),
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                backgroundColor: Colors.white,
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                builder: (context) => const GroupDetailTreePointBottomSheet(),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  borderRadius: BorderRadius.circular(50)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.more_vert),
              ),
            ),
          ),
          SizedBox(width: 10)
        ],
      ),
      body: Obx(
        () {
          final group = groupController.groupDetail.value;
          if (group == null) return Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // GRUP GÖRSELİ VE BAŞLIĞI
                Center(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Kapak fotoğrafı
                          Container(
                            height: 95,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(group.bannerUrl ?? ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Profil fotoğrafı
                          Positioned(
                            bottom: -30,
                            left: MediaQuery.of(context).size.width / 2 - 55,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 36,
                                backgroundImage:
                                    NetworkImage(group.avatarUrl ?? ''),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      // Grup adı + doğrulama
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            group.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (group.isFounder) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle,
                                color: Color(0xff2c96ff), size: 18),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Üye avatarları
                InkWell(
                  onTap: () {
                    Get.toNamed("/followers");
                  },
                  child: SizedBox(
                    width: 150,
                    child: Center(
                      child: buildMemberAvatars([]),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  child: Text(
                    textAlign: TextAlign.center,
                    group.description,
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff9ca3ae)),
                  ),
                ),
                SizedBox(height: 12),

                // KURULUŞ TARİHİ VE ÜYE SAYISI
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffffffff),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "Oluşturuldu",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                  color: Color(0xff9ca3ae),
                                ),
                              ),
                              Text(
                                group.humanCreatedAt,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.28,
                                  color: Color(0xff414751),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.toNamed("/followers");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  "Katılımcı Sayısı",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10,
                                    color: Color(0xff9ca3ae),
                                  ),
                                ),
                                Text(
                                  formatMemberCount(group.userCountWithAdmin),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.28,
                                    color: Color(0xff414751),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // TABS: Belgeler / Bağlantılar / Fotoğraflar
                DefaultTabController(
                  length: 3,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        TabBar(
                            dividerColor: Color(0xfffafafa),
                            dividerHeight: 3,
                            labelColor: Color(0xffef5050),
                            indicatorColor: Color(0xffef5050),
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                  width: 2.0, color: Color(0xffef5050)),
                              insets: EdgeInsets.symmetric(horizontal: 16.0),
                            ),
                            labelStyle: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, fontSize: 13.28),
                            tabs: [
                              Tab(text: "Belgeler"),
                              Tab(text: "Bağlantılar"),
                              Tab(text: "Fotoğraflar"),
                            ]),
                        SizedBox(
                          height: 350,
                          child: TabBarView(
                            children: [
                              // BELGELER
                              if (group.documents.isNotEmpty)
                                Scrollbar(
                                  controller: documentsScrollController,
                                  trackVisibility: true,
                                  thumbVisibility: true,
                                  thickness: 5,
                                  radius: Radius.circular(15),
                                  child: ListView.builder(
                                    controller: documentsScrollController,
                                    itemCount: group.documents.length,
                                    itemBuilder: (context, index) {
                                      final doc = group.documents[index];
                                      return ListTile(
                                        leading: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: Color(0xfff5f6f7),
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: SvgPicture.asset(
                                              "images/icons/document_icon.svg",
                                              colorFilter: ColorFilter.mode(
                                                Color(0xff9ca3ae),
                                                BlendMode.srcIn,
                                              ),
                                            )),
                                        title: Text(
                                          doc.name,
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xff414751)),
                                        ),
                                        subtitle: Text(
                                          "${doc.sizeMb} Mb • ${doc.humanCreatedAt}",
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xff9ca3ae)),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              else
                                Center(
                                  child: Text(
                                    "Henüz belge eklenmemiş",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Color(0xff9ca3ae),
                                    ),
                                  ),
                                ),

                              // BAĞLANTILAR
                              if (group.links.isNotEmpty)
                                Scrollbar(
                                  controller: linksScrollController,
                                  trackVisibility: true,
                                  thumbVisibility: true,
                                  thickness: 5,
                                  radius: Radius.circular(15),
                                  child: ListView.builder(
                                    controller: linksScrollController,
                                    itemCount: group.links.length,
                                    itemBuilder: (context, index) {
                                      final link = group.links[index];
                                      return ListTile(
                                        leading: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: Color(0xfff5f6f7),
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Transform.rotate(
                                                angle: -45 * 3.1415926535 / 180,
                                                child: Icon(
                                                  Icons.link,
                                                  color: Color(0xff9ca3ae),
                                                ))),
                                        title: Text(
                                          link.title,
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xff414751)),
                                        ),
                                        subtitle: Text(
                                          link.url,
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xff9ca3ae)),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              else
                                Center(
                                  child: Text(
                                    "Henüz bağlantı eklenmemiş",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Color(0xff9ca3ae),
                                    ),
                                  ),
                                ),

                              // FOTOĞRAFLAR
                              if (group.photoUrls.isNotEmpty)
                                Scrollbar(
                                  controller: photosScrollController,
                                  trackVisibility: true,
                                  thumbVisibility: true,
                                  thickness: 5,
                                  radius: Radius.circular(15),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 16,
                                        top: 8,
                                        bottom: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: GridView.builder(
                                          controller: photosScrollController,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                          ),
                                          itemCount: group.photoUrls.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(0.6),
                                              child: Image.network(
                                                group.photoUrls[index],
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Center(
                                  child: Text(
                                    "Henüz fotoğraf eklenmemiş",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Color(0xff9ca3ae),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // ETKİNLİKLER
                if (group.events != null && group.events.isNotEmpty) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Grup Etkinlikleri",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: group.events.length,
                        itemBuilder: (context, index) {
                          final event = group.events[index];
                          return EventCard(
                              eventTitle: event.title,
                              eventDescription: event.description,
                              eventDate: event.humanStartTime,
                              eventImage: event.bannerUrl,
                              onShare: () {},
                              onLocation: () {});
                        },
                      ),
                    ],
                  ),
                ],

                // GRUP ETKİNLİKLERİ (group_events)
                if (group.groupEvents != null && group.groupEvents.isNotEmpty) ...[
                  SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Grup Etkinlikleri",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff414751),
                          )),
                      SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: group.groupEvents.length,
                        itemBuilder: (context, index) {
                          final event = group.groupEvents[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Event banner image
                                if (event.bannerUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                      event.bannerUrl,
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                        height: 120,
                                        color: Color(0xfff5f6f7),
                                        child: Icon(
                                          Icons.event,
                                          color: Color(0xff9ca3ae),
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Event title
                                      Text(
                                        event.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff414751),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // Event description
                                      if (event.description.isNotEmpty)
                                        Text(
                                          event.description,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff9ca3ae),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      SizedBox(height: 12),
                                      // Event details row
                                      Row(
                                        children: [
                                          // Date
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 14,
                                                  color: Color(0xff9ca3ae),
                                                ),
                                                SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    event.humanStartTime,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w400,
                                                      color: Color(0xff9ca3ae),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Location
                                          if (event.location.isNotEmpty)
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 14,
                                                    color: Color(0xff9ca3ae),
                                                  ),
                                                  SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      "Konum",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color(0xff9ca3ae),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      // Action buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                // Share event
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Color(0xfff5f6f7),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.share,
                                                      size: 14,
                                                      color: Color(0xff9ca3ae),
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      "Paylaş",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xff9ca3ae),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () async {
                                                // Open location
                                                if (event.location.isNotEmpty) {
                                                  final uri = Uri.parse(event.location);
                                                  if (await canLaunchUrl(uri)) {
                                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                  }
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Color(0xfff5f6f7),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 14,
                                                      color: Color(0xff9ca3ae),
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      "Konum",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xff9ca3ae),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
