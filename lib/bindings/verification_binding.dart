import 'package:get/get.dart';
import '../services/verification_service.dart';
import '../controllers/verification_controller.dart';

class VerificationBinding extends Bindings {
  @override
  void dependencies() {
    // Service'leri inject et
    Get.lazyPut<VerificationService>(() => VerificationService());
    
    // Controller'ları inject et
    Get.lazyPut<VerificationController>(() => VerificationController());
  }
}
