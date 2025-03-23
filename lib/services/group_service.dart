// group_services.dart
import 'package:edusocial/models/grup_suggestion_model.dart';

import '../models/group_model.dart';

class GroupServices {
  // group_services.dart

  Future<List<GroupSuggestionModel>> fetchSuggestionGroups() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      GroupSuggestionModel(
        groupName: "Yapay Zeka Topluluğu",
        groupImage:
            "https://images.pexels.com/photos/1181357/pexels-photo-1181357.jpeg",
        groupAvatar:
            "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg",
        memberCount: 120,
        description: "Yapay zeka ve makine öğrenimi konularına ilgi duyanların bir araya geldiği aktif bir topluluk."
      ), 

      GroupSuggestionModel(
        groupName: "Felsefe Kulübü",
        groupImage:
            "https://images.pexels.com/photos/17485645/pexels-photo-17485645.jpeg",
        groupAvatar:
            "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg",
        memberCount: 88,
        description: "Antik çağdan günümüze felsefi akımları tartışan ve düşünce üretimini teşvik eden bir kulüp."
      ), 
      GroupSuggestionModel(
        groupName: "Mobil Geliştiriciler",
        groupImage:
            "https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg",
        groupAvatar:
            "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
        memberCount: 230,
        description: "Flutter, React Native ve Android üzerine çalışan geliştiriciler için bilgi paylaşım grubu."
      ), 

      GroupSuggestionModel(
        groupName: "Edebiyat Sevenler",
        groupImage:
            "https://images.pexels.com/photos/46274/pexels-photo-46274.jpeg",
        groupAvatar:
            "https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg",
        memberCount: 145,
        description: "Roman, şiir ve kısa hikayeler üzerine kitap önerileri ve tartışmalar için oluşturulmuş bir grup."
      ), 

      GroupSuggestionModel(
        groupName: "Girişimcilik Atölyesi",
        groupImage:
            "https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg",
        groupAvatar:
            "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
        memberCount: 198,
        description: "Roman, şiir ve kısa hikayeler üzerine kitap önerileri ve tartışmalar için oluşturulmuş bir grup."
      ),
    ];
  }

  Future<List<GroupModel>> fetchUserGroups() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      GroupModel(
        id: "1",
        name: "Kimya Kulübü",
        description: "Kimya severlerin bir araya geldiği grup.",
        imageUrl:
            "https://images.pexels.com/photos/2280549/pexels-photo-2280549.jpeg",
        memberCount: 564,
        category: "Kimya",
        isJoined: true,
      ),
      GroupModel(
        id: "2",
        name: "Fizikçiler Platformu",
        description: "Fizik üzerine tartışmalar.",
        imageUrl:
            "https://images.pexels.com/photos/256369/pexels-photo-256369.jpeg",
        memberCount: 443,
        category: "Fizik",
        isJoined: true,
      ),
      GroupModel(
        id: "1",
        name: "Edebiyat Kulübü",
        description: "Edebiyat severlerin bir araya geldiği grup.",
        imageUrl:
            "https://images.pexels.com/photos/2280549/pexels-photo-2280549.jpeg",
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
            "https://images.pexels.com/photos/2280549/pexels-photo-2280549.jpeg",
        memberCount: 35,
        category: "Kimya",
        isJoined: true,
      ),
      GroupModel(
        id: "3",
        name: "Teknoloji Dünyası",
        description: "Yeni teknolojiler ve haberler.",
        imageUrl:
            "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg",
        memberCount: 55,
        category: "Teknoloji",
        isJoined: false,
      ),
      GroupModel(
        id: "4",
        name: "Eğitimde Yenilik",
        description: "Eğitim teknolojileri üzerine.",
        imageUrl:
            "https://images.pexels.com/photos/4145190/pexels-photo-4145190.jpeg",
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
            "https://images.pexels.com/photos/4145190/pexels-photo-4145190.jpeg",
        memberCount: 410,
        category: "Eğitim",
        isJoined: false,
      ),
    ];
  }
}
