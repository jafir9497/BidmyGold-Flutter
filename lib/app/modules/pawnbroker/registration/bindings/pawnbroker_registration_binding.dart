import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/pawnbroker/registration/controllers/pawnbroker_registration_controller.dart';

class PawnbrokerRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PawnbrokerRegistrationController>(
      () => PawnbrokerRegistrationController(),
    );
  }
}
