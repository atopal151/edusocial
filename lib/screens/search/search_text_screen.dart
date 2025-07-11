import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/search_text_controller.dart';
import '../../components/lists/user_list.dart';
import '../../components/lists/group_list.dart';
import '../../components/cards/event_card.dart';
import '../../services/language_service.dart';

class SearchTextScreen extends StatefulWidget {
  const SearchTextScreen({super.key});

  @override
  State<SearchTextScreen> createState() => _SearchTextScreenState();
}

class _SearchTextScreenState extends State<SearchTextScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SearchTextController controller = Get.find();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();
    
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      appBar: AppBar(
        backgroundColor: Color(0xfffafafa),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xffffffff)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SvgPicture.asset(
                    'images/icons/back_icon.svg',
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.all(Radius.circular(40))),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: TextField(
                    style: GoogleFonts.inter(
                        fontSize: 13.28, fontWeight: FontWeight.w600),
                    controller: controller.searchTextController,
                    onChanged: (value) {
                      controller
                          .fetchSearchResults(value); // backend'den veri getir
                      controller
                          .filterResults(value); // gelen verilerde filtrele
                    },
                    decoration: InputDecoration(
                      hintText: languageService.tr("search.searchField.placeholder"),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          // TabBar
          Container(
            height: 50,
            color: Color(0xfff2f2f2),
            child: DefaultTabController(
              length: 3,
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Color(0xffffffff)),
                dividerColor: Colors.transparent,
                labelColor: Color(0xff414751),
                unselectedLabelColor: Color(0xffd9d9d9),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "images/icons/profile_icon_settings.svg",
                          colorFilter: ColorFilter.mode(
                            Color(0xffd9d9d9),
                            BlendMode.srcIn,
                          ),
                          height: 18,
                          width: 18,
                        ),
                        SizedBox(width: 8),
                        Text(languageService.tr("search.tabs.people"),
                            style: GoogleFonts.inter(
                                fontSize: 13.28, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "images/icons/group_icon.svg",
                          colorFilter: ColorFilter.mode(
                            Color(0xffd9d9d9),
                            BlendMode.srcIn,
                          ),
                          height: 18,
                          width: 18,
                        ),
                        SizedBox(width: 8),
                        Text(languageService.tr("search.tabs.groups"),
                            style: GoogleFonts.inter(
                                fontSize: 13.28, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "images/icons/event.svg",
                          colorFilter: ColorFilter.mode(
                            Color(0xffd9d9d9),
                            BlendMode.srcIn,
                          ),
                          height: 18,
                          width: 18,
                        ),
                        SizedBox(width: 8),
                        Text(languageService.tr("search.tabs.events"),
                            style: GoogleFonts.inter(
                                fontSize: 13.28, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Kişiler Listesi
                Obx(() => ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: controller.filteredUsers.length,
                      itemBuilder: (context, index) {
                        var user = controller.filteredUsers[index];
                        return UserListItem(user: user);
                      },
                    )),

                // Gruplar Listesi
                Obx(() => ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: controller.filteredGroups.length,
                      itemBuilder: (context, index) {
                        var group = controller.filteredGroups[index];
                        return GroupListItem(group: group);
                      },
                    )),

                // Etkinlikler Listesi
                Obx(() => ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: controller.filteredEvents.length,
                      itemBuilder: (context, index) {
                        var event = controller.filteredEvents[index];
                        return EventCard(
                          eventTitle: event.title,
                          eventDescription: event.description,
                          eventDate: formatSimpleDateClock(event.endTime),
                          eventImage: event.bannerUrl,
                          onShare: () {
                            Get.snackbar(languageService.tr("common.messages.success"),
                                "${event.title} ${languageService.tr("event.notifications.shared")}");
                          },
                          onLocation: () async {
                            final url = event.location;
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {
                              Get.snackbar(languageService.tr("common.messages.error"), 
                                  languageService.tr("event.notifications.locationView"));
                            }
                          },
                        );
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
