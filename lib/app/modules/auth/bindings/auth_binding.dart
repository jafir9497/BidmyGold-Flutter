import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Use fenix: true to recreate the controller if it's ever removed,
    // ensuring auth state listener is always active after initial login/logout.
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
