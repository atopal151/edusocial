import 'package:edusocial/models/topic_model.dart';
import 'package:edusocial/services/entry_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/entry_model.dart';
import '../models/user_model.dart';
import 'package:edusocial/controllers/profile_controller.dart'; // Import ProfileController
import 'package:edusocial/models/profile_model.dart'; // Import ProfileModel
import 'package:edusocial/controllers/entry_detail_controller.dart'; 
import 'package:edusocial/models/display_entry_item.dart'; //

class EntryController extends GetxController {
  var entryList = <EntryModel>[].obs;
  var entryPersonList = <EntryModel>[].obs;
  final RxList<EntryModel> filteredByCategoryList = <EntryModel>[].obs;
  final RxList<EntryModel> filteredEntries = <EntryModel>[].obs;
  var currentTopic = Rxn<TopicModel>();

  var isEntryLoading = false.obs;
  final TextEditingController titleEntryController = TextEditingController();
  final TextEditingController bodyEntryController = TextEditingController();
  final RxString topicName = ''.obs;
  final TextEditingController entrySearchController = TextEditingController();

  var allTopics = <TopicModel>[].obs; // Tüm tartışma konuları (Eski, artık tam kullanılmayacak)
  var user = Rxn<UserModel>(); // Current user for EntryController

  // Yeni eklenenler: Ana ekran için merkezi entry listeleri
  final RxList<DisplayEntryItem> allDisplayEntries = <DisplayEntryItem>[].obs;
  final RxList<DisplayEntryItem> displayEntries = <DisplayEntryItem>[].obs; // Filtered list for UI

  final EntryServices entryServices = EntryServices();

  @override
  void onInit() {
    super.onInit();
    // fetchAllTopics(); // Artık fetchAndPrepareEntries() çağrılacak

    // ProfileController'dan kullanıcı bilgisini al ve EntryController.user'a ata
    final ProfileController profileController = Get.find<ProfileController>();
    ever(profileController.profile, (ProfileModel? profileModel) {
      if (profileModel != null) {
        user.value = profileModel.toUserModel();
      }
    });
  }

  // Tüm kategorileri çek, ilk entry'lerini al ve DisplayEntryItem olarak hazırla
  Future<void> fetchAndPrepareEntries() async {
    try {
      isEntryLoading.value = true;
      final fetchedCategories = await entryServices.fetchTopicCategories();
      
      final List<DisplayEntryItem> preparedEntries = [];
      for (var category in fetchedCategories) {
        if (category.first_entry != null) {
          preparedEntries.add(
            DisplayEntryItem(
              entry: category.first_entry!.copyWith(
                topic: (category.topics?.isNotEmpty == true && category.topics?.first != null)
                    ? category.topics!.first.copyWith(category: category) // Topic'e kategori bilgisini enjekte et
                    : null,
              ),
              topicName: category.topics?.isNotEmpty == true ? category.topics?.first.name : null,
              categoryTitle: category.title,
            ),
          );
        }
      }
      allDisplayEntries.assignAll(preparedEntries);
      displayEntries.assignAll(preparedEntries); // Initially, display all entries
    } catch (e) {
      debugPrint("⚠️ EntryController'da entry'ler hazırlanırken hata: $e");
    } finally {
      isEntryLoading.value = false;
    }
  }

  // Tüm tartışma konularını getir (Eski, artık sadece topic-categories için kullanılacak)
  Future<void> fetchAllTopics() async {
    try {
      // isEntryLoading.value = true; // Yükleme durumu fetchAndPrepareEntries içinde yönetiliyor
      final response = await entryServices.fetchAllTopics(); // Bu metot hala var ama kullanımı değişebilir
      allTopics.assignAll(response);
    } catch (e) {
      debugPrint("⚠️ Error in fetchAllTopics: $e");
    } finally {
      // isEntryLoading.value = false; // Yükleme durumu fetchAndPrepareEntries içinde yönetiliyor
    }
  }

  /// 📤 Entry oluştur (Yeni Konu ile birlikte)
  void shareEntryPost({required String topicName, required String content, required int topicCategoryId}) async {
    debugPrint("📝 Konu oluşturma başlatıldı:");
    debugPrint("📌 Konu Başlığı: $topicName");
    debugPrint("📌 İçerik: $content");
    debugPrint("📌 Kategori ID: $topicCategoryId");

    if (topicName.isEmpty || content.isEmpty || topicCategoryId == 0) {
      debugPrint("⚠️ Eksik bilgi tespit edildi!");
      Get.snackbar("Eksik Bilgi", "Lütfen tüm alanları doldurun");
      return;
    }

    isEntryLoading.value = true;
    debugPrint("🔄 API çağrısı yapılıyor...");

    final success = await EntryServices.createTopicWithEntry(
      name: topicName,
      content: content,
      topicCategoryId: topicCategoryId,
    );

    isEntryLoading.value = false;
    debugPrint("✅ API yanıtı alındı. Başarılı: $success");

    if (success) {
      debugPrint("🎉 Konu başarıyla oluşturuldu!");
      Get.back();
      Get.snackbar("Başarılı", "Konu başarıyla oluşturuldu");
      titleEntryController.clear();
      bodyEntryController.clear();
      debugPrint("🔄 Entry listesi yenileniyor...");
      await fetchAndPrepareEntries();
      debugPrint("✅ Entry listesi güncellendi");
    } else {
      debugPrint("❌ Konu oluşturma başarısız!");
      Get.snackbar("Hata", "Konu oluşturulamadı");
    }
  }

  void shareEntry() {
    Get.toNamed("/entryShare");
  }

  // Vote Entry
  Future<void> voteEntry(int entryId, String vote) async {
    final success = await EntryServices.voteEntry(
      vote: vote,
      entryId: entryId,
    );

    if (success) {
      // Ana ekrandaki ilgili entry'nin oy sayılarını ve is_like/is_dislike durumunu güncelle
      final indexInAll = allDisplayEntries.indexWhere((item) => item.entry.id == entryId);
      if (indexInAll != -1) {
        final currentEntry = allDisplayEntries[indexInAll].entry;
        int newUpvotes = currentEntry.upvotes_count;
        int newDownvotes = currentEntry.downvotes_count;
        bool? newIsLike = currentEntry.is_like;
        bool? newIsDislike = currentEntry.is_dislike;

        if (vote == "up") {
          if (newIsLike == true) {
            // Already liked, unlike it
            newUpvotes--;
            newIsLike = false;
          } else {
            // Like it
            newUpvotes++;
            newIsLike = true;
            if (newIsDislike == true) {
              newDownvotes--;
              newIsDislike = false;
            }
          }
        } else if (vote == "down") {
          if (newIsDislike == true) {
            // Already disliked, undislike it
            newDownvotes--;
            newIsDislike = false;
          } else {
            // Dislike it
            newDownvotes++;
            newIsDislike = true;
            if (newIsLike == true) {
              newUpvotes--;
              newIsLike = false;
            }
          }
        }

        final updatedEntry = currentEntry.copyWith(
          upvotes_count: newUpvotes,
          downvotes_count: newDownvotes,
          is_like: newIsLike,
          is_dislike: newIsDislike,
        );

        allDisplayEntries[indexInAll] = allDisplayEntries[indexInAll].copyWith(
          entry: updatedEntry,
        ); 

        // Filtered listeyi de güncelle (bu, UI'ı otomatik olarak tetikleyecektir)
        applySearchFilterToDisplayList();
      }

      // Eğer detay ekranı açıksa, yorumları güncelle
      if (Get.isRegistered<EntryDetailController>()) {
        final entryDetailController = Get.find<EntryDetailController>();
        if (entryDetailController.currentTopic.value?.id != null) {
          debugPrint("🔄 EntryController: Detay ekranı açık, yorumlar güncelleniyor...");
          entryDetailController.fetchEntryComments();
        }
      }
      Get.snackbar("Başarılı", "Oylama işlemi başarılı oldu");
    } else {
      Get.snackbar("Hata", "Oylama işlemi başarısız oldu");
    }
  }

  // Send Entry To Topic
  Future<void> sendEntryToTopic(int topicId, String content) async {
    final success = await EntryServices.sendEntryToTopic(
      topicId: topicId,
      content: content,
    );

    if (success) {
      // Başarılı entry gönderimi sonrası listeyi güncelle (detay ekranından geliyorsa)
      // EntryDetailScreen'deki fetchEntryComments'i tetiklemeliyiz.
      // Ana ekrandaki listeyi de güncelleyebiliriz, eğer gönderilen entry bir first_entry ise
      // Şimdilik sadece detay ekranı güncelleniyor.
      Get.back();
      Get.snackbar("Başarılı", "Entry başarıyla gönderildi");
    } else {
      Get.snackbar("Hata", "Entry gönderilemedi");
    }
  }

  // Arama filtresini displayEntries listesine uygular
  void applySearchFilterToDisplayList() {
    final query = entrySearchController.text.toLowerCase();
    if (query.isEmpty) {
      displayEntries.assignAll(allDisplayEntries);
    } else {
      displayEntries.assignAll(
        allDisplayEntries.where((item) {
          return item.entry.content.toLowerCase().contains(query) ||
              (item.topicName?.toLowerCase().contains(query) ?? false) ||
              (item.categoryTitle?.toLowerCase().contains(query) ?? false);
        }).toList(),
      );
    }
  }

  // Fetch Topic Categories With Topics (Bu metod artık fetchAndPrepareEntries ile entegre edilebilir)
  Future<void> fetchTopicCategoriesWithTopics() async {
    // Bu metod artık doğrudan kullanılmayacak, yerine fetchAllTopics veya fetchAndPrepareEntries kullanılacak.
    // Ancak, TopicModel içinde category bilgisi olduğu için bu veri yapısı hala geçerli.
  }

  Future<void> fetchTimelineEntries() async {
    try {
      final entries = await entryServices.fetchTimelineEntries();
      entryList.value = entries;
    } catch (e) {
      debugPrint('Error fetching timeline entries: $e'); // debugPrint kullanıldı
    }
  }

  Future<void> fetchAllEntries() async {
    try {
      print('🔄 Entry\'ler getiriliyor...');
      final entries = await EntryServices.fetchEntries();
      print('📦 Alınan entry sayısı: ${entries.length}');
      
      if (entries.isEmpty) {
        print('⚠️ Hiç entry bulunamadı!');
        entryPersonList.clear();
        return;
      }

      print('📝 Entry\'ler işleniyor...');
      entryPersonList.value = entries;
      print('✅ Entry\'ler başarıyla yüklendi. Toplam: ${entryPersonList.length}');
      
      // Entry'lerin içeriğini kontrol et
      entryPersonList.forEach((entry) {
        print('📌 Entry ID: ${entry.id}');
        print('📌 İçerik: ${entry.content}');
        print('📌 Kullanıcı: ${entry.user.name}');
        print('📌 Topic: ${entry.topic?.name}');
        print('-------------------');
      });
    } catch (e, stackTrace) {
      print('❌ Entry\'ler yüklenirken hata oluştu: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
