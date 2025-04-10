import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';
// Ensure auth service is available

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure AdminAuthService is initialized (if not already permanent)
    // Get.put<AdminAuthService>(AdminAuthService(), permanent: true).init();

    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
  }
}
