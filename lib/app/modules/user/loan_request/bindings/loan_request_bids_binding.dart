import 'package:get/get.dart';
import '../controllers/loan_request_bids_controller.dart';

class LoanRequestBidsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoanRequestBidsController>(
      () => LoanRequestBidsController(),
    );
  }
}
