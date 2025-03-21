import '../models/user_model.dart';

class ProfileService {
  Future<ProfileModel> fetchProfileData() async {
    // Gerçek bir ağ isteği gibi bekleme süresi simüle edelim
    await Future.delayed(const Duration(seconds: 2));

    // Sabit mock veri döndür
    return ProfileModel(
      schoolLogo:
          "https://ui-avatars.com/api/?name=Monnet+International+School",
      schoolName: "Monnet International School",
      schoolDepartment: "Computer Engineering",
      schoolGrade: "Grade 2",
      birthDate: "08.01.1988",
      email: "student@email.com",
      courses: [
        "Veri Yapıları ve Algoritmalar",
        "Pazarlama Yönetimi",
        "Bilişsel Psikoloji",
        "Cebirsel Sayılar",
      ],
      joinedGroups: [
        GroupModel(
          groupName: "Murata Hayranlar Grubu",
          groupImage: "https://images.pexels.com/photos/3931501/pexels-photo-3931501.jpeg?auto=compress&cs=tinysrgb&h=200&w=400",
          groupAvatar: "https://i.pravatar.cc/150?img=5",
          memberCount: 352,
        ),
        GroupModel(
          groupName: "Flutter Developers",
          groupImage: "https://images.pexels.com/photos/6348129/pexels-photo-6348129.jpeg?auto=compress&cs=tinysrgb&h=200&w=400",
          groupAvatar: "https://i.pravatar.cc/150?img=8",
          memberCount: 874,
        ),
      ],
    );
  }
}
