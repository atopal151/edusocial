import 'package:flutter/material.dart';

class ProfileTabBar extends StatelessWidget {
  final TabController tabController;

  const ProfileTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        indicatorColor: Colors.red,
        dividerColor: Colors.transparent,
        labelColor: Colors.red,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(icon: Icon(Icons.grid_view)),
          Tab(icon: Icon(Icons.person_search_sharp)),
        ],
      ),
    );
  }
}
