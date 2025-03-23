import 'package:get/get.dart';
import '../models/hot_topics_model.dart';
import '../services/hot_topics_service.dart';

class TopicsController extends GetxController {
  var isLoading = false.obs;
  var hotTopics = <HotTopicsModel>[].obs;

  final HotTopicsService _service = HotTopicsService();

  @override
  void onInit() {
    super.onInit();
    fetchHotTopics();
  }

  void fetchHotTopics() async {
    isLoading.value = true;
    hotTopics.value = await _service.fetchHotTopics();
    isLoading.value = false;
  }
}
