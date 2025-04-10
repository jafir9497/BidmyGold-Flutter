import 'package:get/get.dart';
import '../controllers/kyc_verification_controller.dart';

class KycVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KycVerificationController>(
      () => KycVerificationController(),
    );
  }
}
