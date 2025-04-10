import 'package:get/get.dart';
import '../controllers/system_settings_controller.dart';

class SystemSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SystemSettingsController>(
      () => SystemSettingsController(),
    );
  }
}
