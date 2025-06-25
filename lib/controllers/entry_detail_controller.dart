import 'package:get/get.dart';
import '../../models/entry_model.dart';
import '../../services/entry_services.dart';
import '../../models/topic_model.dart';
import 'package:flutter/foundation.dart';

class EntryDetailController extends GetxController {
  // Detay sayfasında gösterilecek topic
  var currentTopic = Rxn<TopicModel>();

  // Entry'ye yapılan yorumları tutan liste
  var entryComments = <EntryModel>[].obs;

  // Topic belirleme (detay sayfasına giderken atanır)
  void setCurrentTopic(TopicModel? topic) {
    currentTopic.value = topic;
  }

  Future<void> fetchEntryComments() async {
    debugPrint("🔄 EntryDetailController: Yorumlar çekiliyor...");
    if (currentTopic.value?.id != null) {
      final response = await EntryServices.fetchEntriesByTopicId(currentTopic.value!.id);
      debugPrint("📥 EntryDetailController: fetchEntriesByTopicId yanıtı: ${response?.topic.name} - entries count: ${response?.entries.length}");
      if (response != null && response.entries.isNotEmpty) {
        // İlk entry ana entry, geri kalanlar yorumlar
        final comments = response.entries.skip(1).toList();
        
        // Debug: Sıralama öncesi yorumları yazdır
        debugPrint("📝 Sıralama öncesi yorumlar:");
        for (int i = 0; i < comments.length; i++) {
          final comment = comments[i];
          debugPrint("  [$i] ID: ${comment.id}, Created: ${comment.createdat}, Upvotes: ${comment.upvotescount}, Content: ${comment.content.substring(0, comment.content.length > 20 ? 20 : comment.content.length)}...");
        }
        
        // Yorumları tarihe göre sırala (en yeni en üstte)
        comments.sort((a, b) {
          final dateA = a.createdat;
          final dateB = b.createdat;
          
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1; // null değerler sona
          if (dateB == null) return -1;
          
          return dateB.compareTo(dateA); // En yeni en üstte
        });
        
        // Debug: Sıralama sonrası yorumları yazdır
        debugPrint("📝 Sıralama sonrası yorumlar:");
        for (int i = 0; i < comments.length; i++) {
          final comment = comments[i];
          debugPrint("  [$i] ID: ${comment.id}, Created: ${comment.createdat}, Upvotes: ${comment.upvotescount}, Content: ${comment.content.substring(0, comment.content.length > 20 ? 20 : comment.content.length)}...");
        }
        
        entryComments.value = comments;
        debugPrint("✅ EntryDetailController: Yorumlar tarihe göre sıralandı, yeni yorum sayısı: ${entryComments.length}");
      } else {
        debugPrint("⚠️ EntryDetailController: Yorum bulunamadı veya yanıt boş.");
        entryComments.clear(); // Eğer yorum yoksa listeyi temizle
      }
    } else {
      debugPrint("❌ EntryDetailController: currentTopic ID null, yorumlar çekilemedi.");
      entryComments.clear();
    }
  }

  // Yorum oy durumunu güncelle (yeniden yüklemeden)
  Future<void> updateCommentVoteState(int entryId, String vote) async {
    debugPrint("🔄 Yorum oy durumu güncelleniyor: Entry ID $entryId, Vote: $vote");
    
    final commentIndex = entryComments.indexWhere((comment) => comment.id == entryId);
    if (commentIndex == -1) {
      debugPrint("❌ Güncellenecek yorum bulunamadı: $entryId");
      return;
    }
    
    final currentComment = entryComments[commentIndex];
      int newUpvotes = currentComment.upvotescount;
    int newDownvotes = currentComment.downvotescount;
    bool? newIsLike = currentComment.islike;
    bool? newIsDislike = currentComment.isdislike;

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

    final updatedComment = currentComment.copyWith(
      upvotescount: newUpvotes,
      downvotescount: newDownvotes,
      islike: newIsLike,
      isdislike: newIsDislike,
    );

    entryComments[commentIndex] = updatedComment;
    debugPrint("✅ Yorum oy durumu güncellendi: Upvotes: $newUpvotes, Downvotes: $newDownvotes, IsLike: $newIsLike, IsDislike: $newIsDislike");
  }


  @override
  void onClose() {
    // debugPrint("⚠️ EntryDetailController onClose: entryComments listesi temizleniyor.");
    // entryComments.clear(); // Temizleme işlemi artık widget'ın dispose metodunda yapılacak
    super.onClose();
  }
}
