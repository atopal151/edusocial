
// 3. event_controller.dart
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventController extends GetxController {
  var isLoading = false.obs;
  var eventList = <EventModel>[].obs;

  final EventServices _eventServices = EventServices();

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  void fetchEvents() async {
    isLoading.value = true;
    eventList.value = await _eventServices.fetchEvents();
    isLoading.value = false;
  }

  void shareEvent(String title) {
    Get.snackbar("Paylaşıldı", "$title başarıyla paylaşıldı.");
  }

  void showLocation(String title) {
    Get.snackbar("Konum Gör", "$title için konum bilgisi görüntüleniyor.");
  }
}

