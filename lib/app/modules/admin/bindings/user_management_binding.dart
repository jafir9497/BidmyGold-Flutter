import 'package:get/get.dart';
import '../controllers/user_management_controller.dart';
import '../utils/admin_auth_service.dart';

class UserManagementBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AdminAuthService is available
    if (!Get.isRegistered<AdminAuthService>()) {
      Get.put<AdminAuthService>(AdminAuthService(), permanent: true);
    }

    Get.lazyPut<UserManagementController>(
      () => UserManagementController(),
    );
  }
}
