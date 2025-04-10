import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/appointment/controllers/appointment_details_controller.dart';

class AppointmentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppointmentDetailsController>(
      () => AppointmentDetailsController(),
    );
  }
}
