import 'package:get/get.dart';
import '../controllers/pawnbroker_qr_scanner_controller.dart';

class PawnbrokerQrScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PawnbrokerQrScannerController>(
      () => PawnbrokerQrScannerController(),
    );
  }
}
