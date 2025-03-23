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
            "https://images.pexels.com/photos/1181357/pexels-photo-1181357.jpeg",
      ),
      EventModel(
        title: "Flutter Atölyesi",
        description: "Flutter ile mobil uygulama geliştirmeye giriş.",
        date: "30 Mart 2025",
        image:
            "https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg",
      ),
      EventModel(
        title: "Networking Buluşması",
        description: "Sektör profesyonelleriyle tanışma ve sohbet fırsatı.",
        date: "2 Nisan 2025",
        image:
            "https://images.pexels.com/photos/1181396/pexels-photo-1181396.jpeg",
      ),
      EventModel(
        title: "Hackathon 2025",
        description:
            "48 saat sürecek yazılım geliştirme yarışmasına hazır olun!",
        date: "5 Nisan 2025",
        image:
            "https://images.pexels.com/photos/3184328/pexels-photo-3184328.jpeg",
      ),
      EventModel(
        title: "Girişimcilik Paneli",
        description: "Girişimciler tecrübelerini paylaşıyor.",
        date: "7 Nisan 2025",
        image:
            "https://images.pexels.com/photos/3182763/pexels-photo-3182763.jpeg",
      ),
      EventModel(
        title: "Kadınlar Teknolojide",
        description: "Kadın yazılımcılarla ilham verici bir söyleşi.",
        date: "10 Nisan 2025",
        image:
            "https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg",
      ),
      EventModel(
        title: "Siber Güvenlik Semineri",
        description: "Bilgi güvenliği ve etik hackerlık konuları işlenecek.",
        date: "13 Nisan 2025",
        image:
            "https://images.pexels.com/photos/5380663/pexels-photo-5380663.jpeg",
      ),
      EventModel(
        title: "Veri Bilimi Günü",
        description: "Data science projeleri ve workshoplarla dolu bir gün.",
        date: "15 Nisan 2025",
        image:
            "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg",
      ),
      EventModel(
        title: "Kariyer Simülasyonu",
        description: "İş mülakatları ve CV hazırlama eğitimi.",
        date: "18 Nisan 2025",
        image:
            "https://images.pexels.com/photos/1181319/pexels-photo-1181319.jpeg",
      ),
      EventModel(
        title: "Yazılımda Yeni Trendler",
        description: "2025 yılında öne çıkan yazılım teknolojileri.",
        date: "20 Nisan 2025",
        image:
            "https://images.pexels.com/photos/3861959/pexels-photo-3861959.jpeg",
      ),
      EventModel(
        title: "Kariyer Günleri",
        description: "Uşak Üniversitesi Kariyer Merkezinde buluşalım!",
        date: "23 Mart 2025",
        image:
            "https://images.pexels.com/photos/1181263/pexels-photo-1181263.jpeg",
      ),
      EventModel(
        title: "TeknoFest Hazırlık Atölyesi",
        description: "TeknoFest'e hazırlık yapanlar için buluşma.",
        date: "25 Mart 2025",
        image:
            "https://images.pexels.com/photos/3184394/pexels-photo-3184394.jpeg",
      ),
    ];
  }
}
