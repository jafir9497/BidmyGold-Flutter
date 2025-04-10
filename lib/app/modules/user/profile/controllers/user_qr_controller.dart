import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/services/qr_service.dart';

class UserQrController extends GetxController {
  final QrService _qrService = Get.find<QrService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables
  final RxBool isLoading = true.obs;
  final RxBool canGenerateQr = false.obs;
  final RxString qrData = ''.obs;
  final RxString userName = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString kycStatus = 'pending'.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      // Get user data from Firestore
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        errorMessage.value = 'User data not found';
        return;
      }

      final userData = userDoc.data()!;
      userName.value = userData['name'] ?? '';
      userPhone.value = currentUser.phoneNumber ?? '';
      kycStatus.value = userData['kycStatus'] ?? 'pending';

      // Check if user can generate QR (KYC verified)
      canGenerateQr.value = kycStatus.value == 'verified';

      // Generate QR data if KYC is verified
      if (canGenerateQr.value) {
        await generateQrCode();
      }
    } catch (e) {
      errorMessage.value = 'Error loading user data: $e';
      print(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateQrCode() async {
    try {
      errorMessage.value = '';
      isLoading.value = true;

      // Generate QR data
      final data = await _qrService.generateUserQrData();
      qrData.value = data;
    } catch (e) {
      errorMessage.value = 'Error generating QR code: $e';
      print(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to share QR code
  void shareQrCode() {
    // TODO: Implement sharing functionality
    Get.snackbar(
      'Share QR Code',
      'Sharing functionality will be implemented soon.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
