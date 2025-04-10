import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/user/loan_request/controllers/loan_request_controller.dart';

class LoanRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoanRequestController>(
      () => LoanRequestController(),
    );
  }
}
