import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/home/controllers/anonymous_home_controller.dart';

class AnonymousHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnonymousHomeController>(
      () => AnonymousHomeController(),
    );
  }
}
