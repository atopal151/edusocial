// group_services.dart
import 'dart:convert';

import 'package:edusocial/models/grup_suggestion_model.dart';
import 'package:edusocial/utils/constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../models/group_model.dart';

class GroupServices {
  // group_services.dart


  Future<List<GroupSuggestionModel>> fetchSuggestionGroups() async {
    final box = GetStorage();
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}/timeline/groups"),
        headers: {
          'Authorization': 'Bearer ${box.read('token')}',
        },
      );
      print("📥 Group Suggestion Response: ${response.statusCode}");
      print("📥 Group Suggestion Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        return data.map((item) => GroupSuggestionModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("❗ Group Suggestion error: $e");
      return [];
    }
    /*
    await Future.delayed(Duration(seconds: 1));
    return [
      GroupSuggestionModel(
        groupName: "Yapay Zeka Topluluğu",
        groupImage:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        groupAvatar:
            "https://images.pexels.com/photos/30895959/pexels-photo-30895959/free-photo-of-belo-horizonte-de-kapali-alanda-elma-isiran-kadin.jpeg?auto=compress&cs=tinysrgb&w=400&lazy=load",
        memberCount: 120,
        description: "Yapay zeka ve makine öğrenimi konularına ilgi duyanların bir araya geldiği aktif bir topluluk."
      ), 

      GroupSuggestionModel(
        groupName: "Felsefe Kulübü",
        groupImage:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        groupAvatar:
            "https://images.pexels.com/photos/30895959/pexels-photo-30895959/free-photo-of-belo-horizonte-de-kapali-alanda-elma-isiran-kadin.jpeg?auto=compress&cs=tinysrgb&w=400&lazy=load",
        memberCount: 88,
        description: "Antik çağdan günümüze felsefi akımları tartışan ve düşünce üretimini teşvik eden bir kulüp."
      ), 
      GroupSuggestionModel(
        groupName: "Mobil Geliştiriciler",
        groupImage:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        groupAvatar:
            "https://images.pexels.com/photos/30895959/pexels-photo-30895959/free-photo-of-belo-horizonte-de-kapali-alanda-elma-isiran-kadin.jpeg?auto=compress&cs=tinysrgb&w=400&lazy=load",
        memberCount: 230,
        description: "Flutter, React Native ve Android üzerine çalışan geliştiriciler için bilgi paylaşım grubu."
      ), 

      GroupSuggestionModel(
        groupName: "Edebiyat Sevenler",
        groupImage:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
       groupAvatar:
            "https://images.pexels.com/photos/30895959/pexels-photo-30895959/free-photo-of-belo-horizonte-de-kapali-alanda-elma-isiran-kadin.jpeg?auto=compress&cs=tinysrgb&w=400&lazy=load",
        memberCount: 145,
        description: "Roman, şiir ve kısa hikayeler üzerine kitap önerileri ve tartışmalar için oluşturulmuş bir grup."
      ), 

      GroupSuggestionModel(
        groupName: "Girişimcilik Atölyesi",
        groupImage:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        groupAvatar:
            "https://images.pexels.com/photos/30895959/pexels-photo-30895959/free-photo-of-belo-horizonte-de-kapali-alanda-elma-isiran-kadin.jpeg?auto=compress&cs=tinysrgb&w=400&lazy=load",
         memberCount: 198,
        description: "Roman, şiir ve kısa hikayeler üzerine kitap önerileri ve tartışmalar için oluşturulmuş bir grup."
      ),
    ];*/
  }

  Future<List<GroupModel>> fetchUserGroups() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      GroupModel(
        id: "1",
        name: "Kimya Kulübü",
        description: "Kimya severlerin bir araya geldiği grup.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 564,
        category: "Kimya",
        isJoined: true,
      ),
      GroupModel(
        id: "2",
        name: "Fizikçiler Platformu",
        description: "Fizik üzerine tartışmalar.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 443,
        category: "Fizik",
        isJoined: true,
      ),
      GroupModel(
        id: "1",
        name: "Edebiyat Kulübü",
        description: "Edebiyat severlerin bir araya geldiği grup.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 776,
        category: "Eğitim",
        isJoined: true,
      ),
    ];
  }

  Future<List<GroupModel>> fetchAllGroups() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      GroupModel(
        id: "1",
        name: "Kimya Kulübü",
        description: "Kimya severlerin bir araya geldiği grup.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 35,
        category: "Kimya",
        isJoined: true,
      ),
      GroupModel(
        id: "3",
        name: "Teknoloji Dünyası",
        description: "Yeni teknolojiler ve haberler.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 55,
        category: "Teknoloji",
        isJoined: false,
      ),
      GroupModel(
        id: "4",
        name: "Eğitimde Yenilik",
        description: "Eğitim teknolojileri üzerine.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 23,
        category: "Eğitim",
        isJoined: false,
      ),
      GroupModel(
        id: "3",
        name: "Teknoloji Dünyası",
        description: "Yeni teknolojiler ve haberler.",
        imageUrl:
            "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg",
        memberCount: 800,
        category: "Teknoloji",
        isJoined: false,
      ),
      GroupModel(
        id: "4",
        name: "Eğitimde Yenilik",
        description: "Eğitim teknolojileri üzerine.",
        imageUrl:
            "https://images.pexels.com/photos/4145190/pexels-photo-4145190.jpeg",
        memberCount: 440,
        category: "Eğitim",
        isJoined: false,
      ),
      GroupModel(
        id: "3",
        name: "Teknoloji Dünyası",
        description: "Yeni teknolojiler ve haberler.",
        imageUrl:
            "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg",
        memberCount: 657,
        category: "Teknoloji",
        isJoined: false,
      ),
      GroupModel(
        id: "4",
        name: "Eğitimde Yenilik",
        description: "Eğitim teknolojileri üzerine.",
        imageUrl:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        memberCount: 410,
        category: "Eğitim",
        isJoined: false,
      ),
    ];
  }
}
