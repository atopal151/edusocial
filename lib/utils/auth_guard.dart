import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../controllers/onboarding_controller.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final token = GetStorage().read('token');
    if (token == null) {
      return const RouteSettings(name: Routes.login);
    }
    
    // Token varsa async olarak kullanıcı bilgilerini kontrol et
    _checkUserOnboarding();
    
    return null; // Şimdilik devam et, async kontrolden sonra yönlendirme yapılacak
  }

  Future<void> _checkUserOnboarding() async {
    //debugPrint("🔍 AuthGuard: Kullanıcı onboarding durumu kontrol ediliyor...");
    
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    
    if (user == null) {
      debugPrint("❗ AuthGuard: Kullanıcı bilgisi alınamadı, login'e yönlendiriliyor");
      Get.offAllNamed(Routes.login);
      return;
    }
    
    final schoolId = user['school_id'];
    final departmentId = user['school_department_id'];
    
    //debugPrint("🔍 AuthGuard: school_id=$schoolId, department_id=$departmentId");
    
    if (schoolId == null || departmentId == null) {
      debugPrint("⚠️ AuthGuard: Onboarding tamamlanmamış, step1'e yönlendiriliyor");
      // OnboardingController'ı hazırla
      try {
        final onboardingController = Get.find<OnboardingController>();
        onboardingController.loadSchoolList();
      } catch (e) {
        // Controller henüz yüklenmemiş, manuel initialize et
        debugPrint("❗ OnboardingController bulunamadı, manuel initialize ediliyor: $e");
        Get.put(OnboardingController());
        final onboardingController = Get.find<OnboardingController>();
        onboardingController.loadSchoolList();
      }
      Get.offAllNamed(Routes.step1);
    } else {
      //debugPrint("✅ AuthGuard: Onboarding tamamlanmış, normal akış devam ediyor");
    }
  }
}
