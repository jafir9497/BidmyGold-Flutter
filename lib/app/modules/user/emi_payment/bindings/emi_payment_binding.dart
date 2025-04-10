import 'package:get/get.dart';

import '../controllers/emi_payment_controller.dart';
// No need to explicitly find PaymentService here if it's globally available

class EmiPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmiPaymentController>(
      () => EmiPaymentController(),
    );
    // Ensure PaymentService is available globally before this binding is used
    // Get.put<PaymentService>(PaymentService(), permanent: true); // Example if needed
  }
}
