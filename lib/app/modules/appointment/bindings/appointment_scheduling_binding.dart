import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/appointment/controllers/appointment_scheduling_controller.dart';

class AppointmentSchedulingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppointmentSchedulingController>(
      () => AppointmentSchedulingController(),
    );
  }
}
