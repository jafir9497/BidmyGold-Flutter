import 'package:get/get.dart';
import '../controllers/user_qr_controller.dart';

class UserQrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserQrController>(
      () => UserQrController(),
    );
  }
}
