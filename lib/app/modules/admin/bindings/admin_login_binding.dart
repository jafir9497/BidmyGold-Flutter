import 'package:get/get.dart';
import '../controllers/admin_login_controller.dart';
import '../utils/admin_auth_service.dart';

class AdminLoginBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize the admin auth service
    Get.put<AdminAuthService>(AdminAuthService(), permanent: true).init();

    // Register the admin login controller
    Get.lazyPut<AdminLoginController>(() => AdminLoginController());
  }
}
