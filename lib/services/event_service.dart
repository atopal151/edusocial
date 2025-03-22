// 2. event_services.dart
import '../models/event_model.dart';

class EventServices {
  Future<List<EventModel>> fetchEvents() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      EventModel(
        title: "Kariyer Günleri",
        description: "Uşak Üniversitesi Kariyer Merkezinde buluşalım!",
        date: "23 Mart 2025",
        image: "https://images.pexels.com/photos/1181263/pexels-photo-1181263.jpeg",
      ),
      EventModel(
        title: "TeknoFest Hazırlık Atölyesi",
        description: "TeknoFest'e hazırlık yapanlar için buluşma.",
        date: "25 Mart 2025",
        image: "https://images.pexels.com/photos/3184394/pexels-photo-3184394.jpeg",
      ),
    ];
  }
}
