import 'package:get/get.dart';
import '../controllers/pawnbroker_loan_request_details_controller.dart';

class PawnbrokerLoanRequestDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PawnbrokerLoanRequestDetailsController>(
      () => PawnbrokerLoanRequestDetailsController(),
    );
  }
}
