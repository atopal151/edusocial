import 'package:edusocial/components/cards/event_card.dart';
import 'package:edusocial/controllers/group_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../components/cards/members_avatar.dart';
import '../../components/widgets/group_detail_tree_point_bottom_sheet.dart'
    show GroupDetailTreePointBottomSheet;

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupController groupController = Get.put(GroupController());
  late ScrollController documentsScrollController;
  late ScrollController linksScrollController;
  late ScrollController photosScrollController;
  @override
  void initState() {
    super.initState();
    documentsScrollController = ScrollController();
    linksScrollController = ScrollController();
    photosScrollController = ScrollController();
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
      // binlik ayraç eklemek için
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
                padding: const EdgeInsets.only(left: 8), // soldan biraz boşluk
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
          SizedBox(
            width: 10,
          )
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
                          /// Kapak fotoğrafı
                          Container(
                            height: 95,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(group.coverImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          /// Profil fotoğrafı
                          Positioned(
                            bottom: -30,
                            left: MediaQuery.of(context).size.width / 2 - 55,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 36,
                                backgroundImage: NetworkImage(group.imageUrl),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      /// Grup adı + doğrulama
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
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle,
                              color: Color(0xff2c96ff), size: 18),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                InkWell(
                  onTap: () {
                    Get.toNamed("/followers");
                  },
                  child: SizedBox(
                    width: 150, // genişlik ihtiyacına göre ayarlanabilir
                    child: Center(
                      child: buildMemberAvatars(group.memberImageUrls),
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
                                DateFormat('dd.MM.yyyy')
                                    .format(group.createdAt),
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
                    SizedBox(
                      width: 10,
                    ),
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
                                  formatMemberCount(group.memberCount),
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
                              insets: EdgeInsets.symmetric(
                                  horizontal: 16.0), // genişlik daraltma
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
                                          child: Icon(
                                            Icons.insert_drive_file,
                                            color: Color(0xff9ca3ae),
                                          )),
                                      title: Text(
                                        doc.name,
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff414751)),
                                      ),
                                      subtitle: Text(
                                        "${doc.sizeMb} Mb • ${DateFormat('dd.MM.yyyy').format(doc.date)}",
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff9ca3ae)),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // BAĞLANTILAR
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
                                              angle: -45 *
                                                  3.1415926535 /
                                                  180, // -45 dereceyi radyana çevirdik
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
                              ),

                              // FOTOĞRAFLAR
                              Scrollbar(
                                controller: photosScrollController,
                                trackVisibility: true,
                                thumbVisibility: true,
                                thickness: 5,
                                radius: Radius.circular(15),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 16, top: 8, bottom: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        20), // Container ile aynı radius
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
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
                                            padding: const EdgeInsets.all(0.6),
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
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // ETKİNLİKLER
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
                            eventDescription: event.title,
                            eventDate: event.date,
                            eventImage: event.image,
                            onShare: () {},
                            onLocation: () {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
