import 'package:get/get.dart';
import '../controllers/pawnbroker_verification_controller.dart';
import '../utils/admin_auth_service.dart';

class PawnbrokerVerificationBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AdminAuthService is available
    if (!Get.isRegistered<AdminAuthService>()) {
      Get.put<AdminAuthService>(AdminAuthService(), permanent: true);
    }

    Get.lazyPut<PawnbrokerVerificationController>(
      () => PawnbrokerVerificationController(),
    );
  }
}
