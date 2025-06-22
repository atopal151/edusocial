import 'package:edusocial/controllers/social/chat_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatDetailBody extends StatefulWidget {
  const ChatDetailBody({super.key});

  @override
  State<ChatDetailBody> createState() => _ChatDetailBodyState();
}

class _ChatDetailBodyState extends State<ChatDetailBody> {
  late final ScrollController documentsScrollController;
  late final ScrollController linksScrollController;
  late final ScrollController photosScrollController;
  
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
  }

  @override
  void dispose() {
    documentsScrollController.dispose();
    linksScrollController.dispose();
    photosScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatDetailController>();
    final userChatDetail = chatController.userChatDetail.value!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // GRUP GÖRSELİ VE BAŞLIĞI
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 117,
                  width: 117,
                  child: CircleAvatar(
                    backgroundColor: Color(0xffffffff),
                    radius: 50,
                    backgroundImage: NetworkImage(getFullUrl(userChatDetail.imageUrl)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userChatDetail.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff272727),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Color(0xff2c96ff),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Color(0xffffffff),
                        size: 16,
                        
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

         
          const SizedBox(height: 24),

          SizedBox(
            width: 150,
            child: Center(
              child: buildMemberAvatars(userChatDetail.memberImageUrls),
            ),
          ),
          const SizedBox(height: 10),

          // TABS: Belgeler / Bağlantılar / Fotoğraflar
          DefaultTabController(
            length: 3,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TabBar(
                    dividerColor: const Color(0xfffafafa),
                    dividerHeight: 3,
                    labelColor: const Color(0xffef5050),
                    indicatorColor: const Color(0xffef5050),
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(width: 2.0, color: Color(0xffef5050)),
                      insets: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.28,
                    ),
                    tabs: const [
                      Tab(text: "Belgeler"),
                      Tab(text: "Bağlantılar"),
                      Tab(text: "Fotoğraflar"),
                    ],
                  ),
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
                          radius: const Radius.circular(15),
                          child: ListView.builder(
                            controller: documentsScrollController,
                            itemCount: userChatDetail.documents.length,
                            itemBuilder: (context, index) {
                              final doc = userChatDetail.documents[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff5f6f7),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: SvgPicture.asset(
                                    "images/icons/document_icon.svg",
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xff9ca3ae),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  doc.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff414751),
                                  ),
                                ),
                                subtitle: Text(
                                  "${doc.sizeMb} Mb • ${DateFormat('dd.MM.yyyy').format(doc.createdAt)}",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff9ca3ae),
                                  ),
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
                          radius: const Radius.circular(15),
                          child: ListView.builder(
                            controller: linksScrollController,
                            itemCount: userChatDetail.links.length,
                            itemBuilder: (context, index) {
                              final link = userChatDetail.links[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff5f6f7),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Transform.rotate(
                                    angle: -45 * 3.1415926535 / 180,
                                    child: const Icon(
                                      Icons.link,
                                      color: Color(0xff9ca3ae),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  link.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff414751),
                                  ),
                                ),
                                subtitle: Text(
                                  link.url,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff9ca3ae),
                                  ),
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
                          radius: const Radius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 16,
                              top: 8,
                              bottom: 8,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: GridView.builder(
                                  controller: photosScrollController,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                  ),
                                  itemCount: userChatDetail.photoUrls.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(0.6),
                                      child: Image.network(
                                        getFullUrl(userChatDetail.photoUrls[index]),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          debugPrint('Error loading image: $error');
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMemberAvatars(List<String> memberImageUrls) {
    return Stack(
      children: [
        for (var i = 0; i < memberImageUrls.length && i < 3; i++)
          Positioned(
            left: i * 20.0,
            child: CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(getFullUrl(memberImageUrls[i])),
            ),
          ),
      ],
    );
  }
} 