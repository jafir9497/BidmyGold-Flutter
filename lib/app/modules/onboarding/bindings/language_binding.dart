import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/onboarding/controllers/language_controller.dart';

class LanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageController>(
      () => LanguageController(),
    );
  }
}
