import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/onboarding/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );
  }
}
