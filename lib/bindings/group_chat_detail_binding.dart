import 'package:get/get.dart';
import '../controllers/chat_controllers/group_chat_detail_controller.dart';

class GroupChatDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupChatDetailController>(() => GroupChatDetailController());
  }
} 