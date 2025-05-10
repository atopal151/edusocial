import '../models/group_models/grup_suggestion_model.dart';
import '../models/profile_model.dart';

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
        GroupSuggestionModel(
            id: "1",
            groupName: "Murata Hayranlar Grubu",
            groupImage:
                "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
            groupAvatar:
                "https://images.pexels.com/photos/30895959/pexels-photo-30895959/free-photo-of-belo-horizonte-de-kapali-alanda-elma-isiran-kadin.jpeg?auto=compress&cs=tinysrgb&w=400&lazy=load",
            memberCount: 352,
            description:
                "Yapay zeka ve makine öğrenimi konularına ilgi duyanların bir araya geldiği aktif bir topluluk."),
        GroupSuggestionModel(
          id: "2",
            groupName: "Flutter Developers",
            groupImage:
                "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
            groupAvatar:
                "https://images.pexels.com/photos/30895959/pexels-photo-30895959/free-photo-of-belo-horizonte-de-kapali-alanda-elma-isiran-kadin.jpeg?auto=compress&cs=tinysrgb&w=400&lazy=load",
            memberCount: 874,
            description:
                "Yapay zeka ve makine öğrenimi konularına ilgi duyanların bir araya geldiği aktif bir topluluk."),
      ],
    );
  }
}
