// 2. event_services.dart
import '../models/event_model.dart';

class EventServices {
  Future<List<EventModel>> fetchEvents() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      EventModel(
        title: "Yapay Zeka Sohbetleri",
        description: "AI teknolojileri üzerine güncel gelişmeler konuşulacak.",
        date: "28 Mart 2025",
        image:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      ),
      EventModel(
        title: "Flutter Atölyesi",
        description: "Flutter ile mobil uygulama geliştirmeye giriş.",
        date: "30 Mart 2025",
        image:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      ),
      EventModel(
        title: "Networking Buluşması",
        description: "Sektör profesyonelleriyle tanışma ve sohbet fırsatı.",
        date: "2 Nisan 2025",
        image:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
     
      ),
      EventModel(
        title: "Hackathon 2025",
        description:
            "48 saat sürecek yazılım geliştirme yarışmasına hazır olun!",
        date: "5 Nisan 2025",
        image:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
     
      ),
      EventModel(
        title: "Girişimcilik Paneli",
        description: "Girişimciler tecrübelerini paylaşıyor.",
        date: "7 Nisan 2025",
        image:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
     
      ),
      EventModel(
        title: "Kadınlar Teknolojide",
        description: "Kadın yazılımcılarla ilham verici bir söyleşi.",
        date: "10 Nisan 2025",
        image:
            "https://images.pexels.com/photos/31361239/pexels-photo-31361239/free-photo-of-zarif-sarap-kadehi-icinde-taze-cilekler.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
     
      ),
    
    ];
  }
}
