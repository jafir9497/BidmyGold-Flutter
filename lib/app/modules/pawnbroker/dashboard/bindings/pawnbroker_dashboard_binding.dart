import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/pawnbroker/dashboard/controllers/pawnbroker_dashboard_controller.dart';

class PawnbrokerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PawnbrokerDashboardController>(
      () => PawnbrokerDashboardController(),
    );
  }
}
