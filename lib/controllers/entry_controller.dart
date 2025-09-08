import 'package:edusocial/models/topic_model.dart';
import 'package:edusocial/services/entry_services.dart';
import 'package:edusocial/services/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../models/entry_model.dart';
import '../models/user_model.dart';
import '../models/topic_category_model.dart';
import 'package:edusocial/controllers/profile_controller.dart'; // Import ProfileController
import 'package:edusocial/models/profile_model.dart'; // Import ProfileModel
import 'package:edusocial/controllers/entry_detail_controller.dart'; 
import 'package:edusocial/models/display_entry_item.dart'; //
import 'package:edusocial/controllers/people_profile_controller.dart'; // Import PeopleProfileController

class EntryController extends GetxController {
  final LanguageService languageService = Get.find<LanguageService>();
  var entryList = <EntryModel>[].obs;
  var entryPersonList = <EntryModel>[].obs;
  final RxList<EntryModel> filteredByCategoryList = <EntryModel>[].obs;
  final RxList<EntryModel> filteredEntries = <EntryModel>[].obs;
  var currentTopic = Rxn<TopicModel>();

  var isEntryLoading = false.obs;
  var isSendingEntry = false.obs; // Entry gönderme loading state'i
  final TextEditingController titleEntryController = TextEditingController();
  final TextEditingController bodyEntryController = TextEditingController();
  final RxString topicName = ''.obs;
  TextEditingController? _entrySearchController;
  
  TextEditingController get entrySearchController {
    _entrySearchController ??= TextEditingController();
    return _entrySearchController!;
  }

  var allTopics = <TopicModel>[].obs; // Tüm tartışma konuları (Eski, artık tam kullanılmayacak)
  var user = Rxn<UserModel>(); // Current user for EntryController

  // Yeni eklenenler: Ana ekran için merkezi entry listeleri
  final RxList<DisplayEntryItem> allDisplayEntries = <DisplayEntryItem>[].obs;
  final RxList<DisplayEntryItem> displayEntries = <DisplayEntryItem>[].obs; // Filtered list for UI

  // CATEGORY MANAGEMENT: Kategori yönetimi için yeni state'ler
  final RxList<TopicCategoryModel> categories = <TopicCategoryModel>[].obs;
  final RxString selectedCategory = 'all'.obs; // Varsayılan olarak "all" seçili (dil desteği için)
  final RxList<String> selectedCategories = <String>[].obs; // Çoklu kategori seçimi için
  final RxBool isCategoryLoading = false.obs;

  final EntryServices entryServices = EntryServices();

  @override
  void onInit() {
    super.onInit();
    
    fetchAndPrepareEntries();

    // ProfileController'dan kullanıcı bilgisini al ve EntryController.user'a ata
    if (Get.isRegistered<ProfileController>()) {
      final ProfileController profileController = Get.find<ProfileController>();
      ever(profileController.profile, (ProfileModel? profileModel) {
        if (profileModel != null) {
          user.value = profileModel.toUserModel();
        }
      });
    }
  }

  @override
  void onClose() {
    titleEntryController.dispose();
    bodyEntryController.dispose();
    
    // Controller'ı güvenli bir şekilde dispose et
    _entrySearchController?.dispose();
    _entrySearchController = null;
    
    super.onClose();
  }

  // Tüm kategorileri çek, ilk entry'lerini al ve DisplayEntryItem olarak hazırla
  Future<void> fetchAndPrepareEntries() async {
    try {
      isEntryLoading.value = true;
      final fetchedCategories = await entryServices.fetchTopicCategories();
      
      // CATEGORY MANAGEMENT: Kategorileri kaydet
      categories.assignAll(fetchedCategories);
      debugPrint('✅ ${fetchedCategories.length} kategori yüklendi');
      
      final List<DisplayEntryItem> preparedEntries = [];
      for (var category in fetchedCategories) {
        if (category.firstentry != null) {
          preparedEntries.add(
            DisplayEntryItem(
              entry: category.firstentry!.copyWith(
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
      
      // CATEGORY MANAGEMENT: Seçilen kategoriye göre filtrele
      applyCategoryFilter();
      
    } catch (e) {
      debugPrint("⚠️ EntryController'da entry'ler hazırlanırken hata: $e");
    } finally {
      isEntryLoading.value = false;
    }
  }

  /// CATEGORY MANAGEMENT: Kategori seçimi fonksiyonu (çoklu seçim destekli)
  void selectCategory(String categoryName) {
    // "All" seçilirse diğer tüm seçimleri temizle
    if (categoryName == 'all') {
      selectedCategories.clear();
      selectedCategory.value = 'all';
    } else {
      // "All" seçiliyse onu kaldır
      if (selectedCategory.value == 'all') {
        selectedCategory.value = '';
      }
      
      // Kategori zaten seçili mi kontrol et
      if (selectedCategories.contains(categoryName)) {
        // Seçiliyse kaldır
        selectedCategories.remove(categoryName);
        debugPrint('📂 Kategori kaldırıldı: $categoryName');
      } else {
        // Seçili değilse ekle
        selectedCategories.add(categoryName);
        debugPrint('📂 Kategori eklendi: $categoryName');
      }
      
      // Eğer hiç kategori seçili değilse "all" yap
      if (selectedCategories.isEmpty) {
        selectedCategory.value = 'all';
      } else {
        selectedCategory.value = selectedCategories.join(', ');
      }
    }
    
    applyCategoryFilter();
    debugPrint('📂 Seçili kategoriler: ${selectedCategories.join(', ')}');
  }

  /// CATEGORY MANAGEMENT: Seçilen kategoriye göre entry'leri filtrele (çoklu seçim destekli)
  void applyCategoryFilter() {
    if (selectedCategory.value == 'all' || selectedCategories.isEmpty) {
      // Tüm entry'leri göster
      displayEntries.assignAll(allDisplayEntries);
    } else {
      // Seçilen kategorilere ait entry'leri filtrele
      final filtered = allDisplayEntries.where((item) => 
        selectedCategories.contains(item.categoryTitle)
      ).toList();
      displayEntries.assignAll(filtered);
    }
    
    // Arama filtresini de uygula
    applySearchFilterToDisplayList();
    debugPrint('📊 Filtrelenmiş entry sayısı: ${displayEntries.length} (Kategoriler: ${selectedCategories.join(', ')})');
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
      Get.snackbar(languageService.tr("common.messages.missingInfo"), languageService.tr("common.messages.fillAllFields"));
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
      Get.snackbar(languageService.tr("common.success"), languageService.tr("entry.success.topicCreated"));
      titleEntryController.clear();
      bodyEntryController.clear();
      debugPrint("🔄 Entry listesi yenileniyor...");
      await fetchAndPrepareEntries();
      debugPrint("✅ Entry listesi güncellendi");
    } else {
      debugPrint("❌ Konu oluşturma başarısız!");
      Get.snackbar(languageService.tr("common.error"), languageService.tr("entry.errors.topicCreateFailed"));
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
        int newUpvotes = currentEntry.upvotescount;
        int newDownvotes = currentEntry.downvotescount;
        bool? newIsLike = currentEntry.islike;
        bool? newIsDislike = currentEntry.isdislike;

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
          upvotescount: newUpvotes,
          downvotescount: newDownvotes,
          islike: newIsLike,
          isdislike: newIsDislike,
        );

        allDisplayEntries[indexInAll] = allDisplayEntries[indexInAll].copyWith(
          entry: updatedEntry,
        ); 

        // Filtered listeyi de güncelle (bu, UI'ı otomatik olarak tetikleyecektir)
        applySearchFilterToDisplayList();
      }

      // People Profile Screen'deki entry'lerin oy durumunu güncelle
      if (Get.isRegistered<PeopleProfileController>()) {
        final peopleProfileController = Get.find<PeopleProfileController>();
        final indexInPeople = peopleProfileController.peopleEntries.indexWhere((entry) => entry.id == entryId);
        if (indexInPeople != -1) {
          final currentEntry = peopleProfileController.peopleEntries[indexInPeople];
          int newUpvotes = currentEntry.upvotescount;
          int newDownvotes = currentEntry.downvotescount;
          bool? newIsLike = currentEntry.islike;
          bool? newIsDislike = currentEntry.isdislike;

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
            upvotescount: newUpvotes,
            downvotescount: newDownvotes,
            islike: newIsLike,
            isdislike: newIsDislike,
          );

          peopleProfileController.peopleEntries[indexInPeople] = updatedEntry;
        }
      }

      // Detay ekranındaki yorumların oy durumunu güncelle (yeniden yüklemeden)
      if (Get.isRegistered<EntryDetailController>()) {
        final entryDetailController = Get.find<EntryDetailController>();
        if (entryDetailController.currentTopic.value?.id != null) {
          debugPrint("🔄 EntryController: Detay ekranındaki yorum oy durumu güncelleniyor...");
          await entryDetailController.updateCommentVoteState(entryId, vote);
        }
      }
    } else {
      Get.snackbar("Hata", "Oylama işlemi başarısız oldu");
    }
  }

  // Send Entry To Topic
  Future<void> sendEntryToTopic(int topicId, String content) async {
    isSendingEntry.value = true;
    
    try {
      final success = await EntryServices.sendEntryToTopic(
        topicId: topicId,
        content: content,
      );

      if (success) {
        // Başarılı entry gönderimi sonrası sadece yorumları güncelle
        if (Get.isRegistered<EntryDetailController>()) {
          final entryDetailController = Get.find<EntryDetailController>();
          if (entryDetailController.currentTopic.value?.id != null) {
            debugPrint("🔄 Yeni yorum eklendi, yorumlar güncelleniyor...");
            await entryDetailController.fetchEntryComments();
          }
        }
        // Back işlemi ve snackbar kaldırıldı
      } else {
        Get.snackbar("Hata", "Entry gönderilemedi");
      }
    } catch (e) {
      debugPrint("❌ Entry gönderme hatası: $e");
      Get.snackbar("Hata", "Entry gönderilemedi");
    } finally {
      isSendingEntry.value = false;
    }
  }

  // IMPROVED: Arama ve kategori filtresini birlikte uygular (çoklu seçim destekli)
  void applySearchFilterToDisplayList() {
    final query = _entrySearchController?.text.toLowerCase() ?? '';
    
    // Önce kategori filtresini uygula
    List<DisplayEntryItem> categoryFiltered;
    if (selectedCategory.value == 'all' || selectedCategories.isEmpty) {
      categoryFiltered = allDisplayEntries.toList();
    } else {
      categoryFiltered = allDisplayEntries.where((item) => 
        selectedCategories.contains(item.categoryTitle)
      ).toList();
    }
    
    // Sonra arama filtresini uygula
    if (query.isEmpty) {
      displayEntries.assignAll(categoryFiltered);
    } else {
      displayEntries.assignAll(
        categoryFiltered.where((item) {
          return item.entry.content.toLowerCase().contains(query) ||
              (item.topicName?.toLowerCase().contains(query) ?? false) ||
              (item.categoryTitle?.toLowerCase().contains(query) ?? false);
        }).toList(),
      );
    }
    
    debugPrint('🔍 Filter sonucu: ${displayEntries.length} entry (Kategoriler: ${selectedCategories.join(', ')}, Arama: "$query")');
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
      debugPrint('🔄 Entry\'ler getiriliyor...');
      final entries = await EntryServices.fetchEntries();
      debugPrint('📦 Alınan entry sayısı: ${entries.length}');
      
      if (entries.isEmpty) {
        debugPrint('⚠️ Hiç entry bulunamadı!');
        entryPersonList.clear();
        return;
      }

      debugPrint('📝 Entry\'ler işleniyor...');
      entryPersonList.value = entries;
      debugPrint('✅ Entry\'ler başarıyla yüklendi. Toplam: ${entryPersonList.length}');
      
      // Entry'lerin içeriğini kontrol et
      for (var entry in entryPersonList) {
        debugPrint('📌 Entry ID: ${entry.id}');
        debugPrint('📌 İçerik: ${entry.content}');
        debugPrint('📌 Kullanıcı: ${entry.user.name}');
        debugPrint('📌 Topic: ${entry.topic?.name}');
        debugPrint('-------------------');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Entry\'ler yüklenirken hata oluştu: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}
