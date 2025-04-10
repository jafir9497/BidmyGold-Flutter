import 'package:get/get.dart';
import '../controllers/pawnbroker_place_bid_controller.dart';

class PawnbrokerPlaceBidBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PawnbrokerPlaceBidController>(
      () => PawnbrokerPlaceBidController(),
    );
  }
}
