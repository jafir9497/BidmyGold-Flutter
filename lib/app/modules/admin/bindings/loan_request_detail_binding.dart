import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/admin/controllers/loan_monitoring_controller.dart';

// Binding for the detailed loan request view
class LoanRequestDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Re-use LoanMonitoringController for now, or create a dedicated detail controller
    // Get.lazyPut<LoanRequestDetailController>(() => LoanRequestDetailController());

    // Ensure LoanMonitoringController is available if needed
    Get.find<LoanMonitoringController>();
  }
}
