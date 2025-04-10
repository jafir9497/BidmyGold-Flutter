import 'package:get/get.dart';
import '../controllers/admin_management_controller.dart';

class AdminManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminManagementController>(
      () => AdminManagementController(),
    );
  }
}
