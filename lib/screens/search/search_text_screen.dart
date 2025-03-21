import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/search_text_controller.dart';
import '../../components/lists/user_list.dart';
import '../../components/lists/group_list.dart';
import '../../components/cards/event_card.dart';

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
                    controller: controller.searchTextController,
                    onChanged: (value) => controller.filterResults(value),
                    decoration: InputDecoration(
                      hintText: "Ara...",
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
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 18),
                        SizedBox(width: 6),
                        Text("Kişiler",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined, size: 18),
                        SizedBox(width: 6),
                        Text("Gruplar",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event, size: 18),
                        SizedBox(width: 6),
                        Text("Etkinlikler",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
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
                          eventDate: event.date,
                          eventImage: event.image,
                          onShare: () {
                            Get.snackbar("Paylaşıldı",
                                "${event.title} etkinliği paylaşıldı.");
                          },
                          onLocation: () {
                            Get.snackbar("Konum Görüntülendi",
                                "${event.title} etkinliğinin konumu açıldı.");
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
