import '../models/hot_topics_model.dart';

class HotTopicsService {
  Future<List<HotTopicsModel>> fetchHotTopics() async {
    await Future.delayed(Duration(seconds: 1)); // Simülasyon
    return [
      HotTopicsModel(title: "Arkadaşların seri bir şekilde evlenmesi"),
      HotTopicsModel(title: "Vizeden önce kampüste sabahlama planları"),
      HotTopicsModel(title: "KYK yemek menüsüne isyanlar"),
      HotTopicsModel(title: "Not ortalaması vs sosyal hayat"),
      HotTopicsModel(title: "LinkedIn'de staj paylaşımları"),
    ];
  }
}
