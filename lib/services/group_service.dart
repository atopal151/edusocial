

// group_services.dart
import '../models/group_model.dart';

class GroupServices {
  Future<List<GroupModel>> fetchUserGroups() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      GroupModel(
        id: "1",
        name: "Kimya Kulübü",
        description: "Kimya severlerin bir araya geldiği grup.",
        imageUrl: "https://images.pexels.com/photos/2280549/pexels-photo-2280549.jpeg",
        memberCount: 35,
        category: "Kimya",
        isJoined: true,
      ),
      GroupModel(
        id: "2",
        name: "Fizikçiler Platformu",
        description: "Fizik üzerine tartışmalar.",
        imageUrl: "https://images.pexels.com/photos/256369/pexels-photo-256369.jpeg",
        memberCount: 48,
        category: "Fizik",
        isJoined: true,
      ),GroupModel(
        id: "1",
        name: "Edebiyat Kulübü",
        description: "Edebiyat severlerin bir araya geldiği grup.",
        imageUrl: "https://images.pexels.com/photos/2280549/pexels-photo-2280549.jpeg",
        memberCount: 35,
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
        imageUrl: "https://images.pexels.com/photos/2280549/pexels-photo-2280549.jpeg",
        memberCount: 35,
        category: "Kimya",
        isJoined: true,
      ),
      GroupModel(
        id: "3",
        name: "Teknoloji Dünyası",
        description: "Yeni teknolojiler ve haberler.",
        imageUrl: "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg",
        memberCount: 67,
        category: "Teknoloji",
        isJoined: false,
      ),
      GroupModel(
        id: "4",
        name: "Eğitimde Yenilik",
        description: "Eğitim teknolojileri üzerine.",
        imageUrl: "https://images.pexels.com/photos/4145190/pexels-photo-4145190.jpeg",
        memberCount: 40,
        category: "Eğitim",
        isJoined: false,
      ), GroupModel(
        id: "3",
        name: "Teknoloji Dünyası",
        description: "Yeni teknolojiler ve haberler.",
        imageUrl: "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg",
        memberCount: 67,
        category: "Teknoloji",
        isJoined: false,
      ),
      GroupModel(
        id: "4",
        name: "Eğitimde Yenilik",
        description: "Eğitim teknolojileri üzerine.",
        imageUrl: "https://images.pexels.com/photos/4145190/pexels-photo-4145190.jpeg",
        memberCount: 40,
        category: "Eğitim",
        isJoined: false,
      ), GroupModel(
        id: "3",
        name: "Teknoloji Dünyası",
        description: "Yeni teknolojiler ve haberler.",
        imageUrl: "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg",
        memberCount: 67,
        category: "Teknoloji",
        isJoined: false,
      ),
      GroupModel(
        id: "4",
        name: "Eğitimde Yenilik",
        description: "Eğitim teknolojileri üzerine.",
        imageUrl: "https://images.pexels.com/photos/4145190/pexels-photo-4145190.jpeg",
        memberCount: 40,
        category: "Eğitim",
        isJoined: false,
      ),
    ];
  }
}

