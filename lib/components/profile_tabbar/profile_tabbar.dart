import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileTabBar extends StatefulWidget {
  final TabController tabController;

  const ProfileTabBar({super.key, required this.tabController});

  @override
  State<ProfileTabBar> createState() => _ProfileTabBarState();
}

class _ProfileTabBarState extends State<ProfileTabBar> {

    @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      if (mounted) setState(() {}); // rebuild et
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        tabAlignment: TabAlignment.center,
        controller: widget.tabController,
        isScrollable: true,
        indicatorColor: Color(0xffef5050),
        dividerColor: Colors.transparent,
        labelColor: Color(0xffef5050),
        unselectedLabelColor: Colors.grey,

        labelPadding: EdgeInsets.symmetric(horizontal: 30), // 🔧 Aralığı azalt
        tabs: [
          Tab(
            icon: SvgPicture.asset(
              "images/icons/grid_tab_icon.svg",
              colorFilter: ColorFilter.mode(
                widget.tabController.index == 0 ? Color(0xffef5050) : Colors.grey,
                BlendMode.srcIn,
              ),
              width: 20,
              height: 20,
            ),
          ),
          Tab(
            icon: SvgPicture.asset(
              "images/icons/profile_tab_icon.svg",
              colorFilter: ColorFilter.mode(
                widget.tabController.index == 1 ? Color(0xffef5050) : Colors.grey,
                BlendMode.srcIn,
              ),
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }
}
