import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/user/kyc/controllers/kyc_controller.dart';

class KycBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KycController>(
      () => KycController(),
    );
  }
}
