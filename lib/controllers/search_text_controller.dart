import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/event_model.dart';
import '../models/group_model.dart';
import '../models/user_search_model.dart';

class SearchTextController extends GetxController {
  var searchTextController = TextEditingController();
  var searchQuery = "".obs;
  var selectedTab = 0.obs;
  var isSeLoading = false.obs;

  var allUsers = <UserSearchModel>[
    UserSearchModel(
        name: "Roger Carscraad",
        university: "Pamukkale Üniversitesi (PAÜ)",
        degree: "Lisans Derecesi",
        department: "Bilgisayar Mühendisliği",
        profileImage: "images/user2.png",
        isOnline: true),
    UserSearchModel(
        name: "Elena Smith",
        university: "Boğaziçi Üniversitesi",
        degree: "Yüksek Lisans",
        department: "Yapay Zeka",
        profileImage: "images/user1.png",
        isOnline: false),
  ].obs;

  var allGroups = <GroupSearchModel>[
    GroupSearchModel(
        name: "Murata Hayranlar Grubu",
        description:
            "Flutter geliştiricileri için özel grup.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        memberCount: 352,
        image: "images/user2.png"),
    GroupSearchModel(
        name: "Flutter Türkiye",
        description:
            "Flutter geliştiricileri için özel grup.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        memberCount: 120,
        image: "images/user1.png"),
  ].obs;

  var allEvents = <EventModel>[
    EventModel(
        title: "Lise Buluşması",
        date: "31 Ocak Cuma 16:33",
        description:
            "Lise buluşması için etkinlik yapıyoruz.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        image: "https://images.pexels.com/photos/3184394/pexels-photo-3184394.jpeg",location: "Denizli"),
        
    EventModel(
        title: "Teknoloji Zirvesi",
        date: "5 Nisan 2025 10:00",
        description:
            "Yapay zeka ve yazılım alanındaki son gelişmeler konuşulacak.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        image: "https://images.pexels.com/photos/3184394/pexels-photo-3184394.jpeg",location: "Denizli"),
  ].obs;

  var filteredUsers = <UserSearchModel>[].obs;
  var filteredGroups = <GroupSearchModel>[].obs;
  var filteredEvents = <EventModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    filterResults(""); // İlk yüklemede tüm verileri göster
  }


  void filterResults(String query) {
    searchQuery.value = query.toLowerCase();
    filteredUsers.value = allUsers
        .where((user) => user.name.toLowerCase().contains(searchQuery.value))
        .toList();

    filteredGroups.value = allGroups
        .where((group) =>
            group.name.toLowerCase().contains(searchQuery.value) ||
            group.description.toLowerCase().contains(searchQuery.value))
        .toList();

    filteredEvents.value = allEvents
        .where((event) =>
            event.title.toLowerCase().contains(searchQuery.value) ||
            event.description.toLowerCase().contains(searchQuery.value))
        .toList();
  }
}

