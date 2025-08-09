import 'package:edusocial/components/cards/event_card.dart';
import 'package:edusocial/components/widgets/custom_loading_indicator.dart';
import 'package:edusocial/controllers/group_controller/group_controller.dart';
import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/language_service.dart';

import '../../components/cards/members_avatar.dart';
import '../../components/widgets/group_detail_tree_point_bottom_sheet.dart'
    show GroupDetailTreePointBottomSheet;
import '../../controllers/chat_controllers/group_chat_detail_controller.dart';
import '../../models/chat_models/group_message_model.dart';
import '../../models/document_model.dart';
import '../../models/link_model.dart';
import '../../screens/groups/group_participants_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupController groupController = Get.put(GroupController());
  final GroupChatDetailController chatController =
      Get.find<GroupChatDetailController>();
  late ScrollController documentsScrollController;
  late ScrollController linksScrollController;
  late ScrollController photosScrollController;

  // Base URL for images
  static const String baseUrl = 'https://stageapi.edusocial.pl/storage/';

  String getFullUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }

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
        chatController.fetchGroupDetailsOptimized();
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
    final LanguageService languageService = Get.find<LanguageService>();
    
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
          if (group == null) {
            return Center(
              child: CustomLoadingIndicator(
                size: 48,
                color: const Color(0xFFEF5050),
              ),
            );
          }

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
                    Get.to(() => GroupParticipantsScreen());
                  },
                  child: SizedBox(
                    width: 150,
                    child: Center(
                      child: Column(
                        children: [
                          buildMemberAvatars(
                            group.users
                                .map((user) =>
                                    (user['avatar_url'] ?? '').toString())
                                .toList(),
                          ),
                          // Debug bilgisi
                          if (group.users.isEmpty)
                            Text(
                              languageService.tr("groups.groupDetail.noParticipants"),
                              style: TextStyle(
                                  fontSize: 10, color: Color(0xff9ca3ae)),
                            ),
                        ],
                      ),
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
                                languageService.tr("groups.groupDetail.created"),
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
                          Get.to(() => GroupParticipantsScreen());
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
                                  languageService.tr("groups.groupDetail.participantCount"),
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

                // GRUP MESAJLAŞMA VERİLERİ: Belgeler / Bağlantılar / Fotoğraflar
                if (chatController.groupDocuments.isNotEmpty ||
                    chatController.groupLinks.isNotEmpty ||
                    chatController.groupPhotos.isNotEmpty) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    insets:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                  ),
                                  labelStyle: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.28),
                                  tabs: [
                                    Tab(text: languageService.tr("groups.groupDetail.tabs.documents")),
                                    Tab(text: languageService.tr("groups.groupDetail.tabs.links")),
                                    Tab(text: languageService.tr("groups.groupDetail.tabs.photos")),
                                  ]),
                              SizedBox(
                                height: 350,
                                child: TabBarView(
                                  children: [
                                    // GRUP CHAT BELGELERİ
                                    Obx(() {
                                      // Hem grup chat verilerinden hem de grup mesajlarından belgeleri birleştir
                                      final allDocuments = <DocumentModel>[];

                                      // Grup chat verilerinden belgeler
                                      allDocuments.addAll(
                                          chatController.groupDocuments);

                                      // Grup mesajlarından document türündeki mesajları belge olarak ekle
                                      for (final message
                                          in chatController.messages) {
                                        if (message.messageType ==
                                            GroupMessageType.document) {
                                          // Mesaj ID'sini belge ID'si olarak kullan
                                          final document = DocumentModel(
                                            id: message.id,
                                            name:
                                                '${languageService.tr("groups.groupDetail.document")} - ${message.name} ${message.surname}',
                                            sizeMb: 0.0, // Boyut bilgisi yok
                                            humanCreatedAt:
                                                DateFormat('dd.MM.yyyy HH:mm')
                                                    .format(message.timestamp),
                                            createdAt: message.timestamp,
                                            url:
                                                message.content, // Belge URL'si
                                          );

                                          // Aynı belgeyi tekrar eklemeyi önle
                                          if (!allDocuments.any(
                                              (doc) => doc.id == document.id)) {
                                            allDocuments.add(document);
                                          }
                                        }
                                      }

                                      // Belgeleri tarihe göre sırala (en yeni önce)
                                      allDocuments.sort((a, b) =>
                                          b.createdAt.compareTo(a.createdAt));

                                      return allDocuments.isNotEmpty
                                          ? Scrollbar(
                                              controller:
                                                  documentsScrollController,
                                              trackVisibility: true,
                                              thumbVisibility: true,
                                              thickness: 5,
                                              radius: Radius.circular(15),
                                              child: ListView.builder(
                                                controller:
                                                    documentsScrollController,
                                                itemCount: allDocuments.length,
                                                itemBuilder: (context, index) {
                                                  final doc =
                                                      allDocuments[index];
                                                  return ListTile(
                                                    onTap: () async {
                                                      // Belgeyi açmak için URL'yi kullan
                                                      if (doc.url != null &&
                                                          doc.url!.isNotEmpty) {
                                                        final uri =
                                                            Uri.parse(doc.url!);
                                                        if (await canLaunchUrl(
                                                            uri)) {
                                                          await launchUrl(uri,
                                                              mode: LaunchMode
                                                                  .externalApplication);
                                                        }
                                                      }
                                                    },
                                                    leading: Container(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                0xfff5f6f7),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50)),
                                                        child: SvgPicture.asset(
                                                          "images/icons/document_icon.svg",
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                            Color(0xff9ca3ae),
                                                            BlendMode.srcIn,
                                                          ),
                                                        )),
                                                    title: Text(
                                                      doc.name,
                                                      style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color(
                                                              0xff414751)),
                                                    ),
                                                    subtitle: Text(
                                                      "${doc.sizeMb} Mb • ${doc.humanCreatedAt}",
                                                      style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color(
                                                              0xff9ca3ae)),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Center(
                                              child: Text(
                                                languageService.tr("groups.groupDetail.emptyStates.documents"),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Color(0xff9ca3ae),
                                                ),
                                              ),
                                            );
                                    }),

                                    // GRUP CHAT BAĞLANTILARI
                                    Obx(() {
                                      // Linkleri tarihe göre sırala (en yeni en üstte)
                                      final sortedLinks = List<LinkModel>.from(chatController.groupLinks);
                                      // Link'lerin tarih bilgisi yok, mesaj sırasına göre sırala
                                      // Bu durumda mesaj sırasına göre sırala (en son eklenen en üstte)
                                      
                                      return sortedLinks.isNotEmpty
                                        ? Scrollbar(
                                            controller: linksScrollController,
                                            trackVisibility: true,
                                            thumbVisibility: true,
                                            thickness: 5,
                                            radius: Radius.circular(15),
                                            child: ListView.builder(
                                              controller: linksScrollController,
                                              itemCount: sortedLinks.length,
                                              itemBuilder: (context, index) {
                                                final link = sortedLinks[index];
                                                return ListTile(
                                                  onTap: () async {
                                                    final uri =
                                                        Uri.parse(link.url);
                                                    if (await canLaunchUrl(
                                                        uri)) {
                                                      await launchUrl(uri,
                                                          mode: LaunchMode
                                                              .externalApplication);
                                                    }
                                                  },
                                                  leading: Container(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xfff5f6f7),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50)),
                                                      child: Transform.rotate(
                                                          angle: -45 *
                                                              3.1415926535 /
                                                              180,
                                                          child: Icon(
                                                            Icons.link,
                                                            color: Color(
                                                                0xff9ca3ae),
                                                          ))),
                                                  title: Text(
                                                    link.title,
                                                    style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xff414751)),
                                                  ),
                                                  subtitle: Text(
                                                    link.url,
                                                    style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xff9ca3ae)),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              languageService.tr("groups.groupDetail.emptyStates.links"),
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: Color(0xff9ca3ae),
                                              ),
                                            ),
                                          );
                                    }),

                                    // GRUP CHAT FOTOĞRAFLARI
                                    Obx(() {
                                      // Fotoğrafları tarihe göre sırala (en yeni en üstte)
                                      final sortedPhotos = List<String>.from(chatController.groupPhotos);
                                      // Fotoğraflar mesaj sırasına göre zaten sıralı geliyor
                                      
                                      return sortedPhotos.isNotEmpty
                                        ? Scrollbar(
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
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: GridView.builder(
                                                    controller:
                                                        photosScrollController,
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                    ),
                                                    itemCount: sortedPhotos.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.6),
                                                        child: Image.network(
                                                          getFullUrl(sortedPhotos[index]),
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            debugPrint(
                                                                'Error loading image: $error');
                                                            return const Icon(
                                                                Icons.error);
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              languageService.tr("groups.groupDetail.emptyStates.photos"),
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: Color(0xff9ca3ae),
                                              ),
                                            ),
                                          );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],

                // ETKİNLİKLER
                if (group.groupEvents.isNotEmpty) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(languageService.tr("groups.groupDetail.groupEvents"),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: group.groupEvents.length,
                        itemBuilder: (context, index) {
                          final event = group.groupEvents[index];
                          return EventCard(
                              eventTitle: event.title,
                              eventDescription: event.description,
                              eventDate: formatSimpleDateClock(event.endTime),
                              eventImage: event.bannerUrl,
                              onShare: () {},
                              onLocation: () async {
                                if (event.location.isNotEmpty) {
                                  final uri = Uri.parse(event.location);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  }
                                }
                              });
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
