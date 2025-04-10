import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/admin/controllers/user_management_controller.dart';

// Binding for the detailed user view, could potentially have its own controller later
class UserProfileDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Re-use UserManagementController for now, or create a dedicated one
    // Get.lazyPut<UserProfileDetailController>(() => UserProfileDetailController());

    // Ensure UserManagementController is available if needed to pass data
    Get.find<UserManagementController>();
  }
}
