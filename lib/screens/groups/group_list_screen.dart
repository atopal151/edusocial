import 'package:edusocial/components/user_appbar/group_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/group_controller.dart';
import '../../components/cards/group_card.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupController controller = Get.find();

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: GroupAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Bulunduğun Gruplar",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.userGroups.length,
                  itemBuilder: (context, index) {
                    final group = controller.userGroups[index];
                    return InkWell(
                      onTap: () {
                        controller.getToGroupChatDetail();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GroupCard(
                          chatNotification: 10,
                          imageUrl: group.imageUrl,
                          groupName: group.name,
                          groupDescription: group.description,
                          memberCount: group.memberCount,
                          action: "Katıldınız",
                          onJoinPressed: () {},
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tüm Gruplar",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 30,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.categories.length,
                        itemBuilder: (context, index) {
                          final category = controller.categories[index];
                          return Obx(() {
                            final isSelected =
                                controller.selectedCategory.value == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => controller.selectedCategory.value =
                                    category,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Color(0xffef5050).withAlpha(20)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Color(0xffef5050)
                                          : Color(0xff414751),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = controller.filteredGroups[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GroupCard(
                          category: ["Flutter", "Mobil", "Yazılım"], // 👈 burası yeni
                          imageUrl: group.imageUrl,
                          groupName: group.name,
                          groupDescription: group.description,
                          memberCount: group.memberCount,
                          action: group.isJoined ? "Katıldınız" : "Katıl",
                          onJoinPressed: () => controller.joinGroup(group.id),
                        ),
                      );
                    },
                  )),
            ],
          ),
        );
      }),
    );
  }
}
