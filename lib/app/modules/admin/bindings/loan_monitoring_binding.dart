import 'package:get/get.dart';
import '../controllers/loan_monitoring_controller.dart';

class LoanMonitoringBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoanMonitoringController>(
      () => LoanMonitoringController(),
    );
  }
}
