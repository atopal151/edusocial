import 'package:flutter/material.dart';

import '../../components/user_appbar/user_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserAppBar(),
      backgroundColor: Color(0xffFAFAFA),
      body: const Center(child: Text("Home"),),
    );
  }
}