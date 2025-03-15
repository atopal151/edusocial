
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/appbar_controller.dart';
//import 'package:flutter_svg/flutter_svg.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final AppBarController controller = Get.put(AppBarController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        surfaceTintColor: Color(0xffffffff),
        backgroundColor: Color(0xffffffff),
        /*leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffFAFAFA)
              ),
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: SvgPicture.asset(
                  'images/icons/back_icon.svg',
                ),
              ),
            ),
          ),
        ),*/
        actions: [
          InkWell(
            onTap: controller.navigateToProfile,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(color: Color(0xffFAFAFA),borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.settings,color: Color(0xff414751),),
                  )),
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xffffffff),
      body: const Center(
        child: Text("Profile"),
      ),
    );
  }
}
