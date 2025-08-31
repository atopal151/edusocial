import 'package:edusocial/components/user_appbar/group_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/buttons/custom_button.dart';
import '../../controllers/group_controller/group_controller.dart';
import '../../components/cards/group_card.dart';
import '../../services/language_service.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupController controller = Get.find();
    final LanguageService languageService = Get.find<LanguageService>();

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: GroupAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: Color(0xFFef5050),));
        }

        return RefreshIndicator(
          color: Color(0xFFef5050),
          backgroundColor: Color(0xfffafafa),
          elevation: 0,
          onRefresh: () async {
            await controller.fetchUserGroups();
            await controller.fetchAllGroups();
            await controller.fetchGroupAreas();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                  child: CustomButton(
                    height: 45,
                    borderRadius: 15,
                    text: languageService.tr("groups.groupList.createGroupButton"),
                    onPressed: () {
                      controller.getCreateGroup();
                    },
                    isLoading: controller.isGroupLoading,
                    backgroundColor: Color(0xfffb535c),
                    textColor: Color(0xffffffff),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(languageService.tr("groups.groupList.myGroups"),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Obx(() {
                  debugPrint("🔍 GroupListScreen - Obx widget triggered, userGroups.length: ${controller.userGroups.length}");
                  debugPrint("🔍 GroupListScreen - isLoading: ${controller.isLoading.value}");
                  debugPrint("🔍 GroupListScreen - userGroups.isEmpty: ${controller.userGroups.isEmpty}");
                  
                  if (controller.userGroups.isEmpty && !controller.isLoading.value) {
                    debugPrint("⚠️ GroupListScreen - userGroups boş ve loading değil!");
                  }
                  
                  return SizedBox(
                    height: 210,
                    child: controller.userGroups.isEmpty && !controller.isLoading.value
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.group_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  languageService.tr("groups.groupList.noGroups"),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  languageService.tr("groups.groupList.joinGroupsBelow"),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.userGroups.length,
                            itemBuilder: (context, index) {
                            // DEBUG: Print userGroups length and current group
                            debugPrint("🔍 GroupListScreen - userGroups.length: ${controller.userGroups.length}, building index: $index");
                            final group = controller.userGroups[index];
                            debugPrint("🔍 GroupListScreen - building group: ${group.name} (ID: ${group.id})");
                            return InkWell(
                              onTap: () {
                                controller.getToGroupChatDetail(group.id);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: GroupCard(
                                  chatNotification: group.messageCount,
                                  imageUrl: group.bannerUrl,
                                  groupName: group.name,
                                  groupDescription: group.description,
                                  memberCount: group.userCountWithAdmin,
                                  action: languageService.tr("groups.groupList.joined"),
                                  onJoinPressed: () {},
                                  isFounder: group.isFounder,
                                ),
                              ),
                            );
                          },
                        ),
                  ); 
                }),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(languageService.tr("groups.groupList.allGroups"),
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
                                          fontSize: 12),
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
                            category: [], // 👈 kategoriler varsa eklenir
                            imageUrl: group.bannerUrl,
                            groupName: group.name,
                            groupDescription: group.description,
                            memberCount: group.userCountWithAdmin,
                            action: controller.getButtonText(group, languageService),
                            onJoinPressed: () {
                              controller.handleGroupJoin(group.id);
                            },
                          ),
                        );
                      },
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }
}
